#!/usr/bin/perl
use strict;
use warnings;

#popmap_maker.pl #version 1.3

# This will create files with sample lists you may need to use for different analysis
# It will create a file with two columns: sample name + population name (popmap)	#WILL OVERWRITE
# And two additional files: 1 only with sample names, and other only with the list of population names.
# Will read the names of the files until the first dot (".") it finds.
# All samples need to be in the same directory
# Names of the samples need to be in a format: population code + sample code. Every other information can be to the right of a dot and will be ignored.

# Check the help information from command line if needed

# You can provide a different folder name than the working directory in the command line, or else it will analyse the filenames in the working directory

# Parametres :
# 1 - how many alphanumeric characters correspond to the population name. (poplength). Not needed if name = "POPNAME(alphabetical) + indivnumber(digits)", like in: ALa12 ->POP: ALa Sample ALa12
# 2 - If individual code is the whole name of the file and INCLUDES the population name, or if individual id starts AFTER the population name
# 3 - If indvidual name starts AFTER population name and are separated by a symbol, you must specify it here.


# 1) Number of alphanumeric characters that correspond to the population code.
   # If $poplength=0 the script will automatically interpret the whole sample name as the individual code and everything before the number as a population code; File name=GR01.ext; Pop=GR; Sample=GR01
   # ONLY DIFFERENT FROM 0 IF: Population name includes numbers that do not correspond to sample name or if sample name does not include the population name: Pop1sample1; PopSample1; Pop_001
my $poplength=0;    	#Numerical. 

# Only if $poplength is different than 0
# 2) Specify if code of the individual INCLUDES the population name, or if it is AFTER the population name.
my $indname="INCLUDES";
    #my $indname="AFTER";	#USE ONLY IF $poplength IS NOT 0

#Only if $indname="AFTER"
# 3) If the population ID and the sample ID are separated by a symbol (usually "_" or "-" indicate it here.
my $symbol=""; #By default is empty ("") and assumed that popname and indname are contiguous.





# Some softwares are really picky with the format. Set here the column separator
my $sep = "\t";
#my $sep = " ";


use Cwd qw(cwd);
my $path = cwd;

my $filesloc = $path;

my $folder = 0;  	   #Change if you want to specify a different subdirectory whithout using the command line options, un-comment the next line if so.
#$filesloc = "$path"."/"."$folder";  	  #Un-comment and define the previous variable ("folder") if you want to specify a different subdirectory whithout using the command line options.



#######################################################################################################################################################################
#######################################################################################################################################################################
## 	  -  	Change log - version 1.3 - M'Oskar 09/11/2018
##  	  Now you can pass a directory name as argument, it will analyse everything in it
##  	  if you do not pass a directory name, it will analyse the sample names from the files at the working directory
##  	  As usual, if the argument is "help", "--h", or similar it will output the help lines.
##  	  Also now the outputs are sorted
## 	  -  -  -  -  -  -  -  --  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
## 	  -  	Change log - version 1.2 - M'Oskar 07/08/2018
##  	  I decided that it will be usefull to output a list of the populations
## 	  -  -  -  -  -  -  -  --  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
## 	  -  	Change log - version 1.1 - M'Oskar 06/08/2018
##  	  A bug was detected, when there was files with the same sample name (like bam and bai files) it was storing each name twice.
##  	  Now it uses %hashes in despite of @arrays, this way it will not store repeated values.
##  	  Also now it saves the popmap file in the working directory, not in the subdirectory with the samples
#######################################################################################################################################################################
#######################################################################################################################################################################






my $argumentnumber = scalar (@ARGV);

if($argumentnumber > 0) {
	my $argument = $ARGV[0];
	if ($argumentnumber >= 2 || $argument eq "help" || $argument eq "-help" || $argument eq "--help" || $argument eq "-h" || $argument eq "--h") {
		die "\n\npopmap_maker.pl #version 1.3 -help\n\nThis script will create files with lists of samples you may need to use for different analysis:\n - It will create a popmap file with two columns: sample name + population name (WILL OVERWRITE)\n - also two additional files: 1 only with sample names, and other only with the list of populations.\n\nThe sample and population names will be read from the file names until the first dot (\".\") it finds.\nBy default the names of the samples need to be in this format: alphabetical population code + numerical sample code.\nThe sample code in popmap will include the alphabetical population code and the numerical unique sample code.\nEvery other information can be to the right of the first dot and will be ignored.\n\tACAB042.hajahalaja.tar.gz\t->     ACAB042  ACAB\n\tLemuria2.fasta  \t\t->    Lemuria2  Lemuria\nIf your sample names are coded differently there is a few options you can edit in the script.\nThe samples and populations will appear sorted alphabeticaly\n\nAll sample files need to be in the same directory\nYou can provide a subdirectory name in the command line ( popmap_maker.pl mysamples_dir ), or else it will analyse the filenames in the working directory\n\n";
	}
	elsif ($argumentnumber == 1) {
		$folder = $argument;
		#$folder =~ s/(.*?)\//$1/;
		$filesloc = "$path"."/"."$folder";
	}
}




print "\nProcessing filenames from $filesloc:\n";

opendir(my $DIR, $filesloc) or die "\nUnable to open files at $filesloc: $!\n";						#open the directory with the files
my @files = readdir($DIR);					#extract filenames
closedir($DIR);

#my @ind_pop = ();
#my @ind_list = ();
#my @pop_list = ();
my $k=0;
my %uniquevalues = ();

if ($poplength == 0) {
	foreach my $file (@files) {					#process all the files one by one
		next if ($file =~ /^\.$/);				#don't use any hidden file
		next if ($file =~ /^\.\.$/);
		next unless ($file =~ /^.*\..*$/);		#read only name.extension files
		my $filename = $file;
		print "$filename   \t";
		my ($popname) = $filename =~/^(\D*)\d*\..*$/;	#save alphabetical part of the name
		my ($idnum) = $filename =~ /^\D*(\d*)\..*$/;	##save numerical part of the name
		my $indname = "$popname"."$idnum";
		$uniquevalues{$indname} = $popname;			#save the data in a hash
		#print "File name is $indname".": sample num $idnum from population $popname\n";
		$k++;
	}
}
else {
	if ($indname eq "INCLUDES") {
		foreach my $file (@files) {					#process all the files one by one
			next if ($file =~ /^\.$/);				#don't use any hidden file
			next if ($file =~ /^\.\.$/);
			next unless ($file =~ /^.*\..*$/);		#read only name.extension files
			my ($indname) = $file =~ /^(.*?)\./;
			print "$file:  \t";
			my @code = split(// , $indname);
			my $size = @code;
			$size = $size-1;
			my $popend = $poplength -1;
			my $indbegin = $poplength;
			my @population = @code[0..$popend];
			my @individual = @code[$indbegin..$size];
			my $popname = join ('' , @population);
			my $idind = join ('' , @individual);
			#print "Sample is $indname".", sample id $idind from population $popname\n";
			$uniquevalues{$indname} = $popname;			#save the data in a hash
			$k++;
		}
	}
	elsif ($indname eq "AFTER") {
		foreach my $file (@files) {					#process all the files one by one
			next if ($file =~ /^\.$/);				#don't use any hidden file
			next if ($file =~ /^\.\.$/);
			next unless ($file =~ /^.*\..*$/);		#read only name.extension files
			my ($samplename) = $file =~ /^(.*?)\./;
			#print "File $samplename:  \t";
			
			my $popname = 0;
			my $idind = 0;
			
			if ($symbol ne '') {
				my @code = split($symbol, $samplename);
				$popname = $code[0];
				$idind = $code[-1];
				#print "sample $idind from population $popname\n";
			} 
			else {
				my @code = split(// , $samplename);
				my $size = @code;
				$size = $size-1;
				my $popend = $poplength -1;
				my $indbegin = $poplength;
				my @population = @code[0..$popend];
				my @individual = @code[$indbegin..$size];
				$popname = join ('' , @population);
				$idind = join ('' , @individual);
				#print "sample $idind from population $popname\n";
			}
			$uniquevalues{$indname} = $popname;			#save the data in a hash
			$k++;
		}
	} else {
		print "error defining variable \$indname, it should be defined as \"INCLUDES\" OR \"AFTER\", it was defined as \"". $indname . "\"\n";
	}
}

########### SAVE
my $hashsize = keys %uniquevalues;

#save a file with the populations present in the file

my %unicpop = ();
my $pop = 0;
foreach (keys%uniquevalues) {
	$pop = $uniquevalues{$_};
	$unicpop{$pop} = 42;
}
my $popnum = keys %unicpop;

print "\n\n$k files found, $hashsize files had unique sample names (individuals) for $popnum populations.\n";

my $popmap = "$path"."/"."popmap";
open(my $OUT1, '>', $popmap) or die "error creating $popmap for saving the informationtion: $!";
#Loop over the hash, sort it and print it
foreach my $sorting (sort keys %uniquevalues) {
	print $OUT1 "$sorting$sep$uniquevalues{$sorting}\n";
}


my $indlist = "$path"."/"."ind_list";
open(my $OUT2, '>', $indlist) or die "error creating $indlist for saving the informationtion: $!";
#Loop over the hash
foreach my $indivs (sort keys %uniquevalues) {print $OUT2 "$indivs\n";}
close $OUT2;

my $uniquepops = "$path"."/"."unique_pops";
open(my $OUT4, '>', $uniquepops) or die "error creating $uniquepops for saving the informationtion: $!";
#Loop over the hash
foreach my $pops (sort keys %unicpop) {print $OUT4 "$pops\n";}
close $OUT4;

print "popmap created succesfully!\n\n";

