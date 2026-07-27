---
name: review
description: Review a pull request or feature branch using one verification-first reviewer. Use for pre-merge correctness review when a specialist security or adversarial review is not more appropriate.
argument-hint: [pr-url | pr-number | branch]
---

# Verification-first review

Review `$ARGUMENTS`, or the current feature branch when no argument is supplied.

## Select one review path

Use this skill as the default correctness review. Do not stack it with another general review workflow.

Replace it with a more specific review when:

- The user explicitly requests an adversarial or independent second opinion.
- The change crosses authentication, authorization, secrets, untrusted input, or another exploitable security boundary.
- A repository-specific reviewer is better qualified for the affected subsystem.

Run multiple independent reviewers only when the user requests it or the change has broad, difficult-to-observe regression risk.

## Gather context

Before reviewing:

1. Identify the base branch and changed files.
2. Read the issue, pull request description, existing review threads, and stated acceptance criteria.
3. Read the diff and only the surrounding code needed to understand changed behavior.
4. Include explicit scope exclusions so descoped work is not reported as missing.

## Review

Use one read-only code-review agent by default. The reviewer owns investigation and verification of its findings.

Focus on:

- Incorrect behavior and unmet requirements
- Regressions and unintended public contract changes
- Race conditions, unsafe state transitions, and resource leaks
- Missing error handling that causes observable failure
- Security vulnerabilities when no specialist security review is required
- Tests that do not cover the changed behavior
- Comments or documentation that contradict implementation

Ignore style, naming preferences, formatting, and unrelated pre-existing problems.

## Verification standard

- Report only findings supported by the source, a call-site trace, an executable test, or another concrete artifact.
- Verify runtime claims by running the smallest relevant test or reproduction when feasible.
- Mark context-dependent claims as observations rather than blockers.
- Do not ask the coordinator to repeat verification unless a finding is disputed or fixing it would change intended behavior.

## Triage

Classify findings as:

- **Blocking**: A verified correctness, security, data-loss, or material regression issue that must be fixed before merge.
- **Follow-up**: Verified but outside the pull request's required scope.
- **Observation**: Useful context that is not sufficiently established to require a change.

Fix blocking findings by logical concern, not one commit per comment. Track follow-up work separately rather than expanding the pull request.

## Output

Lead with the verdict: `APPROVE` or `CHANGES REQUESTED`.

For each reported finding include:

- Severity and verification status
- File and line range
- Why the behavior is incorrect
- Evidence used to verify it
- The smallest safe correction

If comments should be posted, draft them in the user's voice and show them before posting. Use one actionable point per comment.

