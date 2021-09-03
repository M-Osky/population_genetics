#!/usr/bin/perl
use strict ; use warnings;

# treemix_formater  			# by M'Óscar https://github.com/M-Osky
# Use this script to create a treemix input file for spatpg from a VCF file and a popmap (with information about the years or generations).
# Call the program with a help flag to check the information and usage.

my $version = "treemix_formater_v1.1.pl";
my $changed = "2020/06/25";

############################

##################################################################################################################
################################    admixture_bachmaker.pl Changelog    ##########################################
######																										######
######		Version 1.1 - 25/06/2020																		######
######		Debugged, added a table with the population and generation order								######
######																										######
######		Version 1.0 - 20/03/2020																		######
######		Added a lot extra more options in order to make possible to parse data from						######
######		multiple diferent kind of files. I you don't need the extra options and find					######
######		the help file overcomplicated, you may use the previous version: first_treemix_formater.pl		######
######																										######
##################################################################################################################




###################################################   PARAMETERS   #####################################################
#######         All of them can and should be set from the command line, check the help information.

my $default = "No default";  		# DON NOT CHANGE THIS (and neither the rest of the variables)
#my $default = "No default";  		# DON NOT CHANGE THIS (and neither the rest of the variables)

my $inputname = "populations.snps.vcf";  		# input file name, should be a string either alphanumeric or alphabetic.
#my $inputname = "populations.snps.vcf";  		# input file name, should be a string either alphanumeric or alphabetic.
my $infocols = 9;  		# check how many columns of information has the VCF file before the first sample column
#my $infocols = 9;  		# check how many columns of information has the VCF file before the first sample column

my $popgenmap = "popgenmap.txt";  		# population and generation map file to know the samples information
#my $popmap = "No default";
my $sep = "\t";  		#column separator for the popgenmap
#my $sep = "\t";  		#column separator for the popgenmap
#my $sep = ";";  		#column separator for the popgenmap
# columns with the information about the samples: sample ID column, population ID column, generation/year column
my $samplecol = 1;		   #individual ID at column number...
#my $samplecol = 1;		   #individual ID at column number...
my $popcol = 2;		   #population ID at column number...
#my $popcol = 2;		   #population ID at column number...

my $environmental = $default;		   #data file with per sample environmental data
#my $environmental = $default;		   #data file with per sample environmental data
my $samplecol2 = $default;		   #individual ID at column number...
#my $samplecol2 = 1;		   #individual ID at column number...
my $popcol2 = $default;		   #population ID at column number...
#my $popcol2 = 1;		   #population ID at column number...
my $envcol = $default;		   #column with the environmental data to use
#my $envcol = $default;		   #column with the environmental data to use
my $sep2 = "\t";		   #column separator of the environmental data file
#my $sep2 = "\t";		   #column separator of the environmental data file
#my $sep2 = ",";		   #column separator of the environmental data file


my $genfile = $default; # name for the optional file with the generation/years info
#my $genfile = $default; # name for the optional file with the generation/years info
my $sep3 = "\t"; #column separator of the file
#my $sep3 = "\t"; #column separator of the file
my $popcol3 = $default; #column with the population info
#my $popcol3 = 1; #column with the population info
my $popgral = 2;   		# population codes that are identical for the same population over the years /generations
#my $popgral = 2;   		# population codes that are identical for the same population over the years /generations
my $samplecol3 = $default; #column with the individual info
#my $samplecol3 = 1; #column with the individual info
my $generationcol = 3;		   #generation/year information column...
#my $generationcol = 3;		   #generation/year information column...
my $first = 1; #first character of the ID with the generation or year info
#my $first = 1; #first character with the generation or year info
my $length = $default; # how many characters of the ID with the generation or year info
#my $length = $default; # how many characters of the ID with the generation or year info

my $missing = 0;		   # covariate value for a group if missing.
#my $miss = 0;		   # covariate value for a group if missing.
#my $miss = median;		   # covariate value for a group if missing.
#my $miss = mean;		   # covariate value for a group if missing.
my $round = 5;		   #number of decimal places to keep
#my $round = 5;		   #number of decimal places to keep
#my $round = "no";		   #number of decimal places to keep
my $method = "cenmedian";		  #method to use the centered value for each group
#my $method = "cenmedian";		  #method to use the centered value for each group
#my $method = "mean";		  #method to use the centered value for each group

#Help!
my %arguments = map { $_ => 1 } @ARGV;
if(exists($arguments{"help"}) || exists($arguments{"--help"}) || exists($arguments{"-help"}) || exists($arguments{"h"}) || exists($arguments{"-h"}) || exists($arguments{"--h"}) || exists($arguments{"--version"})) {
die "\n\n\t   $version   Help Information $changed          
\t-----------------------------------------------------------------------------------------
\n\tThis program will generate a TreeMix / spatpg formated input file.
\tNeeds a VCF file and one or more table files with information about the population, generation/year, and environmental covariable.
\tWill output the input file, the covariable information, and a file with how are populations and generations sorted in the files\n
\t --input / --vcf           Name (or path) of the VCF file. Default: $inputname
\t --infocols                Number of columns of SNP and loci data before de first genotype.
\t                           default: $infocols (CHROM, POS, ID, REF, ALT, QUAL, FILTER, INFO, FORMAT)\n
\t>One file (one single popmap file with individual ID and population, can also include generation/years, and covariables)
\t --popmap                  Name/path to a table file with the information required for each sample. Default: $popgenmap
\t                           one sample per row, individual ID, population ID and generation/year in different columns.
\t                           no headers, or if there are must be commented out (start line with \"#\").
\t --sep                     Column separator in the table file, Default: tab-separated.
\t --indcol                  [int] Position of column with the individual ID information. Default: $samplecol
\t --popcol                  [int] Position of column with the populations IDs for each individual. Default: $popcol
\t                           A population sampled in different years must have the same ppopulation code in all generation/years
\t                           If generation/year data is provided BY POPULATION in another file, then  population codes need to be unique for each population+generation.\n
\t· Environmental covariable data. (Optional) Can be in this --popmap or in --envfile (better if data is given per population).
\t --envcol                  [int] position of column with the environmental covariable data. $envcol\n
\t· Year / Generation data. (Optional) Can be in this --popmap or in --genfile.
\t                           Population code for a same population must be the same in all years/generations.
\t                  Method 1 Column with the generation information from each individual. 
\t --gencol                  [int] position of the column with the year/generation data. No default.\n
\t                  Method 2 Extract generation/year information from sample ID.
\t --first                   [int] position of the first character in the ID with generation/year information. $first
\t --length                  [int] how many characters. If \'--length 0\' will take until the end of the string. $length\n\n
\t>Optional environmental covariable file (only if covariables are not in popmap)
\t --envfile                 Name/path to a table file with environmental covariate data. $environmental
\t                           one sample/pop per row, either no headers or commented out (start line with \"#\").
\t --sep2                    Column separator in the environmental file, Default: tab-separated.
\t --envcol                  [int] Column with the environmental data. Default: $envcol\n
\t Alternative 1 (per population)
\t --popcol2                 [int] Column from --env file with the population ID information. $popcol2
\t                           If values are different for each generation/year, population codes in this column and in popmap
\t                           need to be unique for each population+generation/year, and an additional --genfile with --pogral is needed.\n
\t Alternative 2 (per individual)
\t --indcol2                 [int] Column from --env file with the individual ID information. $samplecol2\n\n
\t>Optional population-generation/year file (only if generations are not in popmap)
\t --genfile                 Name/path to a table file with the generation/years informatio. $genfile
\t                           one sample/pop per row, either no headers or commented out (start line with \"#\").
\t --sep3                    Column separator in the generation/years file, Default: tab-separated.
\t --gencol                  [int] Column with the year/generation information for each individual. Default: $generationcol\n
\t Alternative 1 (per population)
\t --popcol3                 [int] Column from --genfile file with the population ID that matches popmap. $popcol3\
\t                           This population code needs to be unique for each population+generation/year
\t --popgral                 [int] Column from --genfile file with the population ID information. Default: $popgral
\t                           This code needs to be identical for different generation/years of the same population\n
\t Alternative 2 (per individual)
\t --indcol3                 [int] Column from --genfile file with the individual ID information. $samplecol3
\t                           In this case population codes from popmap need to be identical for different generation/years of the same population\n\n
\t>Additionally (when covariable per individual is provided in --popmap or in --envfile)
\t --miss                    Which value output if covariate is missing for a group? Not sure how spatpg deals with missings.
\t                           can be a specific value (0, -9, 1, ...), \"mean\", or \"median\". Default: $missing.
\t --method                  Method to calculate the centered covariate value for each group. Default: $method.
\t                           available methods: \'mean\', \'median\', \'cenmean\', \'cenmedian\'.
\t --round                   Number of decimal places to keep, set to \"no\" if no round up is needed. Default: $round\n\n
\t Usage example\n\t\$ treemix_formater.pl --vcf cleandata.vcf --popmap --indcol 1 --popcol 2 --gencol 3 --envcol 4\n\n
\tIndividual tags within each file should be unique, otherwise only the first onw will be saved.\n\n\tThe output file will be named as the input file but with the extension \".treemix.frq\".\n\tPopulations and generations in the output file will be sorted alphabetically,\n\tif a combination of population-generation is not present in the vcf file \"0,0\" will be input.\n
\tIf using --popcol3 with a different genfile, it must include two columns with differrent population IDs:\n\tone column will be different for each generation/year (as in popmap file), in the other column a population will keep the same code in all years/generations.
\tI did this script to prepare my input files for \'spatpg\' (https://sourceforge.net/projects/spatpg/),\n\tsupposedly spatpg format should fit a TreeMix input file format, but check spatpg manual if you are not sure.
\n\tFor spatpg a file with environmental data per individual can be parsed, group centered values will be calculated.\n\tEnvironmental information can be in the popgen file, in that case just indicate the column with \'--envcol\'.\n\tMethods to calculate the group centered values: mean (average, arithmetic mean), media (middle value of the distribution),\n\tcenmean (group mean after substracting the overall mean), cenmedian (group median after substracting the overall median).\n
\tThis program has been tested with the VCF file generated by \"populations\" (Stacks) and it works well.\n\tThis program has not been tested with other vcf file formats, it should probably work.\n\tThis program has not been tested on animals, but our dog seems ok with it.\n\n";
}






################ PASSING ARGUMENTS
###################################



#CHECK THIS!!!

my $popstring = "not_defined";
use Getopt::Long;

GetOptions( "input=s" => \$inputname,        #   --input
            "vcf=s" => \$inputname,          #   --vcf
            "envfile=s" => \$environmental,      #   --env
            "genfile=s" => \$genfile,      #   --env
            "popmap=s" => \$popgenmap,       #   --popgen
            "sep=s" => \$sep,                #   --sep
            "sep2=s" => \$sep2,              #   --sep2
            "sep3=s" => \$sep3,              #   --sep2
            "indcol=i" => \$samplecol,       #   --indcol
            "indcol2=i" => \$samplecol2,       #   --indcol
            "indcol3=i" => \$samplecol3,       #   --indcol
            "popcol=i" => \$popcol,          #   --popcol
            "popcol2=i" => \$popcol2,          #   --popcol
            "popcol3=i" => \$popcol3,          #   --popcol
            "popgral=i" => \$popgral,          #   --popgral
            "gencol=i" => \$generationcol,   #   --gencol
            "envcol=i" => \$envcol,          #   --envcol
            "first=i" => \$first,          #   --envcol
            "length=i" => \$length,          #   --envcol
            "miss=s" => \$missing,           #   --miss
            "round=s" => \$round,            #   --round
            "method=s" => \$method);         #   --method



###############################################################################################
###############################################################################################

#CHECKING
print "\n";
if ($envcol eq $default) { die "\n\n ERROR!\nNo column with covariate defined (\'--envcol\').\nCheck $version help information: treemix_formater.pl -help\n\n"; }
if ($method ne "average" && $method ne "median" && $method ne "cenmean" && $method ne "cenmedian") { die "\n\n ERROR!\nwrong group centering method for environmental covariate parsed (\'--method $method\')\nCheck $version help information: treemix_formater.pl --h\n\n"; }
if ($environmental eq $default && $genfile eq $default) { print "Environmental data, populations and generations for each ID will be read from $popgenmap\n"; }
if ($environmental ne $default && $genfile eq $default) { print "Environmental data will be read from $environmental, populations and generations for each ID will be read from $popgenmap\n"; }
if ($environmental ne $default && $genfile eq $default && $length eq $default) { print "Environmental data will be read from $environmental, populations and generations for each ID will be read from $popgenmap\n"; }
if ($environmental ne $default && $genfile ne $default && $length eq $default) { print "Environmental data will be read from $environmental, generation/years from $genfile, and populations for each ID will be read from $popgenmap\n"; }
if ($environmental ne $default && $genfile eq $default && $length ne $default) { print "Environmental data will be read from $environmental, generation/years will be extracted from populations defined at $popgenmap\n"; }


### VCF

print "\n$version is reading $inputname...\n";
open my $VCFFILE, '<', $inputname or die "\nUnable to find or open $inputname: $!\n";

#my @samplelist = ();
my %uniquesamp = ();
my %refgenotypes = ();
my $k = 0;
my $amp = 0;
while (<$VCFFILE>) {
	chomp;	#clean "end of line" symbols
	next if /^$/;  		#skip if blank
	next if /^\s*$/;  		#skip if only empty spaces
	my $line = $_;  		#save line
	$line =~ s/\s+$//;  		#clean white tails in lines
	my @wholeline= split("\t", $line);  		#split columns as different elements of an array
	
	next if ($wholeline[0]=~ /^##.*?/);  		#skip first rows with metadata
	
	my $numcolumn = scalar @wholeline;
	my $lastsample = $numcolumn -1;
	
	my @wholegenot = @wholeline[$infocols..$lastsample];
	
	#if ($wholeline[0]=~ /^#.*?/) { @samplelist = @wholegenot; } 		   #save the sample IDs
	if ($wholeline[0]=~ /^#.*?/) { foreach my $samp (@wholegenot) { $uniquesamp{$samp} = $amp; $amp++; } }  		   #save the sample IDs and their position
	else {
		my $this = 0;
		foreach my $onegenot (@wholegenot) {
			$onegenot=~s/(.)\/(.).*?$/$1-$2/;		  #keep only the alleles
			$wholegenot[$this] = $onegenot;
			$this++;
		}
		my $savegenot = join("\t", @wholegenot);
		$refgenotypes{$k} = $savegenot; #save the genotypes
		$k++;
	}
	
}
my $numsnps = $k;


close $VCFFILE;

# save a hash with their position 
#my %uniquesamp = ();
$k = 0;
#foreach my $sample (@samplelist) { $uniquesamp{$sample}=$k; $k++; }
#foreach my $key (keys %uniquesamp) { $uniquesamp{$key}=$k; $k++; }

my $numsamp = scalar keys %uniquesamp;
print "$numsamp samples and $numsnps SNPs saved.\n";

#foreach my $key (keys %uniquesamp) { print "$key "; }
#print "\n\n";

#### POPMAP

print "\nReading $popgenmap";

my $indindx = $samplecol - 1;
my $popindx = $popcol - 1;
my $genindx = $generationcol - 1;
my $covaridx = $envcol - 1;

#my %refgroup_ids = ();
#my %refid_pops = ();
#my %refid_geners = ();
#my %refpops = ();
#my %refgeners = ();

my %uniquepops = ();
my %id_pop = (); #wach out this saves the id as keys and pops as a value for each key
my %refid_groups = ();
my %uniquegeners = ();
my %groups_idindx = ();
my %covarpop = (); #save covar ffrom each pop
my %covarid = (); #wach out this saves the covar by indiv and pop but do not include gen
my %covarvalues = (); #save covariables from each pop_gen


# POPMAP

my @allvalues = ();


if ($genfile ne $default && $environmental ne $default) {
	print "...\n";
	open my $MAP, '<', $popgenmap or die "\nUnable to find or open $popgenmap: $!\n";
	while (<$MAP>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*?/;  		#skip if commented
		my $line = $_;
		my $row = $line;
		$row =~ s/\s+$//;		#clean white tails in lines
		$row =~ s/^\s+//;	#clean white spaces at the beginning
		my @sampledata = split($sep, $row);
		my $id = $sampledata[$indindx];
		my $pop = $sampledata[$popindx];
		#my $gen = $sampledata[$genindx];
		#my $group = "$pop" . "_-_$gen";
		
		#save the information for each sample
		
		if (exists $uniquesamp{$id}) {
			#save the information for each sample (only the ones that are saved at $uniquesamp from vcf)
			#if (exists $refid_groups{$id}) { print "\nWarning!\nThere is more than one row with $id, only first entry was saved.\n"; }  else { $refid_groups{$id} = $group; }
			if (exists $id_pop{$id}) { print "\nWarning!\nThere is more than one row with $id, only first entry was saved.\n"; }  else { $id_pop{$id} = $pop; }
			if (exists $uniquepops{$pop}) { $uniquepops{$pop} = "$uniquepops{$pop}" . "_-_$id"; }  else { $uniquepops{$pop} = $id; }
			#if (exists $uniquegeners{$gen}) { $uniquegeners{$gen} = "$uniquegeners{$gen}" . "_-_$id"; }  else { $uniquegeners{$gen} = $id; }
			#if (exists $groups_idindx{$group}) { $groups_idindx{$group} = "$groups_idindx{$group}" . "-$uniquesamp{$id}"; }  else { $groups_idindx{$group} = $uniquesamp{$id}; }
		}
		
		
		###if (exists $refid_groups{$id}) { print "\nWarning!\nThere is more than one row for $id, only first entry was saved.\n"; }  else { $refid_groups{$id} = $group; }
		###$refid_pops{$id} = $pop;
		###$refid_geners{$id} = $gen;
		
		#save the samples in each group
		###if (exists $refgroup_ids{$group}) { $refgroup_ids{$group} = "$refgroup_ids{$group}" . "_-_$id"; }  else { $refgroup_ids{$group} = $id; }
		
		###if (exists $refpops{$pop}) { $refpops{$pop} = "$refpops{$pop}" . "_-_$id"; }  else { $refpops{$pop} = $id; }
		###if (exists $refgeners{$gen}) { $refgeners{$gen} = "$refgeners{$gen}" . "_-_$id"; }  else { $refgeners{$gen} = $id; }
	}
	close $MAP;
}
elsif ($genfile eq $default && $environmental ne $default) {
	print "...\n";
	open my $MAP, '<', $popgenmap or die "\nUnable to find or open $popgenmap: $!\n";
	while (<$MAP>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*?/;  		#skip if commented
		my $line = $_;
		my $row = $line;
		$row =~ s/\s+$//;		#clean white tails in lines
		$row =~ s/^\s+//;	#clean white spaces at the beginning
		my @sampledata = split($sep, $row);
		my $id = $sampledata[$indindx];
		my $pop = $sampledata[$popindx];
		my $gen = $default;
		if ($length eq $default) { $gen = $sampledata[$genindx]; } else { $gen = substr ($id, $first, $length); }
		my $group = "$pop" . "_-_$gen";
		
		#save the information for each sample
		
		if (exists $uniquesamp{$id}) {
			#save the information for each sample (only the ones that are saved at $uniquesamp from vcf)
			if (exists $id_pop{$id}) { print "\nWarning!\nThere is more than one row with $id, only first entry was saved.\n"; }  else { $id_pop{$id} = $pop; }
			if (exists $uniquepops{$pop}) { $uniquepops{$pop} = "$uniquepops{$pop}" . "_-_$id"; }  else { $uniquepops{$pop} = $id; }
			if (exists $refid_groups{$id}) { print ""; }  else { $refid_groups{$id} = $group; }
			if (exists $uniquegeners{$gen}) { $uniquegeners{$gen} = "$uniquegeners{$gen}" . "_-_$id"; }  else { $uniquegeners{$gen} = $id; }
			if (exists $groups_idindx{$group}) { $groups_idindx{$group} = "$groups_idindx{$group}" . "-$uniquesamp{$id}"; }  else { $groups_idindx{$group} = $uniquesamp{$id}; }
		}
		
		
		###if (exists $refid_groups{$id}) { print "\nWarning!\nThere is more than one row for $id, only first entry was saved.\n"; }  else { $refid_groups{$id} = $group; }
		###$refid_pops{$id} = $pop;
		###$refid_geners{$id} = $gen;
		
		#save the samples in each group
		###if (exists $refgroup_ids{$group}) { $refgroup_ids{$group} = "$refgroup_ids{$group}" . "_-_$id"; }  else { $refgroup_ids{$group} = $id; }
		
		###if (exists $refpops{$pop}) { $refpops{$pop} = "$refpops{$pop}" . "_-_$id"; }  else { $refpops{$pop} = $id; }
		###if (exists $refgeners{$gen}) { $refgeners{$gen} = "$refgeners{$gen}" . "_-_$id"; }  else { $refgeners{$gen} = $id; }
	}
	close $MAP;
}
elsif ($environmental eq $default && $genfile ne $default) {
	print " and reading covariates...\n";
	open my $MAP, '<', $popgenmap or die "\nUnable to find or open $popgenmap: $!\n";
	while (<$MAP>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*?/;  		#skip if commented
		my $line = $_;
		my $row = $line;
		$row =~ s/\s+$//;		#clean white tails in lines
		$row =~ s/^\s+//;	#clean white spaces at the beginning
		my @sampledata = split($sep, $row);
		my $id = $sampledata[$indindx];
		my $pop = $sampledata[$popindx];
		#my $gen = $sampledata[$genindx];
		my $covar = $sampledata[$covaridx];
		#my $group = "$pop" . "_-_$gen";
		
		if (exists $uniquesamp{$id}) {
			#save the information for each sample (only the ones that are saved at $uniquesamp from vcf)
			if (exists $uniquepops{$pop}) { $uniquepops{$pop} = "$uniquepops{$pop}" . "_-_$id"; }  else { $uniquepops{$pop} = $id; }
			if (exists $id_pop{$id}) { print "\nWarning!\nThere is more than one row with $id, only first entry was saved.\n"; }  else { $id_pop{$id} = $pop; }
			#if (exists $refid_groups{$id}) { print "\nWarning!\nThere is more than one row for $id, only first entry was saved.\n"; }  else { $refid_groups{$id} = $group; }
			#if (exists $uniquegeners{$gen}) { $uniquegeners{$gen} = "$uniquegeners{$gen}" . "_-_$id"; }  else { $uniquegeners{$gen} = $id; }
			#if (exists $groups_idindx{$group}) { $groups_idindx{$group} = "$groups_idindx{$group}" . "-$uniquesamp{$id}"; }  else { $groups_idindx{$group} = $uniquesamp{$id}; }
			#if (exists $covarid{$id}) { $covarid{$id} = $covar; }  else { $covarvalues{$group} = $covar; }
			#if (exists $covarvalues{$group}) { $covarvalues{$group} = "$covarvalues{$group}" . "_$covar"; }  else { $covarvalues{$group} = $covar; }
			$covarid{$id} = $covar;
			if (exists $covarpop{$pop}) { $covarpop{$pop} = "$covarpop{$pop}" . "_$covar"; }  else { $covarpop{$pop} = $covar; }
			push (@allvalues, $covar);
		}
	}
	close $MAP;
}
elsif ($environmental eq $default) {
	print " and reading covariates...\n";
	open my $MAP, '<', $popgenmap or die "\nUnable to find or open $popgenmap: $!\n";
	while (<$MAP>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*?/;  		#skip if commented
		my $line = $_;
		my $row = $line;
		$row =~ s/\s+$//;		#clean white tails in lines
		$row =~ s/^\s+//;	#clean white spaces at the beginning
		my @sampledata = split($sep, $row);
		my $id = $sampledata[$indindx];
		my $pop = $sampledata[$popindx];
		my $gen = $default;
		if ($length eq $default) { $gen = $sampledata[$genindx]; } else { $gen = substr ($id, $first, $length); }
		my $covar = $sampledata[$covaridx];
		my $group = "$pop" . "_-_$gen";
		
		
		
		if (exists $uniquesamp{$id}) {
			#save the information for each sample (only the ones that are saved at $uniquesamp from vcf)
			if (exists $id_pop{$id}) { print "\nWarning!\nThere is more than one row with $id, only first entry was saved.\n"; }  else { $id_pop{$id} = $pop; }
			if (exists $uniquepops{$pop}) { $uniquepops{$pop} = "$uniquepops{$pop}" . "_-_$id"; }  else { $uniquepops{$pop} = $id; }
			if (exists $refid_groups{$id}) { print ""; }  else { $refid_groups{$id} = $group; }
			if (exists $uniquegeners{$gen}) { $uniquegeners{$gen} = "$uniquegeners{$gen}" . "_-_$id"; }  else { $uniquegeners{$gen} = $id; }
			if (exists $groups_idindx{$group}) { $groups_idindx{$group} = "$groups_idindx{$group}" . "-$uniquesamp{$id}"; }  else { $groups_idindx{$group} = $uniquesamp{$id}; }
			$covarid{$id} = $covar;
			if (exists $covarpop{$pop}) { $covarpop{$pop} = "$covarpop{$pop}" . "_$covar"; }  else { $covarpop{$pop} = $covar; }
			if (exists $covarvalues{$group}) { $covarvalues{$group} = "$covarvalues{$group}" . "_$covar"; }  else { $covarvalues{$group} = $covar; }
			
			
			push (@allvalues, $covar);
		}
	}
	close $MAP;
}


#file with generations
my %popgens = ();
my %old_idpop = %id_pop;
my %old_uniquepops = %uniquepops;

# generation / year for each indiv
if ($genfile ne $default && $samplecol3 ne $default) {
	
	print "Saving ID - generation/year from $genfile.\n";
	
	open my $GEN, '<', $genfile or die "\nUnable to find or open $genfile: $!\n";

	my $indindx = $samplecol3 - 1;
	my $genindx = $generationcol - 1;

	while (<$GEN>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*?/;  		#skip if commented
		my $line = $_;
		my $row = $line;
		$row =~ s/\s+$//;		#clean white tails in lines
		$row =~ s/^\s+//;	#clean white spaces at the beginning
		
		my @sampledata = split($sep3, $row);
		my $id = $sampledata[$indindx];
		my $gen = $sampledata[$genindx];
		my $group = "$id_pop{$id}" . "_-_$gen";
		
		if (exists $uniquesamp{$id}) {
			#save the information for each group (only the ones that are saved at $uniquesamp from vcf)
			if (exists $refid_groups{$id}) { print "\nWarning!\nThere is more than one row with $id, only first entry was saved.\n"; }  else { $refid_groups{$id} = $group; }
			if (exists $uniquegeners{$gen}) { $uniquegeners{$gen} = "$uniquegeners{$gen}" . "_-_$id"; }  else { $uniquegeners{$gen} = $id; }
			if (exists $groups_idindx{$group}) { $groups_idindx{$group} = "$groups_idindx{$group}" . "-$uniquesamp{$id}"; }  else { $groups_idindx{$group} = $uniquesamp{$id}; }
		}
	}
	
	close $GEN;
}
elsif ($genfile ne $default && $popcol3 ne $default) {
	# generation / year per pop
	
	
	print "Saving pop - generation/year from $genfile.\n";
	
	open my $GEN, '<', $genfile or die "\nUnable to find or open $genfile: $!\n";

	my $popgenindx = $popcol3 - 1;
	my $normpopindx = $popgral - 1;
	my $genindx = $generationcol - 1;

	while (<$GEN>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*?/;  		#skip if commented
		my $line = $_;
		my $row = $line;
		$row =~ s/\s+$//;		#clean white tails in lines
		$row =~ s/^\s+//;	#clean white spaces at the beginning
		
		my @sampledata = split($sep3, $row);
		my $genpop = $sampledata[$popgenindx];
		my $gralpop = $sampledata[$normpopindx];
		my $gen = $sampledata[$genindx];
		my $group = "$gralpop" . "_-_$gen";
		
		if (exists $popgens{$genpop}) { print "\nWarning!\nThere is more than one row with $genpop, only first entry was saved.\n"; }  else { $popgens{$genpop} = $group; }
	}
	
	close $GEN;
	
	#delete uniquepops because is unfixable
	%uniquepops = ();
	
	foreach my $id ( keys %uniquesamp) {
		my $oldpop = $id_pop{$id};
		my $group = $popgens{$oldpop};
		my @grouparray =  split('_-_', $group);
		my $newpop = $grouparray[0];
		my $gen = $grouparray[1];
		
		$id_pop{$id} = $newpop;
		if (exists $uniquepops{$newpop}) { $uniquepops{$newpop} = "$uniquepops{$newpop}" . "_-_$id"; }  else { $uniquepops{$newpop} = $id; }
		#save the information for each group (only the ones that are saved at $uniquesamp from vcf)
		if (exists $refid_groups{$id}) { print "\nWarning!\nThere is more than one row with $id, only first entry was saved.\n"; }  else { $refid_groups{$id} = $group; }
		if (exists $uniquegeners{$gen}) { $uniquegeners{$gen} = "$uniquegeners{$gen}" . "_-_$id"; }  else { $uniquegeners{$gen} = $id; }
		if (exists $groups_idindx{$group}) { $groups_idindx{$group} = "$groups_idindx{$group}" . "-$uniquesamp{$id}"; }  else { $groups_idindx{$group} = $uniquesamp{$id}; }
	}
}





my %covariablespop = ();
#open file with covariates
# covariable for each indiv
if ($environmental ne $default && $samplecol2 ne $default) {
	
	print "Copying covariates from $environmental.\n";
	
	open my $COV, '<', $environmental or die "\nUnable to find or open $environmental: $!\n";

	my $indindx = $samplecol2 - 1;
	my $covindx = $envcol - 1;

	while (<$COV>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*?/;  		#skip if commented
		my $line = $_;
		my $row = $line;
		$row =~ s/\s+$//;		#clean white tails in lines
		$row =~ s/^\s+//;	#clean white spaces at the beginning
		
		my @sampledata = split($sep2, $row);
		my $id = $sampledata[$indindx];
		my $covar = $sampledata[$covindx];
		my $pop = $id_pop{$id};

		if (exists $uniquesamp{$id}) {
			#save the information for each group (only the ones that are saved at $uniquesamp from vcf)
			my $group = $refid_groups{$id};
			push (@allvalues, $covar);
			if (exists $covarvalues{$group}) { $covarvalues{$group} = "$covarvalues{$group}" . "_$covar"; }  else { $covarvalues{$group} = $covar; }
			if (exists $covarpop{$group}) { $covarpop{$pop} = "$covarpop{$pop}" . "_$covar"; }  else { $covarpop{$pop} = $covar; }
			if (exists $covarid{$id}) { print "\nWarning!\nThere is more than one row with $id, only first entry was saved.\n"; }  else { $covarid{$id} = $covar; }
			
		}
	}
	
	close $COV;
}
elsif ($environmental ne $default && $popcol2 ne $default) {
#covariable per population 
	
	print "Copying covariates from $environmental.\n";
	
	open my $COV, '<', $environmental or die "\nUnable to find or open $environmental: $!\n";

	my $popindx = $popcol2 - 1;
	my $covindx = $envcol - 1;
	
	my $countold =  0;
	my $countnew =  0;
	
	while (<$COV>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*?/;  		#skip if commented
		my $line = $_;
		my $row = $line;
		$row =~ s/\s+$//;		#clean white tails in lines
		$row =~ s/^\s+//;	#clean white spaces at the beginning
		
		my @sampledata = split($sep2, $row);
		my $pop = $sampledata[$popindx];
		my $covar = $sampledata[$covindx];
		$covariablespop{$pop} = $covar;
		
		if (exists $old_uniquepops {$pop}) { $countold++; } elsif (exists $uniquepops {$pop}) { $countnew++; } else { print "\nWarning!\nPopulation $pop was not in the vcf file\n"; }
		
	}
	close $COV;
	
	
	if ($countnew >= $countold) {
		# pop names in the covar file are the ones we need for the output file
		foreach my $id ( keys %uniquesamp) {
			#save the information for each group (only the ones that are saved at $uniquesamp from vcf)
			my $thisgroup = $refid_groups{$id};
			my $thispop = $id_pop{$id};
			my $thiscovar = $covariablespop{$thispop};
			$covarpop{$thispop} = $thiscovar;
			$covarid{$id} = $thiscovar;
			$covarvalues{$thisgroup} = $thiscovar;
		}
		
	}
	elsif ($countold > $countnew ) {
		# pop names in the covar file are different for each pop-generation that's cool, but we need the new names
		foreach my $oldpop (keys %popgens) {
			my $group = $popgens{$oldpop};
			my @infoboth = split('_-_', $group);
			my $newpop = $infoboth[0];
			my $covar = $covariablespop{$oldpop};
			$covarvalues{$group} = $covar;
			if (exists $covarpop{$newpop}) { $covarpop{$newpop} = "$covarpop{$newpop}" . "_$covar"; } else { $covarpop{$newpop} = $covar; }
		}
		
		foreach my $id ( keys %uniquesamp) {
			#save the information for each group (only the ones that are saved at $uniquesamp from vcf)
			my $thisgroup = $refid_groups{$id};
			my $thiscovar = $covarvalues{$thisgroup};
			$covarid{$id} = $thiscovar;
		}
	}
}

#check that all samples were in the popmap

my @failed = ();
my $warning = "OK";
my $failcount = 0;

foreach my $key (keys %uniquesamp) {
	my $exists = 0;
	if (exists $refid_groups{$key}) { $exists = 1; }  else { push (@failed, $key); $warning = "NOT OK"; $failcount++; }
}

if ($warning ne "OK") { print "\n WARNING!\n$failcount sample(s) from the VCF file not found at popgen file: @failed\nThose samples would not be accounted for the output file.\n\n"; }

my @listgeners = ();
my @listpops = ();


foreach my $key (sort (keys(%uniquegeners))) { push (@listgeners, "$key"); }
foreach my $key (sort (keys(%uniquepops))) { push (@listpops, "$key"); }

my $numpop = scalar keys %uniquepops;
my $numgener = scalar keys %uniquegeners;

print "VCF file has $numpop populations sampled in $numgener generations.\nPopulations: @listpops\nGenerations: @listgeners\n\n";

my @outputarray = ();
push (@outputarray, "$numpop $numgener $numsnps");

#foreach my $key (keys %groups_idindx) { print "$key "; } 		#just for debuging
#print "\n\n";		#just for debuging

#now print the innformation for each SNP
print "Calculating allele frequencies per population and generation.\nSorting them as: \n";
my @keeptrack = ();

$k = 0;
my $warnings = 0;
my $lastsnp = $numsnps - 1;
foreach my $snp (0..$lastsnp) {
	my @snprow =();
	my $linegenot = $refgenotypes{$snp};
	my @snpalleles = split ("\t", $linegenot);
	foreach my $pop (@listpops) {
		foreach my $gen (@listgeners) {
			my $group = "$pop" . "_-_$gen";
			if ($k == 0) { print "$pop $gen; "; my $popgenprint = "$pop" . "_$gen"; push (@keeptrack, $popgenprint); }
			#if ($k == 0) { print "$pop $gen"; }		#just for debug
			if (exists $groups_idindx{$group}) {
				#print "+ ;";
				my $sampindx = $groups_idindx{$group};
				#print "$sampindx\n";
				my @sampleindexs = split ('-', $sampindx);
				my @genotgroup = ();
					foreach my $index (@sampleindexs) {
						my $onesamp = $snpalleles[$index];
						#print "($onesamp)";
						my @alleles = split ('-', $onesamp);
						push (@genotgroup, "$alleles[0]");
						push (@genotgroup, "$alleles[1]");
					}
				my %allele_count = ('.' => 0, '0' => 0, '1' => 0);
				foreach my $allele (@genotgroup) { $allele_count{$allele} = $allele_count{$allele} + 1; }
				my $nummiss = $allele_count{'.'};
				if ($nummiss > 0) {$warnings = 1; }
				my $block = "$allele_count{0}" . ",$allele_count{1}";
				push (@snprow, "$block");
			}
			else { push (@snprow, "0,0"); }
			#else { push (@snprow, "0,0"); print "- ;";}  		#debug
		}
		if ($k == 0) { print "\n"; }
	}
	my $linesnp = join (' ', @snprow);
	push (@outputarray, $linesnp);
	$k++;
}

if ($warnings == 1) { print "\nWARNING!\nOne or more SNPs have missing values (.), only reference allele (0) and alternative allele (1) will be accounted for.\n"; $warnings++; }

# save file
my $outputname = $inputname;
$outputname =~ s/(.*)\.vcf$/$1\.treemix\.frq/;
$outputname =~ s/(.*)\.VCF$/$1\.treemix\.frq/;


print "\nDone! Saving file $outputname\n";

open my $OUT, '>', $outputname or die "\nUnable to create or save \"$outputname\": $!\n";
foreach (@outputarray) {print $OUT "$_\n";} # Print each entry in our array to the file
close $OUT; 


# covariates
#calculate centered values
my @printcovar = ();

if ($samplecol2 ne $default || $environmental eq $default) {
	
	print "Done! Now computing $method for each group...\n";
	
	
	#global values
	
	my $wholemedian = "none";
	my $totalmedian = "none";
	my $wholemean = "none";
	my $totalmean = "none";
	my $printfinfo = "none";
	
	unless ($round eq "no") { $printfinfo = "%.$round" . "f"; }
	
	if ($method eq "cenmean" || $missing eq "mean") {
		my $summatory = 0;
		my $numvals = scalar @allvalues;
		foreach my $num (@allvalues) { $summatory = $summatory + $num; }
		$wholemean = $summatory / $numvals;
		$totalmean = $wholemean;
		unless ($round eq "no") { $totalmean = sprintf($printfinfo, $wholemean); }
		#print "overall mean: $wholemean\n";		#just for debug
		if ($missing eq "mean") { $missing = $totalmean; }
	}
	
	if ($method eq "cenmedian" || $missing eq "median") {
		my $numvals = scalar @allvalues;
		my @sorted_values = sort {$a <=> $b} @allvalues;
		my $resto = $numvals % 2;
		
		if ($resto == 0) {
			my $sec = $numvals / 2;
			my $fir = $sec - 1;
			
			$wholemedian = ($sorted_values[$fir] + $sorted_values[$sec]) / 2;
		}
		else { my $medinx = int($numvals/2); $wholemedian = $sorted_values[$medinx]; }
		$totalmedian = $wholemedian;
		unless ($round eq "no") { $totalmedian = sprintf($printfinfo, $wholemedian); }
		#print "overall median: $wholemedian\n";		#just for debug
		if ($missing eq "median") { $missing = $totalmedian; }
	}
	
	
	
	#values per group
	
	if ($method eq "cenmedian") {
		foreach my $pop (@listpops) {
			foreach my $gen (@listgeners) {
				my $group = "$pop" . "_-_$gen";
				
				if (exists $covarvalues{$group}) {
					my $envalues = $covarvalues{$group};
					my @groupvalues = split ('_', $envalues);
					
					my $numvals = scalar @groupvalues;
					my @sorted_values = sort {$a <=> $b} @groupvalues;
					
					my $resto = $numvals % 2;
					
					if ($resto == 0) {
						my $sec = $numvals / 2;
						my $fir = $sec - 1;
						
						my $median = ($sorted_values[$fir] + $sorted_values[$sec]) / 2;
						
						my $cenmedian = $median - $wholemedian;
						
						#push (@printcovar, "$group $cenmedian (even)");		#debug
						unless ($round eq "no") { $cenmedian = sprintf($printfinfo, $cenmedian); }
						push (@printcovar, $cenmedian);
					}
					else {
						my $medinx = int($numvals/2);
						my $median = $sorted_values[$medinx];
						my $cenmedian = $median - $wholemedian;
						if ($round == 0) { $cenmedian = sprintf("%.5f", $cenmedian); }
						unless ($round eq "no") { $cenmedian = sprintf($printfinfo, $cenmedian); }
						push (@printcovar, $cenmedian);
						#push (@printcovar, "$group $cenmedian (odd)");		#debug
					}
				}
				else { push (@printcovar, $missing); }
				#else { push (@printcovar, "$group $missing (miss)"); }		#DEBUG
			}
		}
	}
	elsif ($method eq "median") {
		foreach my $pop (@listpops) {
			foreach my $gen (@listgeners) {
				my $group = "$pop" . "_-_$gen";
				
				if (exists $covarvalues{$group}) {
					my $envalues = $covarvalues{$group};
					my @groupvalues = split ('_', $envalues);
					
					my $numvals = scalar @groupvalues;
					my @sorted_values = sort {$a <=> $b} @groupvalues;
					
					my $resto = $numvals % 2;
					
					if ($resto == 0) {
						my $sec = $numvals / 2;
						my $fir = $sec - 1;
						
						my $median = ($sorted_values[$fir] + $sorted_values[$sec]) / 2;
						unless ($round eq "no") { $median = sprintf($printfinfo, $median); }
						push (@printcovar, $median);
					}
					else {
						my $medinx = int($numvals/2);
						my $median = $sorted_values[$medinx];
						unless ($round eq "no") { $median = sprintf($printfinfo, $median); }
						push (@printcovar, $median);
					}
				}
				else { push (@printcovar, $missing); }
			}
		}
	}
	elsif ($method eq "cenmean") {
		foreach my $pop (@listpops) {
			foreach my $gen (@listgeners) {
				my $group = "$pop" . "_-_$gen";
				
				if (exists $covarvalues{$group}) {
					my $envalues = $covarvalues{$group};
					my @groupvalues = split ('_', $envalues);
					
					my $numvals = scalar @groupvalues;
					my $summatory = 0;
					
					foreach my $num (@groupvalues) { $summatory = $summatory + $num; }
					my $mean = $summatory / $numvals;
					my $cenmean = $mean - $wholemean;
					unless ($round eq "no") { $cenmean = sprintf($printfinfo, $cenmean); }
					push (@printcovar, $cenmean);
				}
				else { push (@printcovar, $missing); }
			}
		}
	}
	elsif ($method eq "mean") {
		foreach my $pop (@listpops) {
			foreach my $gen (@listgeners) {
				my $group = "$pop" . "_-_$gen";
				
				if (exists $covarvalues{$group}) {
					my $envalues = $covarvalues{$group};
					my @groupvalues = split ('_', $envalues);
					
					my $numvals = scalar @groupvalues;
					my $summatory = 0;
					
					foreach my $num (@groupvalues) { $summatory = $summatory + $num; }
					my $mean = $summatory / $numvals;
					unless ($round eq "no") { $mean = sprintf($printfinfo, $mean); }
					push (@printcovar, $mean);
				}
				else { push (@printcovar, $missing); }
			}
		}
	}
}
elsif ($popcol2 ne $default) {
	print "\nValues per population suplied, no need to calculate mean or medianof covariables\n";
	
	my $printfinfo = "none";
	unless ($round eq "no") { $printfinfo = "%.$round" . "f"; }
	
	foreach my $pop (@listpops) {
		foreach my $gen (@listgeners) {
			my $group = "$pop" . "_-_$gen";
			if (exists $covarvalues{$group}) {
				my $envalue = $covarvalues{$group};
				my $savecov = $envalue;
				unless ($round eq "no") { $savecov = sprintf($printfinfo, $envalue); }
				push (@printcovar, $savecov);
			}
			else { 
				my $allvalues = $covarpop{$pop};
				my @popvalues = split ('_', $allvalues);
				my $numvals = scalar @popvalues;
				my $inputmiss= 0;
				
				if ($missing eq "mean") {
					my $allvalues = $covarpop{$pop};
					my @popvalues = split ('_', $allvalues);
					my $numvals = scalar @popvalues;
					my $summatory = 0;
					foreach my $num (@popvalues) { $summatory = $summatory + $num; }
					my $mean = $summatory / $numvals;
					$inputmiss = $mean
				}
				elsif ($missing eq "median") {
					my $median = 0;
					my @sorted_values = sort {$a <=> $b} @popvalues;
					my $resto = $numvals % 2;
					
					if ($resto == 0) {
						my $sec = $numvals / 2;
						my $fir = $sec - 1;
						
						$median = ($sorted_values[$fir] + $sorted_values[$sec]) / 2;
						unless ($round eq "no") { $median = sprintf($printfinfo, $median); }
					}
					else {
						my $medinx = int($numvals/2);
						my $median = $sorted_values[$medinx];
						unless ($round eq "no") { $median = sprintf($printfinfo, $median); }
					}
				}
				push (@printcovar, $inputmiss);
			}
		}
	}
}





#save file

my $outcovar = $inputname;
$outcovar =~ s/(.*)\.vcf$/$1\.spatpg\.cov/;
$outcovar =~ s/(.*)\.VCF$/$1\.spatpg\.cov/;

print "Done! Saving covariables as $outcovar\n";

open my $COVT, '>', $outcovar or die "\nUnable to create or save \"$outcovar\": $!\n";
foreach (@printcovar) {print $COVT "$_\n";} # Print each entry in our array to the file
close $COVT; 


#save sorted pop-gen info for reference with outputs
my $outsorted = $inputname;
$outsorted =~ s/(.*)\.vcf$/$1_spatpg_popgen_order/;
$outsorted =~ s/(.*)\.VCF$/$1_spatpg_popgen_order/;

open my $ORDER, '>', $outsorted or die "\nUnable to create or save \"$outsorted\": $!\n";
my $numcomb = scalar @keeptrack;

my $idx = 0;
while ($idx < $numcomb) { print $ORDER "$idx $keeptrack[$idx]\n"; $idx++; }
close $ORDER; 

print "\nAll done! $version finished.\n\n";























