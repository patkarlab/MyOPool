process CANCERVAR_PREPROCESS {
	tag "${Sample}"
    label 'process_inter'
	input:
		tuple val (Sample), path(somaticseq_multianno)
        path (cancervar_config)
	output:
		tuple val(Sample), file ("${Sample}_cancervar_input.dat"), file ("${cancervar_config}")
	script:
	"""
    cancervar_input.py ${somaticseq_multianno} ${Sample}_cancervar_input.dat
    sed -i -r "s/inputfile = .*/inputfile = ${Sample}_cancervar_input.dat/g" ${cancervar_config}
    sed -i -r "s/outfile = .*/outfile = ${Sample}myanno/g" ${cancervar_config}
	"""
}