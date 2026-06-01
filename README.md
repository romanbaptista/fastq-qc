# `fastq-qc`

# Overview
This repository contains the `fastq-qc` pipeline — a modular, HPC‑compatible workflow for:

> Performing quality control analysis of FASTQ files using FastQC and MultiQC within a reproducible, contract‑driven SLURM execution model.

The pipeline is designed for execution in HPC environments and provides:
- Deterministic quality control using FastQC and MultiQC
- Fully validated execution environment prior to any job submission
- Environment provisioning via reproducible `conda` specifications
- Parallel execution through SLURM compute nodes
- Clean separation between validation, orchestration, and execution
- Restart-safe, deterministic outputs

Internally, the pipeline adheres to a contract-driven architecture, enforcing strict separation between:
- configuration
- validation
- execution

This ensures reproducibility, portability, and fail‑fast behaviour across different HPC systems.

All outputs are written to a structured output/ directory, enabling seamless integration with downstream pipelines such as trimming or alignment.

# Repository Structure
```text
fastq-qc/
├── README.md                  # Top-level overview (this file)
├── config.sh                  # User configuration (inputs + resources)
├── fastq-qc.sh               # Entry point (logging + preflight + submission)
│
├── arrays/                   # Declarative pipeline contracts
│   ├── array_preflight.sh
│   ├── array_pipeline.sh
│   ├── array_variables.sh
│   ├── array_binaries.sh
│   └── array_exports.sh
│
├── utils/                    # Static variable definitions (no logic)
│   ├── utils_paths.sh
│   └── utils_multiqc.sh
│
├── functions/                # Atomic helper functions
│   ├── functions_base.sh
│   └── functions_conda.sh
│
├── preflight/                # Validation + environment setup
│   ├── preflight.sh
│   ├── preflight_paths.sh
│   ├── preflight_variables.sh
│   ├── preflight_binaries.sh
│   ├── preflight_input.sh
│   ├── preflight_exports.sh
│   ├── preflight_pipeline.sh
│   ├── preflight_env.sh
│   └── preflight_multiqc.sh
│
├── pipeline/                 # Execution layer
│   ├── pipeline.sh
│   ├── 1-fastqc.sh
│   └── 2-multiqc.sh
│
├── output/                   # Pipeline-generated outputs (created at runtime)
├── logs/                     # Centralised logs
└── env/                      # Environment artefacts and reproducibility records
```

# Workflow
At a high level, the pipeline proceeds as follows:

## Preflight validation
The preflight layer performs strict fail-fast validation before any compute job is submitted:
- Verifies all required system binaries are available
- Confirms all user-defined variables are set and valid
- Validates input directory structure and FASTQ files
- Ensures all pipeline scripts exist and are executable
- Constructs the execution ABI (`EXPORT_ARRAY`)
- Confirms pipeline structure and execution modules
- Creates a deterministic `conda` environment for MultiQC using:
  - reproducible YAML specification
  - tmux-based environment provisioning
  - sentinel-driven synchronisation with timeout protection

## Pipeline orchestration
The entrypoint submits a SLURM orchestration script (`pipeline.sh`), which:
- Logs execution using a centralised log file
- Submits module scripts as SLURM jobs using sbatch
- Passes the full execution ABI via `SBATCH_EXPORTS`
- Captures job IDs for dependency chaining

## Execution modules

### `1-fastqc.sh`
- Runs FastQC on all detected `.fastq.gz` files
- Uses per-file processing to ensure robustness
- Writes results to the `FASTQC_OUTDIR`
- Uses SLURM-provided CPU allocation

### `2-multiqc.sh`
- Activates the pre-built `conda` environment
- Aggregates FastQC outputs into a single report
- Uses a job-specific temporary directory
- Writes results to the MULTIQC_OUTDIR

# Dependency model
Execution order is strictly enforced:
```text
1-fastqc → 2-multiqc
```

MultiQC only runs if FastQC completes successfully.

# Execution environment
- Preflight runs on the login node
- Environment creation occurs inside a `tmux` session
- Execution modules run on SLURM compute nodes
- No implicit state is relied upon across boundaries
- All variables passed via `SBATCH_EXPORTS`

This ensures full reproducibility and portability across HPC clusters.

# Configuration
All user-defined parameters are specified in `config.sh`.

At minimum, the pipeline requires:
```bash
INPUT_DIR="<path to FASTQ directory>"
FASTQC_CPUS=<int>
FASTQC_MEM_PER_CPU="<value>"
MULTIQC_CPUS=<int>
MULTIQC_MEM_PER_CPU="<value>"
```

| Variable | Description |
|----------|------------|
| `INPUT_DIR` | Directory containing input `.fastq.gz` files |
| `FASTQC_CPUS` | Number of CPUs allocated to FastQC jobs |
| `FASTQC_MEM_PER_CPU` | Memory per CPU for FastQC |
| `MULTIQC_CPUS` | Number of CPUs allocated to MultiQC |
| `MULTIQC_MEM_PER_CPU` | Memory per CPU for MultiQC |

# Usage
From the pipeline root directory:
```bash
bash fastq-qc.sh
```

This will:
- Run full preflight validation
- Construct the execution environment
- Submit SLURM jobs
- Execute FastQC and MultiQC in sequence

# Outputs
All outputs are written to `output/` in execution order:

```text
output/
├── 1-fastqc/
│   ├── sample1_fastqc.zip
│   ├── sample1_fastqc.html
│   └── ...
└── 2-multiqc/
    ├── multiqc_report.html
    └── multiqc_data/
```

Outputs are:
- deterministic
- reproducible
- organised by execution stage

# Architecture Summary

| Layer | Responsibility |
|------|----------------|
| `config.sh` | User-defined configuration |
| `arrays/` | Declarative ABI and pipeline contract |
| `utils/` | Static parameter definitions |
| `functions/` | Atomic helper logic |
| `preflight/` | Validation and environment setup |
| `pipeline/` | SLURM orchestration |
| `modules` | Execution (FastQC, MultiQC) |


# Further Documentation
For detailed documentation on individual components:
- `arrays/README.md` — contract layer and ABI design
- `preflight/README.md` — validation logic and guarantees
- `pipeline/README.md` — orchestration and execution model
- `utils/README.md` — static configuration variables
- `functions/README.md` — helper abstractions

# Design Principles
This pipeline enforces:
- Contract-driven design
- Fail-fast validation
- Explicit execution boundaries
- Deterministic environment provisioning
- Strict separation of concerns

# Citation
If you use this pipeline in published work, please cite:

> Baptista, R. _fastq-qc: A contract-driven HPC pipeline for FASTQ quality control_.
> GitHub repository: https://github.com/romanbaptista/fastq-qc