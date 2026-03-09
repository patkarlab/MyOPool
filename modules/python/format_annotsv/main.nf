process FORMAT_ANNOTSV {
	tag "${Sample}"
    label 'process_low'
    publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*_AnnotSV.tsv'
	input:
		tuple val (Sample), file (annotsv_tsv)
	output:
		tuple val (Sample), file ("*_AnnotSV.tsv")
	script:
	"""
	substitute_null.py ${annotsv_tsv} ${Sample}_AnnotSV.tsv
	"""
}