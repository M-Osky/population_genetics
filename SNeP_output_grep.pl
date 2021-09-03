#!/usr/bin/perl
use strict ; use warnings;

# SNeP_output_grep   			# by M'Óscar 
my $version = "SNeP_output_grep.pl";

############################

# Use this script to take the results from different SNeP output files



#######################   PARAMETERS   #########################
# All of them can and should be set from the command line, check the help.

my $def = "default";  # better do not chage this.

my $inputdir = $def;  		# directory with the SNeP output files

my $filter = ".NeAll"; #ending all the files must have in common

my $length = 3; #how many letters from the 

my $ago = 12; #number of different generations to check

my $outname = $def;

#################################################################################################################




#Help!
my %arguments = map { $_ => 1 } @ARGV;
if(exists($arguments{"help"}) || exists($arguments{"--help"}) || exists($arguments{"-help"}) || exists($arguments{"-h"}) || exists($arguments{"--h"})) {
	die "\n\n\t   $version   Help Information\n\t-------------------------------------------------\n
	This program will save a table of Ne estimates from different SNeP outputs.
	Mostly just call the program from the directory with the NeAll files to grep, and it should work.
	\n\tCommand line arguments and defaults:
	--dir                     Name (or path) of the directory with the files. By default the local working diretory.
	--filter                  Something all filenames to read must end in in order to be processed. Default: $filter
	--length                  Number of characters from the beginning of file names to keep as population code. Default: $length
	--ago                     Number of generations ago to grep Ne from. Default: $ago
	--out                     Name for the output file. Otherwise will generate one automatically.\n
	Command line call example:\n\tSNeP_output_grep.pl --input /home/SNeP/out/perpop/ --outname all_pops_Ne.txt\n\n
	We don't have any relationship with SNeP, it is downloable here https:\/\/sourceforge.net\/projects\/snepnetrends\/\n\n\n";
}



################ PASSING ARGUMENTS


use Getopt::Long;

GetOptions( "dir=s" => \$inputdir,    #   --dir
            "filter=s" => \$filter,      #   --filter
            "out=s" => \$outname,      #   --out
            "ago=i" => \$ago,      #   --out
            "length=i" => \$length );   #   --length



#read files

use Cwd qw(cwd);
my $localdir = cwd;

my $dirname = "no default";

if ($inputdir ne $def) { $dirname = $inputdir; }  else { $dirname = $localdir; }

print "\n\n$version is reading files from $dirname\n";

opendir(DIR, $dirname);
my @files = readdir(DIR);
closedir(DIR);



# process the files one by one

my @chosenfiles = ();
my %alldata;
my %refgen;
my %allgen;
my $filenum=1;


foreach my $file (@files) {
	next unless ($file =~ m/^.*$filter$/);
	push (@chosenfiles, $file);
	
	# save population name
	my $popname = substr($file, 0, $length);
	
	print "Reading file from population $popname... ";
	
	my $numgens = 0;
	
	open my $VCFFILE, '<', $file or die "\nUnable to open $file: $!\n";
	
	while (<$VCFFILE>) {
		
		
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*?/;  		#skip comments 
		
		my $line = $_;  		#save line
		
		if ($numgens == 0) {
			$numgens = 1;
		} elsif ($filenum ==1 && $numgens <= $ago) {
			
			my @wholeline= split('\t', $line);  		#split columns as different elements of an array
			
			my $generation = $wholeline[0];
			
			#save generations ago in the corresponding key index
			$refgen{$numgens} = $generation;
			
			#save Ne
			my $Ne = $wholeline[1];
			my $generations = "generations";
			
			#save generations and Ne in an array
			if (exists $allgen{generations}) { $allgen{generations} = "$allgen{generations}" . "\tNe(" . "$generation". ")"; }  else { $allgen{generations} = "Pop\tNe(" . "$generation" . ")"; }
			if (exists $alldata{$popname}) { $alldata{$popname} = "$alldata{$popname}" . "\t" . "$Ne"; }  else { $alldata{$popname} = "$Ne"; }
			
			$numgens++;
			
		} elsif ($numgens <= $ago) {
			
			my @wholeline= split('\t', $line);  		#split columns as different elements of an array
			
			my $generation = $wholeline[0];
			my $Ne = $wholeline[1];
			
			my $origen = $refgen{$numgens};
			
			my $row = $numgens+1;
			
			if ($origen ne $generation) { print "\n\n\n\tWARNING from file $file\n\tIn population $popname the Ne calculated in row $row corresponds with $generation generations ago, not $origen.\n\n\t"; }
			
			if (exists $alldata{$popname}) { $alldata{$popname} = "$alldata{$popname}" . "\t" . "$Ne"; }  else { $alldata{$popname} = "$Ne"; }
			
			$numgens++;
		}
	}
	close $VCFFILE;
	
	$filenum++;
	
	print "done!\n";
	
}

my $totalfiles = scalar @chosenfiles;

print "\n\nAll done!: $totalfiles files processed.\n";


#print information to a file


#get the name of the upper directory
my @directorypath = split('/' , $dirname);
my $pathlength = scalar @directorypath;
my $dir = "no default";
if ($pathlength > 1) { $dir = $directorypath[-1]; }
elsif ($pathlength <= 1) { $dir = $dirname; }


#create an outputname
if ($outname eq $def) { $outname = "SNeP_outputs" . "_$dir" . ".txt"; }


#print generations (headers)
open my $SAVE, '>', $outname or die "\nUnable to create or save \"$outname\": $!\n";
print $SAVE "$allgen{generations}\n"; 

#print Ne estimates per population
foreach my $key (keys %alldata) { print $SAVE "$key\t$alldata{$key}\n"; }

close $SAVE; 

print "Results saved as $outname!\n\n\n";


