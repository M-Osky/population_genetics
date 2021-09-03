#!/usr/bin/perl
use strict ; use warnings;

# tajimaDextract.pl   			# by M'Óscar 24.11.2020 
my $programname = "tajimaDextract.pl";
my $version = "Beta 0.1";
my $date = "24.11.2020";

#run this to extract the numerical values from Tajima D analysis output in vcftools
# call the program with any of the ususal help flags to see usage (--help)




################################################################################################
##############												####################################
##############			Changelog							####################################
##############												####################################
################################################################################################




######## ARGUMENTS ALL CAN AND SHOULD BE INPUT FROM COMMAND LINE, CHECK HELP INFORMATION #######
################################################################################################



my $input = "no default";		  #file with the names we want
my $output = "no default";		  #file with the names we want




################################################
################################################


#Help!

my $helpinfo = "\n\n\t   $programname $version   Help Information $date\n\t-------------------------------------------------\n
	This program will extract the Tajima D values from \'vcftools --TajimaD\' output
	Will print a list of numerical values and some descriptive statistics.\n
	--in                      Output file from VcfTools with Tajima D results to analyse
	                          if a path is parsed will process all files.Tajima.D found
	                          if nothing is parsed will look in the working directory.\n
	--out                     Name for the output file (no extension needed).
	                          if none parsed or there is more than one file to analyse
	                          will name the output files according to the file names
	                          if a path is parsed (must end in \"/\") will be saved there.
	                          output directory will be created if does not exist.\n\n
	In most cases if the vcftools files are kept with their default Tajima.D extension
	just calling the program name should be enough for it to run:\n\t\t$programname
	but can also be adjusted with arguments:
	\t$programname --in /shared/user/files/jangla_mangla_vcftools-tajimad.out --out jangla_mangla_tajimad-summary\n\n";

my %arguments = map { $_ => 1 } @ARGV;
if(exists($arguments{"help"}) || exists($arguments{"--help"}) || exists($arguments{"-help"}) || exists($arguments{"-h"}) || exists($arguments{"--h"})) {
	die "$helpinfo";
}


################ PASSING ARGUMENTS


use Getopt::Long;

GetOptions( "in=s" => \$input,        #   --in
            "out=s" => \$output );       #   --out



############### DIRECTORY PATH

print "$programname $version runing...\n";


use Cwd qw(cwd);
my $localdir = cwd;


use File::Spec;


my $inpath = "menemene";
my $infile = "no default";

#handle files and paths according to the type of input



if ($input eq "no default") {
	$inpath = $localdir;
	print "Reading files in working directory: $inpath\n";
} elsif (-e $input and -d $input) {
	$inpath = $input;
	print "Reading files at: $inpath\n";
} elsif (-e $input) {
	my($vol,$dir,$getfile) = File::Spec->splitpath($input);
	
	if ($dir eq "") {
		$inpath = $localdir;
		$infile = $getfile;
		print "Reading file $infile\n";
	} else { 
		$inpath = $dir;
		$infile = $getfile;
		print "Reading file $infile in $inpath\n";
	}
} else { die "\n\n\n\n\tERROR!\n\n  input file or path parsed does not exist:\n  $input\n  Check the help information to see usage:\n\n\n$helpinfo"; }


#now output names
my $outfile = "no default";
my $isdir = substr ($output, -1);
my $outpath = "no default";

if ($output eq "no default") {
	$outpath = $inpath;
} elsif (-e $output and -d $output) {
	$outpath = $output;
} elsif ($isdir eq "/") { 
	$outpath = $output;
} else {
	my($vol,$dir,$getfile) = File::Spec->splitpath($output);
	if ($dir eq "") {
		$outpath = $localdir;
		$outfile = $getfile;
	} else { 
		$outpath = $dir;
		$outfile = $getfile;
	}
}

unless(-e $outpath or mkdir $outpath) {die "Unable to create output directory $outpath\n"};

# check all TajimaD files if a directory was parsed

my @infiles = ();
my $filenum = "";
#print "\ncheck infile $infile\n\n";

if ($infile eq "no default") {
	opendir(DIR, $inpath);						#open the directory with the files
	my @files = readdir(DIR);					#extract filenames
	closedir(DIR);
	
	# parse all files
	
	foreach my $file (@files) {
		next if ($file =~ /^\.$/);				#don't use any hidden file
		next if ($file =~ /^\.\.$/);			
		if ($file =~ /.*\.Tajima.D$/) { push (@infiles, $file); }		#save only the right files
	}
	
	$filenum = scalar @infiles;
	
	print "$filenum \"Tajima.D\" files found\n\nProcessing...";
} else { push (@infiles, $infile); $filenum = 1; print "\nProcessing..."; }


#check number of files
if ($filenum > 1 && $outfile ne "no default") { 
	print "\n\n\n\tWARNING!\n\tmore than one input file found but a single output name was parsed, will rename outputs acosrding to iput files.\n\n\n";
	$outfile = "no default";
}


my @summarytable = ("file\tn\taverage\tsd\tmin\tmax\tq1\tmedian\tq3");

#process all files

use List::Util qw(min max sum);



my $k=1;
foreach my $file (@infiles) {
	print " $file ($k" . "/" . "$filenum)\n";
	
	my @thisfileinfo = ();
	
	my $filepath = "$inpath/$file";
	
	open my $VCFTOOLSFILE, '<', $filepath or die "\nUnable to find or open $filepath: $!\n";
	my @values = ();
	my $row = 0;
	while (<$VCFTOOLSFILE>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*/;  		#skip commented lines
		
		push (@thisfileinfo, $file);
		
		my $line = $_;  		#save line
		$line =~ s/\s+$//;  		#clean white tails in lines
		
		my @wholeline= split('\t', $line);  		#split columns as different elements of an array
		
		my $tajd = $wholeline[3];  		#extract tajima D
		
		#save only numerical values
		
		if ($tajd ne "nan" && $tajd ne "TajimaD") { push (@values, $tajd); }
		$row++;
	}
	
	my $locinum = scalar @values;
	
	my $rawname = "";
	
	#base name for output
	if ($outfile eq "no default") { 
		$rawname = $file;
		$rawname =~ s/^(.*)\.Tajima\.D$/$1/;
	} else { $rawname = $outfile }
	
	my $fulllist = "$outpath" . "/" . "$rawname" . "_tajimaD_list.txt";
	
	#clean
	$fulllist =~ s/\/\//\//g;
	
	print "saving values at $fulllist\n";
	#save list of values
	open my $LIST, '>', $fulllist or die "\nUnable to create or save \"$fulllist\": $!\n";
	foreach (@values) { print $LIST "$_\n"; } # Print each entry in our array to the file
	close $LIST; 
	
	my $rownum = $row-1;
	
	print "$rownum loci processed, $locinum values saved.\n\n";
	
	#save descriptive statistics to table
	
	my $minimum = min(@values);
	my $maximum = max(@values);
	my $total = sum(@values);
	my $average = $total / $locinum;
	
	
	#calculate quartiles 
	my @sortedvalues = sort {$a <=> $b} @values;
	
	my $q25cut = $locinum*0.25;
	#print "$q25cut\n";
	my $q25pos = sprintf('%.0f', $q25cut) - 1;
	#print "$q25pos\n";
	my $q1 = $sortedvalues[$q25pos];
	#print "$q1\n";
	
	
	
	my $q50cut = $locinum*0.50;
	#print "$q50cut\n";
	my $q50pos = sprintf('%.0f', $q50cut) - 1;
	#print "$q50pos\n";
	my $q2 = $sortedvalues[$q50pos];
	#print "$q2\n";
	
	
	
	my $q75cut = $locinum*0.75;
	#print "$q75cut\n";
	my $q75pos = sprintf('%.0f', $q75cut) - 1;
	#print "$q50pos\n";
	my $q3 = $sortedvalues[$q75pos];
	#print "$q3\n";
	
	
	#calculate SD
	
	my @sumatorium = ();
	foreach my $val (@values) {
		my $added = ($val - $average)**2;
		push (@sumatorium, $added);
	}
	my $totaltop = sum(@sumatorium);
	my $denominator = $locinum - 1;
	my $division = $totaltop / $denominator;
	my $sd = $division**0.5;
	
	my $newdata = "$file\t$locinum\t$average\t$sd\t$minimum\t$maximum\t$q1\t$q2\t$q3";
	push (@summarytable, $newdata);
	
	$k++;
}


#create a name for the general table if needed

if ($outfile eq "no default") {
	
	#date and time
	my $datestring = localtime();
	my @rawdate = split (' ', $datestring);
	my $time = $rawdate[3];
	$time =~ s/://g;
	my $datetime = "$rawdate[-1]$rawdate[1]$rawdate[2]" . "_" . "$time";
	
	#directory name
	my $checkpath = "$outpath";
	$checkpath =~ s/\/\//\//g;
	my @fullpath = split ('/' , $checkpath);
	my $lastlevel = $fullpath[-1];
	
	if ($lastlevel eq "") {
		$lastlevel = $fullpath[-2];
	}
	
	$outfile = "$lastlevel" . "_" . "$datetime";
}


my $fulltable = "$outpath" . "/tajimaD_summaryTable_" . "$outfile" . ".txt";

print "All processed, saving summary table\n$fulltable\n";
#save all values
open my $TABLE, '>', $fulltable or die "\nUnable to create or save \"$fulltable\": $!\n";
foreach (@summarytable) { print $TABLE "$_\n"; } # Print each entry in our array to the file
close $TABLE; 


print "\n\n\tFINISHED!\n\n"






