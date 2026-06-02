#!/bin/bash

######################### MAIN ###########################

# EXPORT_ARRAY:
# Canonical list of pipeline variables that define the execution ABI.
#
# Scope:
#   - Defines the complete set of variables exposed to downstream
#     execution scripts (pipeline modules).
#   - Used by preflight_exports.sh to construct an export snapshot
#     of the pipeline environment.
#
# Notes:
#   - This array represents the explicit variable contract between
#     pipeline layers (preflight → execution).
#   - Only variables required by downstream scripts should be included.
#   - Variables listed here must:
#       * be defined during CONFIG or PREFLIGHT stages
#       * be valid and non-empty before export
#
# Execution Model:
#   - In SLURM-based pipelines:
#       EXPORT_ARRAY is converted into SBATCH_EXPORTS and passed via:
#           sbatch --export=...
#
# Design Principles:
#   - Defines the pipeline ABI explicitly
#   - Prevents reliance on implicit global variables
#   - Enables reproducibility and portability across environments
#   - Maintains strict separation between validation and execution
#   - Must NOT include SLURM-injected variables (e.g. SLURM_CPUS_PER_TASK)

# Define export array (execution ABI)
EXPORT_ARRAY=(
    # Core paths
    INPUT_DIR
    OUTPUT_DIR
    FUNCTIONS_DIR
    FASTQC_OUTDIR
    MULTIQC_OUTDIR
    LOG_DIR
    PIPELINE_DIR
    # Compute resources
    FASTQC_CPUS
    FASTQC_MEM_PER_CPU
    MULTIQC_CPUS
    MULTIQC_MEM_PER_CPU
)