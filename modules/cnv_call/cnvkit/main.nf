process CNVKIT {
	tag "${Sample}"
	label 'process_inter'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.final-scatter.png'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.final-diagram.pdf'
	input:
		tuple val (Sample), file (bam), file (bamBai)
		file (cnvkit_ref)
	output:
		tuple val (Sample), file ("${Sample}.final.cnr"), file ("${Sample}.final.cns"), emit: cnvkit_files
		tuple val (Sample), file ("${Sample}.final-scatter.png"), file ("${Sample}.final-diagram.pdf"), emit: cnvkit_plots
	script:
	"""
	cnvkit.py batch ${bam} -r ${cnvkit_ref} -m hybrid --drop-low-coverage --output-dir ./ --diagram --scatter
	"""
}
