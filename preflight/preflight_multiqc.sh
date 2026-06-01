#!/bin/bash
set -euo pipefail

######################### GUARDS #########################

GUARD_ARRAY=(
    FUNCTIONS_DIR
    UTILS_DIR
    PREFLIGHT_DIR
    ENV_DIR
)

for var in "${GUARD_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "Variable is empty or not defined: ${var}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

######################### SOURCE #########################

source "${FUNCTIONS_DIR}/functions_conda.sh"
source "${UTILS_DIR}/utils_multiqc.sh"

######################### TMUX #########################

# Define session name
TMUX_SESSION_NAME="env-multiqc"

# Define export array
TMUX_ARRAY=(
    FUNCTIONS_DIR
    ENV_NAME
    YAML_FILE
    SENTINEL_FILE
)

# Initialise tmux exports
TMUX_EXPORTS=""

# Construct exports
for var in "${TMUX_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "TMUX export variable not set: ${var}"
    TMUX_EXPORTS+="${var}='${!var}' "
done

######################### COUNTER ########################

MAX_WAIT=10800
TIME_TO_WAIT=10
WAITED=0

######################### CHECKS #########################

variable_check_nonempty CONDA_MODULE || fail_message "Conda module not provided"
variable_check_nonempty ENV_NAME || fail_message "MultiQC environment name empty or not set"

file_check_exists "${YAML_FILE}" || fail_message "YAML file not found: ${YAML_FILE}"
file_check_nonempty "${YAML_FILE}" || fail_message "YAML file is empty: ${YAML_FILE}"

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."
echo "  Checking for conda environment..."

# Load module
conda_load "${CONDA_MODULE}"

# Check for environment
if ! conda_check_env "${ENV_NAME}"; then
    
    echo "  Conda environment not found: ${ENV_NAME}"
  
    if tmux has-session -t "${TMUX_SESSION_NAME}" 2>/dev/null; then
        echo "  Cleaning up existing tmux session..."
        tmux kill-session -t "${TMUX_SESSION_NAME}" || fail_message "Failed to kill existing tmux session: ${TMUX_SESSION_NAME}"
        echo "  Cleanup complete"
    fi

    echo "  Creating new tmux session..."

    tmux new-session -d -s "${TMUX_SESSION_NAME}" "${TMUX_EXPORTS} bash ${PREFLIGHT_DIR}/preflight_env.sh"

    echo "  tmux session created: ${TMUX_SESSION_NAME}"
    echo "  To attach to the session use; 'tmux attach -t ${TMUX_SESSION_NAME}'"
    echo "  To detach again, without stopping jobs; Press Ctrl+b then d"
    echo "  To kill session, use; 'tmux kill-session -t ${TMUX_SESSION_NAME}'"
    echo "  User may disconnect from the cluster if required, while environment creation continues"

    # Check for sentinel file
    while ! file_check_exists "${SENTINEL_FILE}"; do

        # Tick counter
        sleep "${TIME_TO_WAIT}"
        WAITED=$((WAITED + TIME_TO_WAIT))

        # Check counter
        if (( WAITED >= MAX_WAIT )); then
            fail_message "Conda environment setup timed out after ${MAX_WAIT} seconds"
        fi
    done

    # Cleanup sentinel file
    rm -f "${SENTINEL_FILE}"

    # Confirm environment
    conda_check_env "${ENV_NAME}" || fail_message "Failed to create conda environment: ${ENV_NAME}"
else
    echo "  Conda environment already exists: ${ENV_NAME}"
fi

echo "  Conda environment confirmed"
echo "${SCRIPT_NAME} COMPLETE"