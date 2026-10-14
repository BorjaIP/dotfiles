# Installs the Pi coding agent (https://github.com/earendil-works/pi) via npm, plus the
# gentle-pi harness (npm:gentle-pi).
# Windows only (see .chezmoiignore). Idempotent: safe to run again.
# npm:gentle-pi ships no prebuilt Windows binary: its postinstall builds gentle-ai.exe from
# Go source, so Go >= 1.25.10 has to be on PATH before the package is installed.

$Package    = "@earendil-works/pi-coding-agent"
$Harness    = "npm:gentle-pi"
$MinNode    = [version]"22.19.0"
$MinGo      = [version]"1.25.10"

function Write-Msg  { param([string]$Text) Write-Host " $Text" -ForegroundColor Green }
function Write-Info { param([string]$Text) Write-Host " -> $Text" -ForegroundColor Cyan }
function Write-Err  { param([string]$Text) Write-Host " -> $Text" -ForegroundColor Red }
function Exit-WithError { param([string]$Text) Write-Err $Text; exit 1 }

# Re-read PATH so tools installed earlier in this run (winget) are visible.
function Update-SessionPath {
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path", "User")
}

function Get-NodeVersion {
    $node = Get-Command node -ErrorAction SilentlyContinue
    if (-not $node) { return $null }
    return [version](& node --version).TrimStart("v")
}

# Both stable "go version go1.27.0 windows/amd64" and devel builds "go version devel go1.28-...".
function Get-GoVersion {
    $go = Get-Command go -ErrorAction SilentlyContinue
    if (-not $go) { return $null }
    $first = & go version 2>$null | Select-Object -First 1
    $match = [regex]::Match([string]$first, '\bgo(\d+)\.(\d+)(?:\.(\d+))?')
    if (-not $match.Success) { return $null }
    $patch = if ($match.Groups[3].Success) { [int]$match.Groups[3].Value } else { 0 }
    return [version]"$($match.Groups[1].Value).$($match.Groups[2].Value).$patch"
}

# pi reads its config location from the environment. The persistent user-level values are
# written by run_onchange_after_set-pi-env.ps1, which chezmoi may run after this script, so
# default them for this session: 'pi install' below has to write to the chezmoi-managed
# config dir and not to pi's legacy %USERPROFILE%\.pi\agent default.
if (-not $env:PI_CODING_AGENT_DIR)         { $env:PI_CODING_AGENT_DIR = Join-Path $HOME ".config\pi" }
if (-not $env:PI_CODING_AGENT_SESSION_DIR) { $env:PI_CODING_AGENT_SESSION_DIR = Join-Path $HOME ".local\state\pi" }

# A postinstall that dies leaves an empty or directory-shaped 'gentle-ai.exe' behind; only a
# non-empty file proves the harness is usable, and a wildcard covers any pinned version dir.
function Test-GentleAiBinary {
    param([string]$Pattern)
    $found = @(Get-Item -Path $Pattern -ErrorAction SilentlyContinue |
               Where-Object { -not $_.PSIsContainer -and $_.Length -gt 0 })
    return $found.Count -gt 0
}

Write-Msg "Installing Pi coding agent"

# --- Node.js (Pi needs >= 22.19) ----------------------------------------------
$nodeVersion = Get-NodeVersion
if (-not $nodeVersion -or $nodeVersion -lt $MinNode) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Exit-WithError "Node.js >= $MinNode is required and winget is not available."
    }
    Write-Msg "Installing Node.js LTS"
    winget install --id OpenJS.NodeJS.LTS --exact --silent --accept-package-agreements --accept-source-agreements
    Update-SessionPath
    $nodeVersion = Get-NodeVersion
    if (-not $nodeVersion -or $nodeVersion -lt $MinNode) {
        Exit-WithError "Node.js >= $MinNode not available after install. Open a new terminal and retry."
    }
}
Write-Info "Node.js $nodeVersion"

# --- Pi -------------------------------------------------------------------------
Update-SessionPath
$installed = (& npm ls -g --depth=0 $Package 2>$null | Select-String -SimpleMatch $Package -Quiet)
if ($installed) {
    Write-Info "Pi is already installed"
} else {
    Write-Msg "npm install -g $Package"
    # --ignore-scripts is the officially documented flag for this package
    & npm install -g --ignore-scripts $Package
    if ($LASTEXITCODE -ne 0) { Exit-WithError "Failed to install $Package" }
}

# npm's global bin dir (%APPDATA%\npm) may not be on PATH in this session yet
$npmBin = (& npm config get prefix).Trim()
if ($env:Path -notlike "*$npmBin*") { $env:Path += ";$npmBin" }

$pi = Get-Command pi -ErrorAction SilentlyContinue
if (-not $pi) { Exit-WithError "Installed, but 'pi' is not on PATH. Add $npmBin to your user PATH." }
Write-Info "pi $(& pi --version 2>&1 | Select-Object -First 1)"

# --- Go (npm:gentle-pi builds its gentle-ai binary from source on Windows) -------
$goVersion = Get-GoVersion
if (-not $goVersion -or $goVersion -lt $MinGo) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Exit-WithError "Go >= $MinGo is required by $Harness and winget is not available."
    }
    Write-Msg "Installing Go (>= $MinGo) - $Harness builds its gentle-ai binary from source"
    winget install --id GoLang.Go --exact --silent --accept-package-agreements --accept-source-agreements
    Update-SessionPath
    $goVersion = Get-GoVersion
    if (-not $goVersion -or $goVersion -lt $MinGo) {
        Exit-WithError "Go >= $MinGo not available after install. Open a new terminal and retry."
    }
}
Write-Info "Go $goVersion"

# --- gentle-pi (harness: review / RDD, agents, skills) ---------------------------
# The package resolves to <agent-dir>/npm/node_modules/gentle-pi; its binary lives in the
# versioned .gentle-ai directory next to it. A missing binary means a broken postinstall.
$harnessDir = Join-Path $env:PI_CODING_AGENT_DIR "npm\node_modules\gentle-pi"
$harnessBin = Join-Path $harnessDir ".gentle-ai\v*\gentle-ai.exe"
if (Test-GentleAiBinary $harnessBin) {
    Write-Info "$Harness is already installed"
} else {
    Write-Msg "pi install $Harness"
    & pi install $Harness
    if ($LASTEXITCODE -ne 0) {
        Exit-WithError "Failed to install $Harness (its postinstall builds gentle-ai.exe with Go >= $MinGo and needs access to proxy.golang.org)."
    }
    if (-not (Test-GentleAiBinary $harnessBin)) {
        Exit-WithError "$Harness installed without a gentle-ai binary under $harnessDir\.gentle-ai. Reinstall it with Go >= $MinGo on PATH."
    }
    Write-Info "$Harness installed"
}

Write-Msg "Pi is ready. Run 'pi' in a project folder, then /login or set ANTHROPIC_API_KEY."
