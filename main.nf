#!/usr/bin/env nextflow
nextflow.enable.dsl=2

log.info """
STARTING PIPELINE
=*=*=*=*=*=*=*=*=
Sample list: ${params.input}
BED file: ${params.bedfile}
Sequences in:${params.sequences}
"""



include { FASTQTOBAM; FASTQTOBAM_WGS } from './workflows/fastq_to_bam.nf'
include { ABRA_BAM } from './modules/abra/realign/main.nf'
include { ABRA_SORT } from './modules/samtools/abra_sort/main.nf'


// // FLT3 ITD detection
include { FLT3_ITD_EXT } from './modules/flt3_itd_ext/flt3_itd_detect/main.nf'
include { FILT3R } from './modules/filt3r/flt3_itd_detect/main.nf'
include { ANNOVAR as ANNOVAR_FILT3R } from './modules/annovar/annotate/main.nf'
include { FORMAT_FILT3R } from './modules/python/format_filt3r/main.nf'
include { CHR13_BAM_GEN } from './modules/samtools/chr13_bam_gen/main.nf'
include { BAM_TO_FASTQ } from './modules/bedtools/bamtofastq/main.nf'
include { GETITD } from './modules/getitd/flt3_itd_detect/main.nf'

// // HSmetrics calculation
include { HSMETRICS; HSMETRICS_COLLECT } from './modules/gatk/hsmetrics/main.nf'

// // COVERAGE calculation
include { COVERAGE } from './modules/bedtools/coverage/main.nf'
include { COVERVIEW } from './modules/coverview/coverage/main.nf'
include { FORMAT_COVERVIEW } from './modules/python/format_coverview/main.nf'
// include { COVERAGE; COVERVIEW; COVERAGE_WGS; COVERAGE_WGS_COLLECT } from './modules/coverage.nf'

// // Variant calling
include { PLATYPUS } from './modules/variant_call/platypus/main.nf'
// include { PLATYPUS; FREEBAYES; MUTECT2; VARDICT; DEEPSOMATIC; LOFREQ; STRELKA; PINDEL; PINDEL_UBTF} from './modules/variant_call.nf'

// // Variant integration 
// include { SOMATICSEQ; COMBINE_VARIANTS } from './modules/somaticseq.nf'

// // CNV calling
// include { CNVKIT; ANNOT_SV; IFCNV } from './modules/cnv_call.nf'

// // IGV reports
// include { IGV_REPORTS } from './modules/igv_reports.nf'

// // ichorCNA
// include { ICHOR_CNA; OFFTARGET_BAM_GEN; ICHORCNA_OFFTARGET } from './modules/ichorCNA.nf'

// // Format output
// include {CAVA; FORMAT_SOMATICSEQ_COMBINED; FORMAT_CONCAT_SOMATICSEQ_COMBINED; FORMAT_PINDEL; FORMAT_PINDEL_UBTF; MERGE_CSV; FINAL_OUTPUT; UPDATE_FREQ; UPDATE_DB} from './modules/format_output.nf'

// // DND SCV
// include { DNDSCV } from './modules/dnd_scv.nf'


bedfile = file("${params.bedfile}", checkIfExists: true )
bedfile_exonwise = file("${params.bedfile_exonwise}", checkIfExists: true )
genome_loc = file("${params.genome}", checkIfExists: true)
index_files = file("${params.genome_dir}/${params.ind_files}.*")
filt3r_reference = file("${params.filt3r_ref}", checkIfExists: true)
filt3r = params.filt3r
flt3_bedfile = file("${params.flt3_bedfile}", checkIfExists: true )
coverview_config = file("${params.coverview_config}", checkIfExists: true )

workflow MYOPOOL {
	leukemia = Channel
		.fromPath(params.input)
		.splitCsv(header:false)
		.map { row ->
			def sample_full = row[0].trim()
			def sample_base = sample_full.tokenize('-')[0]

			def r1 = file("${params.sequences}/${sample_full}_S*_R1_*.fastq.gz", checkIfExists: false)
			def r2 = file("${params.sequences}/${sample_full}_S*_R2_*.fastq.gz", checkIfExists: false)

			if (!r1 && !r2) {
				r1 = file("${params.sequences}/${sample_full}*_R1.fastq.gz", checkIfExists: false)
				r2 = file("${params.sequences}/${sample_full}*_R2.fastq.gz", checkIfExists: false)
			}

			tuple(sample_full, sample_base, r1, r2)
		}
		.branch {
			myopool: it[0].toLowerCase().contains("myopool") || it[0].toLowerCase().contains("screl")
			wgs:     it[0].contains("WGS")
		}

	myopool_ch = leukemia.myopool.map { full, base, r1, r2 -> tuple(base, r1, r2) }
	wgs_ch     = leukemia.wgs.map     { full, base, r1, r2 -> tuple(base, r1, r2) }


	main:
	// Adapter Trimming, alignment and GATK BQSR - MYOPOOL
	myo_bam_ch = FASTQTOBAM(myopool_ch)
	ABRA_BAM(myo_bam_ch.final_bams_ch, bedfile, genome_loc, index_files )
	ABRA_SORT(myo_bam_ch.final_bams_ch.join(ABRA_BAM.out))

	//// FLT3 ITD detection
	FILT3R(myo_bam_ch.trimmed_fastq, filt3r_reference)
	ANNOVAR_FILT3R(FILT3R.out.filt3r_vcf, filt3r)
	FORMAT_FILT3R(ANNOVAR_FILT3R.out.join(FILT3R.out.filt3r_json))
	CHR13_BAM_GEN(ABRA_SORT.out.final_bam)
	BAM_TO_FASTQ(CHR13_BAM_GEN.out)
	GETITD(BAM_TO_FASTQ.out)
	FLT3_ITD_EXT(ABRA_SORT.out.final_bam)

	//// HSmetrics calculation 
	HSMETRICS(ABRA_SORT.out.final_bam, bedfile, bedfile_exonwise, genome_loc, index_files)
	all_hsmetrics_pw = HSMETRICS.out.probewise.collect()
	all_hsmetrics_ew = HSMETRICS.out.exonwise.collect()
	HSMETRICS_COLLECT(all_hsmetrics_pw, all_hsmetrics_ew)

	//// COVERAGE calculation
	COVERAGE(ABRA_SORT.out.final_bam, bedfile, bedfile_exonwise, flt3_bedfile)
	COVERVIEW(ABRA_SORT.out.final_bam, bedfile_exonwise, coverview_config)
	FORMAT_COVERVIEW(COVERVIEW.out)

	//// ichorCNA Offtarget
	//OFFTARGET_BAM_GEN(ABRA_BAM.out)
	//ICHORCNA_OFFTARGET(OFFTARGET_BAM_GEN.out)

	//// Variant calling 
	PLATYPUS(ABRA_SORT.out.final_bam, genome_loc, index_files, bedfile)
	//FREEBAYES(ABRA_BAM.out)
	//MUTECT2(ABRA_BAM.out)
	//VARDICT(ABRA_BAM.out)
	//DEEPSOMATIC(ABRA_BAM.out)
	//LOFREQ(ABRA_BAM.out)
	//STRELKA(ABRA_BAM.out)
	//PINDEL(ABRA_BAM.out)
	//PINDEL_UBTF(ABRA_BAM.out)

	//// Variant integration 
	//SOMATICSEQ(ABRA_BAM.out.join(MUTECT2.out.join(VARDICT.out.join(DEEPSOMATIC.out.join(LOFREQ.out.join(STRELKA.out.join(FREEBAYES.out.join(PLATYPUS.out))))))))
	//COMBINE_VARIANTS(MUTECT2.out.join(VARDICT.out.join(DEEPSOMATIC.out.join(LOFREQ.out.join(STRELKA.out.join(FREEBAYES.out.join(PLATYPUS.out)))))))

	//// CNV calling
	//CNVKIT(ABRA_BAM.out)
	//ANNOT_SV(CNVKIT.out)
	//IFCNV(ABRA_BAM.out.collect())

	//// IGV reports
	//IGV_REPORTS(SOMATICSEQ.out)

	//// Format Output
	//CAVA(SOMATICSEQ.out.join(COMBINE_VARIANTS.out))	
	//FORMAT_SOMATICSEQ_COMBINED(SOMATICSEQ.out)
	//FORMAT_CONCAT_SOMATICSEQ_COMBINED(FORMAT_SOMATICSEQ_COMBINED.out)
	//FORMAT_PINDEL(PINDEL.out.join(COVERAGE.out))
	//FORMAT_PINDEL_UBTF(PINDEL_UBTF.out.join(COVERAGE.out))
	//MERGE_CSV(FORMAT_CONCAT_SOMATICSEQ_COMBINED.out.join(CAVA.out.join(COVERVIEW.out.join(FORMAT_PINDEL.out.join(CNVKIT.out.join(SOMATICSEQ.out.join(FILT3R.out.join(FORMAT_PINDEL_UBTF.out.join(FLT3_ITD_EXT.out)))))))))	
	//FINAL_OUTPUT(COVERAGE.out.join(CNVKIT.out))
	//UPDATE_FREQ(MERGE_CSV.out.collect())
	//UPDATE_DB(SOMATICSEQ.out.collect())

	//// Adapter Trimming, alignment and GATK BQSR - WGS
	wgs_bam_ch = FASTQTOBAM_WGS(wgs_ch)

	//// Coverage calculation for WGS
	//COVERAGE_WGS(wgs_bam_ch)
	//all_coverages_wgs = COVERAGE_WGS.out.collect()
	//COVERAGE_WGS_COLLECT(all_coverages_wgs)

	//// ichorCNA
	//ICHOR_CNA(wgs_bam_ch)

}

workflow.onComplete {
	log.info ( workflow.success ? "\n\nDone! Output in the 'Final_Output' directory \n" : "Oops .. something went wrong" )
	log.info ( "Completed at: ${workflow.complete}")
	log.info ( "Total time taken: ${workflow.duration}")
}
