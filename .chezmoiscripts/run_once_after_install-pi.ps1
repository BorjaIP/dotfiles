# Installs the Pi coding agent (https://github.com/earendil-works/pi) via npm.
# Windows only (see .chezmoiignore). Idempotent: safe to run again.

$Package    = "@earendil-works/pi-coding-agent"
$MinNode    = [version]"22.19.0"

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
Write-Msg "Pi is ready. Run 'pi' in a project folder, then /login or set ANTHROPIC_API_KEY."
