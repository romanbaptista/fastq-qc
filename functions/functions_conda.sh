#!/bin/bash

####################################################### FUNCTIONS

# conda_load
conda_load() {
    local path="${1-}"

    # VALIDATION
    arg_check_nonempty "${path}" || return $?

    # FUNCTION
    module load "${path}"
}

# conda_enable
# Requires 'conda' to be available in PATH (validated in preflight)
# WARNING:
# Modifies shell state (set +u / set -u)
# Must only be used in controlled contexts (e.g. preflight layer)
conda_enable() {

    # FUNCTION
    set +u
    eval "$(conda shell.bash hook)"
    set -u
}

# conda_check_env
conda_check_env() {
    local name="${1-}"

    # VALIDATION
    arg_check_nonempty "${name}" || return $?

    # FUNCTION
    conda info --envs | awk '{print $1}' | grep -qx "${name}"
}

# conda_create_env
conda_create_env() {
    local name="${1-}"
    local yaml="${2-}"

    # VALIDATION
    local arg_array=(
        "${name}"
        "${yaml}"
    )

    for arg in "${arg_array[@]}"; do
        arg_check_nonempty "${arg}" || return $?
    done

    # FUNCTION
    conda env create -n "${name}" -f "${yaml}"
}


conda_activate_env() {
    local name="${1-}"

    # VALIDATION
    arg_check_nonempty "${name}" || return $?

    # FUNCTION
    conda activate "${name}"
}
