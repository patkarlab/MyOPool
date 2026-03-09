process FORMAT_PINDEL {
	tag "${Sample}"
	label 'process_inter'
    publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.csv'
	input:
		tuple val (Sample), file (pindelFLT3Multianno), file (pindelUBTFMultianno), file (pindelFLT3CountsBed), file (pindelUBTFCountsBed)
	output:
		tuple val (Sample), file("${Sample}_final_pindel_flt3.csv"), file("${Sample}_final_pindel_ubtf.csv")
	script:
	"""
	pindel_format_csv.py ${pindelFLT3CountsBed} ${pindelFLT3Multianno} ${Sample}_final_pindel_flt3.csv
    pindel_format_csv.py ${pindelUBTFCountsBed} ${pindelUBTFMultianno} ${Sample}_final_pindel_ubtf.csv
	"""
}