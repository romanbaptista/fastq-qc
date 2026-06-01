# `pipeline`

# Overview
The `pipeline/` directory contains the execution layer of the pipeline.

| File | Responsibility |
|------|----------------|
| `pipeline.sh` | Orchestrates SLURM job submission and dependency chaining |
| `1-fastqc.sh` | Runs FastQC on input FASTQ files |
| `2-multiqc.sh` | Aggregates FastQC outputs using MultiQC |

These scripts implement the data processing workflow, operating on a fully validated environment created by the preflight layer.

All execution in this directory assumes that:
- all required variables are defined
- all required tools are installed and functional
- all directories are correctly initialised

No validation or setup logic is duplicated here.

# Module Naming Convention
Module scripts follow the pattern:

```text
<stage>-<tool>.sh
```

This reflects the execution stage and tool responsibility within the pipeline.
Examples in this pipeline:

```text
`1-fastqc.sh`     → runs FastQC on input FASTQ files
`2-multiqc.sh`    → aggregates results using MultiQC
```

This convention provides:
- clear indication of execution order
- consistent naming across pipelines
- improved readability in logs and outputs

# Design Contract
All scripts in this directory adhere to the following principles:
- single responsibility per script
- execution-only (no validation logic beyond guards)
- explicit input and output paths
- deterministic behaviour
- no reliance on implicit working directories
- no reliance on undeclared global state
- compatibility with SLURM execution boundaries

Modules assume that all preflight invariants have already been enforced.

# Execution Model
The execution layer is orchestrated by `pipeline.sh`.

This script:
- runs on the login node (submitted after preflight)
- consumes a fully validated environment
- submits module scripts as SLURM jobs

Execution behaviour is defined by:
- explicit module submission
- SLURM dependency chaining
- controlled resource allocation

Unlike array-based pipelines, this implementation uses stage-based execution:

| Component | Role |
|----------|------|
| Orchestrator (``pipeline.sh``) | Submits and coordinates SLURM jobs |
| Module (``1-fastqc.sh``) | Performs FastQC analysis |

## `pipeline.sh`

### Role
- `pipeline.sh` is the internal orchestrator for the execution layer
- It coordinates SLURM job submission but performs no data processing

### Responsibilities
- configures pipeline-level logging (`tee`)
- submits `1-fastqc.sh` via SLURM
- captures FastQC job ID (`--parsable`)
- submits `2-multiqc.sh` with dependency on FastQC completion
- passes the execution ABI via `SBATCH_EXPORTS`
- enforces fail-fast behaviour on job submission
 
### Guarantees
- deterministic orchestration
- explicit job dependency management
- no duplication of preflight validation
- strict ABI propagation across SLURM boundary

# Module Overview
Each module implements a single execution responsibility.

Modules are:
- execution-only
- stateless beyond defined inputs/outputs
- restart-safe where applicable
- fully dependent on preflight guarantees

## `1-fastqc.sh`

### Role
Performs FastQC analysis on all `.fastq.gz` files in the input directory.

### Inputs
```text
INPUT_DIR
FASTQC_OUTDIR
SLURM_CPUS_PER_TASK
```

### Workflow
- loads FastQC module via environment modules
- discovers all `.fastq.gz` files
- processes each file independently
- runs FastQC using allocated SLURM CPUs
- writes results to `FASTQC_OUTDIR`

### Outputs
```text
output/1-fastqc/
├── sample1_fastqc.html
├── sample1_fastqc.zip
└── ...
```

### Guarantees
- per-file processing
- deterministic output structure
- consistent CPU utilisation via SLURM
- failure isolation with clear error reporting

## `2-multiqc.sh`

### Role
Aggregates FastQC outputs into a single report using MultiQC.

### Inputs
```text
FASTQC_OUTDIR
MULTIQC_OUTDIR
OUTPUT_DIR
ENV_NAME
SLURM_JOB_ID
```

### Workflow
- enables `conda` inside SLURM job environment
- activates pre-built MultiQC environment
- unsets `PYTHONPATH` to avoid contamination
- creates a temporary job-specific directory
- runs MultiQC on FastQC output directory
- cleans up temporary directory on exit
- deactivates environment

### Outputs
```text
output/2-multiqc/
├── multiqc_report.html
└── multiqc_data/
```

### Guarantees
- deterministic aggregation
- isolated temporary workspace
- environment reproducibility via `conda`
- clean teardown of resources
- no reliance on upstream shell state

# Execution Boundary Considerations
This pipeline operates across strict execution boundaries.

Key principles:
- preflight and orchestration run in one shell
- `tmux` sessions create environments independently
- modules run in separate SLURM job shells
- environment state is never implicitly shared

This is enforced through:

```text
EXPORT_ARRAY → defines execution ABI
SBATCH_EXPORTS → injects variables into SLURM jobs
```

Modules:
- rely only on exported variables
- reinitialise required environments (e.g. `conda`)
- do not assume inherited state

# Logging Model
The pipeline implements structured logging:
- `pipeline.sh` → orchestration log (via tee)
- SLURM (`1-fastqc.sh`) → FastQC job logs
- SLURM (`2-multiqc.sh`) → MultiQC job logs

This ensures:
- traceability of execution
- separation of orchestration and computation logs
- reproducible debugging

# Key Rules
- do not include validation logic in modules
- do not install tools during execution
- do not modify global configuration
- always use explicit paths
- ensure restart-safe behaviour
- maintain strict separation between orchestration and execution
- never rely on implicit environment state across SLURM boundaries

# Summary
The `pipeline/` directory implements the execution phase of the pipeline.

It provides:
- a SLURM-based orchestration layer
- stage-based execution with explicit dependencies
- scalable, parallel processing across compute nodes

This design ensures that all runtime behaviour is:
- deterministic
- reproducible
- robust across HPC environments
- easy to extend and maintain