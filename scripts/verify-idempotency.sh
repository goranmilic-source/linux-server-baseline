#!/usr/bin/env bash
#
# verify-idempotency.sh - apply the playbook twice and fail if the
# second run changes anything.
#
# Usage: scripts/verify-idempotency.sh [extra ansible-playbook options]
#   for example: scripts/verify-idempotency.sh -K
#
# Exit codes: 0 = idempotent, 1 = second run changed something,
#             any other code = the playbook itself failed

set -Eeuo pipefail

PLAYBOOK="${PLAYBOOK:-site.yaml}"
LOG_DIR="${LOG_DIR:-.verify}"

mkdir -p "$LOG_DIR"

echo "==> Run 1 of 2: applying ${PLAYBOOK}"
ansible-playbook "$PLAYBOOK" "$@" | tee "${LOG_DIR}/run1.log"

echo "==> Run 2 of 2: checking that nothing changes"
ansible-playbook "$PLAYBOOK" "$@" | tee "${LOG_DIR}/run2.log"

# Add up changed=N from every host's line in the PLAY RECAP.
changed=$(grep 'unreachable=' "${LOG_DIR}/run2.log" \
  | grep -oE 'changed=[0-9]+' \
  | awk -F= '{ total += $2 } END { print total + 0 }')

if (( changed == 0 )); then
  echo "==> PASS: second run changed nothing (changed=0)"
  exit 0
fi

echo "==> FAIL: second run changed ${changed} task(s):"
awk '/^(TASK|RUNNING HANDLER) \[/ { task = $0; sub(/ \*+$/, "", task) }
     /^changed:/ { print "    " task }' "${LOG_DIR}/run2.log" | sort -u
exit 1
