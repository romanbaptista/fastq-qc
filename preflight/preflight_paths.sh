#!/bin/bash

######################### GUARDS #########################

GUARD_ARRAY=(
    ROOT_DIR
    UTILS_DIR
)

for var in "${GUARD_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "Variable is empty or not defined: ${var}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

######################### SOURCE #########################

# Source utils
source "${UTILS_DIR}/utils_paths.sh"

######################### CHECKS #########################

variable_check_nonempty DIR_ARRAY || fail_message "DIR_ARRAY is empty or is not set"
array_check_nonempty DIR_ARRAY || fail_message "DIR_ARRAY has no elements"

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."
echo "  Creating pipeline directories..."

# Define pipeline-specific directories (appended to DIR_ARRAY from utils layer)
ENV_DIR="${ROOT_DIR}/env"
FASTQC_OUTDIR="${OUTPUT_DIR}/1-fastqc"
MULTIQC_OUTDIR="${OUTPUT_DIR}/2-multiqc"

# Append to DIR_ARRAY
DIR_ARRAY+=(
    ENV_DIR
    FASTQC_OUTDIR
    MULTIQC_OUTDIR
)

# Create directories
for dir in "${DIR_ARRAY[@]}"; do
    directory_create "${!dir}" || fail_message "Failed to create directory: ${!dir}"
done

echo "  Directories created"
echo "${SCRIPT_NAME} COMPLETE"