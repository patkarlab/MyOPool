process IGV_REPORTS {
	tag "${Sample}"
    label 'process_inter'
    publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.html'
	input:
		tuple val(Sample), file (bam), file (bamBai), file (MultiannoVcf)
		path (GenFile)
		path (GenDir)
	output:
		tuple val(Sample), file("${Sample}_igv.html")
	script:
	"""
	create_report ${MultiannoVcf} --fasta ${GenFile} --standalone --tracks ${bam} --output ${Sample}_igv.html
	"""		
}