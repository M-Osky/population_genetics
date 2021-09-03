Auxiliary scripts that can be used to handle data in order to do some genomics or population genetics analysis with other programs.
This does not include the software for the analysis (such as: FastStructure, Plink, Arlequin, bcftools, vcftools, etc.), just scripts to prepare the data for the analysis or to extract specific results from the output.
These scripts have their own help information that can be called using the usual flags (-h, --help, etc.).

- ped_fixer - edits ped files (Plink auxiliary input file) with information from another file 
- prune_plinkLD - this will call multiple programs in order to produce a sorted input file for Plink from a vcf file, it can also remove loci in LD with Plink
  Programs needed: bcftools bgzip tabix vcftools plink
  Scrips needed: ped_fixer
- grep_scaffolds - outputs scaffold length from all scaffolds in a fasta file. If a list of scaffolds is parsed it will also output the sequences from those scaffolds
- treemix_formater - will generate a TreeMix / spatPG input file from a vcf file
- tajimaDextract - extracts tajima D values from vcftools output and prints some summary estatistics
- bach_savenames_signif_bayescan - will outpout a list of significant loci names from multiple Bayescan outputs
- inputconverter_faststructure - used to convert a Structure input file to a FastStructure format, also outputs a popmap and list of population codes needed to plot
- runfaststructure_evoleco - used to run multiple independent FastStructure analyses for a range of Ks, will also look for the "best" K (needs FastStructure)
- plotBestKs - plots the best results (or a range of K values) from FastStructure (needs distruct)
- admixture_batchmaker - generates multiple submission scripts of Admixture for a range of K values as independent jobs (for our cloud computing server).
  Will generate a script to grep results from all output directories in a table.
- refmap_bachmaker - will generate multiple submission files to submit independent ref_map jobs (Stacks pipeline) for a range of values. (for our cloud computing server)
- bowtie_maker - will generate the submission files for bowtie (for our cloud computing server)
- SNeP_output_grep - will save a table of Ne estimates from different SNeP file outputs
- arlequin_project_maker - bach transforms all .arp files in a directory to one-population-per-group Arlequin projects
- maker_structure - will create multiple Structure submission files for a range of parameters and also the file to submit them all (for our cloud computing server)
- extractLogtlike - extract the log likelihood from each K ran in Structure (outdated, it was used in an old Structure Unix pipeline)
- str_likelihood - extract the row of likelihood values from each Structure independent run outut to a table (outdated)
- popmap_maker - it has been moved to M-Osky/handle_edit_files because its use is not exclusive for population genetics
- save_signif_loci - is a shameful script I did to extract loci with significant pair-wise Fst from the general tsv files (from program 'populations' from Stacks)
- coveragen_vcfilter has been moved to M-Osky/VCFiles because it's not an auxiliary script, it does perform analysis by itself


