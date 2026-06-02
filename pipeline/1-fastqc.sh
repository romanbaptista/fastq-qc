#!/bin/bash
set -euo pipefail

######################### GUARDS #########################

GUARD_ARRAY=(
    FUNCTIONS_DIR
    INPUT_DIR
    FASTQC_OUTDIR
)

for var in "${GUARD_ARRAY[@]}"; do
    : "${!var:?${var} not set or empty}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

######################### SOURCE #########################

# Enable module loading
source /etc/profile.d/modules.sh
source "${FUNCTIONS_DIR}/functions_base.sh"

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."

echo
echo "  Loading fastqc module..."

# Load fastqc
module load apps/fastqc-0.11.9.tcl

echo "  fastqc loaded"
echo "  Running fastqc..."
echo

# Run fastqc
while read -r FASTQ_FILE; do

echo "  Processing file: ${FASTQ_FILE}"

    (
        fastqc \
            -t "${SLURM_CPUS_PER_TASK}" \
            --noextract \
            --outdir "${FASTQC_OUTDIR}" \
            "${FASTQ_FILE}"
    ) || fail_message "Failed to complete fastqc for file: ${FASTQ_FILE}"
    
done < <(find "${INPUT_DIR}" -type f -name "*.fastq.gz")

echo
echo "  fastqc complete"
echo "${SCRIPT_NAME} COMPLETE"