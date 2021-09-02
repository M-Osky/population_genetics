Scripts that can be used to handle data in order to do some genomics or population genetics analysis.
This does not include the software for the analysis (such as: FastStructure, Plink, Arlequin...), just scripts to prepare the data for the analysis or to extract specific results from the output.
Most of these scripts have their own help information that can be called using the usual flags (-h, --help, etc.).

- maker_structure will create multiple Structure submission files for a range of parameters and also the file to submit them all (for our cloud computing server)
- extractLogtlike: extract the log likelihood from each K ran in Structure (outdated, it was used in an old Structure Unix pipeline)
- str_likelihood: extract the row of likelihood values from each Structure independent run outut to a table (outdated)
- bowtie_maker will generate the submission files for bowtie (for our cloud computing server)

- popmap_maker it has been moved to another repository






- save_signif_loci is a shameful script I did to extract loci with significant pair-wise Fst from the general tsv files (program 'populations' from Stacks)


