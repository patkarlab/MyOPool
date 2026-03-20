process MERGE_CSV {
	tag "${Sample}"
	label 'process_low'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.xlsx'
	input:
		tuple val (Sample), file (finalConcat), file (artefacts), file(cancervarTsv), file (cavaCsv), file (coverviewRegions) ,file (finalPindelFLT3), file (finalPindelUBTF), file(finalCnr), file(finalCns), file(filt3rCsv), file(ext_vcf)
		path (pharma_input_xlxs)
	output:
		tuple val (Sample), file ("${Sample}.xlsx")
	script:
	"""
	sed -i 's/\t/,/g' ${finalCnr}
	pharma_markers_v2.py ${Sample} ./ ${pharma_input_xlxs} ${Sample}_pharma.csv
	flt3_ext_format.py -v ${ext_vcf} -o ${Sample}.flt3-itd-ext.csv
	merge-csv_v3.py ${Sample} ./ ${Sample}.xlsx ./ ${coverviewRegions} ${finalPindelFLT3} ${finalCnr} ${Sample}_pharma.csv ${finalPindelUBTF} ${Sample}.flt3-itd-ext.csv ${cancervarTsv} ${filt3rCsv}
	add_pcgr_cpsr.py ${Sample}.xlsx
	mv output_temp.xlsx ${Sample}.xlsx
	"""
}