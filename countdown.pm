package countdown;

use strict;
sub addition
{
	return @_[0]+@_[1];
}

sub soustraction
{
	return @_[0]-@_[1];
}

sub multiplication
{
	return @_[0]*@_[1];
}

sub division
{
	return @_[0]/@_[1];
}

sub enleverElement
{
	my ($i,$tab)=@_;
	my @ntab=();
	my $j=0;
	foreach (@$tab)
	{
		if($j!=$i) { push(@ntab,$_); }
		$j++;
	}
	return @ntab;
}

my %operations=("+"=>\&addition,"-"=>\&soustraction,"*"=>\&multiplication,"/"=>\&division);

#my %operations=("+"=>\&addition,"-"=>\&soustraction,"*"=>\&multiplication);

sub essai
{
	my ($nbs,$resultatCourant,$calcul,$objectif)=@_;
	if($resultatCourant==$objectif)
	{
		return "$calcul";
	}
	if((scalar @$nbs)==0)
	{
		return "fail";
	}
	my $i=0;
	foreach my $nb (@$nbs)
	{
		my $tempTab=[enleverElement($i,$nbs)];
		if($resultatCourant==0)
		{
			my $r=essai($tempTab,$nb,$nb,$objectif);
			if($r ne "fail") { return $r; }
		}
		else
		{
			foreach my $operation (keys %operations)
			{ # récursif terminal ? ( revoir...)
				#my $r=essai([enleverElement($i,$nbs)],$operations{$operation}($resultatCourant,$nb),$calcul.$operation.$nb,$objectif);
				if($operation eq "/" && ($resultatCourant%$nb != 0 || $nb==1)) { next; }
				my $r=essai($tempTab,$operations{$operation}($resultatCourant,$nb),(($operation eq "*" || $operation eq "/") && ($calcul =~ /[\+|-][0-9]+$/) ? "($calcul)" : $calcul).$operation.$nb,$objectif);
				if($r ne "fail") { return $r; }
			}
		}
		$i++; # trouver une façon de trouver la soluce opti ?
	}
	return "fail";
}

sub solve
{
	my ($nombres,$objectif)=@_;
	my $retour;
	eval
	{
	    local $SIG{ALRM} = sub { die "timeout\n" };
	    alarm 50;
		$retour=essai([map {int($_)} (@$nombres)],0,"",$objectif);
		alarm 0;
	};
	if($@) { return "trop long"; }
	return $retour;
}

1;