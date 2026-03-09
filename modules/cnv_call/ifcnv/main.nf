process IFCNV {
	tag "${Sample}"
	label 'process_inter'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy'
	input:
		tuple val (Sample), file (bam), file (bamBai)
		file (bedfile)
	output:
		tuple val (Sample), file ("*")
	script:
	"""
	ifCNV -i ./ -b ${bedfile} -o ${Sample}_ifCNV -sv True -a ''
	"""
}
