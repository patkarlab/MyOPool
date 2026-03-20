process ICHORCNA {
	tag "${Sample}"
	publishDir "${params.outdir}/${Sample}/${Sample}-WGS/" , mode: 'copy'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: "*_genomeWide_all_sols.pdf"
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: "*_genomeWide.pdf"
	input:
		tuple val(Sample), file(bam), file(bamBai)
		path (seqinfo_rds)
	output:
		tuple val(Sample), path("${Sample}_ichorCNA"), file("*_genomeWide_all_sols.pdf"), file("*_genomeWide.pdf")
	script:
	"""
	readCounter --window 1000000 --quality 20 \
	--chromosome "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY" \
	${bam} > ${Sample}_tumor.wig

	sed -i 's/chr//g' ${Sample}_tumor.wig
	sed -i 's/om/chrom/g' ${Sample}_tumor.wig
	mkdir ${Sample}_ichorCNA

	Rscript /usr/local/bin/ichorCNA/scripts/runIchorCNA.R --id ${Sample} \
	--libdir /usr/local/bin/ichorCNA/ \
	--WIG ${Sample}_tumor.wig --ploidy "c(2,3)" --normal "c(0.5,0.6,0.7,0.8,0.9)" --maxCN 5 \
	--gcWig /usr/local/bin/ichorCNA/inst/extdata/gc_hg19_1000kb.wig \
	--mapWig /usr/local/bin/ichorCNA/inst/extdata/map_hg19_1000kb.wig \
	--centromere /usr/local/bin/ichorCNA/inst/extdata/GRCh37.p13_centromere_UCSC-gapTable.txt \
	--normalPanel /usr/local/bin/ichorCNA/inst/extdata/HD_ULP_PoN_1Mb_median_normAutosome_mapScoreFiltered_median.rds \
	--includeHOMD False --chrTrain "c(1:22)" --seqinfo ${seqinfo_rds} \
	--estimateNormal True --estimatePloidy True --estimateScPrevalence True \
	--scStates "c(1,3)" --txnE 0.9999 --txnStrength 10000 --outDir ${Sample}_ichorCNA \


	cp ${Sample}_ichorCNA/${Sample}/${Sample}_genomeWide_all_sols.pdf ./
	cp ${Sample}_ichorCNA/${Sample}/${Sample}_genomeWide.pdf ./
	"""
}
