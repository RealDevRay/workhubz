# Branch protection policy for `main`

This is the recommended production policy for `main`.

## Required status checks

Set these checks as **required**:

- `Secret Scan`
- `Flutter Quality`

> These come from `.github/workflows/ci.yml`.

## Recommended protection settings

Enable:

- Require a pull request before merging
  - Require approvals: **1** (or **2** for stricter teams)
  - Dismiss stale pull request approvals when new commits are pushed
  - Require review from code owners (if you add `CODEOWNERS`)
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Require conversation resolution before merging
- Restrict who can push to matching branches (optional, for teams)
- Do **not** allow force pushes
- Do **not** allow deletions

## GitHub CLI command (quick setup)

Run this from a machine with `gh` authenticated:

```bash
gh api \
  -X PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/RealDevRay/workhubz/branches/main/protection \
  -f required_status_checks.strict=true \
  -f required_status_checks.contexts[]='Secret Scan' \
  -f required_status_checks.contexts[]='Flutter Quality' \
  -f enforce_admins=true \
  -f required_pull_request_reviews.dismiss_stale_reviews=true \
  -f required_pull_request_reviews.required_approving_review_count=1 \
  -f required_conversation_resolution=true \
  -f allow_force_pushes=false \
  -f allow_deletions=false
```

If branch protection is already set, this updates it in-place.

## Notes

- `Android Build` is intentionally not a required PR check by default (it can be slower and is mainly artifact generation).
- `Release` workflow should run only on tags/manual trigger and should not gate everyday PRs.
