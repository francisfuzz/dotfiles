# Examples

## Feature with body

```bash
git commit --signoff -m "$(cat <<'EOF'
feat(auth): add session expiry validation

## What

Add middleware that checks session token expiry before processing requests.
Expired sessions now return 401 instead of proceeding with stale credentials.

## Why

Users with expired sessions were hitting downstream services that rejected
them anyway, generating confusing 500 errors. This affects end users and
the on-call team triaging false alarms.

## Notes

- Sessions older than 24h are force-expired; configurable via SESSION_TTL env var
- Existing active sessions are unaffected by this change

Relates to https://github.com/org/repo/issues/42
EOF
)"
```

## Simple commit without body

```bash
git commit --signoff -m "chore: bump dependencies to latest patch versions"
```
