#!/usr/bin/perl
use strict ; use warnings;

# SNeP_output_grep   			# by M'Óscar 
my $programname = "grep_scaffolds.pl";
my $version = "0.3";  #printing results in each loop instead of storing them, should be faster that  way (I hope). Also posibility to ignore "N"

############################

# Use this script to extract scaffolds from a fasta file

#####fasta file example
#>Scaffold42
#GGGGGGCAGGCTGTAGCCATGGACATGCTATGTGATCTGATGGTGAATTTGG
#>Scaffold48151623
#AACATAAAAGGCGCAGGAATTAGTCCTTCCACCAACAGTTTAATACAAGAGATCAATGTTTTCCTGCAAAGAGAACGTGG
#AGGGACCGAGGTTTCCCCCAATGAAGAAGACAAGAAGGTCAGCTTCACACTGAACATACAATCTGAAGGAACTGAAGTTT
#CCATGAAGAGGTTAGTCGGCGACnnnnnnGCTTTCCTTACCGAGGAAACGGGAATCACAGAATATTCCCTGAACGCCGGA
#GGCCAAGGAATCCCTCGGCAACCCAACTCAGCAGAACAGCAGATCCGATTTACTCTTCATATAAAAGGGCAAGGCATGGA
#ATCAGCTCTTAAGAGATTACTCAAAAAGAGCAGGTTTCTTCTCCTAGCCCAAAAGGATTTCCGTAATATTTCAATGA



#######################   PARAMETERS   #########################
# All of them can and should be set from the command line, check the help.

my $def = "default";  # better do not chage this.

my $inputfile = $def;  		# directory with the SNeP output files

my $filter = ".fa"; #ending the fasta file must have

my $filelist = "$def"; #file with the list of scaffolds

my $outname = $def;

my $non = 0;

#################################################################################################################




#Help!
my %arguments = map { $_ => 1 } @ARGV;
if(exists($arguments{"help"}) || exists($arguments{"--help"}) || exists($arguments{"-help"}) || exists($arguments{"-h"}) || exists($arguments{"--h"})) {
	die "\n\n\t  $programname v$version   Help Information\n\t-------------------------------------------------\n
	This program will output scaffold lengths from all scaffolds in a fasta file.\n\tIf a list of scaffolds is parsed it will also output the sequences from those scaffolds
	If no fasta file is parsed it will analyse the first file.fa found in working directory.
	\n\tCommand line arguments and defaults:\n
	--in                      Name (or path) of the fasta file, if none parsed will analyse the first one found.\n
	--list                    List of scaffolds to copy, if no file is parsed will output all scaffold lengths.
	                          file with list of scaffolds must have one scaffold per line.\n
	--out                     Name for the output files. Otherwise will be generated automatically.\n
	--non                     add this flag if you want indetermined nucleotides (N) to be ignored when calculating length\n
	Command line call example:\n\t$programname --in /home/genome/ref/refgenome.fa --list \"scaffold_list_dataset42.txt\"\n\n\n";
}



################ PASSING ARGUMENTS


use Getopt::Long;

GetOptions( "in=s" => \$inputfile,    #   --in
            "filter=s" => \$filter,      #   --filter
            "out=s" => \$outname,      #   --out
            "non" => \$non,      #   --out
            "list=s" => \$filelist );   #   --list



#read files

use Cwd qw(cwd);
my $localdir = cwd;

if ($inputfile eq $def) { 
	
	print "\nNo input parsed, reading files from $localdir\n";
	opendir(DIR, $localdir);
	my @files = readdir(DIR);
	closedir(DIR);
	foreach my $file (@files) {
		$inputfile = $file;
		next unless ($file =~ m/^.*$filter$/);
		last if ($file =~ m/^.*$filter$/);
	}
} else { print "\n" }
#print "$programname will analyse $inputfile\n\n";

if ($filelist ne $def) {
	
	print "Saving list of scaffolds from $filelist\n";
	open my $SCAFLIST, '<', $filelist or die "\nUnable to find or open $filelist: $!\n";
	
	my %seqscaffolds = ();
	
	#save scaffolds from list
	while (<$SCAFLIST>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*$/;  		#skip comments
		my $line = $_;  		#save line
		$line =~ s/\s+$//;  		#clean white tails in lines
		if (exists $seqscaffolds{$line}) { print "warning: $line appears more than once\n"; } else { $seqscaffolds{$line} = 0; }
	}
	
	close $SCAFLIST;
	
	my $listlength = scalar keys %seqscaffolds;
	print "$listlength scaffold names saved, now analysing $inputfile\n\n";
	
	
	
	### create output files
	
	my $fastafile = $def;
	my $tablefile = $def;
	
	if ($outname eq $def) {
		my $inputname = $inputfile;
		$inputname =~ s/^(.*?)$filter$/$1/;
		my $listname = $filelist;
		$listname =~ s/^(.*?)\..*$/$1/;
		my $outfile = "$inputname" . "_" . "$listname";
		$fastafile = "$outfile" . ".fa";
		$tablefile = "$outfile" . "_length.txt";
	} else {
		$fastafile = "$outname" . ".fa";
		$tablefile = "$outname" . ".txt";
	}
	
	#print "\n\n$tablefile\n\n";
	
	open my $SEQ, '>', $fastafile or die "\nUnable to create or save \"$fastafile\": $!\n";
	open my $SIZE, '>', $tablefile or die "\nUnable to create or save \"$tablefile\": $!\n";
	
	print $SIZE "Scaffold\tBP\n"; 
	
	open my $FASTA, '<', $inputfile or die "\nUnable to find or open $inputfile: $!\n";
	
	#save scaffolds from list
	my $k = 0;
	my $scafcount=0;
	my $scafname = $def;
	my $totalscaf=0;
	
	while (<$FASTA>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*$/;  		#skip comments
		my $line = $_;  		#save line
		$line =~ s/\s+$//;  		#clean white tails in lines
		
		if ($line =~ /^>.*$/ && $k==0) {
			#check if the scaffold is in the list to keep, save just name if no scaffold was being saved
			my $linescaf = $line;
			$linescaf =~ s/^>(.*?)$/$1/;
			$scafname = $linescaf;
			
			if (exists $seqscaffolds{$scafname}) { 
				
				print $SEQ ">$scafname\n"; #print name of chosen scaffold
				print $SIZE "$scafname\t"; #print name of chosen scaffold
				$scafcount++;
				$k=1;
			} else { 
				$k=0;
			}
			$totalscaf++;
		} elsif ($line !~ /^>.*$/ && $k==1) {
			#if scaffold name was saved and line is nucleotides,print and save size
			print $SEQ "$line\n"; #print sequences of chosen scaffold
			
			my $nucleotides = 0;
			
			if($non == 0) {
				$nucleotides = length($line);
			} elsif ($non == 1) {
				my $tomeasure = $line;
				$tomeasure =~ s/N//gi;
				$nucleotides = length($tomeasure);
			}
			
			$seqscaffolds{$scafname} = $seqscaffolds{$scafname} + $nucleotides;	    #save length of this sequence fragment (plus the previous)
		} elsif ($line =~ /^>.*$/ && $k==1) {
			#check if the scaffold is in the list to keep, save the previous scaffold
			
			#print size saved last time
			my $totalsize = $seqscaffolds{$scafname};
			print $SIZE "$totalsize\n"; #print size of chosen scaffold
			
			#mark as done
			$seqscaffolds{$scafname} = "done";
			
			#now process the new scaffold
			my $linescaf = $line;
			#save new scaffold
			$linescaf =~ s/^>(.*?)$/$1/;
			$scafname = $linescaf;
			
			if (exists $seqscaffolds{$scafname}) { 
				#print name to both files
				print $SEQ ">$scafname\n"; #print name of chosen scaffold
				print $SIZE "$scafname\t"; #print name of chosen scaffold
				
				$scafcount++;
				$k=1;
			} else { 
				$k=0;
			}
			$totalscaf++;
		}
		
	}
	close $FASTA;
	
	#in case the last scaffold was chosen, save it's size
	if ($k==1) {
		my $totalsize = $seqscaffolds{$scafname};
		print $SIZE "$totalsize\n"; #print size of chosen scaffold
	}
	
	print "Done! $scafcount scaffolds were found from a total of $totalscaf.\n";
	
	close $SEQ;
	
	#add also the scaffolds that were not found
	foreach my $key (keys %seqscaffolds) { 
		my $status = $seqscaffolds{$key};
		
		if($status ne "done") {
			print $SIZE "$key\tnot found\n";
		}
	
	}
	
	close $SIZE;
	
} elsif ($filelist eq $def) {
	
	print "No list of scaffolds parsed, analysing $inputfile\n\n";
	
	### create output files
	
	my $fastafile = $def;
	my $tablefile = $def;
	
	if ($outname eq $def) {
		my $inputname = $inputfile;
		$inputname =~ s/^(.*?)$filter$/$1/;
		$tablefile = "$inputname" . "_length.txt";
	} else {
		$tablefile = "$outname";
	}
	
	#print "\n\n$tablefile\n\n";
	
	open my $SIZE, '>', $tablefile or die "\nUnable to create or save \"$tablefile\": $!\n";
	
	print $SIZE "Scaffold\tBP\n"; 
	
	open my $FASTA, '<', $inputfile or die "\nUnable to find or open $inputfile: $!\n";
	
	#save scaffolds from list
	my $k = 0;
	my $scafname = $def;
	my $totalscaf=0;
	my %seqscaffolds = ();
	
	while (<$FASTA>) {
		chomp;	#clean "end of line" symbols
		next if /^$/;  		#skip if blank
		next if /^\s*$/;  		#skip if only empty spaces
		next if /^#.*$/;  		#skip comments
		my $line = $_;  		#save line
		$line =~ s/\s+$//;  		#clean white tails in lines
		
		if ($line =~ /^>.*$/ && $k==0) {
			#check if the scaffold is in the list to keep, save just name if no scaffold was being saved
			my $linescaf = $line;
			$linescaf =~ s/^>(.*?)$/$1/;
			$scafname = $linescaf;
			$seqscaffolds{$scafname} = 0;
			print $SIZE "$scafname\t"; #print name of chosen scaffold
			$k=1;
			$totalscaf++;
		} elsif ($line !~ /^>.*$/ && $k==1) {
			#scaffold name was saved and line is nucleotides,print and save size
			my $nucleotides = 0;
			
			if($non == 0) {
				$nucleotides = length($line);
			} elsif ($non == 1) {
				my $tomeasure = $line;
				$tomeasure =~ s/N//gi;	#remove Ns
				$nucleotides = length($tomeasure);
			}
			
			$seqscaffolds{$scafname} = $seqscaffolds{$scafname} + $nucleotides;	    #save length of this sequence fragment (plus the previous)
		} elsif ($line =~ /^>.*$/ && $k==1) {
			#check if the scaffold is in the list to keep, save the previous scaffold
			
			#print size saved last time
			my $totalsize = $seqscaffolds{$scafname};
			print $SIZE "$totalsize\n"; #print size of chosen scaffold
			
			#mark as done
			$seqscaffolds{$scafname} = "done";
			
			#now process the new scaffold
			my $linescaf = $line;
			#save new scaffold
			$linescaf =~ s/^>(.*?)$/$1/;
			$scafname = $linescaf;
			$seqscaffolds{$scafname} = 0;
			#print name
			print $SIZE "$scafname\t"; #print name of chosen scaffold
			$k=1;
			$totalscaf++;
		}
		
	}
	
	close $FASTA;
	
	#save last scaffold size
	if ($k==1) {
		my $totalsize = $seqscaffolds{$scafname};
		print $SIZE "$totalsize\n"; #print size of chosen scaffold
	}
	
	print "Done! $totalscaf scaffolds saved as $tablefile.\n";
	
	close $SIZE;
	
}


print "All done! $programname finished.\n\n\n";

