#!/usr/bin/env bash
# install-schedule.sh - install babysit-prs.sh as a launchd LaunchAgent.
#
# launchd (not Copilot CLI's /every) is the scheduler here on purpose: it
# survives sleep/wake, terminal closure, and CLI crashes, and costs zero LLM
# tokens per tick. This script generates and loads the plist; babysit-prs.sh
# itself is unchanged either way.
#
# Usage:
#   install-schedule.sh [--interval-minutes N] [--owner OWNER]...
#                        [--allowed-repo OWNER/REPO]... [--skip-repo OWNER/REPO]...
#                        [--active-days N] [--no-notify]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE="${SCRIPT_DIR}/babysit-prs.sh"
LABEL="cli.copilot.babysit-prs"
PLIST_PATH="${HOME}/Library/LaunchAgents/${LABEL}.plist"
LOG_PATH="${HOME}/Library/Logs/babysit-prs.log"
INTERVAL_MINUTES=15
declare -a PASSTHROUGH_ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --interval-minutes) INTERVAL_MINUTES="$2"; shift 2 ;;
    --owner) PASSTHROUGH_ARGS+=(--owner "$2"); shift 2 ;;
    --allowed-repo) PASSTHROUGH_ARGS+=(--allowed-repo "$2"); shift 2 ;;
    --skip-repo) PASSTHROUGH_ARGS+=(--skip-repo "$2"); shift 2 ;;
    --active-days) PASSTHROUGH_ARGS+=(--active-days "$2"); shift 2 ;;
    --no-notify) PASSTHROUGH_ARGS+=(--no-notify); shift ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [ ! -x "$ENGINE" ]; then
  echo "engine script not found or not executable: $ENGINE" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found on PATH" >&2
  exit 1
fi
GH_PATH="$(command -v gh)"
JQ_PATH="$(command -v jq)"
GH_DIR="$(dirname "$GH_PATH")"
JQ_DIR="$(dirname "$JQ_PATH")"

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated. Run: gh auth login --scopes repo,workflow" >&2
  exit 1
fi

mkdir -p "$(dirname "$PLIST_PATH")" "$(dirname "$LOG_PATH")"

# Build the <string> entries for ProgramArguments.
ARGS_XML="        <string>${ENGINE}</string>"
if [ "${#PASSTHROUGH_ARGS[@]}" -gt 0 ]; then
  for a in "${PASSTHROUGH_ARGS[@]}"; do
    ARGS_XML="${ARGS_XML}
        <string>${a}</string>"
  done
fi

cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
${ARGS_XML}
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>${GH_DIR}:${JQ_DIR}:/usr/bin:/bin:/usr/sbin:/sbin</string>
        <key>HOME</key>
        <string>${HOME}</string>
    </dict>
    <key>StartInterval</key>
    <integer>$((INTERVAL_MINUTES * 60))</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${LOG_PATH}</string>
    <key>StandardErrorPath</key>
    <string>${LOG_PATH}</string>
</dict>
</plist>
PLIST

# launchctl unload is a no-op (with a harmless error) if it wasn't loaded.
launchctl unload "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl load -w "$PLIST_PATH"

echo "Installed and loaded ${LABEL} (every ${INTERVAL_MINUTES}m)."
echo "Plist: ${PLIST_PATH}"
echo "Log:   ${LOG_PATH}"
echo "Check status with: scripts/status.sh"
