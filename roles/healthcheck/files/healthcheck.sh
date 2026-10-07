#!/bin/bash
#
# healthcheck.sh - basic server health check
#
# Checks disk, memory, CPU load and key services, then writes one
# summary line to the screen and to a log file.
#
# Exit codes (monitoring convention):
#   0 = OK
#   1 = WARNING
#   2 = CRITICAL
#   3 = UNKNOWN (the script itself failed)
#
# Settings can be changed with environment variables, for example:
#   DISK_WARN=50 ./healthcheck.sh

set -Eeuo pipefail

# If any command fails unexpectedly, report UNKNOWN instead of a misleading result.
trap 'echo "UNKNOWN: healthcheck failed on line ${LINENO}" >&2; exit 3' ERR


# ----- Settings (override with environment variables) -----
DISK_WARN="${DISK_WARN:-80}"     # % of root filesystem used
DISK_CRIT="${DISK_CRIT:-90}"
MEM_WARN="${MEM_WARN:-80}"       # % of memory used
MEM_CRIT="${MEM_CRIT:-90}"
LOAD_WARN="${LOAD_WARN:-70}"     # 1-minute load as % of CPU cores
LOAD_CRIT="${LOAD_CRIT:-100}"
SERVICES="${SERVICES:-ssh ufw fail2ban}"
LOG_FILE="${HEALTHCHECK_LOG:-/var/log/healthcheck.log}"

LEVEL_NAMES=(OK WARNING CRITICAL UNKNOWN)

overall=0
summary=""

# ----- Helper functions -----

# level_for VALUE WARN CRIT -> prints 0 (OK), 1 (WARNING) or 2 (CRITICAL)
level_for() {
  local value="$1" warn="$2" crit="$3"
  if (( value >= crit )); then
    echo 2
  elif (( value >= warn )); then
    echo 1
  else
    echo 0
  fi
}

# record LEVEL CHECK_NAME DETAIL -> adds to the summary and keeps the worst level
record() {
  local level="$1" check="$2" detail="$3"
  summary+="${check}=${LEVEL_NAMES[level]}(${detail}) "
  if (( level > overall )); then
    overall="$level"
  fi
}


# ----- Checks -----

check_disk() {
  local used
  used=$(df --output=pcent / | tail -n 1 | tr -dc '0-9')
  record "$(level_for "$used" "$DISK_WARN" "$DISK_CRIT")" "disk" "${used}%"
}

check_memory() {
  local used
  used=$(free | awk '/^Mem:/ { printf "%d", ($2 - $7) * 100 / $2 }')
  record "$(level_for "$used" "$MEM_WARN" "$MEM_CRIT")" "memory" "${used}%"
}

check_load() {
  local load1 cores load_pct
  read -r load1 _ < /proc/loadavg
  cores=$(nproc)
  load_pct=$(awk -v l="$load1" -v c="$cores" 'BEGIN { printf "%d", l / c * 100 }')
  record "$(level_for "$load_pct" "$LOAD_WARN" "$LOAD_CRIT")" "load" "${load_pct}%"
}

check_services() {
  local services service
  read -r -a services <<< "$SERVICES"
  for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
      record 0 "svc_${service}" "active"
    else
      record 2 "svc_${service}" "inactive"
    fi
  done
}


# ----- Main -----
check_disk
check_memory
check_load
check_services

line="$(date --iso-8601=seconds) status=${LEVEL_NAMES[overall]} ${summary% }"
echo "$line"
echo "$line" >> "$LOG_FILE"

exit "$overall"
