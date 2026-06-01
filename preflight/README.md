# `preflight`

# Overview
The `preflight/` directory implements the validation and environment construction layer of the pipeline.

This layer is responsible for ensuring that all requirements are satisfied before any SLURM jobs are submitted.
It performs:
- validation of user configuration
- validation of system environment
- validation of input FASTQ data
- validation of pipeline structure
- construction of runtime directories
- creation of runtime environments (MultiQC conda environment)
- construction of the execution ABI (`SBATCH_EXPORTS`)

The preflight phase enforces a strict fail‑fast model, guaranteeing that downstream execution begins only in a fully validated and deterministic state.

# Design Principles
The preflight layer follows core architectural rules:
- Fail-fast — any error immediately terminates the pipeline
- Validation-only responsibility — no execution or data processing logic
- Deterministic ordering — all steps run in a strictly defined sequence
- Explicit contracts — validation driven entirely by arrays
- No hidden state — all required variables, tools, and inputs are explicitly checked
- Reproducibility — environments are created deterministically from YAML specifications

This ensures that all downstream scripts can assume:
- consistent state
- valid inputs
- functional tools
- reproducible environments

# Role in the Pipeline
The preflight layer is executed immediately after the entrypoint script (`fastq-qc.sh`) and before any SLURM submission occurs.

It ensures:
- all required variables are defined and non-empty
- all required binaries are available
- all input files and directories are valid
- all pipeline scripts exist and are executable
- all runtime directories are created
- the MultiQC conda environment is created and ready
- the execution ABI is fully constructed

Only once all checks succeed does execution proceed to the pipeline orchestration stage.

# Execution Flow
Preflight is orchestrated by `preflight.sh`.

This script:
- sources `array_preflight.sh`
- validates the existence of `preflight_env.sh` explicitly
- executes each preflight script in order
- terminates immediately on failure

Each script:
- consumes only validated upstream state
- constructs or validates a specific part of the environment

This enforces a strict producer → consumer relationship between stages.

# Preflight Stages
The pipeline implements the following validation stages:

### Paths
- Defines all pipeline directories via `utils_paths.sh`
- Extends `DIR_ARRAY` with pipeline-specific directories
- Creates all required directories

### Variables
- Validates user-defined configuration variables from `config.sh`

### Binaries
- Verifies required system-level CLI tools from `BINARY_ARRAY`

### Input
- Validates input directory structure
- Confirms presence of `.fastq.gz` files

### Exports
- Constructs the pipeline execution ABI from `EXPORT_ARRAY`
- Generates `SBATCH_EXPORTS` for SLURM job submission

### Pipeline
- Confirms all module scripts exist
- Ensures scripts are non-empty and executable
- Validates presence of `pipeline.sh`

### MultiQC Environment
- Validates existence of the MultiQC conda environment
- If absent:
    - launches a `tmux` session
    - executes `preflight_env.sh`
    - synchronises via sentinel file
    - enforces timeout on environment creation
- Confirms environment availability before allowing pipeline execution

# Script Structure
Each preflight script follows a consistent structure:
```text
GUARDS
SETUP
SOURCE
CHECKS
MAIN
```

- `GUARDS` validate required input variables
- `SETUP` defines script-level constants
- `SOURCE` imports required definitions
- `CHECKS` validate consumed state
- `MAIN` performs validation or state construction

This structure ensures:
- predictable control flow
- minimal side effects
- explicit dependencies

# Environment Construction Model
The pipeline implements a two-stage environment construction model:

1. `preflight_multiqc.sh`
- Runs in the main preflight context
- Checks if the environment already exists
- Launches a `tmux` session if required
- Passes required variables across the boundary
- Waits for a sentinel file to signal completion

2. `preflight_env.sh`
- Runs inside the `tmux` session (new shell)
- Re-sources required functions
- Enables `conda`
- Creates the environment from a YAML file
- Writes a sentinel file upon completion

This separation ensures:
- correct handling of execution boundaries
- no reliance on inherited shell state
- deterministic environment provisioning

# Execution ABI
The preflight layer constructs the execution ABI via:
- `array_exports.sh` → defines required variables
- `preflight_exports.sh` → constructs `SBATCH_EXPORTS`

This ensures that:
- only required variables are passed to SLURM jobs
- no implicit environmental state is relied upon
- execution is reproducible across compute nodes

# Execution Relationships

| Script | Responsibility |
|--------|----------------|
| `preflight.sh` | Orchestrates execution of all preflight checks |
| `preflight_paths.sh` | Defines and creates required directories |
| `preflight_variables.sh` | Validates user configuration variables |
| `preflight_binaries.sh` | Validates required system binaries |
| `preflight_input.sh` | Validates input FASTQ directory and files |
| `preflight_exports.sh` | Constructs SBATCH_EXPORTS from EXPORT_ARRAY |
| `preflight_pipeline.sh` | Validates pipeline scripts and orchestrator |
| `preflight_multiqc.sh` | Orchestrates environment creation via tmux and validation |
| `preflight_env.sh` | Creates conda environment within execution boundary |

# Key Rules
- Do not include execution logic in preflight scripts
- Do not defer validation to later stages
- Always fail immediately on errors
- Only validate variables consumed by the script
- Maintain strict ordering via `PREFLIGHT_ARRAY`
- Do not rely on implicit environment state
- Ensure all execution dependencies are satisfied before completion
- Treat `tmux` and SLURM transitions as strict execution boundaries

# Summary
The `preflight/` directory guarantees that the pipeline executes in an environment that is:
- fully validated
- reproducible
- deterministic

By enforcing strict contracts and fail-fast validation, it provides a clean boundary between setup and execution.
This ensures that all downstream pipeline stages can operate:
- without ambiguity
- without hidden dependencies
- with full confidence in their execution context