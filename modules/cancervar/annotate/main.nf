process CANCERVAR_RUN {
	tag "${Sample}"
    label 'process_inter'
	input:
		tuple val(Sample), file (cancervar_input), file (cancervar_config)
	output:
		tuple val(Sample), file ("${Sample}myanno.hg19_multianno.txt.cancervar.ensemble.pred")
	script:
	"""
    python3 /tools/annovar/bin/CancerVar.py -c ${cancervar_config}
	python3 /tools/annovar/bin/OPAI/scripts/feature_preprocess.py -a ${Sample}myanno.hg19_multianno.txt.grl_p -c ${Sample}myanno.hg19_multianno.txt.cancervar -m ensemble -n 5 \
		-d /tools/annovar/bin/OPAI/saves/nonmissing_db.npy -o ${Sample}myanno.hg19_multianno.txt.cancervar.ensemble.csv
	if [ -s ${Sample}myanno.hg19_multianno.txt.cancervar.ensemble.csv ]; then
		python3 /tools/annovar/bin/OPAI/scripts/opai_predictor.py -i ${Sample}myanno.hg19_multianno.txt.cancervar.ensemble.csv -m ensemble -c /tools/annovar/bin/OPAI/saves/ensemble.pt -d cpu -v ${Sample}myanno.hg19_multianno.txt.cancervar -o ${Sample}myanno.hg19_multianno.txt.cancervar.ensemble.pred
	else
		echo "#Chr	Start	End	Ref	Alt	Ref.Gene	Func.refGene	ExonicFunc.refGene	Gene.ensGene	avsnp147	AAChange.ensGene	AAChange.refGene	clinvar: Clinvar	CancerVar: CancerVar and Evidence	Freq_ExAC_ALL	Freq_esp6500siv2_all	Freq_1000g2015aug_all	Freq_gnomAD_genome_ALL	CADD_raw	CADD_phred	SIFT_score	GERP++_RS	phastCons20way_mammalian	dbscSNV_ADA_SCORE	dbscSNV_RF_SCORE	Interpro_domain AAChange.knownGene	MetaSVM_score	Freq_gnomAD_genome_POPs	OMIM	Phenotype_MIM	OrphaNumber	Orpha	Pathway	Therap_list	Diag_list	Prog_list	Polyphen2_HDIV_score	FATHMM_score	MetaLR_score	MutationAssessor_score	cosmic91	icgc28	Otherinfo	ensemble_score" > ${Sample}myanno.hg19_multianno.txt.cancervar.ensemble.pred
	fi
	"""
}