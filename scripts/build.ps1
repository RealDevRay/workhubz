# WorkHubz Build Script (secure)
param(
    [switch]$Run,
    [switch]$Release
)

$defines = @()
$envFile = Join-Path -Path $PSScriptRoot -ChildPath "..\.env"

if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        if (-not [string]::IsNullOrWhiteSpace($line) -and -not $line.StartsWith("#") -and $line -match '^[A-Za-z_][A-Za-z0-9_]*=') {
            $defines += "--dart-define=$line"
        }
    }
}

# Fallback to process environment if .env is missing or empty
if ($defines.Count -eq 0) {
    $keys = @(
        "SUPABASE_URL",
        "SUPABASE_ANON_KEY",
        "GROQ_API_KEY",
        "MPESA_CONSUMER_KEY",
        "MPESA_CONSUMER_SECRET",
        "MPESA_PASSKEY"
    )

    foreach ($key in $keys) {
        $value = [System.Environment]::GetEnvironmentVariable($key)
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            $defines += "--dart-define=$key=$value"
        }
    }
}

$required = @("SUPABASE_URL", "SUPABASE_ANON_KEY")
$missing = @()
foreach ($req in $required) {
    $found = $false
    foreach ($define in $defines) {
        if ($define.StartsWith("--dart-define=$req=")) {
            $found = $true
            break
        }
    }
    if (-not $found) {
        $missing += $req
    }
}

if ($missing.Count -gt 0) {
    Write-Error "Missing required configuration: $($missing -join ', '). Add them to .env or environment variables."
    exit 1
}

if ($Release) {
    flutter build apk --release @defines --android-skip-build-dependency-validation
} elseif ($Run) {
    flutter run --debug @defines --android-skip-build-dependency-validation
} else {
    flutter build apk --debug @defines --android-skip-build-dependency-validation
}
