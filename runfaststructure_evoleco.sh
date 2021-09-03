#!/bin/bash 

# FastStructure launcher
#It asumes that the input file is in the right str format for fast structure
# To launch it just write:		bash runfaststructure_evoleco.sh
#It will run fast structure for the range of K set and then it check which is the most probable K

########################################################	This is a quick script to submit the runs of faststructure
                                                      ##	
                                                      ##	
MAXPOPS=10                                             ##	Set the maximum number of cluster or populations you want to test
INPUTFILE=lemurian_gamusins_42populations_FastStr                                ##	Name of our inputfile, without extension
OUTFOLDER=out_simp                                        ##	Output directory
PRIOR=simple                                        ##	Choose "simple" (quicker) or "logistic" (better when population structure is weak).
REPEAT=4                                            ##	Number of repeats for cross-validation
                                                      ##	
                                                      ##	
########################################################	Out of this square do not modify anything unless you know what you are doing

#Before proceeding check where is faststructure installed and be sure that you add the path for python in "export PATH=$PATH"
PROGRAMPATH=/software/fastStructure

#minmimum k you want to check. Don't change this unless you have a strong reason
KMIN=1

#Set curent directory as a workpath
WORKPATH=$(pwd)
echo "$WORKPATH"

#Additionaly you can manually set the Working directory
# WORKPATH=/home/moscar/lizards/faststructure

#This will be added at the end of the input file name to generate output file names
SUFIX="_out"



########################################################################################



WHOLEINPUT="$INPUTFILE.str"


if [ -d "$OUTFOLDER" ]
then 
	printf "\nAlready existing sub-directory will be used as output directory: $OUTFOLDER\n"
else 
	mkdir -p $OUTFOLDER
	printf "\nOutput directory created succesfully: $OUTFOLDER\n"
fi

STRUCTUREPATH="$PROGRAMPATH/structure.py"

OUTNAME="$INPUTFILE$SUFIX"
INPATH="$WORKPATH/$INPUTFILE"
OUTPATH="$WORKPATH/$OUTFOLDER/$OUTNAME"
printf "Reading data from $INPATH.str\n"


printf "\nFastStructure analysis:\n"
for ((k=$KMIN; k<=$MAXPOPS; k++))			#THIS SHOULD STAR IN K=1 UNLESS THERE IS SOME REASON!!																		#k=1
do
	printf "\tRunning analysis for K = $k ...\t"
	python $STRUCTUREPATH -K $k --input=$INPATH --output=$OUTPATH --prior=$PRIOR --cv=$REPEAT --format=str --full
	printf "	Done\n"
done
printf "\nFinished without errors (hopefully). "
printf "Results ready!\n\n"
printf "\nNow comparing the output files: $OUTPATH\n"

CHOOSEK="chooseK.py"
BESTK="BestK.txt"
KPATH="$PROGRAMPATH/$CHOOSEK"
SAVEK="$WORKPATH/BestK.txt"

BESTK= python $KPATH --input=$OUTPATH

python $KPATH --input=$OUTPATH > $SAVEK

echo $BESTK
printf "\nReady to plot.\n"
