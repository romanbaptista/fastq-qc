# `utils`

# Overview
The `utils/` directory contains all static variable definitions used throughout the pipeline.

These scripts define:
- directory paths
- environment parameters
- tool-specific configuration values

Importantly, `utils/` is a pure definition layer — it contains no logic, validation, or execution.

# Design Principles
The `utils/` layer follows strict design rules:
- Definitions only — no functions or control flow
- No validation — all checks occur in the preflight layer
- No side effects — sourcing only sets variables
- Centralised variable ownership — each variable is defined exactly once
- Deterministic behaviour — no runtime decisions or dynamic modification

These principles ensure that the pipeline maintains a clean separation between:
- what is defined (`utils/`)
- what is validated (`preflight/`)
- what is executed (`pipeline/` and modules)

# Role in the Pipeline
The `utils/` layer acts as the source of truth for derived variables, particularly:
- directory structure
- environment definitions
- tool-specific configuration (e.g. `conda` environment parameters)

| Aspect | Description |
|--------|------------|
| Purpose | Static variable definitions |
| Contains logic? | No |
| Performs validation? | No |
| Consumed by | Preflight and execution layers |
| Scope | Paths and environment/tool parameters |

These variables are:
- consumed by preflight scripts for validation and environment setup
- used to construct derived runtime state (e.g. output directories, environment files)
- passed explicitly downstream through the execution ABI when required

This ensures that all paths and environment parameters are:
- defined once
- validated centrally
- used consistently across all layers

# File Overview
The directory is organised into:
- a shared path definition file (`utils_paths.sh`)
- tool-specific configuration files (`utils_<tool>.sh`)

Each file:
- defines variables within its domain
- contains no logic
- introduces no side effects

| File | Responsibility |
|------|----------------|
| `utils_paths.sh` | Defines core directory variables and initialises DIR_ARRAY |
| `utils_multiqc.sh` | Defines MultiQC environment parameters (ENV_NAME, YAML_FILE, SENTINEL_FILE) |

## `utils_paths.sh`
Defines all core directory paths derived from `ROOT_DIR`.

Typical variables include:
```text
ARRAY_DIR
FUNCTIONS_DIR
PIPELINE_DIR
PREFLIGHT_DIR
UTILS_DIR
OUTPUT_DIR
```

It also initialises `DIR_ARRAY`, which defines the base set of pipeline-owned writable directories.

This array is later extended during preflight to include:
- environment directories (`ENV_DIR`)
- module-specific output directories (`FASTQC_OUTDIR`, `MULTIQC_OUTDIR`)

This file establishes the directory structure contract of the pipeline.

## `utils_multiqc.sh`
Defines all parameters required for the MultiQC environment.

Includes:
- conda environment name (`ENV_NAME`)
- YAML specification path (`YAML_FILE`)
- sentinel file path (`SENTINEL_FILE`)

These variables are consumed by:
- `preflight_multiqc.sh` (orchestration and validation)
- `preflight_env.sh` (environment creation)
- `2-multiqc.sh` (environment activation and execution)

No environment creation or validation logic is included here — it is strictly declarative.

# Variable Ownership Model
Each variable is defined in the layer where its meaning originates:
- global directory structure → `utils_paths.sh`
- tool/environment configuration → `utils_multiqc.sh`
- pipeline-derived values → preflight scripts

This prevents:
- duplication
- accidental redefinition
- hidden dependencies

and ensures each variable has a clear, single owner.

# Usage Pattern
Utils scripts are sourced by preflight and execution scripts:
```bash
source "${UTILS_DIR}/utils_paths.sh"
source "${UTILS_DIR}/utils_multiqc.sh"
```

Variables defined here are then:
- validated in preflight
- used to construct pipeline state
- passed to execution layers where required

They are never redefined during execution.

# Key Rules
- Do not include logic (no loops, no conditionals)
- Do not perform validation
- Do not modify variables after definition
- Ensure variables are clearly named and unambiguous
- Keep all definitions deterministic and reproducible

# Summary
The `utils/` directory defines the static configuration layer of the pipeline.

It ensures that:
- all paths and environment parameters are declared in one place
- variable definitions are consistent and traceable
- downstream scripts rely on a stable, pre-validated environment

This separation is critical for maintaining a:
- reproducible
- portable
- contract-driven HPC pipeline architecture