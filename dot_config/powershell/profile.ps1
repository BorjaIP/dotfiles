# Alias
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias l ls
Set-Alias grep findstr
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'

# Terminal icons
Import-Module -Name Terminal-Icons

# PSReadLine
Import-Module -Name PSReadLine
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Fzf
Import-Module -Name PSReadLine
Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'

# Custom functions
function touch($file) {
    "" | Out-File $file -Encoding ASCII
}
function df {
    get-volume
}
function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}
function pkill($name) {
    ps $name -ErrorAction SilentlyContinue | kill
}
function pgrep($name) {
    ps $name
}
function itunes {
    Write-Host "Launching iTunes..." -ForegroundColor Green
    Start-Process "C:\Program Files\iTunes\iTunes.exe"

    Write-Host "Waiting for 5 seconds to ensure service is fully restarted..." -ForegroundColor Cyan
    Start-Sleep -Seconds 5

    Write-Host "Restarting Apple Mobile Device Service..." -ForegroundColor Yellow
    net stop "Apple Mobile Device Service"
    net start "Apple Mobile Device Service"
}

# Startship custom Prompt
# $ENV:STARSHIP_CONFIG = "E:\Config\Startship\startship.toml"
# $ENV:STARSHIP_DISTRO = "者"
Invoke-Expression (&starship init powershell)