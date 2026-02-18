process HSMETRICS {
	tag "${Sample}"
	label 'process_low'
	input:
		tuple val(Sample), path(bam), path(bai)
		path (bedfile)
		path (bedfile_exonwise)
		path (GenFile)
		path (GenDir)
	output:
		path("${Sample}_hsmetrics.txt"), emit: probewise
		path("${Sample}_hsmetrics_exonwise.txt"), emit: exonwise
	script:
	"""
	gatk BedToIntervalList I=${bedfile} O=${bedfile}_sortd.interval_list SD=${GenFile}.dict
	gatk CollectHsMetrics I=${bam} O=${Sample}_hsmetrics.txt BAIT_INTERVALS=${bedfile}_sortd.interval_list TARGET_INTERVALS=${bedfile}_sortd.interval_list R= ${GenFile} VALIDATION_STRINGENCY=LENIENT
    
	gatk BedToIntervalList I=${bedfile_exonwise} O=${bedfile_exonwise}_sortd.interval_list SD=${GenFile}.dict
	gatk CollectHsMetrics I=${bam} O=${Sample}_hsmetrics_exonwise.txt BAIT_INTERVALS=${bedfile_exonwise}_sortd.interval_list TARGET_INTERVALS=${bedfile_exonwise}_sortd.interval_list R= ${GenFile} VALIDATION_STRINGENCY=LENIENT
	"""
}

process HSMETRICS_COLLECT {
	label 'process_low'
	publishDir "${params.output}/", mode: 'copy'
	input:
		file (ProbeWise) 
		file (ExonWise)
	output:
		file("hsmetrics_probewise.txt") 
		file("hsmetrics_exonwise.txt")
	script:
	"""
	echo -e "Sample name\tOn target\tOff target" > hsmetrics_probewise.txt
	for i in ${ProbeWise}
	do
		samp_name=\$(basename -s .txt \${i})
		grep -v '#' \${i} | awk -v name=\${samp_name} 'BEGIN{FS="\t"; OFS="\t"}NR==3{ print name,\$7,\$8}' >> hsmetrics_probewise.txt
	done

	echo -e "Sample name\tOn target\tOff target" > hsmetrics_exonwise.txt
	for i in ${ExonWise}
	do
		samp_name=\$(basename -s .txt \${i})
		grep -v '#' \${i} | awk -v name=\${samp_name} 'BEGIN{FS="\t"; OFS="\t"}NR==3{ print name,\$7,\$8}' >> hsmetrics_exonwise.txt
	done
	"""
}
