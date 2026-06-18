param(
    [string]$Repo = "RealDevRay/workhubz",
    [string]$Base = "main",
    [string]$Head = "",
    [string]$Title = "",
    [string]$Body = ""
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) is not installed or not in PATH."
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is not installed or not in PATH."
}

if ([string]::IsNullOrWhiteSpace($Head)) {
    $Head = (git branch --show-current).Trim()
}

if ([string]::IsNullOrWhiteSpace($Head)) {
    throw "Could not determine current branch."
}

if ($Head -eq $Base) {
    throw "Head branch cannot be '$Base'. Checkout your feature branch first."
}

$null = gh auth status

if ([string]::IsNullOrWhiteSpace($Title)) {
    $Title = "Merge $Head into $Base"
}

if ([string]::IsNullOrWhiteSpace($Body)) {
    $Body = @"
Automated PR created by scripts/auto-merge.ps1.

- Base: $Base
- Head: $Head

This PR is configured for auto-merge (squash) once required checks pass.
"@
}

Write-Host "Checking for existing open PR from '$Head' to '$Base'..."
$existingRaw = gh pr list -R $Repo --state open --head $Head --base $Base --json number,url,title -L 1
$existing = $existingRaw | ConvertFrom-Json

$prNumber = $null
$prUrl = $null

if ($existing -and $existing.Count -gt 0) {
    $prNumber = $existing[0].number
    $prUrl = $existing[0].url
    Write-Host "Using existing PR #$prNumber -> $prUrl"
}
else {
    Write-Host "Creating PR..."
    $createdUrl = gh pr create -R $Repo --base $Base --head $Head --title $Title --body $Body
    $prUrl = $createdUrl.Trim()

    $created = gh pr view $prUrl -R $Repo --json number,url,title | ConvertFrom-Json
    $prNumber = $created.number
    Write-Host "Created PR #$prNumber -> $prUrl"
}

Write-Host "Enabling auto-merge (squash + delete branch)..."
gh pr merge $prNumber -R $Repo --auto --squash --delete-branch

Write-Host "Done. PR #$prNumber is set to auto-merge after required checks pass."
Write-Host "Monitor checks with: gh pr checks $prNumber -R $Repo --watch"
