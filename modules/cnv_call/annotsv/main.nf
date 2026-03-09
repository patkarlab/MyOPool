process ANNOTSV {
	tag "${Sample}"
	label 'process_inter'
	input:
		tuple val (Sample), file (final_cnr), file (final_cns)
	output:
		tuple val (Sample), file ("${Sample}_annotsv.tsv")
	script:
	"""
	echo -e "# chrom\tStart\tEnd" > ${Sample}.bed
	awk 'BEGIN{OFS="\t"}NR>1{if(\$5 > 0.4 || \$5 < -0.4) print \$1,\$2,\$3}' ${final_cns} >> ${Sample}.bed
	no_of_line=\$(wc -l ${Sample}.bed | awk '{print \$1}')

	if [ \${no_of_line} -gt 1 ];then
		AnnotSV -SVinputFile ${Sample}.bed -outputFile ./${Sample}_annotsv.tsv -genomeBuild GRCh37
		rm ${Sample}.bed
	else
		touch ./${Sample}_annotsv.tsv
	fi
	"""
}
