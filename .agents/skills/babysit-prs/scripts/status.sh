#!/usr/bin/env bash
# status.sh - show babysit-prs launchd job status, recent log lines, and
# a summary of what's currently tracked in the state file.

set -euo pipefail

LABEL="cli.copilot.babysit-prs"
PLIST_PATH="${HOME}/Library/LaunchAgents/${LABEL}.plist"
LOG_PATH="${HOME}/Library/Logs/babysit-prs.log"
STATE_FILE="${HOME}/.local/state/babysit-prs/state.json"

echo "== launchd job =="
if [ -f "$PLIST_PATH" ]; then
  if launchctl list "$LABEL" >/dev/null 2>&1; then
    launchctl list "$LABEL"
  else
    echo "Plist exists at ${PLIST_PATH} but job is not loaded. Run install-schedule.sh again."
  fi
else
  echo "Not installed. Run install-schedule.sh to set up the schedule."
fi

echo
echo "== recent log (${LOG_PATH}) =="
if [ -f "$LOG_PATH" ]; then
  tail -n 40 "$LOG_PATH"
else
  echo "No log file yet."
fi

echo
echo "== tracked PR state (${STATE_FILE}) =="
if [ -f "$STATE_FILE" ] && command -v jq >/dev/null 2>&1; then
  jq -r '
    .prs
    | to_entries
    | map("\(.key): last_activity=\(.value.last_activity // "-") notified=\(if (.value.notified_sig // "") == "" then "no" else "yes" end)")
    | .[]
  ' "$STATE_FILE"
else
  echo "No state file yet (job has not run, or --dry-run only so far)."
fi
