#!/usr/bin/perl
use strict;
use warnings;


# refmap_bachmaker   			# by M'Óscar 
my $version = "refmap_bachmaker_v1.6.pl";


############################

# This will make a submission file for every combination of max-obs-het, min-maf, r and p parameters of populations in ref_map.pl
# will also produce a submission file to run vcf_fixer for each output.
# will also create a series of scripts to submit all refmap jobs
# Check the help if needed: refmap_bachmaker.pl -help














###########################################################################################################################
###############    Chagelog:                                                                       ########################
###############                                                                                    ########################
###############     Version 1.6: 2020-06-02                                                        ########################
###############    added new parameter options R and project code for submission                   ########################
###############                                                                                    ########################
###############     Version 1.5: 2020-04-03                                                        ########################
###############    vcf_fixer was overloading the node, submision script was edited as requested    ########################
###############                                                                                    ########################
###############     Version 1.4: 2020-04-02                                                        ########################
###############    fixed extra options for populations, fixed m_min and m_max now deffault is 0    ########################
###############                                                                                    ########################
###############     Version 1.3: 2020-03-12                                                        ########################
###############    as vcf_fixer takes long now it will do its own submission file                  ########################
###############                                                                                    ########################
###############     Version 1.2.1 : 2019-10-14                                                     ########################
###############    adapted it to the new vcf_fixer version 1.1                                     ########################
###############                                                                                    ########################
###############     Version 1.2 : 2019-10-09                                                       ########################
###############    minor debug and improvements                                                    ########################
###############                                                                                    ########################
###############     Version 1.1 : 2019-10-04                                                       ########################
###############    added "extra options" for populations settings                                  ########################
###############                                                                                    ########################
###############     Version 1.0 : 2019-09-30                                                       ########################
###############    Edited it to work in remote (no need to move the script to your directory)      ########################
###############    with command line options, and to launch vcf_fixer afterwards                   ########################
###############                                                                                    ########################
###########################################################################################################################







###### GLOBAL PARAMETERS THAT COULD NEED TO BE EDIT (Program locations)
######  Everything else should be set from command line


my $vcffixer = "vcfixer.pl";
# path to ref_map.pl
my $programpath = "/shared/astambuk/bin/stacks_2.53/bin";
my $programfile = "ref_map.pl";  
# Path to perl scripts
my $scriptspath = "/shared/astambuk/perl5/scripts";





########################### COMMAND LINE PARAMETER DEFAULTS

#REFMAPS PARAMETERS
# set the same value in both (min and max) variables of the same parameter if you only one to run a specific value for it

my $not_set = "No default";    # don't touch this

# -- min-maf
my $m_max = $not_set;
my $m_min = 0;
#will be incremented by adding +0.01

# -r
my $r_max = 0.7;
my $r_min = $not_set;
#will be incremented by adding +0.1

# -p
my $p_min = $not_set;
my $number_pops = $not_set;
#will be incremented by adding +1

# -R
my $bigr_max = 0.8;
my $bigr_min = $not_set;
#will be incremented by adding +0.1


# --max-obs-het
my $het_max = 0.6;
my $het_min = $not_set;
#will be incremented by adding +0.1

# populations settings
my $populations = "--vcf --write-single-snp";
#my $populations = "--vcf --fstats";
my $extraoptions = "--fstats -f p_value";
#my $extraoptions = "--fst_correction p_value --write_single_snp";

#gstack options
my $gstacks = "--min-mapq 20";


# Your email address
my $emailaddress = 'example@biol.pmf.hr';
#my $emailaddress = 'oscar.mira@biol.pmf.hr';

# Number of cores to use
my $cores = 1;
#my $cores = 1;
#my $cores = 16;

# A prefix for the submission file names
my $name = "subjob_refmap";

# Set the name of the output folder that will include each output subdirectory from each job (once they are submited)
my $outfolder = "out";

#set a project code
my $project = "IP-2016-06-9177";

# Requested memory
my $memo = "20G";
#my $memo = "20G";

# File locations #full path unless are in the working directory
my $samples = $not_set;		   #Folder with the samples
#my $samples = "/shared/omiraper/REFMAPS/snp/refmapop/Lizards/psic/psicdata";
my $popmap = $not_set;		   #full popmap file path
#my $popmap = "/shared/omiraper/REFMAPS/snp/refmapop/Lizards/psic/popmap";

#  subirectory to store the submission files this script will produce
my $directory = "submissionfiles";


####################
#vcf fixer settings:

my $fixer = 0;  # you want to omit vcf_fixer submission files?
#my $fixer = 0;  # you want to omit vcf_fixer submission files?
#my $fixer = 1;  # you want to omit vcf_fixer submission files?

#my $sumpath = "/shared/omiraper/REFMAPS/snp/refmapop/Lizards/psic/out/purged/summary_table.txt";  		#path to a file that will gather some of the details of ref_maps and vcf_fixer outputs
my $sumpath = "summarytable_vcf_fixer.txt";  		#path to a file that will gather some of the details of ref_maps and vcf_fixer outputs
#my $sumpath = "no";  		#path to a file that will gather some of the details of ref_maps and vcf_fixer outputs

#not needed, will use ref_map popmap
#my $poplength = 2;  		#how many characters long is the population code at the beginning of the sample code
#my $poplength = 3;  		#how many characters long is the population code at the beginning of the sample code

my $poplog = "ref_map.log";  		#name of the log file from populations run
#my $poplog = "populations.log";  		#name of the log file from populations run

my $vcffile = "populations.snps.vcf"; # default name for vcf files should be this one, but may change
#my $vcffile = "populations.snps.vcf"; # default name for vcf files should be this one, but may change

my $infocols = 9;  		# how many columns of information has the VCF file before the first sample column
#my $infocols = 9;  		# how many columns of information has the VCF file before the first sample column

my $minpop = 8;  		# minimum number of samples that must exist in a population in order to process it
#my $minpop = 6;  		# minimum number of samples that must xist in a population in order to process it

my $emptyrate = 0.8;  		#missing rate for which we consider a sample or loci as "empty" of value.
#my $empty = 0.8;  		#missing rate for which we consider a sample or loci as "empty" of value.

my $miss_samples = 0.3;            #ratio of missing from which samples must be deleted
#my $miss_samples = 0.3;            #ratio of missing from which samples must be deleted

my $miss_loci = 0.3;               #ratio of missing from which loci must be deleted
#my $miss_loci = 0.3;               #ratio of missing from which loci must be deleted

my $gralmiss = "pop";  		#how should the program replace the missing values?
#my $gralmiss = "global";  		#how should the program replace the missing values?
#my $gralmiss = "pop";  		#how should the program replace the missing values?
#my $gralmiss = "miss";  		#how should the program replace the missing values?
#my $gralmiss = "2/2";  		#how should the program replace the missing values?

my $misspop = "global";  		#how should the program replace when a SNP is missing in a entire population?
#my $misspop = "miss";  		#how should the program replace when a SNP is missing in a entire population?
#my $misspop = "global";  		#how should the program replace when a SNP is missing in a entire population?
#my $misspop = "2/2";  		#how should the program replace when a SNP is missing in a entire population?

my $moar = '';			#more parameters for vcf_fixer


######################################################################################################
######################################################################################################

my $defemail = 'example@biol.pmf.hr';

#Help!
my %arguments = map { $_ => 1 } @ARGV;
if(exists($arguments{"help"}) || exists($arguments{"--help"}) || exists($arguments{"-help"}) || exists($arguments{"h"}) || exists($arguments{"-h"}) || exists($arguments{"--h"})) {
	die "\n\n\t   $version   Help Information\n\t-------------------------------------------------\n
	Use this program to generate multiple ref_map job submission files with a different combination of parameters.
	In adition will generate submission files for vcf_fixer to fix missing data in the output file, and sumarize it.
	It will also generate a bash script to submit all the submission files
	and another to send all the log files from each job to the output directory of that job\n
	\n\tCommand line arguments and defaults:\n
	Submission parameters
	--cores                   [int] number of threads (mpi). Around 16 should be fine. Default: $cores
	--memo                    Requested memory for the job. Default: $memo
	--mail                    email address for Isabella to notify you. Example: $emailaddress
	--subname                 prefix for all submission file names. Default: $name
	--dirsub                  subdirectory that will hold all the submission files created. Default: $directory
	--project                 Code of the project from which you want to submit the jobs. Default: $project\n
	ref_map (Stacks) directories and files
	http:\/\/catchenlab.life.illinois.edu\/stacks\/comp\/populations.php
	--samples                 path to the directory with your bai/bam files. $samples
	--popmap                  full path to your popmap file for ref_map. Default: $popmap
	--gstacks                 Extra options to add to \'gstacks\' settings. Use \' \'. Default: \'$gstacks\'
	--outdir                  directory path to hold ref_map results from all runs, will be created if it does not exist.
	                          a subdirectory for each set of parameters (each job) will be created. Default: $outfolder\n
	populations (Stacks) parameters ranges (set min and max to the same number for a unique value)  
	--m_min                   minimum value of --min-maf parameter (minimum allele frequency). Default: $m_min
	--m_max                   minimum value of --min-maf (increased by +0.01 each iteration). Default = m_min + 0.02
	--r_max                   maximum value of -r parameter (minimum samples per population). Default: $r_max
	--r_min                   minimum value of -r (increased by +0.1 each iteration). Default = r_max - 0.2
	--bigr_max                   maximum value of -R parameter (minimum samples overall). Default: $bigr_max
	--bigr_min                   minimum value of -R (increased by +0.1 each iteration). Default = bigr_max - 0.2
	--pops / --p_max          maximum value of -p (minimum number of populations). Must be number of populations sequenced.
	--p_min                   minimum value of -p parameter (increased by +1 each iteration). Default = pops - 2
	--het_max                 maximum value of --max-obs-het parameter (maximum observed heterozygosity). Default: $het_max
	--het_min                 minimum value of --max-obs-het (increased by +0.1 each iteration). Default = het_max - 0.3\n
	other \"ref_map.pl\" parameters. All submission files will run with this options for \'populations\': $populations
	--extra                   Extra options to add to \'populations\' settings. Use \' \'. Default: \'$extraoptions\'\n
	--nofixer                 Flag. Add this if you do not want to generate vcf_fixer submission files.\n
	vcf_fixer (unless \'--nofixer\')
	--summary                 path/name for a summary table that gathers some details of ref_map and vcf_fixer outputs.
	                          if \'--summary no\' the file will not be created. Default: $sumpath
	--empty                   [float] missing rate from which a sample will be considered \"empty\" and deleted. Default: $emptyrate
	--miss_loci               [float] missing rate from which a loci should be deleted. Default: $miss_loci
	--miss_samples            [float] missing rate from which a sample should be deleted. Default: $miss_loci
	--minpop                  [int] minimum number of samples a population must have in order to keep it. Default: $minpop
	--gral_miss               How to replace the regular missing values?  Default: $gralmiss\n\t\t\t\t  \"pop\" to replace it with the population mode* (most frequent genotype)
	\t\t\t  \"global\" to replace the missing with the whole dataset mode*.
	\t\t\t  \"miss\" to leave it as missing. \"2/2\" or any other value to input that value.
	--pop_miss                What to input if a SNP is missing in an entire population? Default: $misspop\n\t\t\t\t  \"global\" to input the global mode*, \"miss\" to keep them as missing,
	\t\t\t  \"2/2\" (or any other value) to input a new genotype to mark its difference from the rest.
	--poplog                  [optional] path or name of the populations (Stacks) log file. Default: $poplog
	                          if \'--poplog no\' it will not look for a logfile. 
	                          If no path (only name) provided will look for file in vcf file location.
	--moar                    More parameters or flags to pass to vcf_fixer. No defaults. Use \' \'.\n
 Example:\n   refmap_bachmaker.pl --samples data/alignsamp --popmap data/popmap --oudir data/out --summary data/out/sum_table.txt\n\n
	*Version of ref_map selected for the submission files is stored at \"$programpath\"
	 We have no relation with ref_maps, stacks programs and populations, check their help information (ex: populations --help)
	 Any doubt about them should be addressed to the authors. http:\/\/catchenlab.life.illinois.edu\/stacks\/
	 vcf_fixer has more options and its own help information slightly more detailed than this one: $vcffixer --help
	 This software was not tested on animals, but the boss' dog seems to be OK with it.\n\n\n";
}



my $popstring = "not_defined";
use Getopt::Long;

GetOptions( "cores=i" => \$cores,      #   --cores
            "memo=s" => \$memo,      #   --memo
            "mail=s" => \$emailaddress,      #   --mail
            "subname=s" => \$name,      #   --subname
            "project=s" => \$project,      #   --project
            "dirsub=s" => \$directory,      #   --directory
            "nofixer" => \$fixer,      #   --nofixer
            "samples=s" => \$samples,      #   --samples
            "popmap=s" => \$popmap,      #   --popmap
            "extra=s" => \$extraoptions,      #   --extra
            "gstacks=s" => \$gstacks,      #   --gstacks
            "outdir=s" => \$outfolder,      #   --outdir
            "m_min=s" => \$m_min,      #   --m_min
            "m_max=s" => \$m_max,      #   --m_max
            "r_min=s" => \$r_min,      #   --r_min
            "r_max=s" => \$r_max,      #   --r_max
            "bigr_min=s" => \$bigr_min,      #   --bigr_min
            "bigr_max=s" => \$bigr_max,      #   --r_max
            "p_min=s" => \$p_min,      #   --p_min
            "p_max=s" => \$number_pops,      #   --p_max
            "pops=s" => \$number_pops,      #   --p_max
            "het_min=s" => \$het_min,      #   --het_min
            "het_max=s" => \$het_max,      #   --het_max
            "infocols=s" => \$infocols,      #   --infocols
            "empty=f" => \$emptyrate,      #   --empty
            "miss_loci=f" => \$miss_loci,      #   --miss_loci
            "miss_samples=f" => \$miss_samples,      #   --miss_samples
            "summary=s" => \$sumpath,      #   --summary
            "minpop=i" => \$minpop,      #   --minpop
            "poplog=s" => \$poplog,      #   --poplog
            "pop_miss=s" => \$misspop,      #   --pop_miss
            "gral_miss=s" => \$gralmiss );   #   --gral_miss

#print "\nfrom $r_min to $r_max\n";

if ($samples eq $not_set) { die "\n\n ERROR!\nNo samples directory set (--samples). Check help information: $version --h\n\n"; }
if ($number_pops eq $not_set) { die "\n\n ERROR!\nNo maximum value for --p given (--pops / p_max). Check help information: $version help\n\n"; }
if ($popmap eq $not_set) { die "\n\n ERROR!\nNo popmap parsed, set a path to a valid popmap file (--popmap). Check help information: $version -help\n\n"; }
if ($p_min eq $not_set) { $p_min = $number_pops - 2; }
if ($r_min eq $not_set) { $r_min = $r_max - 0.2; }
if ($bigr_min eq $not_set) { $bigr_min = $bigr_max - 0.2; }
if ($m_max eq $not_set) { $m_max = $m_min + 0.02; }
if ($het_min eq $not_set) { $het_min = $het_max - 0.3; }
#print "\nfrom $r_min to $r_max\n";


print "\nRunning $version. Submission files will be stored at: $directory\n\n";
#if ($popmap eq "popmap") { print "Command line options parsed, will look for popmap at working directory.\n\n"; }



my $notification = "Nothing set on this variable, wtf??";
if ($emailaddress eq $defemail) { $notification ="## ## ## No email was set, you will not be notified or emailed when the job starts/ends.\n"}
else {$notification = "#\$ -m abe\t\t\t\t\t\t\#report beginning, end, and aborted\n#\$ -M $emailaddress \t\t#email me\n"}




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

my $count = 0;
my $minmaf = $m_min;
my $rflag = $r_min;
my $pflag = $p_min;
my $heteroz = $het_min;
my $globr = $bigr_min;
my @alljobs = ("#!/bin/bash", "# launch_them_all.sh", "# quick script to submit all your ref_map jobs at once", "# just \"bash\" or \"./\" this file", "\n", "#Jobs:");
my @movethemall = ("#!/bin/bash", "# move_them_all.sh", "# quick script to move all the subjob_ref_map.sh.o4815162342, subjob_ref_map.sh.po4815162342, subjob_vcfixer.sh.o.4815162342, and subjob_ref_map.sh.po.4815162342 log files to the folders where all the other outputs of the run are at", "# just \"bash\" or \"./\" this file after all the jobs finish\n");
my @allvcfs = ("#!/bin/bash", "# fix_them_all.sh", "# quick script to submit all your vcf_fixer jobs at once", "# just \"bash\" or \"./\" this file", "\n", "#Jobs:");
#my @moveallvcfs = ("#!/bin/bash", "# move_them_allvcfs.sh", "# quick script to move all the subjob_vcf_fixer.sh.o4815162342 and subjob_vcf_fixer.sh.po4815162342 log files to the folders where all the other outputs of the run are at", "# just \"bash\" or \"./\" this file after all the jobs finish\n");

#print "\nfrom $r_min to $r_max (flag = $rflag)\n";

until ($globr > $bigr_max) {
	$minmaf = $m_min;
	until ($minmaf > $m_max) {
		$rflag = $r_min;
		until ($rflag > $r_max) {
			$pflag = $p_min;
			until ($pflag > $number_pops) {
				$heteroz = $het_min;
				until ($heteroz > $het_max) {
					# Use the open() function to create the submission file.
					my $mpart = $minmaf;
					$mpart =~ s/.*\.//;
					my $rpart = $rflag;
					$rpart =~ s/.*\.//;
					my $bigrpart = $globr;
					$bigrpart =~ s/.*\.//;
					my $ppart = $pflag;
					$ppart =~ s/.*\.//;
					my $hetpart = $heteroz;
					$hetpart =~ s/.*\.//;
					
					
					my $submissionname = "$name" . "_m" . "$mpart" . "r" . "$rpart" . "p" . "$ppart" . "R" . "$bigrpart" . "h" . "$hetpart" . ".sh";
					my $filepath ="$dirbase1"."$directory"."/"."$submissionname";														######fullpath
					$filepath =~ s/\/\//\//g;
					open my $FILE, '>', $filepath or die "\nUnable to create $filepath: $!\n";######fullpath
					
					my $outdir = "$dirbase2" . "$outfolder" ."/" . "m" . "$mpart" . "/" . "r" . "$rpart" . "/" . "R" . "$bigrpart" . "/" . "p" . "$ppart" . "/" . "h" . "$hetpart";
					$outdir =~ s/\/\//\//g;
					# Write text to the file.
					print $FILE "#!/bin/bash\n#\n# #$submissionname\n# Isabella submission file for refmaps\n";
					print $FILE "\n\n#\$ -cwd\t\t\t\t\t\t\t#print wd\n";
					print $FILE "#\$ -j y\t\t\t\t\t\t\t#report errors\n";
					print $FILE "$notification";
					print $FILE "#\$ -P $project\n";
					print $FILE "#\$ -pe *mpisingle $cores\t\t\t\t\#$cores CPU\n#\$ -l h_vmem=$memo\t\t\t\t#Request memory\n\n";
					print $FILE "#set -e\n#set -u\n\n#CHR=\$SGE_TASK_ID\n\n";
					print $FILE "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/lib:/shared/astambuk/bin/lib:/shared/astambuk/bin/bin:/shared/astambuk/bin/lib64:/shared/astambuk/bin/stacks_2.2/bin:/shared/astambuk/bin/gcc8.2/lib64:/shared/astambuk/bin/gcc8.2/lib:/shared/astambuk/bin/gcc8.2/bin:$programpath:$scriptspath\n";
					print $FILE "export PATH=\$PATH:/shared/astambuk/bin/bin:/shared/astambuk/bin/stacks_2.2/bin:/shared/astambuk/bin/stacks_2.2:$programpath\n";
					print $FILE "export PERL5LIB=\$PERL5LIB:/shared/astambuk/perl5\n\n\n####################\n\n";
					print $FILE "#Checking and creating output directories\n\n";
					print $FILE "if [ -d \"$outdir\" ]\nthen\n\tprintf \"Already existing sub-directory will be used as output directory: $outdir\\n\"\n";
					print $FILE "else\n\tmkdir -p \"$outdir\"\nfi\n\n\n";
					print $FILE "#Run ref_map\n\n";
					#print $FILE "structure -K $count -o  $outdata/K$count\_\"\$SGE_TASK_ID\" > $outfolder/runseqK$count"."_\"\$SGE_TASK_ID\"\n\n\n##End\n";							#delete if full path
					
					if($gstacks ne '') {
						if ($minmaf == 0) { print $FILE "$programpath"."/"."$programfile -T $cores -o $outdir --popmap $popmap --samples $samples -X \"gstacks: $gstacks\" -X \"populations: -t $cores $populations $extraoptions -R $globr -r $rflag -p $pflag --max-obs-het $heteroz\"\n\n"; } #fullpath
						else {print $FILE "$programpath"."/"."$programfile -T $cores -o $outdir --popmap $popmap --samples $samples -X \"gstacks: $gstacks\" -X \"populations: -t $cores $populations $extraoptions --min-maf $minmaf -R $globr -r $rflag -p $pflag --max-obs-het $heteroz\"\n\n"; }  #fullpath
					}
					else {
						if ($minmaf == 0) { print $FILE "$programpath"."/"."$programfile -T $cores -o $outdir --popmap $popmap --samples $samples -X \"populations: -t $cores $populations $extraoptions -R $globr -r $rflag -p $pflag --max-obs-het $heteroz\"\n\n"; } #fullpath
						else {print $FILE "$programpath"."/"."$programfile -T $cores -o $outdir --popmap $popmap --samples $samples -X \"populations: -t $cores $populations $extraoptions --min-maf $minmaf -R $globr -r $rflag -p $pflag --max-obs-het $heteroz\"\n\n"; }  #fullpath
					}
					# close the file.
					close $FILE;
					print "$submissionname created\n";
					#save the job name and the submission command
					my $currentjob = "qsub $filepath";
					push (@alljobs, "\n");
					push (@alljobs, $currentjob);
					my $movingfiles = "mv $submissionname" . ".* $outdir\nmv $filepath $outdir\n";
					push (@movethemall, $movingfiles);
					
					
					if ($fixer == 0) {
						
						my $submissionfix = "subjob_vcfixer" . "_m" . "$mpart" . "r" . "$rpart" . "p" . "$ppart" . "h" . "$hetpart" . ".sh";
						my $filepathfix ="$dirbase1"."$directory"."/"."$submissionfix";														######fullpath
						$filepathfix =~ s/\/\//\//g;
						open my $FIXFILE, '>', $filepathfix or die "\nUnable to create $filepathfix: $!\n";######fullpath
						
						print $FIXFILE "#!/bin/bash\n#\n# #$submissionfix\n# Isabella submission file for vcf_fixer\n";
						print $FIXFILE "\n\n#\$ -cwd\t\t\t\t\t\t\t#print wd\n";
						print $FIXFILE "#\$ -j y\t\t\t\t\t\t\t#report errors\n";
						print $FIXFILE "$notification";
						print $FIXFILE "#\$ -l exclusive=1\t\t\t#to not overload the node\n#\$ -l h_vmem=$memo\t\t\t\t#Request memory\n\n";
						print $FIXFILE "#set -e\n#set -u\n\n#CHR=\$SGE_TASK_ID\n\n";
						print $FIXFILE "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/lib:/shared/astambuk/bin/lib:/shared/astambuk/bin/bin:/shared/astambuk/bin/lib64:/shared/astambuk/bin/stacks_2.2/bin:/shared/astambuk/bin/gcc8.2/lib64:/shared/astambuk/bin/gcc8.2/lib:/shared/astambuk/bin/gcc8.2/bin:$scriptspath\n";
						print $FIXFILE "export PATH=\$PATH:/shared/astambuk/bin/bin:/shared/astambuk/bin/stacks_2.2/bin:/shared/astambuk/bin/stacks_2.2\n";
						print $FIXFILE "export PERL5LIB=\$PERL5LIB:/shared/astambuk/perl5:$scriptspath\n\n\n####################\n\n";
						
						print $FIXFILE "#Run fixer\n\n$scriptspath"."/"."$vcffixer --input $outdir/$vcffile --infocols $infocols --popmap $popmap --empty $emptyrate --miss_loci $miss_loci --miss_samples $miss_samples --minpop $minpop --gral_miss $gralmiss --pop_miss $misspop --poplog $poplog --summary $sumpath\n\n";
						
						# close the file.
						close $FIXFILE;
						print "$submissionfix created\n";
						#save the job name and the submission command
						my $currentfix = "qsub $filepathfix";
						push (@allvcfs, "\n");
						push (@allvcfs, $currentfix);
						my $movingvcf = "mv $submissionfix" . ".* $outdir\nmv $filepathfix $outdir\n";
						push (@movethemall, $movingvcf);
						
					}
					
					$count++;
					
					$heteroz = $heteroz+0.1;
				}
				$pflag++;
			}
			$rflag = $rflag+0.1;
		}
		$minmaf = $minmaf+0.01;
	}
	$globr = $globr+0.1;
}

print "\n $count submission files with different settings were created!\n\n";

my $launcher = "$dir" . "/" . "launch_them_all.sh";
my $fixerlauncher = "$dir" . "/" . "fix_them_all.sh";
my $bachmv = "$dir" . "/" . "move_them_all.sh";

#create a short script for submiting a bunch of similar jobs at once
open my $JOB, '>', $launcher or die "\nUnable to create $launcher: $!\n";
foreach (@alljobs) {print $JOB "$_\n";} # Print each entry in our array to the file
print $JOB "\n\nprintf \"\\nAll submited!\\n\\n\"\n";
close $JOB;

#create a short script for submiting all vcf_fixer jobs at once
open my $POSTJOB, '>', $fixerlauncher or die "\nUnable to create $fixerlauncher: $!\n";
foreach (@allvcfs) {print $POSTJOB "$_\n";} # Print each entry in our array to the file
print $POSTJOB "\n\nprintf \"\\nAll submited!\\n\\n\"\n";
close $POSTJOB;

#create a short script for moving all the qsub job logfiles to their output directory
open my $LOG, '>', $bachmv or die "\nUnable to create $bachmv: $!\n";
foreach (@movethemall) {print $LOG "$_\n";} # Print each entry in our array to the file
print $LOG "\n\nprintf \"\\nAll moved!\\n\\n\"\n";
close $LOG;


print "created \"launch_them_all.sh\", \"move_them_all.sh\", and \"fix_them_all\": Two scripts to submit them all, One script to find the log files, move them all, and in the darkness bind them.\n";
print "\nAll done!\n\n";



