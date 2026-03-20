process ICHORCNA_OFFTARGET {
	tag "${Sample}"
	publishDir "${params.outdir}/${Sample}/" , mode: 'copy'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: "*_genomeWide_all_sols.pdf"
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: "*_genomeWide.pdf"
	input:
		tuple val(Sample), file(offtarget_bam), file(offtarget_bai)
		file (bedfile)
		file (bedfile_exonwise)
		file (normal_wig)
		file (seqinfo_rds)
	output:
		tuple val(Sample), path("${Sample}_offtarget"), file("*_genomeWide_all_sols.pdf"), file("*_genomeWide.pdf")
	script:
	"""
	awk 'BEGIN{OFS="\t"} {print \$1,\$2,\$3,\$4,"-"}' ${bedfile} > probes.bed
	awk 'BEGIN{OFS="\t"} {print \$1,\$2,\$3,\$4,"-"}' ${bedfile_exonwise} > exons.bed


	readCounter --window 1000000 --quality 20 \
	--chromosome "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY" \
	${offtarget_bam} > ${Sample}.tumor.wig

	sed -i 's/chr//g' ${Sample}.tumor.wig
	sed -i 's/om/chrom/g' ${Sample}.tumor.wig

	mkdir ${Sample}_normalized

	Rscript /opt/ichorCNA_offtarget/normalize_offtarget.R \
	--id ${Sample} \
	--libdir /usr/local/bin/ichorCNA/ \
	--offTargetFuncs /opt/ichorCNA_offtarget/utils.R \
	--TUMWIG ${Sample}.tumor.wig \
	--NORMWIG ${normal_wig} \
	--baitBedTum probes.bed \
	--gcWig /usr/local/bin/ichorCNA/inst/extdata/gc_hg19_1000kb.wig \
	--mapWig /usr/local/bin/ichorCNA/inst/extdata/map_hg19_1000kb.wig \
	--centromere /usr/local/bin/ichorCNA/inst/extdata/GRCh37.p13_centromere_UCSC-gapTable.txt \
	--genomeBuild hg19 \
	--outDir ${Sample}_normalized


	mkdir ${Sample}_offtarget

	Rscript /opt/ichorCNA_offtarget/runIchorCNA_offTarget.R \
	--libdir /usr/local/bin/ichorCNA/ \
	--id ${Sample} \
	--logRFile ${Sample}_normalized/${Sample}_offTarget_cor.txt \
	--statsFile ${Sample}_normalized/${Sample}_readStats.txt \
	--gcWig /usr/local/bin/ichorCNA/inst/extdata/gc_hg19_1000kb.wig \
	--mapWig /usr/local/bin/ichorCNA/inst/extdata/map_hg19_1000kb.wig \
	--repTimeWig /usr/local/bin/ichorCNA/inst/extdata/RepTiming_hg19_1000kb.wig \
	--normalPanel /usr/local/bin/ichorCNA/inst/extdata/HD_ULP_PoN_1Mb_median_normAutosome_mapScoreFiltered_median.rds \
	--ploidy "c(2,3)" \
	--normal "c(0.5,0.6,0.7,0.8,0.9)" \
	--maxCN 5 \
	--includeHOMD False \
	--chrTrain "c(1:22)" \
	--genomeBuild hg19 \
	--estimateNormal True \
	--estimatePloidy True \
	--estimateScPrevalence True \
	--scStates "c(1,3)" \
	--likModel t \
	--centromere /usr/local/bin/ichorCNA/inst/extdata/GRCh37.p13_centromere_UCSC-gapTable.txt \
	--exons.bed exons.bed \
	--txnE 0.9999 \
	--txnStrength 10000 \
	--minMapScore 0.9 \
	--fracReadsInChrYForMale 0.002 \
	--maxFracGenomeSubclone 0.5 \
	--maxFracCNASubclone 0.5 \
	--normal2IgnoreSC 0.95 \
	--scPenalty 5 \
	--plotFileType pdf \
	--plotYLim "c(-2,4)" \
	--outDir ${Sample}_offtarget

	cp ${Sample}_offtarget/${Sample}/${Sample}_genomeWide_all_sols.pdf ./
	cp ${Sample}_offtarget/${Sample}/${Sample}_genomeWide.pdf ./

	"""
}	