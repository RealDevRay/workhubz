# WorkHubz Build Script
param(
    [switch]$Run,
    [switch]$Release
)

# Read .env file and convert to --dart-define flags
$envFile = Join-Path -Path $PSScriptRoot -ChildPath "..\.env" | Resolve-Path
$defines = Get-Content $envFile | Where-Object { $_ -match '^[A-Za-z_][A-Za-z0-9_]*=' } | ForEach-Object {
    "--dart-define=$_"
}
$DART_DEFINES = $defines -join ' '

if ($Release) {
    flutter build apk --release $DART_DEFINES --android-skip-build-dependency-validation
} elseif ($Run) {
    flutter run --debug $DART_DEFINES --android-skip-build-dependency-validation
} else {
    flutter build apk --debug $DART_DEFINES --android-skip-build-dependency-validation
}
