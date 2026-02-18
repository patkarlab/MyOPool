process CHR13_BAM_GEN { 
	tag "${Sample}"
	label 'process_low'
	input:
		tuple val(Sample), file(bam), file(bamBai)
	output:
		tuple val (Sample), file ("${Sample}.chr13.bam")
	script:
	"""
	samtools view -@ ${task.cpus} ${bam} -b -h chr13 > ${Sample}.chr13.bam
	"""
}