process OFFTARGET_BAM_INDEX {
	tag "${Sample}"
	input:
		tuple val (Sample), file(offtarget_bam)
	output:
		tuple val (Sample), file ("${Sample}_offtarget.bam"), file ("${Sample}_offtarget.bam.bai")
	script:
	"""
	samtools index ${offtarget_bam} > ${Sample}_offtarget.bam.bai
	"""
}