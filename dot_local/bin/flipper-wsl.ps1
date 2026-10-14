# Thin wrapper kept for convenience: flipper-wsl.ps1 [-Detach]
& "$PSScriptRoot\usb-wsl.ps1" -Device flipper @args
exit $LASTEXITCODE
