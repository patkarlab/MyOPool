process FORMAT_VEP_CANCERVAR {
	tag "${Sample}"
	label 'process_low'
	input:
		tuple val (Sample), file(vep_out), file (finalConcat), file (artefacts), file (cancervarMultianno)
	output:
		tuple val (Sample), file("${Sample}_cancervar.tsv")
	script:
	"""
	vep_extract.py ${finalConcat} ${vep_out} > ${Sample}.vep
	cancervar_extract.py ${cancervarMultianno} ${Sample}.vep ${Sample}_cancervar.tsv
	"""
}
