<#
.SYNOPSIS
    Detects a USB device on Windows and forwards it to WSL with usbipd.

.EXAMPLE
    usb-wsl.ps1 -Device flipper          # preset
    usb-wsl.ps1 -Device esp32            # any common ESP32 USB-serial chip
    usb-wsl.ps1 -Device 10c4:ea60        # explicit VID:PID
    usb-wsl.ps1 -Device flipper -Detach  # give it back to Windows
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Device,
    [switch]$Detach,
    [string]$Distro = ""
)

$ErrorActionPreference = "Continue"

# Presets: name -> list of VID:PID
$presets = @{
    flipper = @("0483:5740")
    esp32   = @(
        "10c4:ea60",  # Silicon Labs CP210x
        "1a86:7523",  # WCH CH340
        "1a86:55d4",  # WCH CH9102
        "303a:1001",  # Espressif native USB (S2/S3/C3)
        "303a:0002",  # Espressif S2 download mode
        "0403:6001",  # FTDI FT232
        "0403:6010"   # FTDI FT2232
    )
}

$targets = if ($presets.ContainsKey($Device.ToLower())) { $presets[$Device.ToLower()] }
           elseif ($Device -match '^[0-9a-fA-F]{4}:[0-9a-fA-F]{4}$') { @($Device.ToLower()) }
           else { Write-Host " -> Unknown device '$Device'. Use a preset ($($presets.Keys -join ', ')) or VID:PID." -ForegroundColor Red; exit 1 }

$usbipd = (Get-Command usbipd -ErrorAction SilentlyContinue).Source
if (-not $usbipd) { $usbipd = "C:\Program Files\usbipd-win\usbipd.exe" }
if (-not (Test-Path $usbipd)) {
    Write-Host " -> usbipd not found. Install it: winget install --id dorssel.usbipd-win" -ForegroundColor Red
    exit 1
}

function Get-Target {
    (& $usbipd state | ConvertFrom-Json).Devices |
        Where-Object {
            $_.BusId -and ($_.InstanceId -match 'VID_([0-9A-F]{4})&PID_([0-9A-F]{4})') -and
            ($targets -contains ("$($Matches[1]):$($Matches[2])").ToLower())
        } | Select-Object -First 1
}

$dev = Get-Target
if (-not $dev) {
    Write-Host " -> No '$Device' device found. Plug it in and retry." -ForegroundColor Red
    exit 1
}

$busId   = $dev.BusId
$isBound = [bool]$dev.PersistedGuid
$null = $dev.InstanceId -match 'VID_([0-9A-F]{4})&PID_([0-9A-F]{4})'
$vid = $Matches[1].ToLower(); $pid_ = $Matches[2].ToLower()
Write-Host " -> $($dev.Description) [$vid`:$pid_] at BUSID $busId" -ForegroundColor Cyan

$wslBase = @()
if ($Distro) { $wslBase = @("-d", $Distro) }

# usbipd keeps reporting "attached" after WSL restarts, so ask WSL itself.
function Test-InWsl {
    # no embedded quotes: wsl.exe would strip them
    $cmd = 'for d in /sys/bus/usb/devices/*; do grep -qx ' + $vid + ' $d/idVendor 2>/dev/null && grep -qx ' + $pid_ + ' $d/idProduct 2>/dev/null && exit 0; done; exit 1'
    & wsl.exe @wslBase -e sh -c $cmd 2>$null
    return ($LASTEXITCODE -eq 0)
}

function Get-WslTty {
    (& wsl.exe @wslBase -e sh -c 'ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null' 2>$null) -join ' '
}

if ($Detach) {
    & $usbipd detach --busid $busId *>$null
    Write-Host " -> Detached. Windows owns the device again." -ForegroundColor Green
    exit 0
}

if (Test-InWsl) {
    Write-Host " -> Already available in WSL. Serial ports: $(Get-WslTty)" -ForegroundColor Green
    exit 0
}

if (-not $isBound) {
    # bind is persistent and needs admin: only the first time
    Write-Host " -> Sharing device (needs admin, one time only)..." -ForegroundColor Yellow
    Start-Process $usbipd -ArgumentList "bind", "--busid", $busId -Verb RunAs -Wait
}

# Clear stale state (e.g. after wsl --shutdown), then attach. The device can
# re-enumerate for a moment after a detach, so re-detect it and retry.
& $usbipd detach --busid $busId *>$null
$attached = $false
for ($i = 0; $i -lt 6 -and -not $attached; $i++) {
    $d = Get-Target
    if ($d) {
        $wslArgs = @("attach", "--wsl")
        if ($Distro) { $wslArgs += $Distro }
        & $usbipd @wslArgs --busid $d.BusId
        $attached = ($LASTEXITCODE -eq 0)
    }
    if (-not $attached) { Start-Sleep -Seconds 1 }
}
if (-not $attached) {
    Write-Host " -> Could not attach the device to WSL." -ForegroundColor Red
    exit 1
}

# The device node shows up a moment after attach.
for ($i = 0; $i -lt 10; $i++) {
    if (Test-InWsl) {
        $tty = Get-WslTty
        if ($tty) { Write-Host " -> Attached. Serial ports in WSL: $tty" -ForegroundColor Green }
        else      { Write-Host " -> Attached, but no /dev/ttyACM*|ttyUSB* yet (driver missing in WSL kernel?)." -ForegroundColor Yellow }
        exit 0
    }
    Start-Sleep -Milliseconds 500
}
Write-Host " -> Attached, but the device did not appear in WSL." -ForegroundColor Red
exit 1
