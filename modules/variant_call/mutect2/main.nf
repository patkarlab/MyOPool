process MUTECT2 {
	tag "${Sample}"
	label 'process_inter'
	input:
		tuple val (Sample), file(subsampledBam), file(subsampledBamBai)
		path (GenFile)
		path (GenDir)
		path (bedfile)
		path (knownSNPs)
		path (knownSNPs_index)		
	output:
		tuple val (Sample), file ("${Sample}_mutect.vcf")
	script:
	"""
	mv ${GenFile}.dict ${GenFile.simpleName}.dict
	gatk --java-options "-Xmx${task.memory.toGiga()}g" Mutect2 -R ${GenFile} -I:tumor ${subsampledBam} -O ${Sample}_mutect.vcf --germline-resource ${knownSNPs} -L ${bedfile} --native-pair-hmm-threads ${task.cpus} -mbq 25
	"""
}