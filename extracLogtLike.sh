#!/bin/bash 

#quickly adapted from my "launch_structure" file to extract log likelihood values from previous runs

##################	
                ##	
                ##	
MAXPOPS=5	    ##	Set the maximum number of cluster or populations you want to test, usually ~ number of a priori locations + 2 (MAXPOPS in the file mainparams)
RUNSNUM=3	    ##	Set the number of independent runs (repetitions or iterations) you want for each value of K tested (between 5 and 15 is enough to test convergence)
                ##	
                ##	
##################	



printf "\nExtracting the likelihood of each run\n"
for ((k=1; k<=$MAXPOPS; k++))			
do
	for ((r=0; r<=$RUNSNUM; r++))		
	do
		printf "."
		#you will need to change the path and file name.
		grep -H "Estimated Ln Prob of Data" /cygdrive/d/Dropbox/MOSKY/CURRO/marine_stuff/STRUCTURE/OCTOPUS/Miguel/results_test/iteration"$r"_K"$k"_f >> /cygdrive/d/Dropbox/MOSKY/CURRO/marine_stuff/STRUCTURE/OCTOPUS/Miguel/results_test/loglikelihood.txt
	done
done

printf "\nResults ready!\n\n"