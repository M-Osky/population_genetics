#!/usr/bin/perl
use strict;
use warnings;


# admixture_bachmaker   			# by M'Óscar 
my $version = "admixture_bachmaker_v1.2.pl";
my $edited ="2020/09/14";

############################

# This will make a submission file for every K and grep the cross validated error values.
# will also create a series of scripts to submit all admixture jobs
# Check the help if needed: admixture_bachmaker.pl -help



##############################################################################################
######################    admixture_bachmaker.pl  Changelog    ###############################
######																					######
######		Vesion 1.2 - 14/09/2020														######
######		added some default options, edited mv files for it to be more specific, 	######
######		now only moves each K outputs, not all at once.								######
######		Now it also greps log likelihood											######
######																					######
######		Vesion 1.1 - 25/06/2020														######
######		Added many new options, new parameters, project, exclusivity, and grep cv	######
######																					######
######		Vesion 1.0 - 23/05/2020														######
######		Did the real program whith options											######
######																					######
##############################################################################################
##############################################################################################













###### GLOBAL PARAMETERS THAT COULD NEED TO BE EDIT (Program locations)
######  Everything else should be set from command line


# path to admixture program
my $programpath = "/shared/astambuk/bin/anaconda2/bin";
my $programfile = "admixture";  





########################### COMMAND LINE PARAMETER DEFAULTS


my $not_set = "No default";    # don't touch this
#my $not_set = "No default";    # don't touch this

# K
my $k_max = 4;
#my $k_max = 4;
my $k_min = 2;
#my $k_min = 3;
#will be incremented by adding +1

# default admixture settings
my $admixture = "--cv -s time";
#my $admixture = "--cv";

#extra arguments to parse
my $extraoptions = $not_set;
#my $extraoptions = "-c 0.0001";

# Your email address
my $emailaddress = 'example@biol.pmf.hr';
#my $emailaddress = 'oscar.mira@biol.pmf.hr';

# Number of cores to use
my $cores = 1;
#my $cores = 1;
#my $cores = 16;

#project to assign the run to 
my $project = $not_set;

#share cores?
my $exclusive = 0;

# A prefix for the submission file names
my $name = "admix";

# Set the name of the output folder that will include each output subdirectory from each job (once they are submited)
my $outfolder = "out";

# Requested memory
my $memo = "20G";
#my $memo = "20G";

# bed Input file name full path unless are in the working directory
my $input = $not_set;
#my $input = $not_set;
#my $input = "*.bed";

#  subirectory to store the submission files this script will produce
my $directory = "submissionfiles";

#number of replicates for each job (not sure if needed)
my $replicates = 1;

#edit the input file chromosome names?
my $editchrom = 0;


######################################################################################################
######################################################################################################

my $defemail = 'example@biol.pmf.hr';

#Help!
my %arguments = map { $_ => 1 } @ARGV;
if(exists($arguments{"help"}) || exists($arguments{"--help"}) || exists($arguments{"-help"}) || exists($arguments{"h"}) || exists($arguments{"-h"}) || exists($arguments{"--h"})) {
	die "\n\n\t   $version   Help Information   $edited\n\t-------------------------------------------------\n
	Use this program to generate multiple Admixture job submission files with for a range of K values.
	It will also generate a bash script to submit all the submission files
	and another to send all the log files from each job to the output directory and extract the cross validation results\n
	\n\tCommand line arguments and defaults:\n
	Submission parameters
	--cores                   [int] number of threads (mpi). Around 16 should be fine. Default: $cores
	--greedy                  [flag] Add this flag if you want the whole core for yourself (\"exclusive\")
	--memo                    Requested memory for the job. Default: $memo
	--mail                    email address for Isabella to notify you. Example: $emailaddress
	--project                 To which project you want the job to be assigned? Add the code. $project
	--subname                 prefix for all submission file names. Default: $name
	--dirsub                  subdirectory that will hold all the submission files created. Default: $directory\n
	Admixture directories and files
	--input                   full path/name of your input file.bed; $input
	--editbim                 [flag] add this flag to delete the \"Scaffold\" that precedes scaffold numbers in the bim file.
	--outdir                  directory path to send Admixture results from all runs, will be created if it does not exist.
	                          output files will be created in the working directory, but move there afterwards. Default: $outfolder\n
	--k_min                   [int] minimum value of K (number of clusters) to test. Default: $k_min
	--k_max                   [int] maximum value of K to test. Default: $k_max
	--replicates              [int] numbers of runs with the same parameters for each K value. Default: $replicates\n
	other Admixture parameters.
	All submission files will run with the option \'$admixture\' (change with --main)
	--extra                   Extra options to add to each run. Use \' \'. Example: \'-c 0.0001\'. Default: $extraoptions\n
	Example:\n\tadmixture_bachmaker.pl --input data/mytrial_file.bed --oudir data/out --k_max 42\n\n
	*We have no relation with Admixture, check their help information (ex: admixture --help)
	 Any doubt about it should be addressed to the authors. http:\/\/software.genetics.ucla.edu\/admixture
	 This software was not tested on animals, but the boss' dog seems to be OK with it.\n\n\n";
}



#my $popstring = "not_defined";
use Getopt::Long;

GetOptions( "cores=i" => \$cores,      #   --cores
            "memo=s" => \$memo,      #   --memo
            "mail=s" => \$emailaddress,      #   --mail
            "subname=s" => \$name,      #   --subname
            "dirsub=s" => \$directory,      #   --directory
            "input=s" => \$input,      #   --input
			"main=s" => \$admixture,       #   --main
            "project=s" => \$project,      #   --project
            "extra=s" => \$extraoptions,      #   --extra
            "outdir=s" => \$outfolder,      #   --outdir
            "editbim" => \$editchrom,      #   --editbim
            "greedy" => \$exclusive,      #   --exclusive
            "replicates=i" => \$replicates,      #   --replicates
            "k_min=i" => \$k_min,      #   --k_min
            "k_max=i" => \$k_max);      #   --k_max);   #   --gral_miss


if ($input eq $not_set) { die "\n\n ERROR!\nNo input file parsed (--input file.bed). Check help information: admixture_bacjmaker.pl --h\n\n"; }

print "\nRunning $version. Submission files will be stored at: $directory\n";
#if ($popmap eq "popmap") { print "Command line options parsed, will look for popmap at working directory.\n\n"; }



my $notification = "Nothing set on this variable, wtf??";
if ($emailaddress eq $defemail) { $notification ="## ## ## No email was set, you will not be notified or emailed when the job starts/ends.\n"}
else {$notification = "#\$ -m abe\t\t\t\t\t\t\#report beginning, end, and aborted\n#\$ -M $emailaddress \t\t#email me\n"}

if ($editchrom == 1) {
	my $bim = $input;
	#get bim file name from bed file name
	$bim =~ s/(.*)\.bed/$1.bim/;
	print "Detected flag \'--editbim\', editing $bim\n";
	
	#open
	open my $BIMF, '<', $bim or die "\nUnable to open or edit $bim: $!\n";
	
	#backup
	system ("mv $bim backup_$bim");
	
	my @newbim = ();
	
	while (<$BIMF>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		my $line = $_;  		#save line
		$line =~ s/\s+$//;  		#clean white tails in lines
		$line =~ s/^Scaffold(.*$)/$1/; #delete "Scaffold"
		push (@newbim, $line);
	}
	close $BIMF;
	
	#save
	open my $NBIM, '>', $bim or die "\nUnable to open or overwrite $bim: $!\n";
	foreach my $row (@newbim) { print $NBIM "$row\n"; } # print each entry to file
	close $NBIM;
	print "Done!\n\n";
}

my $printcores = "-pe *mpisingle ";
if ($exclusive == 1) {
	print "Detected flag \'--greedy\', Admixture will use the cores in exclusivity\n\n";
	#$printcores = "-l exclusive=";
	$printcores = "-pe *mpifull ";
}





use Cwd qw(cwd);
my $dir = cwd;																								######

my $checkroot = substr ($directory, 0, 1);
my $dirbase1 = "none";

if ($checkroot eq "/") { $dirbase1 = ""; }
else { $dirbase1 = "$dir" . "/" }

$checkroot = substr ($outfolder, 0, 1);
my $dirbase2 = "none";

if ($checkroot eq "/") { $dirbase2 = ""; }
else { $dirbase2 = "$dir" . "/" }

unless(-e $directory or mkdir $directory) {die "Unable to create output directory $directory\n"};


#file to gather all cross validated error values
my $cv_values = "choose_Kcv.txt";
my $lk_values = "choose_Klk.txt";

my $count = 0;
my $cluster = $k_min;
my @alljobs = ("#!/bin/bash", "# launch_them_all.sh", "# quick script to submit all your admixture jobs at once", "# just \"bash\" or \"./\" this file", "\n", "#Jobs:");
my @movethemall = ("#!/bin/bash", "# clean_them_all.sh", "# quick script to move all the admixture_subjob.sh.o4815162342, admixture_subjob.sh.po4815162342 log files to the folders where the output files are at, and to extract cross validated values.", "# just \"bash\" or \"./\" this file after all the jobs finish\n", "touch $cv_values", "touch $lk_values");



until ($cluster > $k_max) {
	my $rep = 1;
	until ($rep > $replicates) {
		#create name for the submission file
		my $submissionname = $name;
		if ($replicates == 1) { $submissionname = "$name" . "_k" . "$cluster" . "submit.sh"; }
		else { $submissionname = "$name" . "_k" . "$cluster" . "_" . "$rep" . "submit.sh"; }
		my $filepath ="$dirbase1"."$directory"."/"."$submissionname";														######fullpath
		$filepath =~ s/\/\//\//g;
		# Use the open() function to create the submission file.
		open my $FILE, '>', $filepath or die "\nUnable to create $filepath: $!\n";######fullpath
		
		my $outdir = "$dirbase2" . "$outfolder";
		$outdir =~ s/\/\//\//g;
		# Write text to the file.
		print $FILE "#!/bin/bash\n#\n# #$submissionname\n# Isabella submission file for Admixture\n";
		print $FILE "\n\n#\$ -cwd\t\t\t\t\t\t\t#print wd\n";
		print $FILE "#\$ -j y\t\t\t\t\t\t\t#report errors\n";
		print $FILE "$notification";
		
		if ($project eq $not_set) { print $FILE "## #job will be assigned to the last used project\n"; }
		else { print $FILE "#\$ -P $project\n"; }
		
		print $FILE "#\$ $printcores$cores\t\t\t\t\#$cores CPU\n#\$ -l h_vmem=$memo\t\t\t\t#Request memory\n\n";
		print $FILE "#set -e\n#set -u\n\n#CHR=\$SGE_TASK_ID\n\n";
		print $FILE "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/lib:/shared/astambuk/bin/lib:/shared/astambuk/bin/bin:/shared/astambuk/bin/lib64:/shared/astambuk/bin/gcc8.2/lib64:/shared/astambuk/bin/gcc8.2/lib:/shared/astambuk/bin/gcc8.2/bin:/shared/astambuk/bin/anaconda2:/shared/astambuk/bin/anaconda2/bin:$programpath\n";
		print $FILE "export PATH=\$PATH:/shared/astambuk/bin/anaconda2:/shared/astambuk/bin/anaconda2/bin:$programpath\n";
		print $FILE "\n\n#Checking and creating output directories\n\n";
		print $FILE "if [ -d \"$outdir\" ]\nthen\n\tprintf \"Already existing sub-directory will be used as output directory: $outdir\\n\"\n";
		print $FILE "else\n\tmkdir -p \"$outdir\"\nfi\n\n\n";
		print $FILE "#Run Admixture\n\n";
		
		if ($extraoptions eq $not_set) { print $FILE "$programpath"."/"."$programfile $admixture -j$cores $input $cluster\n\n"; }
		else { print $FILE "$programpath"."/"."$programfile $admixture $extraoptions -j$cores $input $cluster\n\n"; }
		
		print $FILE "mv *$cluster.P* $outdir\n";
		print $FILE "mv *$cluster.Q* $outdir\n\n";
		# close the file.
		close $FILE;
		print "$submissionname created\n";
		#save the job name and the submission command
		my $currentjob = "qsub $filepath";
		push (@alljobs, "");
		push (@alljobs, $currentjob);
		
		my $movingfiles = "grep CV $submissionname.o* >> $cv_values\nprintf \"K$cluster\\t\" >> $lk_values\ngrep ^Loglikelihood: $submissionname.o* >> $lk_values\n\nmv $submissionname.* $outdir\nmv $filepath $outdir\n";
		push (@movethemall, $movingfiles);
		
		
		$count++;
		$rep++;
	}
	$cluster++;
}


print "\n $count submission files with different Ks (or replicates) were created!\n\n";

my $launcher = "$dir" . "/" . "launch_them_all.sh";
my $bachmv = "$dir" . "/" . "tidy_them_all.sh";

#create a short script for submiting a bunch of similar jobs at once
open my $JOB, '>', $launcher or die "\nUnable to create $launcher: $!\n";
foreach (@alljobs) {print $JOB "$_\n";} # Print each entry in our array to the file
print $JOB "\n\nprintf \"\\nAll submited!\\n\\n\"\n";
close $JOB;

#create a short script for moving all the qsub job logfiles to their output directory
open my $LOG, '>', $bachmv or die "\nUnable to create $bachmv: $!\n";
foreach (@movethemall) {print $LOG "$_\n";} # Print each entry in our array to the file
print $LOG "\n\nprintf \"\\nAll moved/grepped!\\n\\n\"\n";
close $LOG;


print "created \"launch_them_all.sh\" and \"tidy_them_all\": one script to submit them all, and one to take their values, move them all, and in the darkness bind them.\n";
print "\nAll done!\n\n";



