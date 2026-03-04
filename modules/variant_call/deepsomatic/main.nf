process DEEPSOMATIC {
	tag "${Sample}"
	label 'process_inter'
	input:
		tuple val (Sample), file(bam), file (bamBai)
		path (control_bam)
		path (control_bamBai)
		path (GenFile)
		path (GenDir)
		path (bedfile)
	output:
		tuple val(Sample), file("${Sample}_DS.vcf")
	script:
	""" 
	run_deepsomatic --model_type=WGS --ref=${GenFile} --reads_tumor=${bam} --reads_normal=${control_bam} --output_vcf=${Sample}_DS.vcf --num_shards=${task.cpus} --regions=${bedfile}
	"""
}

