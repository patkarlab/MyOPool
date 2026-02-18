process BAM_TO_FASTQ { 
	tag "${Sample}"
	label 'process_low'
	input:
		tuple val(Sample), file(chr13_bam)
	output:
		tuple val (Sample), path("${Sample}_chr13.fastq")
	script:
	"""
	bedtools bamtofastq -i ${chr13_bam} -fq ${Sample}_chr13.fastq
	"""
}