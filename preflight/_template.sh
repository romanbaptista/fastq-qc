#!/bin/bash
set -euo pipefail

######################### GUARDS #########################

GUARD_ARRAY=(
    # Guard variables go here
)

for var in "${GUARD_ARRAY[@]}"; do
    variable_check_nonempty "${var}" || fail_message "Guard check failed: ${var}"
done

######################### SETUP ##########################

# Define script name
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}" .sh)

######################### SOURCE #########################

# Source array
source "${ARRAY_DIR}/array_.sh"

######################### CHECKS #########################

variable_check_nonempty ARRAY || fail_message "ARRAY is empty or is not set"
array_check_nonempty ARRAY || fail_message "ARRAY has no elements"

######################### MAIN ###########################

echo
echo "RUNNING ${SCRIPT_NAME} ..."
echo "  Doing something..."

...

echo "  Something done"
echo "${SCRIPT_NAME} COMPLETE"

