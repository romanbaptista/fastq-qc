#!/bin/bash
set -euo pipefail

######################### GUARDS #########################

GUARD_ARRAY=(
    FUNCTIONS_DIR
    ARRAY_DIR
    LOG_DIR
    PIPELINE_DIR
    SBATCH_EXPORTS
    FASTQC_CPUS
    FASTQC_MEM_PER_CPU
    MULTIQC_CPUS
    MULTIQC_MEM_PER_CPU
)

for var in "${GUARD_ARRAY[@]}"; do
    : "${!var:?${var} not set or empty}"
done

######################### SETUP ###########################

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

######################### SOURCE ##########################

source "${FUNCTIONS_DIR}/functions_base.sh"
source "${ARRAY_DIR}/array_pipeline.sh"    

######################### CHECKS #########################

variable_check_nonempty PIPELINE_ARRAY || fail_message "PIPELINE_ARRAY is empty or not defined"
array_check_nonempty PIPELINE_ARRAY || fail_message "PIPELINE_ARRAY has no elements"

######################### LOGS ###########################

LOG_FILE="${LOG_DIR}/${SCRIPT_NAME}.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."

echo
echo "  Scripts to run:"

for script in "${PIPELINE_ARRAY[@]}"; do
    echo "      ${script}"
done

echo "  SUBMITTING 1-fastqc.sh ..."

# Submit fastqc
FASTQC=$(
    sbatch \
        --parsable \
        --export="${SBATCH_EXPORTS}" \
        --cpus-per-task="${FASTQC_CPUS}" \
        --mem-per-cpu="${FASTQC_MEM_PER_CPU}" \
        --output="${LOG_DIR}/1-fastqc.%j.log" \
        "${PIPELINE_DIR}/1-fastqc.sh"
) || fail_message "Failed to submit 1-fastqc.sh"

echo "  1-fastqc.sh SUBMITTED"
echo "  1-fastqc.sh Job ID: ${FASTQC}"
echo "  SUBMITTING 2-multiqc.sh"

# Submit multiqc
MULTIQC=$(
    sbatch \
        --parsable \
        --export="${SBATCH_EXPORTS}" \
        --cpus-per-task="${MULTIQC_CPUS}" \
        --mem-per-cpu="${MULTIQC_MEM_PER_CPU}" \
        --dependency=afterok:"${FASTQC}" \
        --output="${LOG_DIR}/2-multiqc.%j.log" \
        "${PIPELINE_DIR}/2-multiqc.sh"
) || fail_message "Failed to submit 2-multiqc.sh"

echo "  2-multiqc.sh SUBMITTED"
echo "  2-multiqc.sh Job ID: ${MULTIQC}"
echo "${SCRIPT_NAME} COMPLETE"