process FLT3_ITD_EXT {
	tag "${Sample}"
	label 'process_low'
	input:
		tuple val (Sample), file(bam), file(bamBai)
	output:
		tuple val (Sample), file("${Sample}*.vcf")
	script:
	"""
	perl /biosoft/FLT3_ITD_ext/FLT3_ITD_ext.pl --bam ${bam} -o ./ || true
	"""
}