process VEP {
	tag "${Sample}"
	label 'process_inter'
	input:
		tuple val (Sample), path(Vcf)
	output:
		tuple val (Sample), file("${Sample}_vep_delheaders.txt")
	script:
	"""
	vep -i ${Vcf} --cache -o ${Sample}_vep.txt --offline --tab --force_overwrite --af_1kg --af --af_gnomadg --pubmed --sift b --canonical --hgvs --shift_hgvs 1
	filter_vep -i ${Sample}_vep.txt -o ${Sample}_filtered.txt --filter "(CANONICAL is YES) and (AF < 0.01 or not AF)" --force_overwrite
	grep -v "##" ${Sample}_filtered.txt > ${Sample}_vep_delheaders.txt
	"""
}