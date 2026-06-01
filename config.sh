#!/bin/bash

################################# INPUT #################################

# INPUT_DIR:
# Absolute or relative path to the directory containing input sequencing data
# for the QC pipeline.
# This directory must exist and must contain one or more compressed FASTQ files
# (e.g. *.fastq.gz). This value is consumed by 1-fastqc.sh; downstream stages operate only on
# pipeline-generated outputs derived from this input.
INPUT_DIR=""

######################### 1-FASTQC.SH ###################################

# FASTQC_CPUS:
# Number of CPU threads allocated per FastQC task.
# Increasing this value may improve processing performance but will increase
# per-job CPU usage.
FASTQC_CPUS=20

# FASTQC_MEM_PER_CPU:
# Amount of memory allocated per CPU thread for fastqc.
# This value is typically passed to the scheduler as memory-per-CPU
# and should be adjusted based on dataset size and cluster policy.
FASTQC_MEM_PER_CPU=8G

######################### 2-MULTIQC.SH ##################################

# MULTIQC_CPUS:
# Number of CPU threads allocated per MultiQC task.
# Increasing this value may improve performance but will increase per-job
# CPU usage (>5 is unnecessary for typical workloads).
MULTIQC_CPUS=2

# MULTIQC_MEM_PER_CPU:
# Amount of memory allocated per CPU thread for multiqc.
# This value is typically passed to the scheduler as memory-per-CPU
# and should be adjusted based on dataset size and cluster policy.
MULTIQC_MEM_PER_CPU=8G