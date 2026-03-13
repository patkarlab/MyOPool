process FORMAT_CAVA {
	tag "${Sample}"
    label 'process_low'
	input:
		tuple val(Sample), file (somaticseq_cava), file (combinevariants_cava)
	output:
		tuple val(Sample), file ("${Sample}.cava.csv")
	script:
	"""
	cava_concat.py ${somaticseq_cava} ${combinevariants_cava} ${Sample}.cava.csv
	"""
}