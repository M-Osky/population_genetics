#!/usr/bin/perl
use strict; use warnings;

# ped_fixer.pl   			# by M'Óskar
my $version = "ped_fixer.pl";

# use this to add some relevant information to a ped file. Call help to see the options










###########################################################################################################################
###########################################################################################################################
###########################################################################################################################

## PARAMETER DEFAULTS (CHANGE FROM COMMAND LINE)

my $default = "No default";    		#do not change this
#my $default = "No default";    		#do not change this

my $pedmap = $default;    		#file with the information to add to the ped file
#my $pedmap = $default;    		#file with the information to add to the ped file
#my $pedmap = "pop_sex_table.txt";    		#file with the information to add to the ped file

my $pedfile = $default;    		#ped file to modify
#my $pedfile = $default;    		#ped file to modify
#my $pedfile = "*\.ped";    		#ped file to modify

my $sep = "\t";    		#column separator
#my $sep = "\t";    		#column separator
#my $sep = ",";    		#column separator

my $tail = "_backup";    		#tail to add at the end of the file name to save a backup
#my $tail = "_backup";    		#tail to add at the end of the file name to save a backup
#my $tail = ".bkp";    		#tail to add at the end of the file name to save a backup


###########################################################################################################################
###########################################################################################################################



#Help!
my %arguments = map { $_ => 1 } @ARGV;
if(exists($arguments{"help"}) || exists($arguments{"--help"}) || exists($arguments{"-help"}) || exists($arguments{"-h"}) || exists($arguments{"--h"}) || exists($arguments{"h"})) {
	die "\n\n\t   $version   Help Information\n\t-------------------------------------------------\n
\tThis script will replace the first six columns from a .ped file with some information from another table file
\tThe individual codes in the second column from the ped file (within family ID) must be at the first column of the table file
\tif one individual code is not found in the table the values at the ped file will be let as they were. A warning will be output.\n\n
\tParameters:\n
\t  --ped               \tname of the ped file, if none is provided, will open the first \".ped\" file found\n
\t  --map               \tname of the table with the information to be added. The format should be as in the ped file (check Plink manual).
\t                      \tno headers or must be commented out (#), one row per sample, at least six columns:
\t                      \tfamily ID (pop); individual ID; paternal ID; Maternal ID; sex; phenotype; other. $pedmap\n
\t  --sep               \tcolumn separator of the table with the information. Tab-separated by default.\n
\t  --tail              \ttail to add to the original ped file name when backing it up. Default: $tail
\t                      \twill be added before the \".ped\" extension unless the tail is a new extension (stars with a dot).\n\n
\t  Example:    \tped_fixer.pl --pedmap data_raw_30SNPx85samp.ped --pedmap table_ID_sex.csv --sep \',\' --tail .bkp\n\n";
}



###########################################################################################################################
###########################################################################################################################

print "\nRunning $version\n";

use Getopt::Long;

GetOptions( "ped=s" => \$pedfile,      # --pedfile
            "map=s" => \$pedmap,      # --pedmap
            "sep=s" => \$sep,    # --sep
            "tail=s" => \$tail, );    # --tail


###########################################################################################################################
###########################################################################################################################



if ($pedmap eq $default) { die "\n\tERROR!\n   No table with the information to add found. Not my fault, I didn't find it because none was provided with --pedmap\n   I cannot work like this... check the help information: ped_fixer.pl  help\n\n"; }


use Cwd qw(cwd);
my $localdir = cwd;																								######

# find the first ped file if none parsed
if ($pedfile eq $default) { 
	print "\nWarning!\nNo \".ped\" file parsed, will open the first ped file found in the working directory... \n";
	
	opendir(DIR, $localdir);						#open the directory 
	my @infiles = readdir(DIR);					#extract filenames
	closedir(DIR);
	
	foreach my $file (@infiles) {					#process all the files one by one
		next if ($file =~ /^\.$/);				#don't use any hidden file
		next if ($file =~ /^\.\.$/);			
		if ($file =~ /(.*)\.ped$/) { $pedfile = $file; }
	}
}


if ($pedfile eq $default) { die "\n\tERROR!\n   No \".ped\" file found at $localdir\n   In order to add information to a ped file, I need a ped file... Makes sense?\n   Check the help information: ped_fixer.pl --h\n\n"; }



print "Backing up $pedfile as ";

#create backup file name
my $backup = "default_backup";
if ($tail =~ /^\.(.*)/) { 
	my $pedname = $pedfile;
	$pedname =~ s/^(.*)\.(.*)$/$1_$2/;
	$backup = "$pedname$tail";
}
else {
	my @pedparts = split('\.', $pedfile);
	#print "\n$pedfile parts: @pedparts\n";
	pop @pedparts;
	my $namefile = join ('.', @pedparts);
	$backup = "$namefile$tail.ped";
}

print "$backup\n";

system("cp $pedfile $backup");


print "Reading $pedmap\n";
# get the data from the table

open my $MAP, '<', $pedmap or die "\nUnable to find or open $pedmap: $!\n";

my %newinfo = ();

while (<$MAP>) {
	chomp;	#clean "end of line" symbols
	next if /^(\s*(#.*)?)?$/;   # skip blank lines and comments
	my $line = $_;
	$line =~ s/\s+$//;		#clean white tails in lines
	my @lineinfo = split ($sep, $line);
	my $newkey = $lineinfo[1];
	$newinfo{$newkey}="$lineinfo[0]$sep$lineinfo[1]$sep$lineinfo[2]$sep$lineinfo[3]$sep$lineinfo[4]$sep$lineinfo[5]";
}

close $MAP;




print "Processing $pedfile\n";
# get the data from the ped file

open my $PED, '<', $pedfile or die "\nUnable to find or open $pedfile: $!\n";

my %pedinfo = ();

while (<$PED>) {
	chomp;	#clean "end of line" symbols
	next if /^(\s*(#.*)?)?$/;   # skip blank lines and comments
	my $line = $_;
	$line =~ s/\s+$//;		#clean white tails in lines
	my @lineinfo = split (" ", $line);
	my $code = $lineinfo[1];
	$pedinfo{$code}="$line";
}

close $PED;




print "Replacing sample information...\n";
# do the thing
my $k = 0;
my %finalped = ();
foreach my $sample (keys %pedinfo) {
	my $sampledata = $pedinfo{$sample};
	my @allinfo = split (" ", $sampledata);
	
	if (exists $newinfo{$sample}) {
		my $newdata = $newinfo{$sample};
		my @allnew = split ($sep, $newdata);
		
		$allinfo[0] = $allnew[0];
		$allinfo[2] = $allnew[2];
		$allinfo[3] = $allnew[3];
		$allinfo[4] = $allnew[4];
		$allinfo[5] = $allnew[5];
		$k++;
	}
	else { print "sample $sample not found in pedmap table\n"; }
	my $newline = join (" ", @allinfo);
	$finalped{$sample} = $newline;
}

print "\nInformation replaced in $k samples, now saving the file.\n";

open my $FIXED, '>', $pedfile or die "\nUnable to overwrite or save \"$pedfile\": $!\n";


foreach my $id (sort keys %finalped) {
	printf $FIXED "$finalped{$id}\n";
}

close $FIXED; 

print "$pedfile has been overwritted with the new information.\nDone!\n\n";

#die "\n\nDebugin\n\n";















