#!/usr/bin/perl
use strict; use warnings;

# bachsavenames_signif_bayescan.pl by M'Óskar
my $version = "bach_savenames_signif_bayescan_v1.2.pl";
###################################################################################

#This script will extract the loci names from Structure files (one column per locus)
# The first line must be the line with loci names
# then will read all the bayescan fst output files in the folder
# Will add loci names as a column to the bayescan outputs
# and will save a list of those loci that are significant (counsidered outliers)

# my files are named pop1-pop2_relevantinfo_otherstuff_out_fst.txt and pop1-pop2samplesxloci_relevantinfo_otherstuff.str

###################################################################################

my $filter="fst.txt";		#something all the bayescan files to open must have in common
my $pretag = "bayescan_";		#something you want to add to the beginning of the name of the files processed with significant loci names
my $posttag = "_outliers";		#something you want to add to the end of the name of the files processed with significant loci names
my $limit = 0.05;		#p-value limit for considering it significant
my $samechar = 5;		#how many characters at the beginning of a file name must be equal to consider one Structure and one Bayescan file a pair (and different from other pairs)
my $outdir = "out";		#folder that will contain the output files
my $newbay = "_newbayescan";		#tag to add at the end of the name of the new bayes output files created with the loci names
my $strext = ".str";		#something all the structure files (or files with loci names) to open must have in common inthe name
my $wdir = "local working directory";		#directory to process





################################################
################################################


#Help!
my %arguments = map { $_ => 1 } @ARGV;
if(exists($arguments{"help"}) || exists($arguments{"--help"}) || exists($arguments{"-help"}) || exists($arguments{"-h"}) || exists($arguments{"--h"})) {
	die "\n\n\t   $version   Help Information\n\t-------------------------------------------------\n
\twill read all Bayescan Fst output files, select significant loci, and output a list with their names.
\tloci names for each file are taken from Structure files that match the beginning of Bayescan file names
\tfor each bayescan output file will also output a list with locinames instead of positions.\n
\tArguments:
\t--wdir   \t\tdirectory in which the program should run. Default is the local working directory.
\t--input  \t\tending that a Bayescan output file must have in order for it to be processed. Default: $filter
\t--str    \t\tending that a Structure output file must have in order for it to be processed. Default: $strext
\t         \t\t(Structure files can be replaced with any other file with loci names in the first row)
\t--match  \t\t[int] number of characters from the beginning of Structure and Bayescan file names that must match
\t         \t\tfor the program to pair them. Default: at least the first $samechar alphanumeric characters must be identical
\t         \t\t(Some of those characters must be different from all the other pairs of Bayescan - Structure files).
\t--alpha  \t\tlimit to consider an Fst significant. Default: < $limit
\t--out    \t\tname of the directory that will hold output files. Default: $outdir
\t--head   \t\ta tag to add at the beginning of each file with significant loci names. Default: $pretag
\t--tail   \t\ta tag to add at the end of each file with significant loci names. Default: $posttag
\t--newname\t\ttail to add to the Bayescan file name to generate Bayescan file with locinames. Default: $newbay\n
\tExample:\n\t$version --input _out_fst.txt --alpha 0.01 --head bayes_outliera_ --tail \"\" --wdir /home/files\n\n";
}




################ PASSING ARGUMENTS


use Getopt::Long;

GetOptions( "input=s" => \$filter,      #   --oldname
            "wdir=s" => \$wdir,      #   --wdir
            "str=s" => \$strext,      #   --str
            "out=s" => \$outdir,      #   --out
            "head=s" => \$pretag,      #   --head
            "tail=s" => \$posttag,      #   --tail
            "newname=s" => \$newbay,      #   --newname
            "match=i" => \$samechar,      #   --match
            "alpha=f" => \$limit );       #   --apha



use Cwd qw(cwd);
my $localdir = cwd;
my $workingdir = 0;

if ($wdir eq "local working directory") { $workingdir = $localdir; }
else { $workingdir = $wdir; }


print "\n$version is checking files at\n$workingdir\n";


my $sep = "\t";		#column separator for outputs




opendir(DIR, $workingdir);						#open the directory 
my @infiles = readdir(DIR);					#extract filenames
closedir(DIR);


my @strfiles = ();
my @bayesfiles = ();
my $n=0;
foreach my $infile (@infiles) {
	next if ($infile =~ /^\.$/);				#don't use any hidden file
	next if ($infile =~ /^\.\.$/);			
	if ($infile =~ /$filter$/) { push (@bayesfiles, $infile); }		#save the bayescan files
	if ($infile =~ /$strext$/) { push (@strfiles, $infile); }		#save the bayescan files
	$n++;
}

my $bayesnum = scalar @bayesfiles;
my $strnum = scalar @strfiles;

if ($bayesnum != $strnum) { die "\n\nERROR! Number of Bayescan files ($bayesnum) is not equal to number of Structure files ($strnum)\nProgram aborted.\nCheck the help information if needed:\n\t$version -help\n\n"; }

print "$bayesnum files found. \n\n";


# output folder path
my @outpath = split ('/', $outdir);
my $pathlength = scalar @outpath;
my $newfolder = "undefined";

if($pathlength > 1) { $newfolder = $outdir; }
elsif ($pathlength <= 1) { $newfolder = "$workingdir" . "/$outdir"; }

unless(-e $newfolder or mkdir $newfolder) {die "Unable to create the directory \"$newfolder\"\nMay be you don't have the rights: $!\n"; }
print "Output files will be saved at\n$newfolder\nReading files... ";

my $k=0;

foreach my $strfile (@strfiles) {
	my $strpath = $workingdir . "/$strfile";

	if ($k == 0) { print "Saving loci names from $strfile... "; }

	open my $FILESTR, '<', $strpath or die "\nUnable to find or open $strpath: $!\n";

	my $locinames = <$FILESTR>;  #read only the first line
	close $FILESTR;

	$locinames =~ s/\s+$//;		#clean white tails in the line
	$locinames =~ s/^\s+//;

	my @locilist= split('\t', $locinames);		#split columns as different elements of an array
	
	my $locistr = scalar @locilist;
	
	if ($k == 0) { print "Loci names extracted. "; }
	
	#substring the part of the file that should match
	
	my $same = substr ($strfile, 0, $samechar);
	
	#if ($k == 0) { print "Looking bayescan file matching $same \n\n"; }
	
	#select the right bayescan file
	my $thisfile = "no match";
	my $notfound = 0;
	foreach my $bayesfile (@bayesfiles) {
		next unless ($bayesfile =~ /^$same/);		#read only the output files with the outliers information
		$thisfile = $bayesfile;
		$notfound++;
	}
	
	if ($thisfile eq "no match") { die "\n\nERROR! No Bayescan file found ($thisfile) for $strfile\n\n" }
	
	my $bayespath = $workingdir . "/$thisfile";

	if ($k == 0) { print "\nReading Bayescan file $thisfile: "; }
	
	open my $INFILE, '<', $bayespath or die "\nUnable to find or open $bayespath: $!\n";

	#my $fileline = 0;
	my @newbayescan = ();
	my $num = 0;

	#save part of the file name only
	my @splittedname = split('\.' , $thisfile);
	my $ext = $splittedname[-1];
	pop @splittedname;
	my $namekept = join ('.', @splittedname);
	


	#loop over the file to add the column

	#my $newfileline = 0;
	#my @linebayes = ();
	#my $first = 0;

	while (<$INFILE>) {
		chomp;	#clean "end of line" symbols
		
		next if /^(\s*(#.*)?)?$/;   # skip blank lines and comments
		my $fileline = $_;
		$fileline =~ s/\s+$//;		#clean white tails in lines
		my @linebayes = split (' ', $fileline);		#separate the columns of the file
		
		if ($linebayes[-1] eq "fst") { 
			#print "\nheaders: $fileline --> ";
			$fileline =~ s/[ ]{4}/$sep/g;
			$fileline =~ s/[ ]{3}/$sep/g;
			$fileline =~ s/[ ]{2}/$sep/g;
			#$fileline =~ s/\G[ ]*/$sep/g;
			#$fileline =~ s/\G[ ]*/$sep/g;
			my $header = "LociName" . $fileline;
			#$header =~ s/ /$sep/g;
			#print "$header\n\n";
			push (@newbayescan, $header);
			#$first++;
		}
		else {
			#if ($k==0) { print "\npre @linebayes --> $linebayes[0]\n"; }
			my $bayescol = scalar @linebayes;
			my $indexbayes = $bayescol - 1;
			
			my @nopos = @linebayes[1..$indexbayes];
			my @newbayesline = ($locilist[$num], @nopos);
			#if ($k==0) { print "\npost @newbayesline --> $newbayesline[0]\n\n"; }
			my $newfileline = join ($sep, @newbayesline);
			
			#if ($k==0) { print "\n@linebayes --> $linebayes[0]\n"; }
			#shift (@linebayes);		#delete first column with loci number (sorted loci position)
			#unshift (@linebayes, $locilist[$num]);		#add loci name for that position
			#@linebayes = grep /\S/, @linebayes;
			#my $newfileline = join ("\t", @linebayes);
			#if ($k==0) { print "\n@linebayes --> $linebayes[0]\n"; }
			push (@newbayescan, $newfileline);
			$num++;
		}
	}

	close $INFILE;
	
	if ($locistr != $num) { die "\nERROR!: Structure and Bayescan files matching $same do not have the same number of loci\nNumber of loci at Structure file ($locistr) is different from number of loci at Bayescan file ($num)\nCheck the help of the program if needed: $version -help\n\n"; }
	
	#create a new file with the information

	my $bayescanout = "$namekept$newbay.$ext";
	my $savebayes = "$newfolder/$bayescanout";
	open my $SAVE, '>', $savebayes or die "\nUnable to create or save \"$bayescanout\" at $newfolder: $!\n";
	# Loop over the array
	foreach (@newbayescan) {print $SAVE "$_\n";} # Print each entry in our array to the file

	close $SAVE;
	
	
	# Open each bayescan output file
	open my $FILE, '<', $savebayes or die "\nUnable to find or open \"$bayescanout\" at $newfolder: $!\n";

	#my $line = 0;
	#my $numbercols = 0;
	#my $allele = 0;
	#my @newline = ();
	#my $lociname = 0;
	#my $pvalue = 0;
	my $signifloci = 0;
	my $allloci = 0; #1?
	my @locisguays = ();
	
	my @decimal = split ('\.', $limit);
	my $signif = $decimal[-1];
	
	if ($k == 0) { print "Checking p-values...\n"; }
	
	
	while (<$FILE>) {
		chomp;	#clean "end of line" symbols
		next if /^(\s*(#.*)?)?$/;   # skip blank lines and comments
		my $line = $_;
		$line =~ s/\s+$//;		#clean white tails in lines
		
		my @newline= split('\t', $line);	#split columns as different elements of an array
		
		next if $newline[-1] eq "fst";
		
		my $lociname=$newline[0];
		
		my $pvalue = $newline[3];
		
		if ($pvalue < $limit) {
			push (@locisguays, $lociname);
			$signifloci++;
		}
		$allloci++;
	}

	
	my $outname = "$pretag$namekept$signif$posttag";
	if ($k == 0) { print "Saving names of $signifloci loci (from a total of $allloci) as $outname\n"; }
	my $outpath = "$newfolder/$outname";
	open my $OUT, '>', $outpath or die "\nUnable to create or save $outname at $newfolder: $!\n";

	# Loop over the array
	foreach (@locisguays) {print $OUT "$_\n";} # Print each entry in our array to the file


	close $OUT;
	
	my $rest = $bayesnum - ($k + 1);
	
	if ($k == 0) { print "\nFile 1 of $bayesnum saved, now processing the $rest left\n"; }
	elsif ($k >= 1) { print "Files matching $same processed, $signifloci significant loci of $allloci saved\n"; }
	$k++;
	
}

print "\n\nNames of outliers from all files saved.\n$version is done!\n\n";

