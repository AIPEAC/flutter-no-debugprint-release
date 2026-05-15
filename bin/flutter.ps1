# flutter-no-debugprint-release wrapper
# Intercepts `flutter build <target> --ndrelease` and performs a shadow build
# with all debugPrint() and print() calls stripped from the source.

$scriptDir = (Resolve-Path (Split-Path -Parent $MyInvocation.MyCommand.Path)).Path

# Find the REAL flutter binary (skip our own wrapper)
$realFlutter = $null
foreach ($cmd in @('flutter.bat', 'flutter')) {
    $found = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($found) {
        $foundDir = (Resolve-Path (Split-Path -Parent $found.Source)).Path
        if ($foundDir -ne $scriptDir) {
            $realFlutter = $found.Source
            break
        }
    }
}

if (-not $realFlutter) {
    Write-Error "Could not find real flutter binary in PATH"
    exit 1
}

# Parse arguments
$buildCmd = $false
$hasNdrelease = $false
$newArgs = @()

foreach ($arg in $args) {
    if ($arg -eq 'build') {
        $buildCmd = $true
    }
    if ($arg -eq '--ndrelease' -or $arg -eq '--no-debug-release') {
        $hasNdrelease = $true
        continue
    }
    $newArgs += $arg
}

# If not a build command with --ndrelease, pass through to real flutter
if (-not $buildCmd -or -not $hasNdrelease) {
    & $realFlutter @args
    exit $LASTEXITCODE
}

# Ensure --release is present if no build mode flag was given
$buildModeFlags = @('--debug', '--profile', '--release', '--jit-release')
$hasBuildMode = $false
foreach ($flag in $buildModeFlags) {
    if ($newArgs -contains $flag) {
        $hasBuildMode = $true
        break
    }
}
if (-not $hasBuildMode) {
    $newArgs += '--release'
}

# ============================================================================
# Shadow build for --ndrelease
# ============================================================================

$projectRoot = Get-Location
$shadowDir = Join-Path $projectRoot "build\ndrelease_shadow"
$outputDir = Join-Path $projectRoot "build\ndrelease"

# Clean up any existing shadow
if (Test-Path $shadowDir) {
    Remove-Item -Recurse -Force $shadowDir
}
New-Item -ItemType Directory -Path $shadowDir | Out-Null

# Copy project to shadow using robocopy, excluding build artifacts
$excludeDirs = @('build', '.dart_tool', '.git', 'ios/Pods', 'android/.gradle', 'android/app/build', '.idea')

# Build robocopy arguments
$robocopyArgs = @('/E', '/MT', '/R:0', '/W:0')
foreach ($dir in $excludeDirs) {
    $robocopyArgs += "/XD:$dir"
}
$robocopyArgs += '/XF:*.iml'

& robocopy $projectRoot $shadowDir @robocopyArgs | Out-Null

# Strip debugPrint and print from all .dart files in shadow/lib
$libDir = Join-Path $shadowDir "lib"
if (Test-Path $libDir) {
    Get-ChildItem -Path $libDir -Recurse -Filter "*.dart" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        # Remove standalone debugPrint(...) and print(...) lines
        $content = $content -replace '(?m)^\s*debugPrint\(.*\);\s*\r?\n', ''
        $content = $content -replace '(?m)^\s*print\(.*\);\s*\r?\n', ''
        # Clean up consecutive blank lines
        $content = $content -replace '(\r?\n){3,}', "`n`n"
        Set-Content $_.FullName $content -NoNewline
    }
}

# Run flutter build in shadow
Push-Location $shadowDir
& $realFlutter @newArgs
$buildExit = $LASTEXITCODE
Pop-Location

# Copy build outputs back
if ($buildExit -eq 0 -and (Test-Path (Join-Path $shadowDir "build"))) {
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    $srcBuild = Join-Path $shadowDir "build"
    Get-ChildItem -Path $srcBuild | ForEach-Object {
        $dest = Join-Path $outputDir $_.Name
        if (Test-Path $dest) {
            Remove-Item -Recurse -Force $dest
        }
        if ($_.PSIsContainer) {
            Copy-Item -Recurse $_.FullName $dest
        } else {
            Copy-Item $_.FullName $dest
        }
    }
}

# Clean up shadow
Remove-Item -Recurse -Force $shadowDir

exit $buildExit
