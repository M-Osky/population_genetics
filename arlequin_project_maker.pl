#!/usr/bin/perl
use strict; use warnings;

# arlequin_makeproject.pl by M'Óskar
my $version = "arlequin_project_maker.pl";
###################################################################################

#This script will take an arlequin input file and make a one pop per group project file
#check the help information if needed.

###################################################################################

my $dirin = "arlfiles";
my $dirout = "arlproject";
my $match = ".arp";






################################################
################################################


#Help!
my %arguments = map { $_ => 1 } @ARGV;
if(exists($arguments{"help"}) || exists($arguments{"--help"}) || exists($arguments{"-help"}) || exists($arguments{"-h"}) || exists($arguments{"--h"})) {
die "\n\n\t   $version   Help Information\n\t-------------------------------------------------\n
\tTransform all arlequin input files (.arp) in a directory to a one-sample-per-group project (sample = population)\n
\t--input     \tname of the directory with the input files
\t--filter    \tsomething that all files must have in common in order to be processed. Default: $match
\t--out       \tname for the output directory for all the project files.\n\n";
}


################ PASSING ARGUMENTS


use Getopt::Long;

GetOptions( "input=s" => \$dirin,      #   --input
            "filter=s" => \$match,      #   --filter
            "out=s" => \$dirout );       #   --out



use Cwd qw(cwd);
my $localdir = cwd;

my @inlong = split ('/', $dirin);
my @outlong = split ('/', $dirout);
my $outlength = scalar @outlong;
my $inlength = scalar @inlong;
my $pathdirin = "no default";
my $pathdirout = "no default";

#filepath
if ($inlength > 1 && $outlength > 1) { $pathdirin = "$dirin"; $pathdirout = "$dirout"; }
elsif ($inlength <= 1 && $outlength <= 1) { $pathdirin = "$localdir/$dirin"; $pathdirout = "$localdir/$dirout"; }
elsif ($inlength > 1 && $outlength <= 1) { $pathdirin = "$dirin"; $pathdirout = "$dirin/$dirout"; }
elsif ($inlength <= 1 && $outlength > 1) { $pathdirin = "$localdir/$dirin"; $pathdirout = "$dirout"; }

print "\n$version is checking files at\n$pathdirin\n";

opendir(DIR, $pathdirin);						#open the directory 
my @infiles = readdir(DIR);					#extract filenames
closedir(DIR);


my @arlfiles = ();
foreach my $infile (@infiles) {
	next if ($infile =~ /^\.$/);				#don't use any hidden file
	next if ($infile =~ /^\.\.$/);			
	if ($infile =~ /$match$/) { push (@arlfiles, $infile); }		#save the arlequin files
}

my $arlnum = scalar @arlfiles;

if ($arlnum == 0) { die "\n\nERROR! No files found matching \"$match\" at $dirin\nProgram aborted.\nCheck the help information if needed:\n\t$version -help\n\n"; }

print "$arlnum files found. \n";


# output folder path
unless(-e $pathdirout or mkdir $pathdirout) {die "Unable to create the directory \"$dirout\"\nMay be you don't have the rights: $!\n"; }
print "Output files will be saved at\n$pathdirout\nReading files...\n\n";

my $k=0;

foreach my $arlfile (@arlfiles) {
	my $arlinpath = "$pathdirin/$arlfile";

	if ($k == 0) { print "Reading $arlfile... "; }

	open my $ARLIN, '<', $arlinpath or die "\nUnable to find or open $arlinpath: $!\n";
	
	my @dataarl = ();
	my @populations = ();
	
	while (<$ARLIN>) {
		chomp;	#clean "end of line" symbols
		my $fileline = $_;
		if ($fileline =~ /^(\s*(#.*)?)?$/) {$fileline = "EMPTY"; }   # skip blank lines and comments
		my $clean = $fileline;
		$clean =~ s/\s+$//;		#clean white tails in lines
		$clean =~ s/^\s+//;
		my @linearl = split (' ', $fileline);		#separate the columns of the file
		
		#save population names
		if ($linearl[0] eq "SampleName") { my $pop = $linearl[2]; push (@populations, $pop); }
		
		push (@dataarl, $fileline);
	}
	close $ARLIN;
	
	my $popnum = scalar @populations;
	
	
	my @structure = ("EMPTY", "\t[[Structure]]", "EMPTY", "\t\tStructureName=\"New Edited Structure\"", "\t\tNbGroups=$popnum", "EMPTY",);
	
	#save structure info from each population
	my @outarl = (@dataarl, @structure);
	
	#if ($k == 1) { print "$popnum populations found, writting arlequin project structure... "; }
	
	foreach my $population (@populations) {
		my @popinfo = ("\t\tGroup={", "\t\t\t$population", "\t\t}", "EMPTY");
		@outarl = (@outarl, @popinfo);
	}
	
	push (@outarl, "EMPTY");
	
	#out name
	my @arllong = split ('\.', $arlfile);
	#if ($k == 1) { print "\nfilename = $arlfile, keep $arllong[0]\n"; }
	my $arlname = "$arllong[0]" . "_proj.arp";
	my $arloutpath = "$pathdirout/$arlname";
	open my $SAVE, '>', $arloutpath or die "\nUnable to create or save \"$arlname\" at $pathdirout: $!\n";
	# Loop over the array
	foreach my $line (@outarl) {
		$line =~s/EMPTY/\r/;
		$line =~s/(.*?)$/$1\r/;
		$line =~s/(.*?)\r\r/$1\r/;
		print $SAVE "$line\n";
	} # Print each entry in our array to the file
	
	close $SAVE;
	
	if ($k == 0) { print "$popnum populations saved as arlequin project structure!\n\n"; }
	
	$k++;
	print "$k of $arlnum done. Saved as $arlname\n";
}

print "All files done!\n\n$version finished\n\n";