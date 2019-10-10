#!/usr/bin/perl
use strict;
use warnings;

##Quick perl script to extract likelihood values from Structure outputs and write a table with them
#It is outdated, now we use either a grep one liner or directly faststructure. -M'Ósky-

# parameters
my $OUTFOLDER="out";		   # output directory for table with the likelihood values per run
my $OUTDATA="out/results";	   # directory with the Structure somethingK#_#_f files
my $outfile = "loglikelihood.txt"; # name for the table file to write

#Generating file with likelihoods


print "Extracting the likelihood of each run\n";

use Cwd qw(cwd);
my $dir = cwd;

opendir(my $DIR, $OUTDATA) or die "\nUnable to open directory $OUTDATA at $dir: $!\n";						#open the directory with the files
my @files = readdir($DIR);					#extract filenames
closedir($DIR);

my $k = 0;

my @saved_data =();
my $fn =0;
my $match = 0;
my @wantedline = ();

print "\nProcessing files from $OUTDATA:\n";
foreach my $file (@files) {					#process all the files one by one
	
	next if ($file =~ /^\.$/);				#do not use hidden files
	next if ($file =~ /^\.\.$/);			
	next unless ($file =~ /.*_f$/);		#read only the _f files
	print "$file  ";
	my $filename = $file;
	
	my @runinfo = split('_' , $filename);
	my $Kname = $runinfo[0];
	my $iter = $runinfo[1];
	my @karray = split(// , $Kname);
	shift (@karray);
	my $run_k = join ('' , @karray);
	
	my $filepath = "$dir"."/"."$OUTDATA"."/"."$file";
	my $resultspath = "$dir"."/"."$OUTDATA"."/";
	
	open(my $IN, '<', $filepath) or die "error openning $file at $resultspath for reading: $!\n";
	
	while (<$IN>) {
		if ( $_ =~ m/^Estimated Ln Prob of Data/ ) {
			@wantedline = split(' ' , $_);
			my $likelihood = $wantedline[-1];
			$saved_data[$match] = "K\t$run_k\trep$iter\t$likelihood";
			$match++;
		}
	}
	$fn++;
}


print "\n\n$fn files processed, $match values saved.\n";

my $outpath = "$OUTFOLDER"."/"."$outfile";

open my $OUT, '>', $outpath or die "Cannot create output file $outpath: $!";

# Loop over the array
foreach (@saved_data) {print $OUT "$_\n";} # Print each entry in the array to the file

close $OUT; 


printf "\nLoglikelihood of each run saved to $outfile\n\n"
