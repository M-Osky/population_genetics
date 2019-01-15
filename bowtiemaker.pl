#!/usr/bin/perl
use strict;
use warnings;

#bowtiemaker.pl
#USAGE: This will make a submission file for your samples so you can use bowtie and samtools to map them
#		forward and reverse must be in different directories in the same parent. 
#		Names should be: whichevername.1.fq.gz (for forward) and samename.2.fq.gz, where wichevername = samename
#		script will ignore any file with a differen name pattern
#		set the 7 parametres below and check that the software locations are alright

# 1) Set the PATH where your data are (forward, reverse, and reference sequence) are. Dont forget any "/"
my $pathname = "/shared/omiraper/lizards/psicula/mapping/bowtie2/";

# 2) Name of the sub-directory/ including the forward reads.
my $fwd = "lizard_tmp/fwd/";


# 3) Name of sub-directory/ including the reverse reads."
my $rev = "lizard_tmp/rew/";

# 4) Name of the reference genome to map against
my $refgen = "Psic_sn201_all";

# 5) Name of your output folder/
my $outname = "tryscript/";			#bam_gen

# 6) Name for the submission file you want to create
my $submissionname = "psic_bowtie_launch.sh";

# 7) Your email address
my $emailaddress = 'omira@biol.pmf.hr';




# software locations
my $bowtie = "/shared/rbakaric/bin/bowtie2/bowtie2";

my $samtools ="/shared/rbakaric/software/samtools-1.8/samtools";



##################################### Below this line don't touch anything unless you know what you are doing 



my $filepath ="$pathname"."$submissionname";
my $tempname = "$submissionname".".tmp";
my $filesloc ="$pathname"."$fwd";
my $refpath = "$pathname"."$refgen";
my $cores="numberoffilesprocessed";

use Cwd qw(cwd);
my $dir = cwd;

# Use the open() function to create the submission file.
open my $FILE, '>', $filepath or die "\nUnable to create $submissionname at $pathname: $!\nwd: $dir\n";

# Write some text to the file.
print $FILE "#!/bin/bash\n#\n# Quick script for array job submission\n#\n#\$ -cwd\t\t\t\t\t#print wd\n";
print $FILE "#\$ -j y\t\t\t\t\t#report errors\n#\$ -m abe\t\t\t\t\#report beginning, end, and aborted\n";
print $FILE "#\$ -M $emailaddress \t\t#email me\n#\$ -pe mpi 40\t\t\t\t\#40 CPU\n#\$ -l h_vmem=20G\n";
print $FILE "# #\$ -t 1-$cores\t\t\t\t\#this should be the number of jobs, but its a count of the numbers of samples\n\n#set -e\n#set -u\n\n#CHR=\$SGE_TASK_ID\n\n";
print $FILE "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/lib/:/shared/rbakaric/bin/lib:/shared/rbakaric/bin/lib64/:/shared/rbakaric/software/samtools-1.8/lib:/shared/rbakaric/bin/lib\n";
print $FILE "export PATH=\$PATH:/shared/rbakaric/bin/bin:/shared/rbakaric/bin/:/shared/rbakaric/software/samtools-1.8/\n\n";


opendir(my $DIR, $filesloc) or die "\nUnable to open files at $filesloc: $!\n";						#open the directory with the files
my @files = readdir($DIR);					#extract filenames
closedir($DIR);

my $k = 0;

foreach my $file (@files) {					#process all the files one by one
	
	next if ($file =~ /^\.$/);				#don't use any hidden file
	next if ($file =~ /^\.\.$/);			
	next unless ($file =~ /\.fq\.gz$/);		#read only fq.gz files
	
	my $fwdfile = $file;
	my $revfile = $file;
	
	$revfile =~ s/.1./.2./;		#rev files are named as the fwd files but in despite of.1.fq.gz are .2.fq.gz
	
	my $fwdpath = "$pathname"."$fwd" . "$fwdfile";
	
	my $revpath = "$pathname"."$rev"."$revfile";
	
	my $outfile = $file;
	$outfile =~ s/.1.fq.gz//;		#rev files are named as the fwd files but in despite of.1.fq.gz are .2.fq.gz
	
	my $outbam = "$outfile".".bam";
	my $outbai = "$outbam".".bai";
	
	my $outpathbam = "$pathname"."$outname"."$outbam";
	my $outpathbai = "$pathname"."$outname"."$outbai";
	
	
	print $FILE "$bowtie -1 $fwdpath -2 $revpath -p 40  -x $refpath -q | $samtools-1.8/samtools view -bS - | $samtools sort -o $outpathbam\n";
	print $FILE "$samtools index $outpathbam  $outpathbai\n";
	
	$k++
	
}


# close the file.
close $FILE;

use File::Copy qw(copy);

copy $filepath, $tempname;

open(my $IN, '<', $tempname) or die "error openning $filepath for reading: $!";
open(my $OUT, '>', $filepath) or die "error openning $filepath for reading: $!";

while(<$IN>) {
	$_ =~ s/$cores/$k/;
	print $OUT $_;
}

close($IN);
close($OUT);

unlink($tempname);

print "\nSubmission file $submissionname created successfully!\n";



