process SUBSAMPLE {
	tag "${Sample}"
	input:
		tuple val (Sample), file(bam), file (bamBai)
	output:
		tuple val (Sample), file ("${Sample}_subsampled.bam"), file ("${Sample}_subsampled.bam.bai")
	script:
	"""
	samtools view -@ ${task.cpus} -bs 40.1 ${bam} > ${Sample}_subsampled.bam
	samtools index ${Sample}_subsampled.bam
	"""
}