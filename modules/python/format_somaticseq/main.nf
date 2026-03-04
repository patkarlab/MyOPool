process FORMAT_SOMATICSEQ {
	tag "${Sample}"
	label 'process_low'
	input:
		tuple val (Sample), file (somaticseq_multianno)
		path (artefacts)
	output:
		tuple val (Sample), file ("${Sample}.final.concat.csv"), file ("${Sample}.artefacts.csv")
	script:
	"""
	somaticseqoutput-format.py ${somaticseq_multianno} ${Sample}.somaticseq.csv
	remove_artefacts.py ${Sample}.somaticseq.csv ${artefacts} ${Sample}.final.concat.csv ${Sample}.artefacts.csv
	"""
}
