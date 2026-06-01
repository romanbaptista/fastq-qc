# `functions`

# Overview
The `functions/` directory contains all reusable, atomic logic used throughout the pipeline.

These scripts provide:
- validation primitives
- filesystem and variable checks
- conda environment helpers
- shared utility operations

They represent the execution logic layer, but are strictly limited to stateless, reusable operations.

# Design Principles

| Principle | Description |
|----------|------------|
| Atomicity | Functions perform a single task |
| No orchestration | Control flow handled outside functions |
| Validation-first | Inputs are validated before use |
| Return-based | Failures propagate via return codes |

These principles ensure that:
- logic is modular and reusable
- failure handling is consistent and predictable
- orchestration remains external to function definitions

# File Overview
The `functions/` directory is structured into:
- a shared base layer (`functions_base.sh`)
- environment helpers (`functions_conda.sh`)

Each file has a clearly defined responsibility.

| File | Responsibility |
|------|----------------|
| `functions_base.sh` | Core validation, filesystem operations, and error handling |
| `functions_conda.sh` | Conda environment helpers (enable, create, activate, validate) |

## `functions_base.sh`
This file defines all core helper functions used across the entire pipeline.

It includes:
- argument validation (`arg_check_nonempty`)
- variable validation (`variable_check_nonempty`)
- array validation (`array_check_nonempty`)
- file and directory checks
- filesystem operations (`directory_create`, etc.)
- generic error handling (`fail_message`)

This file forms the foundation of the contract-driven validation system.

All scripts that require:
- validation
- filesystem interaction
- structured error handling

must source this file.

## `functions_conda.sh`
Provides atomic helpers for working with `conda` environments.

### Responsibilities
- enabling conda in non-interactive shells (`conda_enable`)
- loading conda modules (`conda_load`)
- checking environment existence (`conda_check_env`)
- creating environments from YAML (`conda_create_env`)
- activating environments (`conda_activate_env`)

### Key characteristics
- designed for HPC batch and `tmux` contexts
- handles non-interactive shell constraints
- assumes no prior environment state
- performs no orchestration

Validation and control flow are handled in:
- `preflight_multiqc.sh`
- `preflight_env.sh`
- execution modules (`2-multiqc.sh`)

This ensures a clean separation:
- functions → logic
- preflight → orchestration and validation
- modules → execution

# Execution Pattern
Functions follow a strict internal structure:

```bash
my_function() {
    local arg="${1-}"

    # VALIDATION
    arg_check_nonempty "${arg}" || return $?

    # FUNCTION
    do_something "${arg}" || return 1
}
```

This pattern guarantees:
- predictable behaviour
- clear error propagation
- composability across scripts

# Usage in Pipeline
Functions are used across:
- preflight scripts → validation, environment construction, tool checks
- pipeline scripts → minimal helpers where required
- module scripts → filesystem operations, environment activation

Scripts explicitly source the required functions:
```bash
source "${FUNCTIONS_DIR}/functions_base.sh"
source "${FUNCTIONS_DIR}/functions_conda.sh"
```

No implicit function availability is assumed across execution boundaries.

# Execution Boundary Model
The pipeline enforces strict behaviour across execution contexts:
- Same-shell (preflight) → Functions assumed available from entrypoint
- `tmux` session → Functions must be re-sourced
- SLURM job → Functions must be re-sourced

This ensures that:
- no hidden dependencies exist
- all scripts are self-sufficient across process boundaries
- behaviour is deterministic across execution environments

# Error Handling
Functions:
- return non-zero exit codes on failure
- do not terminate execution directly

Pipeline scripts handle failure via:
```bash
function_call || fail_message "error description"
```

This ensures:
- centralised failure control
- consistent messaging
- strict separation between logic and control flow

# Variable and Validation Model
Functions implement a layered validation system:
- `arg_check_nonempty` → validates function arguments
- `variable_check_nonempty` → validates named pipeline variables
- `array_check_nonempty` → validates array structure and contents

Each function:
- validates only its own scope
- does not assume upstream guarantees unless explicitly enforced

This enables a composable validation chain across the pipeline.

# Key Rules
- Do not include orchestration logic in functions
- Do not use exit inside functions
- Always validate inputs before execution
- Keep functions minimal and focused
- Avoid hidden dependencies or global state
- Ensure all functions are reusable across pipeline contexts

# Summary
The `functions/` directory provides the core logic building blocks of the pipeline.

It enables:
- consistent validation and error handling
- strict separation between logic and orchestration
- modular, reusable, and testable components

All higher-level behaviour in the pipeline is constructed from these atomic functions, ensuring:
- clarity of responsibility
- reproducibility
- maintainability