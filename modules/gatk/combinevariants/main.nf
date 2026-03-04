process COMBINE_VARIANTS{
	tag "${Sample}"
	label 'process_inter'
	input:
		tuple val (Sample), file(mutectVcf), file(vardictVcf), file(DeepSomaticVcf), file(lofreqVcf), file(strelkaVcf), file(freebayesVcf), file(platypusVcf)
		path (GenFile)
		path (GenDir)     
	output:
		tuple val(Sample), file("${Sample}.combined.vcf")
	script:
	"""
	vcf_sorter.sh ${mutectVcf} ${Sample}.mutect.sorted.vcf
	vcf_sorter.sh ${vardictVcf} ${Sample}.vardict.sorted.vcf
	vcf_sorter.sh ${DeepSomaticVcf} ${Sample}.DeepSomatic.sorted.vcf
	vcf_sorter.sh ${lofreqVcf} ${Sample}.lofreq.sorted.vcf
	vcf_sorter.sh ${strelkaVcf} ${Sample}.strelka.sorted.vcf
	vcf_sorter.sh ${freebayesVcf} ${Sample}.freebayes.sorted.vcf
	vcf_sorter.sh ${platypusVcf} ${Sample}.platypus.sorted.vcf

	mv ${GenFile}.dict ${GenFile.simpleName}.dict
	java -Xmx${task.memory.toGiga()}g -jar /usr/GenomeAnalysisTK.jar -T CombineVariants -R ${GenFile} --variant ${Sample}.mutect.sorted.vcf --variant ${Sample}.vardict.sorted.vcf --variant ${Sample}.DeepSomatic.sorted.vcf --variant ${Sample}.lofreq.sorted.vcf --variant ${Sample}.strelka.sorted.vcf --variant ${Sample}.freebayes.sorted.vcf --variant ${Sample}.platypus.sorted.vcf -o ${Sample}.combined.vcf -genotypeMergeOptions UNIQUIFY
	"""
}