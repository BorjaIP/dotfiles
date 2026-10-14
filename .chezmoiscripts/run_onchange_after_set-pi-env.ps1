# Windows only (see .chezmoiignore). Idempotent.

$ErrorActionPreference = "Stop"

$configDir = Join-Path $HOME ".config\pi"
$stateDir  = Join-Path $HOME ".local\state\pi"
$legacyDir = Join-Path $HOME ".pi\agent"

function Write-Msg  { param([string]$Text) Write-Host " $Text" -ForegroundColor Green }
function Write-Info { param([string]$Text) Write-Host " -> $Text" -ForegroundColor Cyan }

function Set-UserEnvVar {
    param([string]$Name, [string]$Value)

    if ([Environment]::GetEnvironmentVariable($Name, "User") -eq $Value) {
        Write-Info "$Name already set"
    }
    else {
        # setx persists to HKCU\Environment and broadcasts WM_SETTINGCHANGE.
        & setx $Name $Value *> $null
        if ($LASTEXITCODE -ne 0) {
            Write-Host " -> Failed to set $Name" -ForegroundColor Red
            exit 1
        }
        Write-Info "$Name = $Value"
    }
    Set-Item -Path "Env:$Name" -Value $Value
}

function Copy-IfMissing {
    param([string]$Source, [string]$Destination)

    if ((Test-Path $Source) -and -not (Test-Path $Destination)) {
        New-Item -ItemType Directory -Force -Path (Split-Path $Destination) | Out-Null
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        Write-Info "Migrated $(Split-Path $Source -Leaf)"
    }
}

Write-Msg "Pointing Pi at the chezmoi-managed config"
Set-UserEnvVar "PI_CODING_AGENT_DIR" $configDir
Set-UserEnvVar "PI_CODING_AGENT_SESSION_DIR" $stateDir

# Carry over runtime data from Pi's old default location (%USERPROFILE%\.pi\agent).
if (Test-Path $legacyDir) {
    foreach ($item in @("auth.json", "models-store.json", "baseline.json")) {
        Copy-IfMissing (Join-Path $legacyDir $item) (Join-Path $configDir $item)
    }
    Copy-IfMissing (Join-Path $legacyDir "bin") (Join-Path $configDir "bin")

    $legacySessions = Join-Path $legacyDir "sessions"
    if (Test-Path $legacySessions) {
        New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
        $copied = 0
        Get-ChildItem -Path $legacySessions -Recurse -Filter *.jsonl -File | ForEach-Object {
            $target = Join-Path $stateDir $_.Name
            if (-not (Test-Path $target)) {
                Copy-Item -Path $_.FullName -Destination $target
                $copied++
            }
        }
        if ($copied -gt 0) { Write-Info "Migrated $copied session(s)" }
    }
}

Write-Msg "Pi will use $configDir on the next launch"
