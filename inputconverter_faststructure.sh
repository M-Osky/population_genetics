#!/bin/bash 

#inputconverter_faststructure version 2.5 (08/09/2020)

# transforms populations.structure file from populations->dataset_fixer->PGDSpider to faststructure input file format
# it will also create a popmap file and a file with the populations tags for each sample for the plots
# use the file with the populations to add tags when plotting the results
# it will extract the alphabetical characters from the individual tags and use them as population names!

# To launch it just write:		bash inputconverter_faststructure.sh


####### PARAMETERS TO SET UP
####################################################################################################
                                                        
                                                        
OUTNAME="lemurian_gamusins_42populations_FastStr"                       ##	Output file name, name you want for your FastStructure input file (WITHOUT THE EXTENSION)
#OUTNAME="sicula596x21k_m05r6R7h6DP420_noLDtabHWe_fastK"                       ##	Output file name, name you want for your FastStructure input file (WITHOUT THE EXTENSION)
														
INPUTNAME="gamusins42pop.str"                      ##	Name of the input file you want to transform (with extension)
#INPUTNAME="populations.structure_FINAL.str"                                  ##	Name of the input file you want to transform
														
########################################################	Out of this square do not modify anything unless you know what you are doing


#               change log
#   Version 2: Works with populations.structure_FINAL.str
#       Now it deletes only one row (marker names row) and extracts the alphabetical part of each individual tag to make a new popul



WHOLEINPUT="$OUTNAME.str"
TEMP="temp.txt"

printf "\n\nReading file \"$INPUTNAME\"\n"

cp $INPUTNAME $TEMP
sed -i '1d' $TEMP			#use sed (text lines editor) to delete the two entire first lines '1,2d' (comments and loci names), save it in-situ, in the same file (-i).
sed -i 's/\t0/\t-9/g' $TEMP		# substitute the 0s with -9s (s/0/9/) and do it globaly for all the matches (g)


perl -lne '/^(\w*?)(\d*?)\t(.*?)\t(.*?)$/; print "$1$2\t$1\t$3\t$3\t$1$2\t$1\t$4"' $TEMP > $WHOLEINPUT #extract the population tags, and place them at column 2 and 6, loci will start at column 7


cut -f 1-2 $WHOLEINPUT > sample_pop_list
cut -f 1 $WHOLEINPUT > sampleIDlist
cut -f 2 $WHOLEINPUT > samplePOPlist		#extract the individual and pop names (columns 1 and 2) for distruct


sed -n 1~2p samplePOPlist > populations
sed -n 1~2p sampleIDlist > ind_list
sed -n 1~2p sample_pop_list > popmap

rm sample_pop_list
rm sampleIDlist
rm samplePOPlist

printf "Population map (with one row per sample) saved as \"popmap\"\n"

#perl -lne '/^(.*?)\t(.*?)\t(.*?)$/; print "$1\t$2\t1\t2\t$2\t$1\t$3"' $TEMP > $WHOLEINPUT #let the ID tags at the beggining and end of the file, making a total of 6 columns of metadata
# # #perl -lne '/^(.*?)\t(..)\t(.*?)$/; print "$1\t$3"' $TEMP > $WHOLEINPUT #let the ID tags at the beggining and end of the file, making a total of 6 columns of metadata
rm temp.txt
printf "FastStructure input file generated and saved as $WHOLEINPUT\n\n"


printf "Done!\n\n"







