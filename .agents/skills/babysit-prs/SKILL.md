---
name: babysit-prs
description: This skill should be used when the user asks to "babysit my PRs", "shepherd my pull requests", "watch my open PRs", "stop me from babysitting PRs", "set up PR monitoring", or wants failed required checks retried, stale branches updated, and notifications only when a PR needs human attention. Adapted from zkoppert/babysit-prs (https://github.com/zkoppert/babysit-prs), reimplemented as bash + gh + jq only, no Python.
---

# Babysit PRs - Shepherd Your Own Pull Requests

Runs the mechanical parts of PR upkeep (retrying flaky required checks,
updating stale branches, watching for reviewer activity) on a schedule, and
notifies on macOS only when a PR actually needs a human. Same behavior as
[zkoppert/babysit-prs](https://github.com/zkoppert/babysit-prs), but the
engine is a single bash + `gh` + `jq` script instead of Python, and the
scheduler is `launchd` instead of `launchd`+Python-venv (i.e. still
`launchd` — that part didn't need to change, only the interpreter did).

## Why launchd, not `/every`

Copilot CLI's `/every` scheduler was considered and rejected for this skill.
Two independent model reviews of the plan converged on the same blocking
finding: `/every` only fires while an interactive CLI session stays open, and
restarts measured from session-reopen rather than wall clock. A laptop sleep,
lid close, terminal close, or CLI crash silently stops coverage — the exact
failure mode a background PR watcher exists to prevent. It also costs one LLM
turn per tick even when nothing changed. `launchd` survives all of that and
costs nothing when idle, so this skill manages a `launchd` LaunchAgent instead
and treats setup/status/teardown as its job, not live scheduling.

## When to Use This Skill

- User wants failed CI automatically retried and stale branches automatically
  updated on PRs they authored, without watching them
- User wants a single notification only when a PR needs their attention
  (conflict, changes requested, new review comment, still red after retry,
  ready to merge)
- User asks to set up, check on, or tear down this monitoring

## Setup Flow

1. Confirm prerequisites: `gh auth status` (needs `repo` and `workflow`
   scopes — `workflow` is required to rerun Actions runs), and that `jq` is
   on `PATH`. Both are already present in this environment; if either check
   fails, tell the user what to install/run and stop.
2. Ask the user (don't assume):
   - Polling interval in minutes (default 15).
   - Scope: all owners, or restrict to specific `--owner` value(s)?
   - Any repos to explicitly skip (`--skip-repo owner/repo`, repeatable)?
3. Install the schedule:
   ```bash
   scripts/install-schedule.sh --interval-minutes 15 --owner someorg
   ```
   This generates and loads `~/Library/LaunchAgents/cli.copilot.babysit-prs.plist`
   (label `cli.copilot.babysit-prs`), pointed at `scripts/babysit-prs.sh` with
   the given flags baked in as `ProgramArguments`. Re-running
   `install-schedule.sh` with new flags replaces the existing job.
4. Tell the user it's running and how to check on it (`scripts/status.sh`)
   or stop it (`scripts/uninstall-schedule.sh`).

## Checking Status

```bash
scripts/status.sh
```

Shows: whether the `launchd` job is loaded, the last 40 lines of
`~/Library/Logs/babysit-prs.log`, and a one-line summary per tracked PR from
the state file (last activity seen, whether it's currently in a notified
state).

## Tearing Down

```bash
scripts/uninstall-schedule.sh
```

Unloads and removes the `launchd` job. Does not touch the state file
(`~/.local/state/babysit-prs/state.json`); delete it manually if the user
wants to fully reset tracked PR history.

## Running Once by Hand (dry run)

Before installing the schedule, or to debug, run the engine directly:

```bash
scripts/babysit-prs.sh --dry-run --verbose --owner someorg
```

`--dry-run` performs no `gh pr update-branch`, no `gh run rerun`, no
`osascript` notification, and does not write the state file — it only prints
what it would do. Drop `--dry-run` to act for real; add `--no-notify` to act
but suppress notifications (useful when testing against real PRs without
wanting a notification banner).

## What the Engine Does Each Run

For each open PR the user authored or is assigned to (deduped, filtered to
PRs updated within `--active-days`, default 14):

- **Auto-actions, authored PRs only**, each gated once per head commit via
  the state file:
  - Reruns failed **required** checks (`gh run rerun --failed` on the actual
    Actions run IDs backing the failed required check names). If the
    required-check set can't be read (rulesets and branch protection both
    unreadable — usually a permissions issue), CI auto-actions are skipped
    entirely for that PR rather than guessed at.
  - Updates the branch (`gh pr update-branch`) only when the base is
    **strict** (requires up-to-date branches) and the PR is cleanly
    **behind**. Merge conflicts are never auto-resolved.
- **Notifies** (macOS `osascript`) only when a per-PR state signature
  changes: merge conflict, changes requested, a new non-bot review or
  comment (including inline review-thread replies, and including Copilot's
  reviewer comments — noisy bots like Dependabot are excluded by
  `type == "Bot"`, with Copilot's bot logins explicitly allowlisted), a
  required check still red after the one retry, a failed branch update, or a
  non-draft PR that's green and ready to merge.
- Prints **nothing to stdout** when nothing needs attention. If this script
  is ever invoked directly by the agent (rather than by `launchd`), relay its
  stdout verbatim with no added commentary — if it printed nothing, say
  nothing. Don't editorialize, don't re-run `gh` commands "to double check."

## Known Limitations (v1)

- **No `--nudge-weekdays`** ("PR idle N business days, nudge reviewers").
  The original tool has this; it was cut here because weekday-aware date math
  in portable bash/jq is a real source of off-by-one bugs, and it's the least
  critical of the notification triggers. Candidate for a future iteration.
- **No merge-queue awareness.** If a repo uses GitHub's merge queue, the
  strict/behind branch-update logic doesn't apply cleanly; this tool doesn't
  special-case it. Skip installing the schedule for merge-queue-only repos
  via `--skip-repo`.
- **macOS only.** Notifications go through `osascript`; there's no
  fallback notifier and no Linux/Windows path.
- **`gh search prs` caps at 1000 results.** The script warns to stderr if a
  query hits that cap; narrow `--active-days` or `--owner` if so.

## Flags Reference (`scripts/babysit-prs.sh`)

| Flag | Default | Meaning |
|---|---|---|
| `--owner OWNER` | all | Limit to PRs in this org/user. Repeatable. |
| `--active-days N` | 14 | Only PRs updated within N days. |
| `--allowed-repo OWNER/REPO` | all | Restrict to specific repos. Repeatable. |
| `--skip-repo OWNER/REPO` | none | Never act on a repo. Repeatable. |
| `--dry-run` | off | Preview only, no side effects. |
| `--no-notify` | off | Act on checks/branches, but send no notifications. |
| `--state-file PATH` | `~/.local/state/babysit-prs/state.json` | Per-PR de-dup state. |
| `--verbose` | off | Debug logging to stderr. |

`scripts/install-schedule.sh` additionally accepts `--interval-minutes N`
(default 15) and passes `--owner`/`--allowed-repo`/`--skip-repo`/
`--active-days`/`--no-notify` straight through to the engine.

## Boundaries

**Will:**
- Retry required checks and update stale branches, authored PRs only
- Notify only on state changes that need a human
- Run persistently via `launchd`, independent of any CLI session

**Will Not:**
- Auto-resolve merge conflicts
- Act on PRs the user is only assigned to (alert-only for those)
- Guess at required checks when the check set can't be read
- Run on Linux/Windows (macOS-only, by design, matching the original tool)
