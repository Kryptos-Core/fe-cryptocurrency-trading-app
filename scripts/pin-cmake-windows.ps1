param(
    [ValidatePattern('^[0-9]+(\.[0-9]+){2}$')]
    [string]$Version,
    [ValidateSet("Session", "User", "None")]
    [string]$PathScope = "Session",
    [switch]$ForceDownload
)

$ErrorActionPreference = "Stop"

function Get-PathSegments {
    param([string]$PathValue)

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return @()
    }

    return $PathValue.Split(';', [System.StringSplitOptions]::RemoveEmptyEntries) |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
}

function Format-PathSegment {
    param([string]$Segment)

    return $Segment.Trim().TrimEnd('\\').ToLowerInvariant()
}

function PathContainsSegment {
    param(
        [string]$PathValue,
        [string]$Segment
    )

    $target = Format-PathSegment $Segment
    foreach ($item in (Get-PathSegments $PathValue)) {
        if ((Format-PathSegment $item) -eq $target) {
            return $true
        }
    }

    return $false
}

function PrependPathSegment {
    param(
        [string]$PathValue,
        [string]$Segment
    )

    if (PathContainsSegment -PathValue $PathValue -Segment $Segment) {
        return $PathValue
    }

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return $Segment
    }

    return "$Segment;$PathValue"
}

function Assert-PathInsideRoot {
    param(
        [string]$Path,
        [string]$Root,
        [string]$Label
    )

    $resolvedRoot = [System.IO.Path]::GetFullPath($Root).TrimEnd('\')
    $resolvedPath = [System.IO.Path]::GetFullPath($Path)
    $rootPrefix = $resolvedRoot + [System.IO.Path]::DirectorySeparatorChar

    $isSamePath = $resolvedPath.Equals($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)
    $isChildPath = $resolvedPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)

    if (-not $isSamePath -and -not $isChildPath) {
        throw "Refusing unsafe path for ${Label}: $resolvedPath"
    }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$versionsFile = Join-Path $repoRoot "tools\toolchain-versions.json"
if (-not (Test-Path $versionsFile)) {
    throw "Missing toolchain version file: $versionsFile"
}

$versions = Get-Content $versionsFile -Raw | ConvertFrom-Json
$pinnedVersion = if ([string]::IsNullOrWhiteSpace($Version)) {
    $versions.cmake.version
} else {
    $Version
}

if ([string]::IsNullOrWhiteSpace($pinnedVersion)) {
    throw "CMake version is empty. Check tools/toolchain-versions.json"
}

if ($pinnedVersion -notmatch '^[0-9]+(\.[0-9]+){2}$') {
    throw "Invalid CMake version format '$pinnedVersion'. Expected format like 3.31.6"
}

$osArch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToUpperInvariant()
$cmakeTarget = switch ($osArch) {
    "ARM64" { "windows-arm64" }
    "X64" { "windows-x86_64" }
    "X86" { "windows-i386" }
    default { throw "Unsupported Windows architecture: $osArch" }
}

$expectedSha = $versions.cmake.sha256."$cmakeTarget"
if ([string]::IsNullOrWhiteSpace($expectedSha)) {
    throw "Missing checksum for '$cmakeTarget' in tools/toolchain-versions.json"
}

$toolchainRoot = Join-Path $repoRoot ".toolchains"
$archiveName = "cmake-$pinnedVersion-$cmakeTarget.zip"
$archivePath = Join-Path $toolchainRoot $archiveName
$extractDir = Join-Path $toolchainRoot "cmake-$pinnedVersion-$cmakeTarget"
$cmakeExe = Join-Path $extractDir "bin\cmake.exe"
$downloadUrl = "https://github.com/Kitware/CMake/releases/download/v$pinnedVersion/$archiveName"

Assert-PathInsideRoot -Path $archivePath -Root $toolchainRoot -Label "archivePath"
Assert-PathInsideRoot -Path $extractDir -Root $toolchainRoot -Label "extractDir"
Assert-PathInsideRoot -Path $cmakeExe -Root $extractDir -Label "cmakeExe"

if ($ForceDownload -and (Test-Path $extractDir)) {
    Remove-Item -Path $extractDir -Recurse -Force
}

if ($ForceDownload -and (Test-Path $archivePath)) {
    Remove-Item -Path $archivePath -Force
}

if (-not (Test-Path $cmakeExe)) {
    New-Item -Path $toolchainRoot -ItemType Directory -Force | Out-Null

    if (-not (Test-Path $archivePath)) {
        $maxAttempts = 3
        for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
            try {
                Write-Host "Downloading CMake $pinnedVersion ($cmakeTarget), attempt $attempt/$maxAttempts" -ForegroundColor Cyan
                Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath -TimeoutSec 180
                break
            } catch {
                if (Test-Path $archivePath) {
                    Remove-Item -Path $archivePath -Force -ErrorAction SilentlyContinue
                }
                if ($attempt -eq $maxAttempts) {
                    throw
                }
                Write-Warning "Download failed, retrying..."
            }
        }
    }

    $actualSha = (Get-FileHash -Path $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualSha -ne $expectedSha.ToLowerInvariant()) {
        throw "Checksum mismatch for $archiveName. Expected $expectedSha but got $actualSha"
    }

    if (Test-Path $extractDir) {
        Remove-Item -Path $extractDir -Recurse -Force
    }

    Expand-Archive -Path $archivePath -DestinationPath $toolchainRoot -Force
}

$cmakeBin = Join-Path $extractDir "bin"

switch ($PathScope) {
    "Session" {
        $env:Path = PrependPathSegment -PathValue $env:Path -Segment $cmakeBin
    }
    "User" {
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        $updatedUserPath = PrependPathSegment -PathValue $userPath -Segment $cmakeBin
        [Environment]::SetEnvironmentVariable("Path", $updatedUserPath, "User")
    }
    "None" {
        # Keep PATH unchanged.
    }
}

$versionLine = & $cmakeExe --version | Select-Object -First 1
if ($versionLine -notmatch [Regex]::Escape($pinnedVersion)) {
    throw "Pinned CMake verification failed. Expected version $pinnedVersion but got: $versionLine"
}

Write-Host "Pinned CMake ready: $versionLine" -ForegroundColor Green
Write-Host "CMake binary: $cmakeExe" -ForegroundColor Green

if ($PathScope -eq "User") {
    Write-Host "Restart terminal/IDE so User PATH changes are loaded." -ForegroundColor Yellow
}

Write-Host "To run Flutter with this pinned CMake in current terminal:" -ForegroundColor Cyan
Write-Host "  `$env:Path = '$cmakeBin;' + `$env:Path" -ForegroundColor Gray
Write-Host "  flutter run -d windows" -ForegroundColor Gray
