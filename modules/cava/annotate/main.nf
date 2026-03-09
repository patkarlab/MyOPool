process CAVA {
	tag "${Sample}"
	label 'process_inter'
	input:
		tuple val(Sample), file (somaticseqVcf), file(combinedVcf)
		path (cava_config)
		path (GenFile)
		path (GenDir)
		path (bedfile)
		path (SNPs)
		path (SNPs_index)
		path (ensembl_db)
		path (ensembl_db_index)        
	output:
		val(Sample)
	script:
	"""
	cava.py -c ${cava_config} -i ${somaticseqVcf} -o ${Sample}.somaticseq
	cava.py -c ${cava_config} -i ${combinedVcf} -o ${Sample}.combined
	"""
}