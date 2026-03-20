process SOMATICSEQ_CONCAT { 
	tag "${Sample}"
	label 'process_low'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.vcf'
	input:
		tuple val(Sample), file(somaticseq_snv_vcf), file(somaticseq_indel_vcf)
	output:
		tuple val (Sample), path("${Sample}.somaticseq.vcf")
	script:
	"""
	bgzip -@ ${task.cpus} -c ${somaticseq_snv_vcf} > ${Sample}_somaticseq_snv.vcf.gz
	bcftools index --threads ${task.cpus} -t ${Sample}_somaticseq_snv.vcf.gz

	bgzip -@ ${task.cpus} -c ${somaticseq_indel_vcf} > ${Sample}_somaticseq_indel.vcf.gz
	bcftools index --threads ${task.cpus} -t ${Sample}_somaticseq_indel.vcf.gz
	
	bcftools concat --threads ${task.cpus} -a ${Sample}_somaticseq_snv.vcf.gz ${Sample}_somaticseq_indel.vcf.gz -o ${Sample}.somaticseq.vcf

    sed -i 's/##INFO=<ID=MDLK012,Number=7,Type=Integer,Description="Calling decision of the 7 algorithms: MuTect, VarDict, LoFreq, Strelka, SnvCaller_0, SnvCaller_1, SnvCaller_2">/##INFO=<ID=MDLKFPGS,Number=7,Type=String,Description="Calling decision of the 7 algorithms: MuTect, VarDict, LoFreq, Strelka, Freebayes, Platypus, DeepSomatic">/g' ${Sample}.somaticseq.vcf
    sed -i 's/MDLK012/MDLKFPS/g' ${Sample}.somaticseq.vcf
	"""
}