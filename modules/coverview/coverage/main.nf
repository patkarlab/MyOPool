process COVERVIEW {
	tag "${Sample}"
    label 'process_low'
	input:
		tuple val (Sample), file(bam), file(bamBai)
        path (bedfile_exonwise)
        path (coverview_config)
	output:
		tuple val (Sample), file ("${Sample}.coverview_regions.txt")
	script:
	"""
	coverview -i ${bam} -b ${bedfile_exonwise} -c ${coverview_config} -o ${Sample}.coverview
	"""
}