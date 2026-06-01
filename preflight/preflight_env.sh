#!/bin/bash
set -euo pipefail

######################### GUARDS #########################

GUARD_ARRAY=(
    FUNCTIONS_DIR
    ENV_DIR
    ENV_NAME
    YAML_FILE
    SENTINEL_FILE
)

for var in "${GUARD_ARRAY[@]}"; do
    : "${!var:?${var} not set or empty}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

######################### SOURCE #########################

source "${FUNCTIONS_DIR}/functions_base.sh"
source "${FUNCTIONS_DIR}/functions_conda.sh"

######################### CHECKS #########################

file_check_exists "${YAML_FILE}" || fail_message "YAML file not found: ${YAML_FILE}"
file_check_nonempty "${YAML_FILE}" || fail_message "YAML file is empty: ${YAML_FILE}"

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."
echo "  Info:"
echo "    Environment name:     ${ENV_NAME}"
echo "    YAML file:            ${YAML_FILE}"

echo "  Creating conda environment..."

conda_enable || fail_message "Failed to enable conda"
conda_create_env "${ENV_NAME}" "${YAML_FILE}" || fail_message "Failed to create conda environment: ${ENV_NAME}"

echo "  Conda environment created: ${ENV_NAME}"
echo "  Creating sentinel file..."

touch "${SENTINEL_FILE}" || fail_message "Failed to create sentinel file"
file_check_exists "${SENTINEL_FILE}" || fail_message "Sentinel file not found: ${SENTINEL_FILE}"

echo "  Sentinel file created"
echo "${SCRIPT_NAME} COMPLETE"