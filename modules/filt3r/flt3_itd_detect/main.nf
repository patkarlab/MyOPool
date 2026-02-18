process FILT3R {
	tag "${Sample}"
	label 'process_low'
	input:
		tuple val (Sample), file(trim1), file(trim2)
		file (filt3r_reference)
	output:
		tuple val (Sample), file("${Sample}_filt3r.vcf"), emit: filt3r_vcf
		tuple val (Sample), file("${Sample}_filt3r_json.csv"), emit: filt3r_json
	script:
	"""
	/usr/local/bin/filt3r -k 12 --ref ${filt3r_reference} --sequences ${trim1},${trim2} --nb-threads ${task.cpus} --vcf --out ${Sample}_filt3r.json
	convert_json_to_csv.py ${Sample}_filt3r.json ${Sample}_filt3r_json.csv
	"""
}