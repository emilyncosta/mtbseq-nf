nextflow.enable.dsl = 2
// NOTE: To properly setup the gatk inside the docker image
// - Download the gatk-3.8.0 tar file from here https://console.cloud.google.com/storage/browser/gatk-software/package-archive/gatk;tab=objects?prefix=&forceOnObjectsSortingFiltering=false
// - tar -xvf GATK_TAR_FILE
// - gatk-register gatk_folder/gatk_jar


include { PARALLEL_ANALYSIS } from "./workflows/parallel_analysis/parallel_analysis.nf"
include { BATCH_ANALYSIS } from "./workflows/batch_analysis/batch_analysis.nf"

workflow {

    references_ch = Channel.of[params.global_ref_reference_genome_path,
                               params.global_ref_resistance_list,
                               params.global_ref_interesting_regions,
                               params.global_ref_gene_categories,
                               params.global_ref_base_quality_recalibration]

    if( params.run_type == "sra" ) {
        reads_ch = Channel.fromSRA(params.genomeIds, cache: true, apiKey: params.ncbi_api_key)
    } else if( params.run_type == "local" ) {
        reads_ch = Channel.fromFilePairs(params.reads)
    }

    if( params.analysis_mode == "parallel" ) {
        PARALLEL_ANALYSIS(reads_ch,references_ch)
    } else if( params.analysis_mode == "batch" ) {
        BATCH_ANALYSIS(reads_ch,references_ch)
    }
}

//=======================================
// TESTING
//=======================================

workflow test {
    reads_ch = Channel.fromFilePairs("${params.local_location}/*{R1,R2}*gz")
    references_ch = Channel.of[params.global_ref_reference_genome_path,
                               params.global_ref_resistance_list,
                               params.global_ref_interesting_regions,
                               params.global_ref_gene_categories,
                               params.global_ref_base_quality_recalibration]


    if( params.analysis_mode == "parallel" ) {
        PARALLEL_ANALYSIS(reads_ch, references_ch)
    } else if( params.analysis_mode == "batch" ) {
        BATCH_ANALYSIS(reads_ch, references_ch)
    }

}
