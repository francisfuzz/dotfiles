#!/usr/bin/env bash
# babysit-prs.sh - shepherd your own open pull requests (no Python, gh + jq only).
#
# For each open PR you authored or are assigned to (recently active):
#   - reruns failed REQUIRED checks once per head commit (authored PRs only)
#   - updates the branch when the base is strict and the PR is cleanly behind (authored PRs only)
#   - notifies (macOS osascript) only when a per-PR state signature changes:
#     conflicts, changes requested, a new non-bot comment/review, a required
#     check still red after the retry, a failed branch update, or ready-to-merge.
#
# Designed to be invoked on a schedule (see scripts/install-schedule.sh for a
# launchd-based scheduler). Prints NOTHING to stdout on a no-op run, so an
# agent relaying stdout has nothing to relay when nothing needs attention.
#
# Usage:
#   babysit-prs.sh [--owner OWNER]... [--active-days N] [--allowed-repo OWNER/REPO]...
#                  [--skip-repo OWNER/REPO]... [--dry-run] [--no-notify]
#                  [--state-file PATH] [--verbose]

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults & argument parsing
# ---------------------------------------------------------------------------
ACTIVE_DAYS=14
DRY_RUN=false
NO_NOTIFY=false
VERBOSE=false
STATE_FILE="${HOME}/.local/state/babysit-prs/state.json"
declare -a OWNERS=()
declare -a ALLOWED_REPOS=()
declare -a SKIP_REPOS=()

log() { if [ "$VERBOSE" = true ]; then echo "[babysit-prs] $*" >&2; fi; }
err() { echo "[babysit-prs] ERROR: $*" >&2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --owner) OWNERS+=("$2"); shift 2 ;;
    --active-days) ACTIVE_DAYS="$2"; shift 2 ;;
    --allowed-repo) ALLOWED_REPOS+=("$2"); shift 2 ;;
    --skip-repo) SKIP_REPOS+=("$2"); shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --no-notify) NO_NOTIFY=true; shift ;;
    --state-file) STATE_FILE="$2"; shift 2 ;;
    --verbose) VERBOSE=true; shift ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) err "unknown argument: $1"; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Preconditions
# ---------------------------------------------------------------------------
for bin in gh jq; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    err "'$bin' is required but not found on PATH"
    exit 1
  fi
done

if ! gh auth status >/dev/null 2>&1; then
  err "gh is not authenticated. Run: gh auth login --scopes repo,workflow"
  exit 1
fi

ME="$(gh api user --jq .login)"
log "authenticated as $ME"

# ---------------------------------------------------------------------------
# State file: schema-versioned, flat map keyed by PR URL, guarded by a
# shlock-based lock so overlapping runs (e.g. two schedules) don't race on
# read-modify-write. macOS ships shlock; there is no flock(1) on macOS.
# ---------------------------------------------------------------------------
STATE_DIR="$(dirname "$STATE_FILE")"
mkdir -p "$STATE_DIR"
LOCK_FILE="${STATE_FILE}.lock"

acquire_lock() {
  local tries=0
  while ! shlock -f "$LOCK_FILE" -p $$; do
    tries=$((tries + 1))
    if [ "$tries" -ge 50 ]; then
      err "could not acquire lock $LOCK_FILE after ${tries} attempts (another run in progress?)"
      exit 1
    fi
    sleep 0.2
  done
}
release_lock() { rm -f "$LOCK_FILE"; }
trap release_lock EXIT

acquire_lock

if [ ! -f "$STATE_FILE" ]; then
  echo '{"version":1,"prs":{}}' > "$STATE_FILE"
fi

STATE_JSON="$(cat "$STATE_FILE")"
# If a future version bumps the schema and this run doesn't understand it,
# reset rather than risk operating on a shape we don't recognize.
if [ "$(echo "$STATE_JSON" | jq -r '.version // 0')" != "1" ]; then
  log "state file schema mismatch, resetting"
  STATE_JSON='{"version":1,"prs":{}}'
fi

# Accumulator for the new state, built up as we process PRs and written once
# at the end (still under the same lock).
NEW_STATE_JSON="$STATE_JSON"

get_pr_state() {
  # $1 = PR url; prints {} if unknown
  echo "$STATE_JSON" | jq -c --arg url "$1" '.prs[$url] // {}'
}

set_pr_state() {
  # $1 = PR url, $2 = state json
  NEW_STATE_JSON="$(echo "$NEW_STATE_JSON" | jq -c --arg url "$1" --argjson s "$2" '.prs[$url] = $s')"
}

# ---------------------------------------------------------------------------
# Discover PRs: union of authored + assigned, deduped, filtered by
# --active-days (updated:>=DATE), --owner and --allowed-repo/--skip-repo.
# ---------------------------------------------------------------------------
SINCE="$(date -u -v-"${ACTIVE_DAYS}"d +%Y-%m-%d)"
log "active window: updated >= $SINCE"

declare -a SEARCH_FLAGS=()
for o in "${OWNERS[@]:-}"; do
  [ -n "$o" ] && SEARCH_FLAGS+=(--owner "$o")
done
for r in "${ALLOWED_REPOS[@]:-}"; do
  [ -n "$r" ] && SEARCH_FLAGS+=(--repo "$r")
done

FIELDS="url,repository,number"
declare -a AUTHORED_CMD=(gh search prs "updated:>=${SINCE}" --author=@me --state=open --json "$FIELDS" --limit 1000)
declare -a ASSIGNED_CMD=(gh search prs "updated:>=${SINCE}" --assignee=@me --state=open --json "$FIELDS" --limit 1000)
# Guard the expansion, not just default it: bash 3.2 (macOS's default /bin/bash)
# errors under `set -u` on a bare "${arr[@]}" when arr is empty.
if [ "${#SEARCH_FLAGS[@]}" -gt 0 ]; then
  AUTHORED_CMD+=("${SEARCH_FLAGS[@]}")
  ASSIGNED_CMD+=("${SEARCH_FLAGS[@]}")
fi
AUTHORED_JSON="$("${AUTHORED_CMD[@]}")"
ASSIGNED_JSON="$("${ASSIGNED_CMD[@]}")"

if [ "$(echo "$AUTHORED_JSON" | jq 'length')" -ge 1000 ] || [ "$(echo "$ASSIGNED_JSON" | jq 'length')" -ge 1000 ]; then
  err "search results may be truncated at 1000; narrow --active-days or --owner"
fi

ALL_PRS_JSON="$(jq -c -n \
  --argjson a "$AUTHORED_JSON" \
  --argjson s "$ASSIGNED_JSON" \
  --arg me "$ME" \
  '
  ($a | map(. + {authored: true})) + ($s | map(. + {authored: false}))
  | unique_by(.url)
  | group_by(.url) | map(.[0])
  ')"

# Apply --skip-repo after dedup.
if [ "${#SKIP_REPOS[@]}" -gt 0 ]; then
  SKIP_JSON="$(printf '%s\n' "${SKIP_REPOS[@]}" | jq -R . | jq -s .)"
  ALL_PRS_JSON="$(echo "$ALL_PRS_JSON" | jq -c --argjson skip "$SKIP_JSON" \
    '[.[] | select(([.repository.nameWithOwner] - $skip) | length > 0)]')"
fi

PR_COUNT="$(echo "$ALL_PRS_JSON" | jq 'length')"
log "found $PR_COUNT candidate PR(s)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Is this actor a bot we should ignore for "new comment" purposes?
# Copilot's reviewer bots are explicitly NOT ignored, since their feedback
# usually needs a response.
is_ignored_bot() {
  local login="$1" is_bot="$2"
  if [ "$is_bot" != "true" ]; then
    return 1
  fi
  case "$login" in
    copilot|copilot-pull-request-reviewer|copilot-pull-request-reviewer\[bot\]|github-copilot\[bot\])
      return 1 ;; # not ignored
    *)
      return 0 ;; # ignored
  esac
}

notify() {
  local title="$1" message="$2" url="$3"
  if [ "$DRY_RUN" = true ] || [ "$NO_NOTIFY" = true ]; then
    return 0
  fi
  if command -v osascript >/dev/null 2>&1; then
    # Escape double quotes for AppleScript string literals.
    local esc_title esc_message
    esc_title="$(echo "$title" | sed 's/"/\\"/g')"
    esc_message="$(echo "$message" | sed 's/"/\\"/g')"
    osascript -e "display notification \"${esc_message}\" with title \"${esc_title}\"" >/dev/null 2>&1 || \
      err "osascript notification failed (check System Settings > Notifications permissions)"
  fi
}


# ---------------------------------------------------------------------------
# Main per-PR loop
# ---------------------------------------------------------------------------
ATTENTION_LINES=()

while IFS= read -r pr; do
  URL="$(echo "$pr" | jq -r .url)"
  NUMBER="$(echo "$pr" | jq -r .number)"
  NWO="$(echo "$pr" | jq -r .repository.nameWithOwner)"
  OWNER_NAME="${NWO%%/*}"
  REPO_NAME="${NWO##*/}"
  AUTHORED="$(echo "$pr" | jq -r .authored)"

  log "processing $NWO#$NUMBER (authored=$AUTHORED)"

  DETAIL="$(gh pr view "$NUMBER" -R "$NWO" --json \
    isDraft,mergeStateStatus,mergeable,reviewDecision,headRefName,headRefOid,baseRefName,\
statusCheckRollup,reviews,comments,author,updatedAt 2>/dev/null || echo '')"

  if [ -z "$DETAIL" ]; then
    log "  could not fetch details for $NWO#$NUMBER, skipping"
    continue
  fi

  IS_DRAFT="$(echo "$DETAIL" | jq -r .isDraft)"
  MERGE_STATE="$(echo "$DETAIL" | jq -r .mergeStateStatus)"
  REVIEW_DECISION="$(echo "$DETAIL" | jq -r .reviewDecision)"
  HEAD_OID="$(echo "$DETAIL" | jq -r .headRefOid)"
  BASE_REF="$(echo "$DETAIL" | jq -r .baseRefName)"

  PR_STATE="$(get_pr_state "$URL")"
  RERUN_HEAD="$(echo "$PR_STATE" | jq -r '.rerun_head // ""')"
  UPDATE_HEAD="$(echo "$PR_STATE" | jq -r '.update_head // ""')"
  LAST_ACTIVITY="$(echo "$PR_STATE" | jq -r '.last_activity // ""')"
  NOTIFIED_SIG="$(echo "$PR_STATE" | jq -r '.notified_sig // ""')"

  # -- new human comment/review detection (top-level reviews + issue comments
  #    + inline review-thread comments; bots other than Copilot excluded) --
  INLINE_COMMENTS="$(gh api "repos/${NWO}/pulls/${NUMBER}/comments" --jq \
    '[.[] | {login: .user.login, is_bot: (.user.type == "Bot"), created_at: .created_at}]' 2>/dev/null || echo '[]')"

  ACTIVITY_CANDIDATES="$(jq -c -n \
    --argjson reviews "$(echo "$DETAIL" | jq '[.reviews[] | {login: .author.login, is_bot: (.author.is_bot // false), created_at: .submittedAt}]')" \
    --argjson comments "$(echo "$DETAIL" | jq '[.comments[] | {login: .author.login, is_bot: (.author.is_bot // false), created_at: .createdAt}]')" \
    --argjson inline "$INLINE_COMMENTS" \
    '$reviews + $comments + $inline')"

  NEWEST_HUMAN_ACTIVITY=""
  while IFS= read -r item; do
    login="$(echo "$item" | jq -r .login)"
    is_bot="$(echo "$item" | jq -r .is_bot)"
    ts="$(echo "$item" | jq -r .created_at)"
    [ "$ts" = "null" ] || [ -z "$ts" ] && continue
    if is_ignored_bot "$login" "$is_bot"; then
      continue
    fi
    if [ -z "$NEWEST_HUMAN_ACTIVITY" ] || [[ "$ts" > "$NEWEST_HUMAN_ACTIVITY" ]]; then
      NEWEST_HUMAN_ACTIVITY="$ts"
    fi
  done < <(echo "$ACTIVITY_CANDIDATES" | jq -c '.[]')

  NEW_COMMENT=false
  if [ -n "$NEWEST_HUMAN_ACTIVITY" ] && [[ "$NEWEST_HUMAN_ACTIVITY" > "$LAST_ACTIVITY" ]]; then
    NEW_COMMENT=true
  fi
  EFFECTIVE_LAST_ACTIVITY="${NEWEST_HUMAN_ACTIVITY:-$LAST_ACTIVITY}"

  # -- required checks: rulesets first, classic branch protection fallback --
  REQUIRED_CONTEXTS="[]"
  STRICT=false
  CHECKS_READABLE=false

  RULESET_JSON="$(gh api "repos/${NWO}/rules/branches/${BASE_REF}" 2>/dev/null || echo '')"
  if [ -n "$RULESET_JSON" ]; then
    REQUIRED_CONTEXTS="$(echo "$RULESET_JSON" | jq -c \
      '[.[] | select(.type=="required_status_checks") | .parameters.required_status_checks[]?.context] | unique')"
    RULE_STRICT="$(echo "$RULESET_JSON" | jq -r \
      '[.[] | select(.type=="required_status_checks") | .parameters.strict_required_status_checks_policy] | any')"
    if [ "$REQUIRED_CONTEXTS" != "[]" ]; then
      CHECKS_READABLE=true
      [ "$RULE_STRICT" = "true" ] && STRICT=true
    fi
  fi

  if [ "$CHECKS_READABLE" = false ]; then
    PROTECTION_JSON="$(gh api "repos/${NWO}/branches/${BASE_REF}/protection" 2>/dev/null || echo '')"
    if [ -n "$PROTECTION_JSON" ] && echo "$PROTECTION_JSON" | jq -e '.required_status_checks' >/dev/null 2>&1; then
      REQUIRED_CONTEXTS="$(echo "$PROTECTION_JSON" | jq -c '.required_status_checks.contexts // []')"
      STRICT="$(echo "$PROTECTION_JSON" | jq -r '.required_status_checks.strict // false')"
      CHECKS_READABLE=true
    fi
  fi

  if [ "$CHECKS_READABLE" = false ]; then
    log "  required-check set unreadable for $NWO (no admin / no rules) - skipping CI auto-actions"
  fi

  REASONS=()

  # -- auto-action: update stale branch (authored only) --
  if [ "$AUTHORED" = "true" ] && [ "$MERGE_STATE" = "BEHIND" ] && [ "$STRICT" = true ]; then
    if [ "$UPDATE_HEAD" != "$HEAD_OID" ]; then
      log "  branch behind strict base, updating"
      if [ "$DRY_RUN" = false ]; then
        if gh pr update-branch "$NUMBER" -R "$NWO" >/dev/null 2>&1; then
          UPDATE_HEAD="$HEAD_OID"
        else
          REASONS+=("branch update failed")
        fi
      fi
    fi
  fi

  # -- auto-action: rerun failed required checks once per head commit --
  # Run-id extraction and de-dup both happen in jq (not bash associative
  # arrays): macOS ships bash 3.2 by default, which has no `declare -A`.
  if [ "$AUTHORED" = "true" ] && [ "$CHECKS_READABLE" = true ] && [ "$RERUN_HEAD" != "$HEAD_OID" ]; then
    FAILED_RUN_IDS="$(echo "$DETAIL" | jq -r --argjson required "$REQUIRED_CONTEXTS" '
      [.statusCheckRollup[]? | select(.__typename=="CheckRun") | select(.conclusion=="FAILURE") | select(.name as $n | $required | index($n)) | .detailsUrl]
      | map(select(test("/actions/runs/[0-9]+")) | capture("/actions/runs/(?<id>[0-9]+)").id)
      | unique
      | .[]' 2>/dev/null || echo '')"
    RERUN_ANY=false
    if [ -n "$FAILED_RUN_IDS" ]; then
      while IFS= read -r run_id; do
        [ -z "$run_id" ] && continue
        log "  rerunning failed required check, run $run_id"
        RERUN_ANY=true
        if [ "$DRY_RUN" = false ]; then
          gh run rerun "$run_id" -R "$NWO" --failed >/dev/null 2>&1 || true
        fi
      done <<< "$FAILED_RUN_IDS"
    fi
    if [ "$RERUN_ANY" = true ]; then
      RERUN_HEAD="$HEAD_OID"
    fi
  fi

  # Re-check required-check status for notification purposes (post rerun-gate:
  # if we already retried this head and it's still red, that's a "needs you").
  if [ "$CHECKS_READABLE" = true ]; then
    STILL_FAILING="$(echo "$DETAIL" | jq -r --argjson required "$REQUIRED_CONTEXTS" '
      [.statusCheckRollup[]? | select(.__typename=="CheckRun") | select(.conclusion=="FAILURE") | select(.name as $n | $required | index($n))]
      | length > 0')"
    ALL_REQUIRED_GREEN="$(echo "$DETAIL" | jq -r --argjson required "$REQUIRED_CONTEXTS" '
      ($required | length) > 0 and
      ([$required[] as $r | (.statusCheckRollup[]? | select(.name==$r) | .conclusion=="SUCCESS")] | all)')"
  else
    STILL_FAILING=false
    ALL_REQUIRED_GREEN=false
  fi

  if [ "$STILL_FAILING" = "true" ] && [ "$RERUN_HEAD" = "$HEAD_OID" ]; then
    REASONS+=("required check still failing after retry")
  fi

  if [ "$MERGE_STATE" = "CONFLICTING" ]; then
    REASONS+=("merge conflict")
  fi
  if [ "$REVIEW_DECISION" = "CHANGES_REQUESTED" ]; then
    REASONS+=("changes requested")
  fi
  if [ "$NEW_COMMENT" = "true" ]; then
    REASONS+=("new review comment")
  fi
  if [ "$IS_DRAFT" = "false" ] && [ "$ALL_REQUIRED_GREEN" = "true" ] && \
     { [ "$REVIEW_DECISION" = "APPROVED" ] || [ -z "$REVIEW_DECISION" ]; } && \
     [ "$MERGE_STATE" = "CLEAN" ]; then
    REASONS+=("ready to merge")
  fi

  SIGNATURE="$(printf '%s\n' "${REASONS[@]:-}" | sort | tr '\n' '|')"

  if [ "${#REASONS[@]}" -gt 0 ] && [ "$SIGNATURE" != "$NOTIFIED_SIG" ]; then
    REASON_TEXT="$(IFS=', '; echo "${REASONS[*]}")"
    ATTENTION_LINES+=("${NWO}#${NUMBER}: ${REASON_TEXT} — ${URL}")
    notify "${NWO}#${NUMBER}" "$REASON_TEXT" "$URL"
    NOTIFIED_SIG="$SIGNATURE"
  elif [ "${#REASONS[@]}" -eq 0 ]; then
    NOTIFIED_SIG=""
  fi

  NEW_PR_STATE="$(jq -c -n \
    --arg rerun_head "$RERUN_HEAD" \
    --arg update_head "$UPDATE_HEAD" \
    --arg last_activity "$EFFECTIVE_LAST_ACTIVITY" \
    --arg notified_sig "$NOTIFIED_SIG" \
    '{rerun_head: $rerun_head, update_head: $update_head, last_activity: $last_activity, notified_sig: $notified_sig}')"

  if [ "$DRY_RUN" = false ]; then
    set_pr_state "$URL" "$NEW_PR_STATE"
  fi

done < <(echo "$ALL_PRS_JSON" | jq -c '.[]')

# ---------------------------------------------------------------------------
# Persist state (still holding the lock) and report.
# ---------------------------------------------------------------------------
if [ "$DRY_RUN" = false ]; then
  TMP_FILE="$(mktemp "${STATE_DIR}/.state.XXXXXX")"
  echo "$NEW_STATE_JSON" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATE_FILE"
fi

# Nothing printed here on a no-op run: an agent relaying stdout has nothing
# to relay, and a launchd log stays quiet too.
if [ "${#ATTENTION_LINES[@]}" -gt 0 ]; then
  printf '%s\n' "${ATTENTION_LINES[@]}"
fi
