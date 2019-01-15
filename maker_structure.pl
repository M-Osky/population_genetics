#!/usr/bin/perl
use strict;
use warnings;

#structure_maker.pl
#USAGE: This will make a submission file for every K value for structure.
# The will be stored in a directory called submissionfiles, it will use it if it
# exists, it will create it if it does not exist. As it should be.
# This way you can send as many independent jobs as values of K you are analyzing
# and they could run all at the same time -> $ qsub submissionfiles/structureoctop*

# 8 parameters to set, although some of them probably there is not need to change

# 1) Set the maximum number of cluster or populations you want to test, and number of files
my $pops = 5;

# 2) Set the number of independent runs you want for each K
my $runs = 5;

# 3) Your email address
my $emailaddress = 'omira@biol.pmf.hr';

# 4) Number of cores to use
my $cores = 16;

# 5) A prefix for the submission files
my $name = "structureoctop";

# 6) Set the name of the output folder that will include the log file, summary and the directory with all the result files from Structure
my $outfolder = "out";

# 7) Set the name of the directory that will include all the files with the results for each run. It will be placed inside $outfolder
my $results = "results";

# 8) Requested memory
my $memo = "20G";


######################################################################################################

#If this the resultant submission files do not work we may need to add the path to structure and to the working directory

# 9) Set the path to Structure.
my $program = "/shared/rbakaric/bin/structure";

# 10) Set the PATH where your data and param files are (usually local working directory).
# my $pathname = "/shared/omiraper/octopus/structure";														######fullpath
use Cwd qw(cwd);
my $pathname = cwd;																							######delete if full path
my $dir = cwd;																								######

# 11) Directory to store the submission files this scrippt will produce
my $directory = "submissionfiles";																			######delete if full path
#my $directory = "$pathname"."/"."$directory";																######fullpath


##################################### Below this line don't touch anything unless you know what you are doing 



my $outdata = "$outfolder"."/"."$results";
# my $outdata = "$pathname"."/"."$outdata";																	#####fullpath
# my $outfolder = "$pathname"."/"."$outfolder";																#####fullpath


unless(-e $directory or mkdir $directory) {die "Unable to create output directory $directory\n"};
print "Storing submission files at $directory"."/"."\n in $dir\n";

my $count = 1;

while ($count <= $pops) {
	# Use the open() function to create the submission file.
	my $submissionname = "$name"."_K"."$count".".sh";
	#my $filepath ="$pathname". "/"."$directory"."/"."$submissionname";														######fullpath
	my $filepath ="$directory"."/"."$submissionname";																		######delete if full path
	open my $FILE, '>', $filepath or die "\nUnable to create $submissionname at $pathname: $!\n";			######delete iff full path
	#open my $FILE, '>', $filepath or die "\nUnable to create $submissionname at $pathname: $!\nwd: $dir\n";######fullpath

	# Write text to the file.
	print $FILE "#!/bin/bash\n#\n# #$submissionname\n# Isabella submission file for structure\n#This file will test K = $count in Structure\n";
	print $FILE "\n\n#\$ -cwd\t\t\t\t\t\t\t#print wd\n";
	print $FILE "#\$ -j y\t\t\t\t\t\t\t#report errors\n#\$ -m abe\t\t\t\t\t\t\#report beginning, end, and aborted\n";
	print $FILE "#\$ -M $emailaddress \t\t#email me\n#\$ -pe mpisingle $cores\t\t\t\t\#$cores CPU\n#\$ -l h_vmem=$memo\t\t\t\t#Request memory\n";
	print $FILE "# #\$ -t 1-$runs\t\t\t\t\t\t\#Number of jobs, independent runs\n\n#set -e\n#set -u\n\n#\$ -N Structure_K$count"."_"."\${SGE_TASK_ID}\n\n";
	print $FILE "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/lib/:/shared/rbakaric/bin/lib:/shared/rbakaric/bin/lib64/:/shared/rbakaric/bin/lib:$program\n";
	print $FILE "export PATH=\$PATH:/shared/rbakaric/bin/bin:/shared/rbakaric/bin/:$program\n\n\n####################\n\n";
	print $FILE "\n\nGeneral output folder = $outfolder\n";
	print $FILE "Subdirectory for all the results = $outdata\n\n\n\n";
	print $FILE "#Checking and creating output directories\n\n";
	print $FILE "if [ -d \"\$OUTFOLDER\" ]\nthen\n\tprintf \"Already existing sub-directory will be used as output directory: \$OUTFOLDER\\n\"\n";
	print $FILE "else\n\tmkdir -p \$OUTFOLDER\nfi\n\n";
	print $FILE "if [ -d \"\$OUTDATA\" ]\nthen\n\tprintf \"Already existing sub-directory will be used to store results: \$OUTDATA\\n\"\n";
	print $FILE "else\n\tmkdir -p \$OUTDATA\nfi\n\n\n";
	print $FILE "#Run Structure\n\n";
	print $FILE "structure -K $count -o  $outdata/K$count\_\"\$SGE_TASK_ID\" > $outfolder/runseqK$count"."_\"\$SGE_TASK_ID\"\n\n\n##End\n";							#delete if full path
	#print $FILE "$program"."/"."structure -K $count -o  $outdata/K$count\_\"\$SGE_TASK_ID\" > $outfolder/runseqK$count"."_\"\$SGE_TASK_ID\"\n\n\n##End\n";			#fullpath
	
	# close the file.
	close $FILE;
	$count++;
}
 $count = $count-1;
print "\n $count submission files for Structure were created\n";
