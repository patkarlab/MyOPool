process SOMATICSEQ {
	tag "${Sample}"
	label 'process_medium'
	input:
		tuple val (Sample), file(bam), file(bamBai), file(mutectVcf), file(vardictVcf), file(DeepSomaticVcf), file(lofreqVcf), file(strelkaVcf), file(freebayesVcf), file(platypusVcf)
		path (GenFile)
		path (GenDir)
		path (bedfile)
		path (dbsnp_somatic)
	output:
		tuple val (Sample), file("${Sample}_somaticseq_snv.vcf"), file("${Sample}_somaticseq_indel.vcf")
	script:
	"""
	vcf_sorter.sh ${freebayesVcf} ${Sample}.freebayes.sorted.vcf
	vcf_sorter.sh ${platypusVcf} ${Sample}.platypus.sorted.vcf
	vcf_sorter.sh ${DeepSomaticVcf} ${Sample}.deepsomatic.sorted.vcf

	split_vcf.py -infile ${Sample}.platypus.sorted.vcf -snv ${Sample}_platypus_cnvs.vcf -indel ${Sample}_platypus_indels.vcf -genome ${GenFile}
	split_vcf.py -infile ${Sample}.freebayes.sorted.vcf -snv ${Sample}_freebayes_cnvs.vcf -indel ${Sample}_freebayes_indels.vcf -genome ${GenFile}
	split_vcf.py -infile ${Sample}.deepsomatic.sorted.vcf -snv ${Sample}_deepsomatic_snvs.vcf -indel ${Sample}_deepsomatic_indels.vcf -genome ${GenFile}

	vcf_sorter.sh ${Sample}_platypus_cnvs.vcf ${Sample}_platypus_cnvs_sort.vcf
	vcf_sorter.sh ${Sample}_platypus_indels.vcf ${Sample}_platypus_indels_sort.vcf
	vcf_sorter.sh ${Sample}_freebayes_cnvs.vcf ${Sample}_freebayes_cnvs_sort.vcf
	vcf_sorter.sh ${Sample}_freebayes_indels.vcf ${Sample}_freebayes_indels_sort.vcf
	vcf_sorter.sh ${Sample}_deepsomatic_snvs.vcf ${Sample}_deepsomatic_snvs_sort.vcf
	vcf_sorter.sh ${Sample}_deepsomatic_indels.vcf ${Sample}_deepsomatic_indels_sort.vcf

	somaticseq_parallel.py \
	--output-directory ./${Sample}.somaticseq \
	--genome-reference ${GenFile} \
	--inclusion-region ${bedfile} \
	--threads ${task.cpus} \
	--algorithm xgboost  \
	--dbsnp-vcf  ${dbsnp_somatic} \
	single \
	--sample-name ${Sample} \
	--bam-file ${bam} \
	--mutect2-vcf ${mutectVcf} \
	--vardict-vcf ${vardictVcf} \
	--lofreq-vcf ${lofreqVcf} \
	--strelka-vcf ${strelkaVcf}  \
	--arbitrary-snvs ${Sample}_freebayes_cnvs_sort.vcf ${Sample}_platypus_cnvs_sort.vcf ${Sample}_deepsomatic_snvs_sort.vcf \
	--arbitrary-indels ${Sample}_freebayes_indels_sort.vcf ${Sample}_platypus_indels_sort.vcf ${Sample}_deepsomatic_indels_sort.vcf
	
	vcf_sorter.sh ./${Sample}.somaticseq/Consensus.sSNV.vcf ./${Sample}_somaticseq_snv.vcf
	vcf_sorter.sh ./${Sample}.somaticseq/Consensus.sINDEL.vcf ./${Sample}_somaticseq_indel.vcf
	
	"""
}