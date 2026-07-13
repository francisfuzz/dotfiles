#!/usr/bin/env bash
# uninstall-schedule.sh - unload and remove the babysit-prs launchd job.

set -euo pipefail

LABEL="cli.copilot.babysit-prs"
PLIST_PATH="${HOME}/Library/LaunchAgents/${LABEL}.plist"

if [ -f "$PLIST_PATH" ]; then
  launchctl unload "$PLIST_PATH" >/dev/null 2>&1 || true
  rm -f "$PLIST_PATH"
  echo "Uninstalled ${LABEL} and removed ${PLIST_PATH}."
else
  echo "No plist found at ${PLIST_PATH}; nothing to do."
fi
