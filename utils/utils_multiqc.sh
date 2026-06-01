#!/bin/bash

# NOTE:
# These variables are consumed by preflight_multiqc

######################### MAIN ###########################

# Define multiqc parameters
ENV_NAME="env_multiqc"
YAML_FILE="${UTILS_DIR}/${ENV_NAME}.yaml"
SENTINEL_FILE="${ENV_DIR}/${ENV_NAME}.sentinel"
CONDA_MODULE="apps/anaconda-4.7.12.tcl"