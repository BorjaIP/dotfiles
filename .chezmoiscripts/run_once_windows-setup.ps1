#                 ___       ___  ___  ________   ________  ________  ___       __   ________
#                |\  \     |\  \|\  \|\   ___  \|\   ___ \|\   __  \|\  \     |\  \|\   ____\
#                \ \  \    \ \  \ \  \ \  \\ \  \ \  \_|\ \ \  \|\  \ \  \    \ \  \ \  \___|_
#                 \ \  \  __\ \  \ \  \ \  \\ \  \ \  \ \\ \ \  \\\  \ \  \  __\ \  \ \_____  \
#                  \ \  \|\__\_\  \ \  \ \  \\ \  \ \  \_\\ \ \  \\\  \ \  \|\__\_\  \|____|\  \
#                   \ \____________\ \__\ \__\\ \__\ \_______\ \_______\ \____________\____\_\  \
#                    \|____________|\|__|\|__| \|__|\|_______|\|_______|\|____________|\_________\
#                                                                                     \|_________|

# ------------------------------------------------------------------------------
#                            Helper functions
# ------------------------------------------------------------------------------

function Write-Msg {
    param([string]$Text)
    Write-Host " $Text" -ForegroundColor Green
}

function Write-Info {
    param([string]$Text)
    Write-Host " -> $Text" -ForegroundColor Cyan
}

function Write-Err {
    param([string]$Text)
    Write-Host " -> $Text" -ForegroundColor Red
}

function Exit-WithError {
    param([string]$Text)
    Write-Err $Text
    exit 1
}

# ------------------------------------------------------------------------------
#                            Winget functions
# ------------------------------------------------------------------------------

function Assert-Winget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Exit-WithError "winget not found. Install 'App Installer' from the Microsoft Store and try again."
    }
    Write-Info "winget is available"
}

function Install-WithWinget {
    param(
        [string]$Id,
        [string]$Name
    )

    $result = winget list --id $Id --exact 2>&1
    if ($LASTEXITCODE -eq 0 -and ($result | Select-String -Pattern $Id -Quiet)) {
        Write-Info "$Name is already installed"
        return
    }

    Write-Msg "Installing $Name"
    winget install --id $Id --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Exit-WithError "Failed to install $Name"
    }
    Write-Info "$Name installed successfully"
}

# ------------------------------------------------------------------------------
#                            Package list
# ------------------------------------------------------------------------------

$packages = @(
    # --- Developer tools ---
    @{ Id = "Git.Git";                    Name = "Git"               },
    @{ Id = "Microsoft.VisualStudioCode"; Name = "VSCode"            },
    @{ Id = "Anysphere.Cursor";           Name = "Cursor"            },
    @{ Id = "Microsoft.PowerShell";       Name = "PowerShell"        },
    @{ Id = "Microsoft.WindowsTerminal";  Name = "Windows Terminal"  },
    @{ Id = "Microsoft.PowerToys";        Name = "PowerToys"         },
    @{ Id = "twpayne.chezmoi";            Name = "chezmoi"           },

    # --- CLI tools ---
    @{ Id = "junegunn.fzf";              Name = "fzf"               },
    @{ Id = "jqlang.jq";                 Name = "jq"                },
    @{ Id = "Starship.Starship";         Name = "Starship"          },
    @{ Id = "Rclone.Rclone";             Name = "Rclone"            },
    @{ Id = "gerardog.gsudo";            Name = "gsudo"             },

    # --- Environments ---
    @{ Id = "Microsoft.WSL";             Name = "WSL"               },
    @{ Id = "Canonical.Ubuntu";          Name = "Ubuntu"            },
    @{ Id = "Python.Python.3.11";        Name = "Python 3.11"       },

    # --- Window management ---
    @{ Id = "glzr-io.glazewm";           Name = "GlazeWM"           },

    # --- Productivity ---
    @{ Id = "Obsidian.Obsidian";         Name = "Obsidian"          },
    @{ Id = "Discord.Discord";           Name = "Discord"           },
    @{ Id = "Brave.Brave";               Name = "Brave"             },
    @{ Id = "VideoLAN.VLC";              Name = "VLC"               },
    @{ Id = "7zip.7zip";                 Name = "7-Zip"             },
    @{ Id = "ShareX.ShareX";             Name = "ShareX"            },

    # --- Anthropic ---
    @{ Id = "Anthropic.ClaudeCode";      Name = "Claude Code"       },
    @{ Id = "Anthropic.Claude";          Name = "Claude"            }
)

# ------------------------------------------------------------------------------
#                              Main logic
# ------------------------------------------------------------------------------

Write-Msg "Windows basic setup starting..."

Assert-Winget

foreach ($pkg in $packages) {
    Install-WithWinget -Id $pkg.Id -Name $pkg.Name
}

Write-Msg "Basic setup completed successfully!"
