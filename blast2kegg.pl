#!/usr/bin/env perl
use strict;
use warnings;

defined($ARGV[0]) or die "Usage: $0 folders containning blast m8 file, whether to draw kegg pathway(Default 1)\n";
chomp(@ARGV);
my $map=$ARGV[1];
defined($map) or $map=1;
my $keggHome = "/nfs_genome/BioDB/kegg/202111/kegg";
open LINK_PRO,"<$keggHome/genes/fasta/prokaryotes.dat";
open LINK_EU,"<$keggHome/genes/fasta/eukaryotes.dat";
open LINK_KO,"<$keggHome/pathway/links/pathway_ko.list";
open LINK_MO,"<$keggHome/module/links/module_ko.list";
open KO_name, "<$keggHome/genes/ko/ko";
open MO_name, "<$keggHome/module/module";

my %ko_name;
my $ko;
my %mo_name;
my $mo;

while(<MO_name>)
{
chomp();
my $tmp = $_;
/ENTRY\s+(\w+)\s+/ and $mo = $1;
my $definition;
/NAME\s+(\S+.*)/ and $mo_name{$mo}=$1;
}


while(<KO_name>)
{
chomp();
my $tmp = $_;
/ENTRY\s+(\w+)\s+/ and $ko = $1;
my $definition;
/DEFINITION\s+(\S+.*)/ and $ko_name{$ko}=$1;
}


opendir DIR,"$ARGV[0]";
my %ko_path;
my %link;
while(<LINK_PRO>)
{
chomp();
my @info = split(/\t/,);
$link{$info[0]}{'ko'} = $info[1];
$link{$info[0]}{'symbol'} = $info[3];
}
while(<LINK_EU>)
{
chomp();
my @info = split(/\t/,);
$link{$info[0]}{'ko'} = $info[1];
$link{$info[0]}{'symbol'} = $info[3];
}
while(<LINK_KO>)
{
chomp();
/path\:map.*/ and next;
my @info = split(/\t/,);
$info[0] =~ s/path\://;
$info[1] =~ s/ko\://;
push @{$ko_path{$info[1]}}, $info[0];
}

my %ko_mo;
while(<LINK_MO>)
{
chomp();
/path\:map.*/ and next;
my @info = split(/\t/,);
$info[0] =~ s/md\://;
$info[1] =~ s/ko\://;
push @{$ko_mo{$info[1]}}, $info[0];
}



my %kegg;
my %module;
while(readdir(DIR))
{
/m8$/ or next;
my $file = $_;
$file =~ s/\.faa\.filter\.m8//g;
open BLAST,"<$ARGV[0]/$_";
open KEGGout,">$ARGV[0]/$file\.kegg";
open GENE2TERM, ">$ARGV[0]/$file\_gene2map.csv";
open GENE2MD,">$ARGV[0]/$file\_gene2module.csv";
open GENE2KO, ">$ARGV[0]/$file\_gene2ko.tsv";
open CHART, ">$ARGV[0]/$file\_keggchart.csv";
open MOchart, ">$ARGV[0]/$file\_Module_chart.csv";
my %ko_count;

while(<BLAST>)
{
chomp();
/Gene_id/ and next;

my @info = split(/\t/,);
my @ko = split(/,/,$link{$info[1]}{'ko'});
my @pathway;
my @mod;
foreach my $k (@ko)
{
chomp($k);
$k =~ s/\s+//g;
$ko_count{$k}++;

if(exists($ko_path{$k})) {
push @pathway, @{$ko_path{$k}};
foreach(@{$ko_path{$k}})
{
$kegg{$_}{$k} = 1;
}
}
if(exists($ko_mo{$k})) {
push @mod, @{$ko_mo{$k}};
foreach(@{$ko_mo{$k}})
{
$module{$_}{$k} = 1;
}

}
}
@ko = removeRepeat(\@ko);
@pathway = removeRepeat(\@pathway);
@mod = removeRepeat(\@mod);

foreach (@mod)
{
chomp();
print GENE2MD "$info[0]\t$_\n";
}

foreach (@pathway)
{
chomp();
print GENE2TERM "$info[0]\t$_\n";
}

print KEGGout "$info[0]\t$info[1]\t$info[2]\t$info[3]\t$info[4]\t$info[5]\t$info[6]\t$info[7]\t";

foreach my $ko (@ko)
{
print KEGGout "$ko,$ko_name{$ko};";
print GENE2KO "$info[0]\t$ko\n";
}
print KEGGout "\t";
print KEGGout join(",",@pathway)."\t";
print KEGGout $link{$info[1]}{'symbol'}."\t";
print KEGGout join(",",@mod)."\t";
print KEGGout "\n";
}



#if($map)
#{
#open ERR,">$ARGV[0]/$file/err.log";

foreach my $path (sort keys(%kegg))
{
foreach my $ko (sort keys(%{$kegg{$path}}))
{
chomp($ko);
$ko =~ s/\s+//g;
exists($ko_count{$ko}) and print CHART "$path\t$ko\t$ko_count{$ko}\n";
}
}


foreach my $mo (sort keys(%module))
{
foreach my $ko (sort keys(%{$module{$mo}}))
{
chomp($ko);
$ko =~ s/\s+//g;
exists($ko_count{$ko}) and print MOchart "$mo\t$ko\t$ko_count{$ko}\n";
}

}
}

sub removeRepeat

{

    my $arrRef = shift;

    my %count = ();
    my @uniqArr = grep { ++$count{$_} == 1 } @$arrRef;



    return @uniqArr;

}
