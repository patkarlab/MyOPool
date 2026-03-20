process COVERAGE_WGS {
	tag "${Sample}"
	publishDir "${params.outdir}/${Sample}/${Sample}-WGS/" , mode: 'copy'
	input:
	    tuple val(Sample), file(bam), file(bamBai)
		path (GenFile)
		path (GenDir)
	output:
	    file("${Sample}_WGS_coverage_metrics.txt")
	script:
	"""
	picard CollectWgsMetrics \
	I=${bam} \
	R=${GenFile} \
	O=${Sample}_WGS_coverage_metrics.txt
	"""
}

process COVERAGE_WGS_COLLECT {
	publishDir "${params.outdir}/", mode: 'copy'
	input:
		file (coverage_wgs)
	output:
		file("WGS_metrics.txt")
	script:
	"""
	echo -e "Sample name\tMean coverage" > WGS_metrics.txt
	for i in ${coverage_wgs}
	do
		samp_name=\$(basename -s -WGS_WGS_coverage_metrics.txt \${i})
		grep -v '#' \${i} | awk -v name=\${samp_name} 'BEGIN{FS="\t"; OFS="\t"} /^GENOME_TERRITORY/{getline; print name, \$2}' >> WGS_metrics.txt
	done
	"""
}