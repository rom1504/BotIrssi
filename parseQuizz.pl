use strict;

if((scalar @ARGV)!=2)
{
	print("usage: $0 <fichierSource> <fichierCible>\n");
	exit 1;
}
my ($fichierSource,$fichierCible)=@ARGV;
# 23:01 < laetitia> Current question:  Comment s'apelle la fille d'Ingrid Bergman ?
# (La réponse était : Isabella Rosselini)

# |||...|||

# appliquer un cat | sort | uniq ensuite

open(my $ffichierSouce,"<",$fichierSource);
open(my $ffichierCible,">",$fichierCible);

my $ligne;
my $currentQ;
while($ligne = <$ffichierSouce>)
{
	if($ligne =~ /Current question:  (.+)/ || $ligne =~ /Question:  (.+)/)
	{
		$currentQ=$1;
	}
	if($currentQ ne "" && ($ligne =~ /\(La réponse était : (.+)\)/ || $ligne =~ /La réponse était : (.+)/ || $ligne =~ /Answer was: (.+)/))
	{
		print($ffichierCible $currentQ."|||...|||".$1."\n");
		$currentQ="";
	}
}
close($ffichierSouce);
close($ffichierCible);