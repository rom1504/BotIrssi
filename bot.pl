# # INIT
# # {
# #     while (my ($module, $path) = each %INC)
# #     {
# #         $module_times{ $module } = -M $path;
# #     }
# # }

my $basePath="/home/rom1504/.irssibot/scripts/autorun/botirssi/";

INIT
{
push(@INC,$basePath);
}
push(@INC,$basePath);
use Irssi;
use vars qw($VERSION %IRSSI);
use Encode;
# # my %module_times;
# # 
# # while (my ($module, $time) = each %module_times)
# # {
# # 	my $mod_time   = -M $INC{$module};
# # 	next if $time == $mod_time;
# # 
# # 	no warnings 'redefine';
# # 	require ( delete $INC{  $module } );
# # 	$module_times{ $module } = $mod_time;
# # }
# # require ( delete $INC{  "countdown.pm" } );
# # delete $INC{'countdown.pm'};
# 
# # réfléchir à faire des modules ( comme countdown ) plutôt que cet afreux fichier
# 
use countdown;
# use LWP::UserAgent;
# use URI::Escape;

open ( FILE, "<".$basePath."qr.txt" ) or die "can't open qr.txt\n";
chomp( @qr = <FILE> );
close FILE;

open ( FILE, "<".$basePath."score.txt" ) or die "can't open score.txt\n";
chomp( @sa = <FILE> );
close FILE;

open ( FILE, "<".$basePath."ODS5.txt" ) or die "can't open ODS5.txt\n";
chomp( @diko = <FILE> );
close FILE;

open ( FILE, "<".$basePath."fr.txt" ) or die "can't open fr.txt\n";
chomp( @diko2 = <FILE> );
close FILE;

open ( FILE, "<".$basePath."quote.txt" ) or die "can't open quote.txt\n";
chomp( @quote = <FILE> );
close FILE;


my $cc="\"";

sub reconnaitre
{
	my ($commande,$suite,$texte)=@_;
	my $regex=$cc.$commande.($suite eq "" ? "" : " ".$suite);
	return $texte =~ /^$regex$/;
}



delete $INC{"ia.pl"};
delete $INC{$basePath."ia.pl"};
require $basePath."ia.pl";


#23:49 < courgette> Ce qui serait cool ce serait de prendre une base de donnée et de générer des questions automatiquement à partir de cette bdd
#23:51 < courgette> ça rendrait impossible d'utiliser une méthode aussi stupide que celle utilisée par JY_ et mon bot ( parser les logs et avoir les réponses à tt les questions ) pour la 
#                   résolution automatique

# réfléchir à faire une classe, pour du vrai multi-chan

# multichan sauf les scores

foreach $elt (@sa)
{
	$elt =~ /^(.+):(.+)$/;
	my $pseudo=$1;
	my $score=$2;
	$s{$pseudo}=$score;
}

$taille=0;
foreach $elt (@qr)
{
	$elt =~ /^(.+)\|\|\|\.\.\.\|\|\|(.+)$/;
	my $question=$1;
	my $reponse=$2;
# 	$reponse =~ s/\s+$//;
# 	$reponse =~ s/^\s+//;
	$q{$question}=$reponse;
	$taille++;
}

sub unaccent
{
	my $ligne=shift;
	my @truc=("À","Á","Â","Ã","Ä","Å","Ç","È","É","Ê","Ë","Ì","Í","Î","Ï","Ñ","Ò","Ó","Ô","Õ","Ö","Ù","Ú","Û","Ü","Ý","à","á","â","ã","ä","å","ç","è","é","ê","ë","ì","í","î","ï","ñ","ò","ó","ô","õ","ö","ù","ú","û","ü","ý","ÿ");
	my @machin=("A","A","A","A","A","A","C","E","E","E","E","I","I","I","I","N","O","O","O","O","O","U","U","U","U","Y","a","a","a","a","a","a","c","e","e","e","e","i","i","i","i","n","o","o","o","o","o","u","u","u","u","y","y");
	for($i=0;$i<@truc;$i++)
	{
		@truc[$i]=decode("utf8",@truc[$i]);
		@machin[$i]=decode("utf8",@machin[$i]);
		$ligne =~ s/@truc[$i]/@machin[$i]/g;
	}
	return $ligne;
}

sub recherche
{
	my $mot=shift;
	my $e=shift;
	my $min=0;
	my $max=(scalar @diko2)-1;
	while(1)
	{
		$moy=int(($min+$max)/2);
		if($diko2[$moy] lt $mot)
		{
			$min=$moy;
			if($diko2[$max] eq $mot)
			{
				return $max;
			}
		}
		elsif($diko2[$moy] gt $mot)
		{
			$max=$moy;
		}
		else
		{
			return $moy;
		}
		if($min==$max-1 && $diko2[$min] ne $mot && $diko2[$max] ne $mot)
		{
			return defined($e) ? -1 : $min;
		}
	}
}

sub hint
{
	my ($moti,$motc)=@_;
	my @car=split('',decode("utf8",$moti));
	my @car2=split('',decode("utf8",$motc));
	my $nbi=0;
	for(my $i=0;$i<@car2;$i++)
	{
		if($car2[$i] eq "^") {$nbi++;}
	}
	
	my $nbM=$nbi>2 ? 2 : 1;
	
	my $j=0;
	while($j<$nbM)
	{
		my $k=0;
		for(my $i=0;$i<@car;$i++)
		{
			$k++ if($car2[$i] eq "^");
			if($car2[$i] eq "^" && int(rand(2))==0)
			{
				$car2[$i]=$car[$i];
				$j++;
				if($j==$nbM)
				{
					last;
				}
			}
		}
		last if($k==0);
	}
	
	$hint = join "", @car2;
	$hint = &encode("utf8", $hint);
	return $hint;
}

sub hint_fusion
{
	my ($hint1,$hint2)=@_;
	my @car=split('',decode("utf8",$hint1));
	my @car2=split('',decode("utf8",$hint2));
	
	my $nhint="";
	for(my $i=0;$i<@car;$i++)
	{
		if($car[$i] ne "^") {$nhint.=$car[$i];}
		else {$nhint.=$car2[$i];}
	}
	$nhint = &encode("utf8", $nhint);
	return $nhint;
}

sub in_array
{
    my ($arr,$search_for) = @_;
    foreach my $value (@$arr)
    {
        return 1 if $value eq $search_for;
    }
    return 0;
}

sub event_privmsg
{
	($server, $data, $nick, $mask) =@_;
	($target, $text) = $data =~ /^(\S*)\s:?(.*)/;
	$target=lc($target);
	if(!exists($valeur{$target}))
	{
		$valeur{$target}={"go"=>0,"one_time"=>0,"guess"=>0,"nb_coups"=>0,"quiz"=>0,"az"=>0,"motus"=>0,"azc"=>0,"connected"=>0,"letterdown"=>""};
	}
	$v=$valeur{$target};
	sub message
	{
		my $message=shift;
		$server->command("msg $target $message");
	}
	
	sub r
	{
		my ($commande,$suite)=@_;
		return reconnaitre($commande,$suite,$text);
	}
	
	sub quizsolve
	{
		sub repondre
		{
			if(defined($v->{"question"}))
			{
				if(exists($q{$v->{"question"}})) {message($q{$v->{"question"}});}
				else {message("'quiz solve");}
				$v->{"one_time"}=0;
			}
			else
			{
				message("'quiz");
			}
		}
		if(r("quizsolve start")) 
		{
			$v->{"go"}=1;
			message("Début de la résolution automatique du quiz");
			repondre();
		}
		elsif($v->{"go"} && r("quizsolve stop")) 
		{
			$v->{"go"}=0;
			message("Fin de la résolution automatique du quiz");
		}
		elsif(r("quizsolve solve")) 
		{
			$v->{"one_time"}=1;
			repondre();
		}
		elsif(r("reponse")) 
		{
			message("La réponse est : ".$q{$v->{"question"}});
		}
		elsif(r("qh")) 
		{
			if(!defined($v->{"hint"})) { $v->{"hint"}=$q{$v->{"question"}};
			
			$v->{"hint"}=decode("utf8",$v->{"hint"});
			$v->{"hint"} =~ s/\S/^/g;}
			$v->{"hint"}=hint($q{$v->{"question"}},$v->{"hint"}); # il y a un pb, à voir... : vraiment ?
			message("Hint: ".$v->{"hint"});
		}
		elsif($nick eq 'laetitia' && Irssi::strip_codes($text) =~ /Question:  (.+)/i)
		{
			$v->{"question"}=$1;
			undef($v->{"hint"});
			if($v->{"go"} || $v->{"one_time"})
			{
				repondre();
			}
		}
		elsif($nick eq 'laetitia' && Irssi::strip_codes($text) =~ /Hint: (.+)/i)
		{
			$v->{"hint"}=!exists($v->{"hint"}) || $v->{"hint"} eq "" ? $1 : hint_fusion($1,$v->{"hint"});
		}
		else { return 0; }
		return 1;
	}
	sub guess
	{
	
		if((my @z=r("guess","([0-9]+) ([0-9]+)")) && $z[1] >= $z[0])
		{
			$v->{"guess"}=1;
			$v->{"nb"}=1+$z[0]+int(rand($z[1]));
			$v->{"nb_coups"}=0;
		}
		elsif($v->{"guess"} && $text =~ /^([0-9]+)$/ )
		{
			if($text==$v->{"nb"})
			{
				$v->{"guess"}=0;
				message("$nick a trouvé ".$v->{"nb"}." en ".$v->{"nb_coups"}." coups.");
			}
			else
			{
				message("C'est ".($text>=$v->{"nb"} ? "moins" : "plus").".");
				$v->{"nb_coups"}++;
			}
		}
		else { return 0; }
		return 1;
	}
	sub quizplay
	{
		sub quizq
		{
			$cq=(%q)[int(rand(int($taille/2)))*2];
			message("\x0309Question:\x0315  $cq");
			my $a=$q{$cq};
			$a=decode("utf8",$a);
			@car=split "",$a;
			$a =~ s/\S/^/g;
			@car2=split "",$a;
		}
		if(r("q start"))
		{
			$v->{"quiz"}=1;
			quizq();
		}
		elsif($v->{"quiz"} && r("q\$"))
		{
			message("\x0309Current Question:\x0315  $cq");
		}
		elsif($v->{"quiz"} && r("q stop"))
		{
			$v->{"quiz"}=0;
		}
		elsif($v->{"quiz"} && r("q hint"))
		{
			my $hint=hint(encode("utf8",join('',@car)),encode("utf8",join('',@car2)));
			@car2=split('',decode("utf8",$hint));
			message("Hint: $hint");
		}
		elsif($v->{"quiz"} && r("q solve"))
		{
			message("La réponse est : $q{$cq}");
			quizq();
		}
		elsif($v->{"quiz"} && r("q skip"))
		{
			quizq();
		}
		elsif($v->{"quiz"} && (my @z=r("q score","(.+)")))
		{
			if(exists($s{$z[0]}))
			{
				message("le score de $z[0] est $s{$z[0]}");
			}
			else
			{
				message("$z[0] n'a pas de score");
			}
		}
		elsif($v->{"quiz"} && $text =~ /'q save/)
		{
			open ( FILE, ">".$basePath."score.txt" ) or die "can't open score.txt\n";
			foreach $nick (sort keys %s)
			{
				print FILE  "$nick:$s{$nick}\n"; # sauvegarde auto ? joker ?
			}
			close FILE;
		}
		elsif($v->{"quiz"} && lc($text) eq lc($q{$cq}))
		{
			message("$nick a trouvé la réponse : $q{$cq}");
			if(exists($s{$nick}))
			{
				$s{$nick}++;
			}
			else
			{
				$s{$nick}=1;
			}
			quizq();
		}
		else { return 0; }
		return 1;
	}
	sub az
	{
		if($v->{"az"} && ($nick eq "laetitia" || $nick eq "Erebot") &&  unaccent(decode("utf8", Irssi::strip_codes($text))) =~ / (\S+) -- (\S+)/) #  && $target eq "laetitia"
		{
			$v->{"min"}=$1 eq "???" ? 0 : recherche($1);
			$v->{"max"}=$2 eq "???" ? @diko2-1 : recherche($2);
			my $moy=int(($v->{"min"}+$v->{"max"})/2);
			if($v->{"min"}!=$v->{"max"}-1)
			{
				$server->command("msg $target $diko2[$moy]");
			}
		}
		elsif($v->{"az"} && $nick eq "Erebot" && $text=~ /Une nouvelle partie de/)
		{
			$server->command("msg $target $diko2[int((@diko2-1)/2)]");
		}
		elsif($v->{"az"} && ($nick eq "laetitia" || $nick eq "Erebot") && $text =~ /n'existe pas/ && $v->{"min"}!=$v->{"max"}-1) #  && $target eq "laetitia"
		{
			$server->command("msg $target ".$diko2[int(($v->{"max"}+$v->{"min"})*4/10)]);
		}
		elsif(r("azsolve on"))
		{
			$v->{"az"}=1;
		}
		elsif(r("azsolve off"))
		{
			$v->{"az"}=0;
		}
		else { return 0; }
		return 1;
	}
	sub azc
	{
		if(r("azc"))
		{
			$v->{"azc"}=1;
			$v->{"motazc"}=$diko2[rand(@diko2)];
			$v->{"minazc"}=$diko2[0];
			$v->{"maxazc"}=$diko2[@diko2-1];
			message($v->{"minazc"}." -- ".$v->{"maxazc"});
			$nazc=0;
		}
		elsif(r("azc stop"))
		{
			$v->{"azc"}=0;
		}
		elsif($v->{"azc"} && $text =~ /^\S+$/)
		{
			if($v->{"minazc"} lt $text && $text lt $v->{"maxazc"})
			{
				if(recherche($text,1)!=-1)
				{
					$nazc++;
					if($text lt $v->{"motazc"})
					{
						$v->{"minazc"}=$text;
						message($v->{"minazc"}." -- ".$v->{"maxazc"});
					}
					elsif($text gt $v->{"motazc"})
					{
						$v->{"maxazc"}=$text;
						message($v->{"minazc"}." -- ".$v->{"maxazc"});
					}
					else
					{
						message("$nick a gagné en $nazc essais, le mot était ".$v->{"motazc"}.".");
						$v->{"azc"}=0;
					}
				}
				else
				{
					message("Ce mot n'existe pas dans le dictionnaire utilisé.");
				}
			}
		}
		else { return 0; }
		return 1;
	}
	
	sub motus
	{
		if(r("motussolve on")) # 0 : blanc , 4 : rouge , 9 : vert , 12 : bleu
		{
			$v->{"motus"}=1;
			$v{"lettrePresente"}=[];
			$v{"lettreAbsente"}=[];
			$v{"lettreMalPlace"}=[];
		}
		elsif($v->{"motus"} && $text =~ /Bravo|temps/)#  && $nick ne "Dan"
		{
			$v{"lettrePresente"}=[];
			$v{"lettreAbsente"}=[];
			$v{"lettreMalPlace"}=[];
		}
		elsif($v->{"motus"} && r("motussolve off"))
		{
			$v->{"motus"}=0;
			$v{"lettrePresente"}=[];
			$v{"lettreAbsente"}=[];
			$v{"lettreMalPlace"}=[]; # possible de mettre des mots au hasard quand le mot n'est pas dans le dico jusqu'à ce qu'il y a ai toutes les lettres et à ce moment là juste dire ce mot...
		}
		elsif($v->{"motus"} && $text =~ /::::\|(.+) \|::::/)#  && $nick ne "Dan" à faire marcher ( pb tab asso de tab )
		{
			my $mota=unaccent($1);
			my $u=0;
			my $mot_a_trou;
			if($mota =~ /^(.+)\|:::\|(.+)$/)
			{
				$mot_a_trou=$2;
				my $indice=$1;
				$indice =~ s/^ +//;
				$indice =~ s/ +$//;
				$indice =~ s/\x0300|\x02|\x0312//g;
				my $indice=lc($indice); # avant, après ?
				my @indicec=split(' ',$indice);
				my $i=0;
				foreach $c (@indicec)
				{
					if(($c=~/\x0304(.)/ || $c=~/\x0303(.)/) && !in_array($v{"lettrePresente"},$1) && !in_array($v{"lettreAbsente"},$1)) # ne marche pas bien !!!!!! : vraiment ? (semble marcher)
					{
						push(@{$v{"lettrePresente"}},$1);
					}
					if($c=~/\x0304(.)/)
					{
						if(defined(@{$v{"lettreMalPlace"}}[$i])) # pas parfait ( trop de trucs ajoutés ? ) : vraiment ? (semble marcher)
						{
							if(!in_array(@{$v{"lettreMalPlace"}}[$i],$1))
							{
								push(@{@{$v{"lettreMalPlace"}}[$i]},$1);
							}
						}
						else
						{
							@{$v{"lettreMalPlace"}}[$i]=[$1];
						}
					}
					$i++;
				}
				my $i=0;
				foreach $c (@indicec)
				{
					if($c!~/\x0303./ && $c!~/\x0304(.)/ && Irssi::strip_codes($c) =~ /^(.)$/ && !in_array($v{"lettreAbsente"},$1)) # dernier cond pas parfaite ( and now ? )
					{
						if(!in_array($v{"lettrePresente"},$1))
						{
							push(@{$v{"lettreAbsente"}},$1);
						}
						else
						{
							if(defined(@{$v{"lettreMalPlace"}}[$i])) # pas parfait 
							{
								push(@{@{$v{"lettreMalPlace"}}[$i]},$1);
							}
							else
							{
								@{$v{"lettreMalPlace"}}[$i]=[$1];
							}
						}
					}
					$i++;
				}
			}
			else
			{
				$mot_a_trou=$mota;
			}
			Irssi::print(@{$v{"lettrePresente"}}." lettres présentes : ".join(" ",@{$v{"lettrePresente"}}));
			Irssi::print(@{$v{"lettreAbsente"}}." lettres absentes : ".join(" ",@{$v{"lettreAbsente"}}));
			Irssi::print("Lettres mal placés :");
			my $i=0;
			foreach $e (@{$v{"lettreMalPlace"}})
			{
				$i++;
				if(defined($e))
				{
					Irssi::print($i." : ".join(" ",@$e));
				}
			}
			$mot_a_trou=Irssi::strip_codes($mot_a_trou);
			$mot_a_trou =~ s/ //g;
			$mot_a_trou=&decode("utf8",$mot_a_trou);
			$mot_a_trou=lc(unaccent($mot_a_trou));
			
			my @mat=split "",$mot_a_trou;
			Irssi::print(@mat." lettres : ".join(" ",@mat));
			my $l=length($mot_a_trou);
			b:foreach $mot (@diko)
			{
				if(length($mot)!=$l)
				{
					next;
				}
				my @motc=split "",$mot;
				for($i=0;$i<@mat;$i++)
				{
					next b if(@mat[$i] ne "_" && @mat[$i] ne @motc[$i]);
				}
				for($i=0;$i<@motc;$i++)
				{
					next b if(defined(@{$v{"lettreMalPlace"}}[$i]) && in_array(@{$v{"lettreMalPlace"}}[$i],@motc[$i]));
				}
				foreach $lettre (@{$v{"lettrePresente"}})
				{
					next b if(!in_array(\@motc,$lettre));
				}
				foreach $lettre (@{$v{"lettreAbsente"}})
				{
					next b if(in_array(\@motc,$lettre));
				}
				#message("$mot");
				Irssi::print($mot);
				message($mot);
				$u=1;# ne marche pas, me fatigue (vraiment ? semble marcher)
				last;
			}
			Irssi::print("rien trouvé !!!") if(!$u); # enlever irssi::print ? ( ou au moins cacher,... ? voir )
 		}
 		else { return 0; }
 		return 1;
	}
	sub help
	{
		if($nick ne 'laetitia' && $nick ne 'Erebot' && $text =~ /$server->{nick}/ && $text =~ /help/)
		{
			message("Vous pouvez utiliser : ".$cc."quizsolve start ".$cc."quizsolve stop ".$cc."quizsolve solve ".$cc."guess <min> <max> ".$cc."q start ".$cc."q stop ".$cc."q hint ".$cc."q skip ".$cc."q solve ".$cc."q score ".$cc."q save ".$cc."azsolve on ".$cc."azsolve off ".$cc."reponse ".$cc."azc ".$cc."azc stop ".$cc."connected <pseudo> ".$cc."natures <phrase> ".$cc."getquote [<regex>] ".$cc."getnumquote <nombre> ".$cc."addquote <quote> ".$cc."delquote <num> ".$cc."whoquote <num> ".$cc."db ".$cc."motussolve on ".$cc."motussolve off");
		}
		elsif($nick ne 'laetitia' && $nick ne 'Erebot' && $text =~ /$server->{nick}/ && $text =~ /quit/)
		{
			message($nick.": quit");
		}
		else { return 0; }
		return 1;
	}
	
	sub ia
	{
# 		if(my @z=r("nature","(.+)"))
# 		{
# 			chargerUnMot($z[0]);
# 			message(nature($z[0]));
# 		}
		if(my @z=r("natures","(.+)"))
		{
			#charger($z[0]);
			message(natures($z[0]));
		}
		else { return 0; }
		return 1;
	}
	
	sub connected
	{
		if(my @z=r("connected","(.+)"))
		{	
			$v->{"connected"}=1;
			$server->send_raw("whois $z[0]");
		}
		else { return 0; }
		return 1;
		
	}
	
	sub quote
	{
		sub writequote
		{
			open ( FILE, ">".$basePath."quote.txt" ) or die "can't open quote.txt\n";
			foreach $q (@quote)
			{
				if(defined($q))
				{
					print FILE $q."\n";
				}
			}
			close FILE;
		}

		sub addquote
		{
			my ($personne,$q)=@_;
			my $q2=$personne.":".$q;
			push(@quote,$q2);
			message("Quote ".((scalar @quote)-1)." bien ajouté : ".$q);
			writequote();
		}

		sub delquote
		{
			my $n=shift;
			undef(@quote[$n]);
			writequote();
			message("Quote $n supprimé");
		}

		
		sub getnumquote
		{
			my $i=shift;
			my @q2=split ':',$quote[$i];
			shift @q2;
			message("quote $i : ".(join ':',@q2));
			return;
		}
		
		sub getquote
		{
			if((scalar @_)==0)
			{
				getnumquote(int(rand(scalar @quote)));
				return;
			}
			my $regex=shift;
			my $i=0;
			my $rex; # ajouter l'heure au moment du stockage ( + whoquote )
			if(eval {$rex = qr/$regex/})
			{
				foreach $q (@quote)
				{
					if($q =~ /$rex/)
					{
						getnumquote($i);
						last;
					}
					$i++;
				} 
			}
		}
		sub whoquote
		{
			my $n=shift;
			my $personne=(split ':',@quote[$n])[0];
			message("Quote $n ajouté par ".$personne);
		}

		sub db
		{
			my $i=0;
			foreach $q (@quote)
			{
				if(defined($q))
				{
					$i++;
				}
			}
			message($i." quotes");
		}
		
		if(my @z=r("addquote","(.+)"))
		{
			addquote($nick,$z[0]);
		}
		elsif(my @z=r("delquote","([0-9]+)"))
		{
			delquote($z[0]);
		}
		elsif(my @z=r("whoquote","([0-9]+)"))
		{
			whoquote($z[0]);
		}
		elsif(my @z=r("getnumquote","([0-9]+)"))
		{
			getnumquote($z[0]);
		}
		elsif(my @z=r("getquote","(.+)"))
		{
			getquote($z[0]);
		}
		elsif(r("getquote"))
		{
			getquote();
		}
		elsif(r("db"))
		{
			db();
		}
		else { return 0; }
		return 1;
		
	}
	
# 	sub start
# 	{
# 		if(my @z=r("startquestion","(.+)"))
# 		{
# 			my $question=$z[0];
# 			my $ua=LWP::UserAgent->new;
# 			$ua->agent("MyApp/0.1 ");
# 			$ua->timeout(30);
# 			my $req=HTTP::Request->new(GET=>"http://start.csail.mit.edu/startfarm.cgi?query=".uri_escape($question));
# 			my $res=$ua->request($req);
# 			my $page=$res->content;
# 			open(F,">.irssibot/lalalolo.txt");
# 			print(F $page);
# 			#print(F "lala\n");
# 			close(F);
# 			if($page =~ /<span type="reply" quality=".+?">\s+<!-- REPLY-QUALITY: .+? -->\s+(.+?)\s+<\/span>/s)
# 			{
# 				Irssi::print($1);
# 			}
# 		}
# 		else { return 0; }
# 		return 1;
# 	}


	# pas le module qu'il faut sur perso (passer sur un autre serveur)
	
	# la flemme, à finir plus tard, peut être ( réorganiser le bot : ce fichier est beaucoup trop long )
# 	sub letterdown
# 	{
# 		if($text =~ "$ccletterdown")
# 		{
# 			$v{"letterdown"}="";
# 			my @lettres=split('',"abcdefghijklmnopqrstuvwxyz");
# 			for($i=0;$i<10;$i++)
# 			{
# 				$v{"letterdown"}.=$lettres[int(rand(26))];
# 			}
# 		}
# 		elsif($v{"letterdown"} ne "")
# 		{
# 			
# 		}
# 		else { return 0; }
# 		return 1;
# 	}

	
	sub countdown
	{
		
		if(r("countdownsolve"))
		{
			if(defined($v->{"objectif"}) && defined($v->{"nombres"}))
			{
				message(countdown::solve([split(",",$v->{"nombres"})],$v->{"objectif"}));
			}
		}
		elsif(Irssi::strip_codes($text) =~ "Vous devez obtenir ([0-9]+) grâce aux nombres suivants : (.+?)\\.")
		{
			
			$v->{"objectif"}=$1;
			$v->{"nombres"}=$2;
			$v->{"nombres"} =~ s/&/,/;
			$v->{"nombres"} =~ s/\s//g;
		}
		else { return 0; }
		return 1;
		
	}
	
	if(help()){}
	elsif(quizsolve()){}
	elsif(guess()){}
	elsif(quizplay()){}
	elsif(az()){}
	elsif(azc()){}
	elsif(motus()){}
	elsif(ia()){}
	elsif(connected()){}
	elsif(quote()){}
	elsif(countdown()){}
# 	elsif(start()){}
}

sub event_311
{
	if($v->{"connected"})
	{
		$v->{"connected"}=0;
		my ( $server, $data ) = @_;
		$data =~ /\S+\s+(\S+)\s+(\S+)\s+/;
		my $nom=$2;
		my $pseudo=$1;
		my $connectes=`who | cut -f1 -d' ' | sort | uniq`;
		my $message=$pseudo.($connectes =~ /$nom/ ? " est connecté" : " n'est pas connecté");
		$server->command("msg $target $message"); # un peu moisi mais peut difficilement planter (  seule possibilité : 2 demandes en même temps ) : peut par contre ne rien faire si plein d'autres messages quand demande
	}
}

sub event_kick
{
	my ( $server, $data ) = @_;
	my ( $channel, $nick ) = split( / +/, $data );
	return if ( $server->{ nick } ne $nick );
	$server->send_raw("join $channel");
}

sub event_321
{
	@chans=();
	
}

sub event_322
{
	my ( $server, $data ) = @_;
	local ($info,$topic)=$data =~ /(.*?) :(.*)/;
	local ($nick,$chan,$nb)=split ' ',$info;
	push(@chans,{"chan"=>$chan,"nb"=>$nb,"topic"=>$topic});
}

sub event_323
{
	@chans = sort {-($a->{"nb"} <=> $b->{"nb"})} @chans;
	open ( FILE, ">html/list.html" ) or die "can't open list.html\n";
	print FILE  "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"utf-8\" />\n<title>List</title>\n</head>\n<style>table{border-collapse: collapse;}\ntd,th{border: 1px solid black;}</style>\n<body>\n<h1>".scalar @chans." chans : </h1>\n<table>\n<tr><th>Chan</th><th>Nombre d'utilisateurs</th><th>Topic</th>\n";
	foreach $chan (@chans)
	{
		print FILE  "<tr><td>$chan->{'chan'}</td><td>$chan->{'nb'}</td><td>$chan->{'topic'}</td></tr>\n";
	}
	print FILE  "</table>\n</body>\n</html>";
	close FILE;
}

Irssi::signal_add('event 311','event_311');
Irssi::signal_add('event 321', 'event_321');
Irssi::signal_add('event 322', 'event_322');
Irssi::signal_add('event 323', 'event_323');
Irssi::signal_add('event privmsg', 'event_privmsg');
#Irssi::signal_add('event kick', 'event_kick');
