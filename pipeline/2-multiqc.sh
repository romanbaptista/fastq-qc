#!/bin/bash
set -euo pipefail

######################### GUARDS #########################

GUARD_ARRAY=(
    FASTQC_OUTDIR
    MULTIQC_OUTDIR
    OUTPUT_DIR
    ENV_NAME
    UTILS_DIR
    FUNCTIONS_DIR
)

for var in "${GUARD_ARRAY[@]}"; do
    : "${!var:?${var} not set or empty}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

######################### INPUT ##########################

MULTIQC_INDIR="${FASTQC_OUTDIR}"

######################### SOURCE #########################

# Enable module commands for batch jobs
source /etc/profile.d/modules.sh
# Source utils
source "${UTILS_DIR}/utils_multiqc.sh"
# Source functions
source "${FUNCTIONS_DIR}/functions_base.sh"
source "${FUNCTIONS_DIR}/functions_conda.sh"

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."
echo "  Info:"
echo "    Input directory:      ${MULTIQC_INDIR}"

echo "  Activating conda environment"

conda_enable || fail_message "Failed to enable conda"
conda_activate_env "${ENV_NAME}" || fail_message "Failed to activate environment: ${ENV_NAME}"

echo "  Conda environment activated: ${ENV_NAME}"

# Remove PYTHONPATH from current shell to avoid cluster-wide Python settings
unset PYTHONPATH

# Create temporary directory for SLURM job
export TEMP_DIR="${OUTPUT_DIR}/${SLURM_JOB_ID}.tmp"
directory_create "${TEMP_DIR}" || fail_message "Failed to create temporary directory"

# Ensure temporary directory is cleaned up on exit (success or failure)
trap 'rm -rf "${TEMP_DIR}"' EXIT

echo "  Starting multiQC..."

# Run multiqc
multiqc \
    -m fastqc \
    -o "${MULTIQC_OUTDIR}" \
    -n "multiqc_report" \
    -f \
    "${MULTIQC_INDIR}" \
    || fail_message "Failed to run multiQC"

echo "  multiQC complete"
echo "  Deactivating conda environment..."

conda deactivate

echo "  Conda environment deactivated: ${ENV_NAME}"
echo "${SCRIPT_NAME} COMPLETE"