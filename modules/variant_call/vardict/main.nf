process VARDICT {
	tag "${Sample}"
    label 'process_inter'
	input:
		tuple val (Sample), file (bam), file (bamBai)
		path (GenFile)
		path (GenDir)
		file (bedfile)
	output:
		tuple val (Sample), file ("${Sample}_vardict.vcf")
	script:
	"""
	java -Xmx${task.memory.toGiga()}g -jar /usr/local/share/vardict-java-1.8.3-0/lib/VarDict-1.8.3.jar -G ${GenFile} -th ${task.cpus} -f 0.03 -N ${Sample} -b ${bam} -O 50 -c 1 -S 2 -E 3 -g 4 ${bedfile} | sed '1d' | teststrandbias.R |  var2vcf_valid.pl -N ${Sample} -E -f 0.03 > ${Sample}_vardict.vcf
	"""
}
