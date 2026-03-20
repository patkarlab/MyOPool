process UPDATE_DB {
	publishDir "/new_disk/trash/", mode: 'copy', pattern: 'freq.txt'
	input:
		val Sample
        file (alpdb)
	output:
		file ("freq.txt")
	script:
	"""
	for i in `cat ${params.input} | grep -i 'myo' | sed 's/-[[:alpha:]]*//g'`
	do 
		if [ -f ${params.outdir}/\${i}/\${i}.somaticseq.vcf ]; then
			ln -s ${params.outdir}/\${i}/\${i}.somaticseq.vcf ./
		fi
	done
	files=\$(ls *.somaticseq.vcf)
	append_to_database.py ${alpdb} \${files}
	freq.py ${alpdb} freq.txt
	"""
}