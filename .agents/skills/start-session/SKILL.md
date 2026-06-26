---
name: start-session
description: Bootstrap a working session — verify GitHub API access via /rate_limit, then ask up to 5 scoping questions. Use at the start of a session, or when the user says "start session", "start my day", "let's begin", or similar.
---

## When to Use

* **Session kickoff** — At the start of a new working session, before any
  substantive work begins.
* **Greeting to start work** — When the user opens with "start session", "start
  my day", "let's begin", "morning", or a similar cue.

## What This Skill Does

1. Confirms GitHub API access is healthy before any API-dependent work.
2. Establishes scope for the session through a short, focused round of questions.

## Critical Rules

* **Never echo, print, or log the token value.** Rely on `gh` reading `GH_TOKEN`
  indirectly. `gh api /rate_limit` returns no secret and is safe to surface.
* **Do not start implementation** during this skill. It is for setup and scoping
  only — wait for the user's go-ahead afterward.

## Step 1 — API smoke test

* Run `gh api /rate_limit`.
* Report the core and GraphQL **remaining** quota in one concise line.
* If the call fails (missing or invalid token, network error), say so plainly and
  stop here so the user can fix authentication before work begins.

## Step 2 — Scope the session

Ask up to 5 short questions, one at a time, to optimize the session. Adapt to
context, but typically cover:

1. Primary objective for this session.
2. Repository or area of the codebase in focus.
3. Definition of done for today.
4. Constraints (deadlines, review gates, do-not-touch areas).
5. Preferred working mode (delegate-heavy vs. hands-on, draft PR vs. local only).

Stop asking once you have enough to proceed confidently. Then summarize the plan
and wait for the user's go-ahead.

> **See also:** the global `~/.copilot/copilot-instructions.md` session layer,
> which points here for session kickoff.
