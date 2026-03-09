process COVERAGE {
	tag "${Sample}"
	input:
		tuple val (Sample), file(bam), file(bamBai)
		path(bedfile)
		path(bedfile_exonwise)
		path(flt3_bedfile)
	output:
		tuple val (Sample), file ("${Sample}_pindel_flt3.counts.bed"), file("${Sample}_pindel_ubtf.counts.bed"), emit: pindel_counts
		tuple val (Sample), file ("${Sample}.counts.bed"), emit: counts
	script:
	"""
	bedtools coverage -counts -a ${bedfile_exonwise} -b ${bam} > ${Sample}.counts.bed
	bedtools coverage -counts -a ${flt3_bedfile} -b ${bam} > ${Sample}_pindel_flt3.counts.bed
	grep 'UBTF' ${bedfile} > ubtf_pindel.bed
	bedtools coverage -counts -a ubtf_pindel.bed -b ${bam} > ${Sample}_pindel_ubtf.counts.bed
	"""
}
