#!/usr/bin/perl
use strict; use warnings;

# save_signif_loci_v1.1.pl by M'Óskar

###################################################################################

# Quick script to extract a list of loci that have significant pairwise Fst for each pair-wise comparations
# It should automatically work with populations.fst_pop1-pop2.tsv output
# Implemented for more than one file

###################################################################################

my $sep = '\t';		#symbol differenciating the columns
my $newfolder = "out3";		#output folder
my $tag = "_psic";		#something you want to add to all the files processed
my $keepnames = "YES";	#set to "YES" if you want to keep the names of significant loci, if "NO" it will keep the position on the column instead

use Cwd qw(cwd);
my $localdir = cwd;


unless(-e $newfolder or mkdir $newfolder) {die "Unable to create the directory \"$newfolder\" at\n$localdir\nMay be you don't have the rights: $!\n"; }

print "\nUsing directory \"$newfolder\" to contain the outputs.\nNow reading files at $localdir\n\n";


opendir(DIR, $localdir);						#open the directory with the tsv files
my @files = readdir(DIR);					#extract filenames
closedir(DIR);

foreach my $file (@files) {					#process all the files one by one
	
	next if ($file =~ /^\.$/);				#don't use any hidden file
	next if ($file =~ /^\.\.$/);			
	next unless ($file =~ /\.tsv$/);		#read only tsv files
	
	my $filepath = $localdir . "/". $file;
	
	open my $FILE, '<', $filepath or die "\nUnable to find or open $file at $localdir: $!\n";

	my $line = 0;
	my $numbercols = 0;
	my $allele = 0;
	print "Processing the data in the file \"$file\":\n";

	my $line = 0;
	my @newline = ();
	my $lociname = 0;
	my $pvalue = 0;
	my $signifloci = 0;
	my $allloci = 1;
	
	my $newname = $file;
	$newname =~ s/-/_/g;
	$newname =~ s/\./_/g;
	
	my @splittedname= split('_', $newname);
	my $pop1 = $splittedname[2];
	my $pop2 = $splittedname[3];
	
	my @locisguays = ();
	
	while (<$FILE>) {
		chomp;	#clean "end of line" symbols
		
		next if /^(\s*(#.*)?)?$/;   # skip blank lines and comments
		
		$line = $_;
		$line =~ s/\s+$//;		#clean white tails in lines
		
		@newline= split($sep, $line);	#split columns as different elements of an array
		
		if ($keepnames eq "NO") {
			$lociname=$allloci;
		}
		else {$lociname = $newline[0];
		}
		$pvalue = $newline[8];
		
		if ($pvalue < 0.05) {
			push (@locisguays, $lociname);
			$signifloci++;
		}
		$allloci++;
	}
	
	close $FILE;
	
	$allloci = $allloci - 1;
	print "$signifloci loci from $allloci had significant pair-wise Fst between $pop1 and $pop2.\t";

	my $outname = "signif_fst_loci_" . "$pop1" . "-" . "$pop2" . "$tag";

	my $outpath = "$localdir" . "/" . "$newfolder" . "/" . "$outname";
	open my $OUT, '>', $outpath or die "\nUnable to create or save $outname at $localdir/$newfolder: $!\n";

	# Loop over the array
	foreach (@locisguays) {print $OUT "$_\n";} # Print each entry in our array to the file
	
	

	close $OUT; 

	print "List saved at $newfolder/$outname\n\n";


}
