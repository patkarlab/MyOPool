process UPDATE_FREQ {
	input:
		val (Sample)
	output:
		path "*.xlsx"
	script:
	"""
	ln -s /new_disk/trash/freq.txt ./

	for i in `cat ${params.input} | grep -i 'myo' | sed 's/-[[:alpha:]]*//g'`
	do
		if [ -f ${params.outdir}/\${i}/\${i}.xlsx ]; then
			update_excel_freq.py ${params.outdir}/\${i}/\${i}.xlsx freq.txt

			ln -s ${params.outdir}/\${i}/\${i}.xlsx ./\${i}.xlsx
		fi
	done
	"""
}