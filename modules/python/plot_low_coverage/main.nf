process PLOT_LOW_COVERAGE {
    tag "${Sample}"
    label 'process_low'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.Low_Coverage.png'
	input:
		tuple val (Sample), file(countsBed)
	output:
		tuple val (Sample), file("${Sample}.Low_Coverage.png")
	script:
	"""
	coverageplot.py ${Sample} ${countsBed} ./
	"""
}