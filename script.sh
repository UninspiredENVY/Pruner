#!/bin/bash
set -euo pipefail

#############################################
# Unraid User Script: Prune local folder + Discord (NO rclone)
# Keeps newest N top-level items in TARGET_DIR (files and/or folders).
#############################################

START_TIME=$(date +%s)

# --- CONFIG ---
TARGET_DIR="/mnt/user/backups/MyBackups"         # folder to prune
KEEP_COUNT=7                                      # keep newest N (by modified time)
DRY_RUN=true                                      # set false to actually delete
DISCORD_WEBHOOK="https://discord.com/api/webhooks/REPLACE_ME"  # <-- set me
# -------------

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

send_discord() {
  local message="$1"
  [[ -z "${DISCORD_WEBHOOK}" || "${DISCORD_WEBHOOK}" == *"REPLACE_ME"* ]] && return 0

  # Minimal JSON escaping for Discord
  local payload
  payload=$(printf '{"content":"%s"}' "$(echo "$message" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n')")
  curl -fsSL -H "Content-Type: application/json" -d "$payload" "$DISCORD_WEBHOOK" >/dev/null || true
}

format_duration() {
  local s="$1"
  local h=$((s/3600))
  local m=$(((s%3600)/60))
  local sec=$((s%60))
  if (( h > 0 )); then
    printf "%dh %dm %ds" "$h" "$m" "$sec"
  elif (( m > 0 )); then
    printf "%dm %ds" "$m" "$sec"
  else
    printf "%ds" "$sec"
  fi
}

PRUNED_COUNT=0
STATUS="SUCCESS"

finish() {
  local exit_code=$?
  local end_time elapsed duration mode msg
  end_time=$(date +%s)
  elapsed=$((end_time - START_TIME))
  duration=$(format_duration "$elapsed")

  if (( exit_code != 0 )); then
    STATUS="FAILED (exit ${exit_code})"
  fi

  mode="LIVE"
  [[ "${DRY_RUN}" == "true" ]] && mode="DRY RUN"

  msg="🧹 **Prune Completed** (${mode})
**Target:** \`${TARGET_DIR}\`
**Kept:** ${KEEP_COUNT}
**Pruned:** ${PRUNED_COUNT} item(s)
**Total time:** ${duration}
**Status:** ${STATUS}"

  send_discord "$msg"
}
trap finish EXIT

# Safety checks
if [[ -z "${TARGET_DIR}" || "${TARGET_DIR}" == "/" ]]; then
  log "ERROR: TARGET_DIR is unsafe ('${TARGET_DIR}'). Refusing to run."
  exit 1
fi

if [[ ! -d "${TARGET_DIR}" ]]; then
  log "ERROR: TARGET_DIR does not exist: ${TARGET_DIR}"
  exit 1
fi

if ! [[ "${KEEP_COUNT}" =~ ^[0-9]+$ ]] || (( KEEP_COUNT < 0 )); then
  log "ERROR: KEEP_COUNT must be a non-negative integer."
  exit 1
fi

log "Target: ${TARGET_DIR}"
log "Keep newest: ${KEEP_COUNT}"
log "Dry run: ${DRY_RUN}"

# Build list of direct children sorted newest -> oldest (mtime)
mapfile -d '' ITEMS < <(
  find "${TARGET_DIR}" -mindepth 1 -maxdepth 1 -printf '%T@ %p\0' \
  | sort -z -nr
)

TOTAL=${#ITEMS[@]}
if (( TOTAL == 0 )); then
  log "Nothing to prune (folder is empty)."
  exit 0
fi

log "Found ${TOTAL} item(s)."

if (( TOTAL <= KEEP_COUNT )); then
  log "No pruning needed (<= KEEP_COUNT)."
  exit 0
fi

# Determine what to delete (everything after KEEP_COUNT newest)
DELETE_LIST=()
for (( i=KEEP_COUNT; i<TOTAL; i++ )); do
  entry="${ITEMS[$i]}"
  path="${entry#* }"
  DELETE_LIST+=("$path")
done

PRUNED_COUNT=${#DELETE_LIST[@]}

log "Will prune ${PRUNED_COUNT} item(s):"
for p in "${DELETE_LIST[@]}"; do
  echo "  - $p"
done

if [[ "${DRY_RUN}" == "true" ]]; then
  log "DRY_RUN enabled. No deletions performed."
  exit 0
fi

# Delete safely (files or directories)
for p in "${DELETE_LIST[@]}"; do
  if [[ -d "$p" ]]; then
    rm -rf -- "$p"
  else
    rm -f -- "$p"
  fi
done

log "Prune complete."
