process GETITD {
	tag "${Sample}"	
    label 'process_low'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*_getitd'
	input:
		tuple val (Sample), file(fastq)
	output:
		tuple val (Sample), path ("${Sample}_getitd")
	script:
	"""
	python3 /opt/getitd/getitd.py -reference /opt/getitd/anno/amplicon.txt -anno /opt/getitd/anno/amplicon_kayser.tsv -forward_adapter AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT -reverse_adapter CAAGCAGAAGACGGCATACGAGATCGGTCTCGGCATTCCTGCTGAACCGCTCTTCCGATCT -nkern ${task.cpus} ${Sample} ${Sample}_chr13.fastq
	"""
}
