Scripts that can be used to handle data in order to do some genomics or population genetics analysis.
This does not include the software for the analysis (such as: FastStructure, Plink, Arlequin...), just scripts to prepare the data for the analysis or to extract specific results from the output.
Most of these scripts have their own help information that can be called using the usual flags (-h, --help, etc.).

- ped_fixer 
- prune_plinkLD this will call multiple programs in order to produce a sorted input file for Plink from a vcf file, it can also remove loci in LD with Plink
  Programs needed: bcftools bgzip tabix vcftools plink
  Scrips needed: ped_fixer
- grep_scaffolds outputs scaffold length from all scaffolds in a fasta file. If a list of scaffolds is parsed it will also output the sequences from those scaffolds
- SNeP_output_grep will save a table of Ne estimates from different SNeP file outputs
- maker_structure will create multiple Structure submission files for a range of parameters and also the file to submit them all (for our cloud computing server)
- extractLogtlike: extract the log likelihood from each K ran in Structure (outdated, it was used in an old Structure Unix pipeline)
- str_likelihood: extract the row of likelihood values from each Structure independent run outut to a table (outdated)
- bowtie_maker will generate the submission files for bowtie (for our cloud computing server)
- popmap_maker it has been moved to M-Osky/handle_edit_files
- save_signif_loci is a shameful script I did to extract loci with significant pair-wise Fst from the general tsv files (program 'populations' from Stacks)


