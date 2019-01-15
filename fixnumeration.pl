#!/usr/bin/perl
#fixnumeration.pl

use strict ; use warnings;
#by M'Ósky 2018

# Because people will not stop naming samples wrongly and/or because some programers do not understand that A2 should be sorted before A10
# This will rename all the files so all the numbers have the same digits. Now finally A02 will be sorted before A10!
# Right now only works with files named:  ABC42.something
# 	Being "ABC" an alphabetical string of any length and "42" any number of numerical characters. Everything after the dot (".something" ) will be ignored

# Check the help information from command line if needed

# The number of digits you want to homogeneize to can be set from command line

my $digits=2;


#####################################

use Cwd qw(cwd);
my $localdir = cwd;



my $argumentnumber = scalar (@ARGV);


if($argumentnumber > 0) {
	my $argument = $ARGV[0];
	if ($argumentnumber == 1 && $argument =~ /^[0-9,.E]+$/) {
		$digits = $argument;
	}
	elsif ($argumentnumber > 1 || $argument eq "help" || $argument eq "-help" || $argument eq "--help" || $argument eq "-h" || $argument eq "--h") {
		die "\n\nfixnumeration.pl -help\n\nBecause people forgets that programers do not understand that A2 does not go after A12...\nThis program will rename all the files named ABCnumber.something adding zeros (\"0\") to the left of smaller numbers\n\tACAB42.something -> ACAB042.something\nBeing \"ACAB\" any number of ALPHABETICAL characters and \"42\" any number of NUMERICAL characters.\nAnything after the dot (\".something\" ) will be left as is\n\nProvide the number of digits of the biggest number (3 in the example to change from 42 to 042)\n\tfixnumeration.pl 3\nExecute it in the directory where the files are at\n\n";
	}
}




print "\n\nNumeration will be homogeneized to $digits digits.";
print "\nReading files at $localdir\n\n";



use File::Copy qw(copy);


opendir(DIR, $localdir);						#open the directory with the files
my @files = readdir(DIR);					#extract filenames
closedir(DIR);

my $count = 0;

foreach my $file (@files) {					#process all the files one by one
	
	next if ($file =~ /^\.$/);				#don't use any hidden file
	next if ($file =~ /^\.\.$/);			
	
	
	if ($digits == 2) {
		if ($file=~/^\D*?\d\d\..*$/) {
			print "file  $file  seems alright\n";
		}
		elsif ($file=~/^\D*?\d\d\d\..*$/) {
			print "file  $file  has more digits than expected (maximum should be $digits)\n";
		}
		elsif ($file=~/^\D*?\d\..*$/) {
			print "  ->   Renaming dile $file ...";
			$file=~/^(\D*?)(\d\..*)$/;
			my $outname = $1 . "0" . $2;
			system ("mv $file $outname");
			print "  renamed to  $outname  succesfully!\n";
			$count++;
		}
		else {
			print "File  $file  does not match the required pattern and will be skipped\n";
		}
	}
}

print "\n\n$count files processed!\n\n";
