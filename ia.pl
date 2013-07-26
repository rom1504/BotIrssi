use Encode;
open ( FILE, "<.irssibot/scripts/autorun/dictionnaire.txt" ) or open ( FILE, "<dictionnaire.txt" ) or die "can't open dictionnaire.txt\n";
chomp( @dic = <FILE> );
close FILE;


# possible de mettre la base ailleurs ( commun ) : mais je vais laisser comme ça, à priori

# codé en c++ Qt , à coder en c++ non Qt voir en c ( plutôt c++ non codé )

@caracteristique=('nature','genre','nb','temps','sujet');
@ccomplet=('mot','base','nature','genre','nb','temps','sujet');

@cnature=("Adjectif","Nom","Adverbe","Interjection","Preposition","Pronom","Determinant","Abreviation","Conjonction","Onomatopee","Verbe","NomPropre");
@cgenre=("Masculin","Feminin","Invariant");
@cnb=("Singulier","Pluriel","Invariable");
@ctemps=("Infinitif","IndicatifPresent","IndicatifImparfait","IndicatifPasseSimple","IndicatifFutur","Imperatif","SubjonctifPresent","SubjonctifImparfait"," ConditionelPresent","ParticipePresent","ParticipePasse");
@csujet=("P1","P2","P3");

foreach $c (@caracteristique)
{
	for($i=0;$i<@{"c$c"};$i++)
	{
		${"cd$c"}{${"c$c"}[$i]}=$i;
	}
}


%ccnature=("Adj"=>"Adjectif", "Nom"=>"Nom", "Adv"=>"Adverbe","Int"=>"Interjection", "Pre"=>"Preposition", "Pro"=>"Pronom", "Det"=>"Determinant", "Abr"=>"Abreviation", "Con"=>"Conjonction", "Ono"=>"Onomatopee", "Ver"=>"Verbe");
%ccgenre=("Mas"=>"Masculin", "Fem"=>"Feminin","InvGen"=>"Invariant");
%ccnb=("SG"=>"Singulier", "PL"=>"Pluriel","InvPL"=>"Invariable");
%cctemps=("Inf"=>"Infinitif","IPre"=>"IndicatifPresent","IImp"=>"IndicatifImparfait","IPSim"=>"IndicatifPasseSimple","IFut"=>"IndicatifFutur","Imp"=>"Imperatif","ImPre"=>"Imperatif","SPre"=>"SubjonctifPresent","SImp"=>"SubjonctifImparfait","CPre"=>"ConditionelPresent","PPre"=>"ParticipePresent","PPas"=>"ParticipePasse");
%ccsujet=("P1"=>"P1","P2"=>"P2","P3"=>"P3");

# réfléchir à trainer vraiment dans cet ordre de priorité ( tous les mots pour une assoc puis pour la suivante,... )

@associationSuffisante=(["Determinant","Nom"],["Verbe","Determinant"],["Determinant","NomPropre"],["Pronom","Verbe"],["Adverbe","Adjectif"],["Nom","Verbe"],["NomPropre","Verbe"],["Nom","Adjectif"],["Adjectif","Nom"],["Adjectif","NomPropre"],["NomPropre","Adjectif"],["Verbe","Adjectif"],["Verbe","Adverbe"],["Preposition","Nom"],["Adjectif","Adjectif"]); # ici utilisé pour une seule possibilité mais peut être utilisé pour en faire plusieurs.
# pas vraiment ordre de prio actuellement à cause du parcours aléatoire des divers types grammaticaux des mots : à changer !
@aS=();
foreach $a (@associationSuffisante)
{
	$at=[];
	foreach $n (@{$a})
	{
		push(@{$at},$cdnature{$n});
	}
	push(@aS,$at);
}


@caracteristiquep=('genre','nb','temps','sujet');
%mots=();


sub afficherMot
{
	my $mot2=shift;
	my $j=0;
	my $retour="";
	foreach $k (@ccomplet)
	{
		if(defined($mot2->{$k}))
		{
			$retour.=", " if($j>=1);
			if($k ne "base" && $k ne "mot")
			{
				$retour.="$k: ".${"c$k"}[$mot2->{$k}];
			}
			else
			{
				$retour.="$k: ".$mot2->{$k};
			}
			$j++;
		}
	}
	return $retour;
}



$i=0;

sub ajouter
{
	if(!defined($mots{@smot[0]}))
	{
		$mots{@smot[0]}=[];
	}
	push(@{$mots{@smot[0]}},{%mot});
}

sub chargerMot
{
	local $e=shift;
	local @smot=split '	',$e;
	local @caras=split ':',@smot[2];
	local %mot=();
	$mot{"mot"}=@smot[0];#à voir...
	$mot{"base"}=@smot[1];
	$mot{"nature"}=$cdnature{$ccnature{shift @caras}};
	foreach $u (@caras)
	{
		local @caras2=split '\+',$u;
		foreach $cara (@caras2)
		{
			foreach $c (@caracteristiquep)
			{
				if(defined(${"cc$c"}{$cara}))
				{
					$mot{$c}=${"cd$c"}{${"cc$c"}{$cara}};
				}
			}
		}
		ajouter();
	}
	if(scalar @caras == 0)
	{
		ajouter();
	}
}

sub chargerUnMot
{
	local $motc=shift;
	if(defined($mots{$motc})) { return; }
	local $min=0;
	local $max=@dic-1;
	while($max-$min>1)
	{
		local $moy=int(($min+$max)/2);
		local $moymot=(split '	',@dic[$moy])[0];
		if($moymot lt $motc) { $min=$moy; }
		elsif($moymot gt $motc) { $max=$moy; }
		else {last;}
	}
	for($i=$min;$i<=$max;$i++)
	{
		local $motcr=(split '	',@dic[$i])[0];
		if($motcr eq $motc) { chargerMot(@dic[$i]);}
	}
}

sub chargerDesMots
{
	local $tmot=shift;
	foreach $mot5 (@{$tmot})
	{
		chargerUnMot($mot5);
	}
}

# penser à vérif algo partiel prog avancé

sub charger
{
	foreach $e (@dic)
	{
		chargerMot($e);
	}
}

#charger();

# chargerUnMot("de");
# afficher("de");

# tableau à la place de hash pour prendre moins de place ?

# nature fait, continuer à exploiter ça, penser à de nouvelles commandes intéressantes sur irc
sub dha
{
  my ($ref_tabeau) = @_;
  return keys %{ { map { $_ => 1 } @{$ref_tabeau} } };
}

sub nature_mot
{
	local $mots2=shift;
	local @nature=();
	foreach $mot2 (@{$mots2})
	{
		if(defined($mot2))
		{
			push(@nature,$cnature[$mot2->{"nature"}]);
		}
	}
	return join ', ',dha(\@nature);
}

sub nature
{
	local $mot=shift;
	return nature_mot(\@{$mots{$mot}});
}
# chargerUnMot("de");
# print(nature("de")."\n");


# bof, enfin peut être utile à la fin ( ou via un random plutôt ) s'il reste qq pos dont on ne sais pas choisir
sub analyse
{
	local $phrase=shift;
	local @motsp=split ' ',$phrase;
	local @motsu=();
	foreach $mot (@motsp)
	{
		push(@motsu,@{$mots{$mot}}[0]);
	}
	return \@motsu;
}
# struct ou hash ??? ( surtout cout mémoire, peut être vitesse, à voir... )

sub chargerPhrase
{
	my $phrase=shift;
	$phrase=lc($phrase);
	$phrase=~ s/t'/te /g;
	$phrase=~ s/j'/je /g;
	$phrase=~ s/l'/la /g;#discutable
	$phrase=~ s/m'/me /g;
	$phrase=~ s/\.|,//g;
	$phrase=~s/ +/ /g;
	my @motsp=split ' ',$phrase;
	chargerDesMots(\@motsp);
	my @motsu=();
	foreach $mot (@motsp)
	{
		if(exists($mots{$mot}))
		{
			push(@motsu,\@{$mots{$mot}});
		}
		else
		{
			my $nnmot={};
			$nnmot->{"mot"}=$mot;
			$nnmot->{"nature"}=$cdnature{"NomPropre"};
			push(@motsu,[$nnmot]);
		}
	}
	return \@motsu;
}

sub eliminationSubjonctif
{
	my $temp=shift;
	my @motsu=@{$temp};
	for($j=0;$j<(@{@motsu[$i]});$j++)
	{
		$mot=(@{@motsu[$i]})[$j];
		if(defined($mot))
		{
			if($mot->{"nature"}==8)
			{
				$conj=1;
			}
			if($mot->{"nature"}==10 && (!$conj && ($mot->{"temps"}==6 || $mot->{"temps"}==7)))
			{
				undef(@motsu[$i]->[$j]);
			}
		}
	}
	return \@motsu;
}

sub analyse2
{
	my $phrase=shift;
	my @motsu=@{chargerPhrase($phrase)};
	$conj=0;
	for($i=0;$i<@motsu;$i++)
	{
		@motsu=@{eliminationSubjonctif(\@motsu)};
		if($i>0)
		{
			my $b=-1;
			#print((scalar @{@motsu[$i]})."\n");
			my $w=0;
			foreach $a (@aS)
			{
				if(($b==$w && $b!=-1) || $b==-1)
				{
					boucle1:for($j=0;$j<(@{@motsu[$i]});$j++)
					{
						$mot=(@{@motsu[$i]})[$j];
						if(defined($mot))
						{
							for($k=0;$k<(@{@motsu[$i-1]});$k++)
							{
								$mot2=(@{@motsu[$i-1]})[$k];
								if(defined($mot2))
								{
									if($mot2->{"nature"}==$a->[0] && $mot->{"nature"}==$a->[1])
									{
										if($b==-1)
										{
											$b=$w;
											$j=-1;
											next boucle1;
										}
										elsif($b==$w)
										{
											if($w==1)
											{
												if(defined($mot2->{"sujet"}) && defined($mot->{"sujet"}) && $mot2->{"sujet"}!=$mot->{"sujet"})
												{
													undef @motsu[$i]->[$j];
												}
											}
											elsif($w==0)
											{
												if(defined($mot2->{"nb"}) && defined($mot->{"nb"}) && $mot2->{"nb"}!=2 && $mot->{"nb"}!=2 &&  $mot2->{"nb"}!=$mot->{"nb"})
												{
													undef @motsu[$i]->[$j];
												}
											}
										}
									}
									elsif($b!=-1)
									{
										if($mot2->{"nature"}!=$a->[0])
										{
											undef @motsu[$i-1]->[$k];
										}
										if($mot->{"nature"}!=$a->[1])
										{
											undef @motsu[$i]->[$j];
										}
									}							
								}
							}
						}
					}
				}
				$w++;
				if($b!=-1) { last;}
 			}
		}
	}
	return \@motsu;
}





sub natures
{
	local $phrase=shift;
	local @motsu=@{analyse2($phrase)};
	local $t=0;
	local $retour="";
	foreach $mot (@motsu)
	{
		if($t>0)
		{
			$retour.=", ";
		}
		foreach $mot2 (@{$mot}){if(defined($mot2)) { $retour.=$mot2->{"mot"}.": "; last;}} # détermination ( par ex déterminant oui, mais de quel mot ?? )
		$retour.=nature_mot($mot);
		$t++;
	}
	return $retour;
}
sub affichage
{
	local $phrase=shift;
	local @motsu=@{analyse2($phrase)};
	my $retour="";
	foreach $mot (@motsu)
	{
		foreach $mot2 (@{$mot}){if(defined($mot2)) { $retour.=$mot2->{"mot"}.": \n"; last;}}
		foreach $mot2 (@{$mot})
		{
			if(defined($mot2)) 
			{
				$retour.=afficherMot($mot2)."\n";
			}
		}
	}
	return $retour;
}

sub groupe_nominaux
{
	local $phrase=shift;
	local @motsu=@{analyse2($phrase)};
	foreach $mot (@motsu) # semble pas trop dur mais la flemme
	{
		
	}
}




1;