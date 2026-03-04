process FORMAT_FILT3R {
	tag "${Sample}"
	label 'process_low'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.csv'
	input:
		tuple val (Sample), file(fil3r_multianno), file(filt3r_json)
	output:
		tuple val (Sample), file("${Sample}_filt3r_out.csv")
	script:
	"""
	LINE_COUNT=\$(wc -l < ${Sample}_filt3r.out.hg19_multianno.csv)

	if [[ "\$LINE_COUNT" -le 1 ]]; then
    	touch ${Sample}.filt3r__final.csv
    	touch ${Sample}_filt3r_json_filtered.csv
    	touch ${Sample}_filt3r_out.csv
	else
 		format_filt3r.py ${Sample}_filt3r.out.hg19_multianno.csv ${Sample}.filt3r__final.csv
    	filter_json.py ${Sample}_filt3r_json.csv ${Sample}_filt3r_json_filtered.csv
    	merge_filt3r_csvs.py ${Sample}.filt3r__final.csv ${Sample}_filt3r_json_filtered.csv ${Sample}_filt3r_out.csv
	fi
	"""
}
