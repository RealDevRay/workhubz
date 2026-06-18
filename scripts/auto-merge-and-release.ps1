param(
    [string]$Repo = "RealDevRay/workhubz",
    [string]$Base = "main",
    [string]$Head = "",
    [string]$TagPrefix = "v",
    [bool]$Prerelease = $true,
    [int]$PollSeconds = 20,
    [int]$TimeoutMinutes = 60,
    [switch]$WatchRelease
)

$ErrorActionPreference = "Stop"

function Require-Command([string]$name) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "Required command '$name' is not installed or not in PATH."
    }
}

function Get-NextTag([string]$repo, [string]$tagPrefix) {
    $pattern = "refs/tags/{0}(\d+)\.(\d+)\.(\d+)$" -f [regex]::Escape($tagPrefix)
    $refs = git ls-remote --tags --refs "https://github.com/$repo.git" "$tagPrefix*"

    if ([string]::IsNullOrWhiteSpace($refs)) {
        return "${tagPrefix}0.1.0"
    }

    $versions = @()
    foreach ($line in ($refs -split "`n")) {
        if ($line -match $pattern) {
            $versions += [pscustomobject]@{
                Major = [int]$Matches[1]
                Minor = [int]$Matches[2]
                Patch = [int]$Matches[3]
            }
        }
    }

    if ($versions.Count -eq 0) {
        return "${tagPrefix}0.1.0"
    }

    $latest = $versions | Sort-Object Major, Minor, Patch -Descending | Select-Object -First 1
    return "{0}{1}.{2}.{3}" -f $tagPrefix, $latest.Major, $latest.Minor, ($latest.Patch + 1)
}

Require-Command "gh"
Require-Command "git"

$null = gh auth status

if ([string]::IsNullOrWhiteSpace($Head)) {
    $Head = (git branch --show-current).Trim()
}

if ([string]::IsNullOrWhiteSpace($Head)) {
    throw "Could not determine current branch."
}

if ($Head -eq $Base) {
    throw "Head branch cannot be '$Base'. Checkout your feature branch first."
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$autoMergeScript = Join-Path $scriptDir "auto-merge.ps1"
if (-not (Test-Path $autoMergeScript)) {
    throw "Missing script: $autoMergeScript"
}

Write-Host "Starting automated merge for '$Head' -> '$Base'..."
& $autoMergeScript -Repo $Repo -Base $Base -Head $Head

Write-Host "Locating PR for '$Head' -> '$Base'..."
$prOpen = gh pr list -R $Repo --state open --head $Head --base $Base --json number,url,title -L 1 | ConvertFrom-Json
$prMerged = gh pr list -R $Repo --state merged --head $Head --base $Base --json number,url,title,mergedAt -L 1 | ConvertFrom-Json

$prNumber = $null
$prUrl = $null
$mergedAt = $null

if ($prMerged -and $prMerged.Count -gt 0) {
    $prNumber = $prMerged[0].number
    $prUrl = $prMerged[0].url
    $mergedAt = $prMerged[0].mergedAt
}
elseif ($prOpen -and $prOpen.Count -gt 0) {
    $prNumber = $prOpen[0].number
    $prUrl = $prOpen[0].url
}
else {
    throw "Could not find PR for head '$Head' and base '$Base'."
}

if (-not $mergedAt) {
    Write-Host "Waiting for PR #$prNumber to merge (timeout: $TimeoutMinutes min)..."
    $deadline = (Get-Date).AddMinutes($TimeoutMinutes)

    while ((Get-Date) -lt $deadline) {
        $view = gh pr view $prNumber -R $Repo --json number,url,state,mergedAt,title | ConvertFrom-Json

        if ($view.mergedAt) {
            $mergedAt = $view.mergedAt
            break
        }

        if ($view.state -eq "CLOSED") {
            throw "PR #$prNumber was closed without merge."
        }

        Start-Sleep -Seconds $PollSeconds
    }

    if (-not $mergedAt) {
        throw "Timed out waiting for PR #$prNumber to merge."
    }
}

Write-Host "PR merged: #$prNumber at $mergedAt"

$nextTag = Get-NextTag -repo $Repo -tagPrefix $TagPrefix
Write-Host "Computed next release tag: $nextTag"

$prereleaseValue = if ($Prerelease) { "true" } else { "false" }

Write-Host "Triggering Release workflow for tag '$nextTag' on '$Base'..."
$runOutput = gh workflow run Release -R $Repo -f tag=$nextTag -f target_commitish=$Base -f prerelease=$prereleaseValue
Write-Host $runOutput

$runIdMatch = [regex]::Match($runOutput, "actions/runs/(\d+)")
if ($runIdMatch.Success) {
    $runId = $runIdMatch.Groups[1].Value
    Write-Host "Release run ID: $runId"

    if ($WatchRelease) {
        Write-Host "Watching release run until completion..."
        gh run watch $runId -R $Repo --exit-status
    }
    else {
        Write-Host "Monitor with: gh run watch $runId -R $Repo --exit-status"
    }
}
else {
    Write-Host "Could not parse run ID. Check with: gh run list -R $Repo --workflow Release --limit 5"
}
