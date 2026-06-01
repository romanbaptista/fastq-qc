#!/bin/bash

######################### MAIN ###########################

# BINARY_ARRAY:
# Canonical list of all required external commands (CLI dependencies).
#
# Scope:
#   - Used by preflight_binaries.sh to validate command availability.
#   - Represents all non-tool-specific commands required by:
#       * fastq-qc.sh (entrypoint)
#       * preflight layer
#       * pipeline modules
#
# Notes:
#   - Tool-specific binaries (e.g. EDirect, SRA Toolkit) are NOT included
#     and must be validated in dedicated tool preflight scripts.
#   - This array defines the framework-level runtime environment.
#   - Only commands actually invoked by the pipeline should be listed here.

# Define binary array
BINARY_ARRAY=(
    sbatch
    tmux
    conda
    module
    fastqc
    multiqc
    find
    grep
    awk
    chmod
)