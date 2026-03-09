process IGV_PREPROCESS {
	tag "${Sample}"
	label 'process_inter'
	input:
		tuple val (Sample), path(Vcf)
	output:
		tuple val (Sample), path("${Sample}.annovar.hg19_multianno.vcf")
	script:
	"""
    table_annovar.pl ${Vcf} --out ${Sample}.annovar --remove --protocol refGene,cytoBand,cosmic84,popfreq_all_20150413,avsnp150,intervar_20180118,1000g2015aug_all,clinvar_20170905 \
    --operation g,r,f,f,f,f,f,f --buildver hg19 --nastring . --otherinfo --thread ${task.cpus} /databases/humandb -xreffile /databases/gene_fullxref.txt -vcfinput 
	"""
}
