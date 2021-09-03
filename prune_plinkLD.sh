#!/bin/bash 

# dataset_fixer   			# by M'Óscar (M-Osky at GitHub)
VERSION="prune_plinkLD.sh"
DATE="17/07/2020"

# Use this to prune a vcf file from loci in LD; use any usual help flag to check options ("help" or "--h" or so...)
#	prune_plinkLD.sh -help









################################################################################################################
############################ DEFAULT PARAMETERS. ALL CUSTOMIZABLE FROM COMMAND LINE. ###########################
################################################################################################################

####program locations
BCFTOOLS="/shared/astambuk/software/bcftools-1.10.2/bcftools"
BGZIP="bgzip"
TABIX="tabix"
VCFTOOLS="vcftools"
PLINK="/shared/astambuk/software/plink19/plink"
PEDFIXER="ped_fixer.pl"


####You want to load vcftools from Isabella modules?
MODULE="yes"


####ped_fixer.pl parameters

#file with the info
PEDMAP="No default"

#rest of parameters
PEDPAR=""


#Parameter to filter loci

#Prune method
PRUNE="--indep-pairwise 50 5 0.5"

#Extra options
PLINKPAR="--allow-extra-chr --allow-no-sex"


#Input file
INPUT="populations.snps.vcf"

#Delete transition and temporary files?
CLEAN="no"


#Help!
HELP="\n\n\t   $VERSION   $DATE Help Information\n\t----------------------------------------------------------\n
\n\tThis script will process a vcf file in order for it to be analyzable by Plink.
\tOnce the Scaffold format is properly formated will prune loci in LD with Plink.
\n\t\tOptions:
\t\t--input / --vcf            name/path of the input file. Default: $INPUT\n
\t\tbgzip and tabix will be used to sort loci and create an zip file indexed by chromosome:
\t\t--zip                      bgzip program path. Default: $BGZIP
\t\t--tbx                      tabix program path. Default: $TABIX\n
\t\tbcftools will be used to create a chromosome map:
\t\t--bcf                      bcftools program path. Default: $BCFTOOLS\n
\t\tvcftools will be used to create a plink input file with the chromosome map:
\t\t--module                   [yes/no] use vcftools from Isabella modules? Default: $MODULE
\t\t--vcftools                 vcftools program path. Default: $VCFTOOLS\n
\t\tped_fixer will be used to add relevant information to the Plink ped file:
\t\t--fixer                    ped_fixer.pl program path. Default: $PEDFIXER
\t\t--map                      map file with the extra information for ped_fixer. $PEDMAP
\t\t--par1                     Any extra arguments for per_fixer? (check its help information).$PEDPAR\n
\t\tFinally Plink will be used for pruning loci in LD from the dataset_fixer:
\t\t--plink                    path to Plink software. Default: $PLINK
\t\t--prune                    method/parameters to prune the loci. Default: \'$PRUNE\'\n\t\t                           [if \'--prune no\' will skip the LD loci pruning part]
\t\t--par2                     extra arguments for Plink. Default: \'$PLINKPAR\'\n\n
\t\t--clean                    [yes/no] Do you want to remove all temporary files?. Default: $CLEAN\n\n
\t\tWith the exception of ped_fixer, none of the software used belong to us, they all have their own help file
\t\tthey should be installed and used at your own risk.\n\t\tThis is also true for ped_fixer and prune_plinkLD, but with those we may be able to help.\n
\t\tUsage:\n\t\t$VERSION --vcf gamusins_m05r6R7h6.vcf --map gamusins_data.txt\n\n\n"



######################################################################
################   NOTHING TO SEE BELOW THIS LINE   ##################
######################################################################


#save arguments
#ARGUMENTS=( "$@" )
NUMBER=$#


while test $# -gt 0; do
	case "$1" in
		-h|h|--help|--h|-help|help)
			printf "$HELP"
			exit 0
			;;
		--input)
			shift
			INPUT=$1
			shift
			;;
		--vcf)
			shift
			INPUT=$1
			shift
			;;
		--zip)
			shift
			BGZIP=$1
			shift
			;;
		--tbx)
			shift
			TABIX=$1
			shift
			;;
		--bcf)
			shift
			BCFTOOLS=$1
			shift
			;;
		--bcftools)
			shift
			BCFTOOLS=$1
			shift
			;;
		--module)
			shift
			MODULE=$1
			shift
			;;
		--vcftools)
			shift
			BCFTOOLS=$1
			shift
			;;
		--fixer)
			shift
			PEDFIXER=$1
			shift
			;;
		--map)
			shift
			PEDMAP=$1
			shift
			;;
		--par1)
			shift
			PEDPAR=$1
			shift
			;;
		--plink)
			shift
			PLINK=$1
			shift
			;;
		--prune)
			shift
			PRUNE=$1
			shift
			;;
		--par2)
			shift
			PLINKPAR=$1
			shift
			;;
		--clean)
			shift
			CLEAN=$1
			shift
			;;
		*)
			printf "\n\n\tERROR!\n\t$1 is not a recognized flag!\n\n$HELP"
			exit 0;
		;;
	esac
done



###############################################
##### process the arguments

if [ "$MODULE" == "yes" ]
then
	MODULE="module load $VCFTOOLS"
elif [ "$MODULE"=="no" ]
then
	MODULE=""
else
	printf "\n\n\tERROR\n\tArgument module was invalid. Only \"yes\" or \"no\" accepted, but \"$MODULE\" was parsed\n\tCheck the help information and try again.\n\t prune_plinkLD.pl h"
	exit 0
fi



# Filenames

MYDIR=$(dirname $INPUT)
VCFNAME=$(basename $INPUT)
FILENAME=$(basename $INPUT ".vcf")



SORTED="$MYDIR/sorted_$VCFNAME"
ZIPED="$MYDIR/bgzip_$FILENAME.gz"
CHROM="$MYDIR/chrom-map_$FILENAME.txt"
VCFTFILE="$MYDIR/vcftools_$FILENAME"
PEDFILE="$MYDIR/vcftools_$FILENAME.ped"
TAG1="_plink"
INPLINK="$MYDIR/$FILENAME$TAG1"
TAG2="_noLD"
OUT="$MYDIR/$FILENAME$TAG2"
BKP="_backup.ped"


##########


printf "\n$VERSION is running\n\nSorting loci in $VCFNAME\n"

# set -x
echo "cat $INPUT | awk '\$1 ~ /^#/ {print \$0;next} {print \$0 | "sort -k1,1V -k2,2g"}' > $SORTED"
cat $INPUT | awk '$1 ~ /^#/ {print $0;next} {print $0 | "sort -k1,1V -k2,2g"}' > $SORTED
# set +x

printf "\nCompressing with an indexable format\n"
# set -x
echo "$BGZIP -c $SORTED > $ZIPED"
$BGZIP -c $SORTED > $ZIPED
# set +x

 printf "\nIndexing...\n"
# set -x
echo "$TABIX -p vcf $ZIPED"
$TABIX -p vcf $ZIPED
# set +x

printf "\nPrinting a chromosome map\n"
# set -x
echo "$BCFTOOLS view -H $ZIPED | cut -f 1 | uniq | awk '{print \$0\"\t\"\$0}' > $CHROM"
$BCFTOOLS view -H $ZIPED | cut -f 1 | uniq | awk '{print $0"\t"$0}' > $CHROM
# set +x


printf "\n\nFormating to Plink input file with VCFtools\n\n"
# set -x
printf "\n$MODULE\n"
$MODULE
$VCFTOOLS --gzvcf $ZIPED --plink --chrom-map $CHROM --out $VCFTFILE
# set +x

printf "\n\nAdding relevant information to file with ped_fixer\n\n"
# set -x
$PEDFIXER --ped $PEDFILE --map $PEDMAP $PEDPAR
# set +x


printf "\nCoding plink binary file\n\n\n"
	
# echo "$PLINK --file $VCFTFILE --make-bed --out $INPLINK $PLINKPAR"
$PLINK --file $VCFTFILE --make-bed --out $INPLINK $PLINKPAR



if [ "$PRUNE" == "no" ]
then
	printf "\nFile should be now properly formated. Program will stop now because \'--prune $PRUNE\' was parsed.\n"
else
	printf "\n\nPerforming LD test\n\n\n"
	# set -x
	$PLINK --bfile $INPLINK $PRUNE $PLINKPAR
	# set +x

	printf "\n\nFiltering out linked loci\n\n\n"
	# set -x
	$PLINK --bfile $INPLINK --extract plink.prune.in --out $OUT --make-bed --recode $PLINKPAR
	# set +x

	printf "\n\n\nDone!\nOutput files with only unlinked loci are named $OUT\n"
fi

if [ "$CLEAN" == "yes" ]
then
	printf "Deleting temporary files.\n"
	rm $SORTED
	rm $ZIPED
	rm $ZIPED.tbi
	rm $CHROM
	rm *.log
	rm $VCFTFILE$BKP
	rm *nosex
fi

printf "\n$VERSION finished\n\n\n"
