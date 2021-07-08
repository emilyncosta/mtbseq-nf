nextflow.enable.dsl = 2
// NOTE: To properly setup the gatk inside the docker image
// - Download the gatk-3.8.0 tar file from here https://console.cloud.google.com/storage/browser/gatk-software/package-archive/gatk;tab=objects?prefix=&forceOnObjectsSortingFiltering=false
// - tar -xvf GATK_TAR_FILE
// - gatk-register gatk_folder/gatk_jar


params.resultsDir = "${params.outdir}/tbjoin"
params.saveMode = 'copy'
params.shouldPublish = true

// TODO: Add the tbjoin workflow
process TBJOIN {
    tag "${params.mtbseq_project_name}"
    publishDir params.resultsDir, mode: params.saveMode, enabled: params.shouldPublish

    input:
    path(samples_file)
    path("Position_Tables/*")
    path(gatk_jar)
    env USER

    output:
    path ("Joint/${params.mtbseq_project_name}_joint*samples.{tab,log}")
    tuple path(samples_file), val("${params.mtbseq_project_name}"), path("Joint/${params.mtbseq_project_name}_joint*samples.tab"), emit: next_step

    script:
    """
    gatk-register ${gatk_jar}

    mkdir Joint
    MTBseq --step TBjoin --samples ${samples} --project ${params.mtbseq_project_name}
    """
    stub:

    """
    mkdir Joint
    touch Joint/${params.mtbseq_project_name}_joint_samples.tab
    touch Joint/${params.mtbseq_project_name}_joint_samples.log

    echo "MTBseq --step TBjoin --samples ${samples_file} --project ${params.mtbseq_project_name}"
    """
}
