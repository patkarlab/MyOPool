process OFFTARGET_BAM_GEN {
	tag "${Sample}"
	input:
		tuple val (Sample), file(bam), file (bamBai)
		file (bedfile)	
	output:
		tuple val (Sample), file ("${Sample}_offtarget.bam")
	script:
	"""
	bedtools intersect -abam ${bam} -b ${bedfile} -v > ${Sample}_offtarget.bam
	"""
}