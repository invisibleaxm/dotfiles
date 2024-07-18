#Requires -Version 7
# $global:profile_initialized = $false

<<<<<<< HEAD
=======
# function prompt {
# function Initialize-Profile {

###############################################################################################
# Utilities
>>>>>>> f0174c3e6650ee9248031fac3b07a1fc6c432628
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function unlock_bw_if_locked() {
<<<<<<< HEAD
  if ($null -eq $env:BW_SESSION) {
    Write-Output 'bw locked - unlocking into a new session'
    bw login 'alex.campos@gmail.com' --raw
=======
  if ($env:BW_SESSION) {
    Write-Output 'bw locked - unlocking into a new session'
>>>>>>> f0174c3e6650ee9248031fac3b07a1fc6c432628
    $env:BW_SESSION="$(bw unlock --raw)"
  }
}

function load_azdevops() {
  unlock_bw_if_locked
<<<<<<< HEAD
  $devops_token="$(bw get notes 'AzureDevOps-EnsonoPAT')"
=======
  $devops_patid='108a1618-e6cc-43f9-957c-af3300002e66'
  $devops_token
  $devops_token="$(bw get notes $devops_patid)"
>>>>>>> f0174c3e6650ee9248031fac3b07a1fc6c432628
  $env:SYSTEM_ACCESSTOKEN="$devops_token"
  $env:PERSONAL_ACCESS_TOKEN="$devops_token"
}

function auto {
  Import-Module -Name "DockerCompletion" -ErrorAction Ignore -WarningAction Ignore
  Import-Module -Name "Az.Tools.Predictor" -ErrorAction Ignore -WarningAction Ignore
<<<<<<< HEAD
  $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm0"
=======
  $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
>>>>>>> f0174c3e6650ee9248031fac3b07a1fc6c432628
  if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
  }
}

function wezterm_sessionizer() {
<<<<<<< HEAD
      (fd . $HOME/dev/personal $HOME/dev/work --min-depth 0 --max-depth 1 --type directory | Resolve-Path).path | Out-File $HOME/.projects
  Write-Output "$env:LOCALAPPDATA/nvim" | Out-File $HOME/.projects -Append
  Write-Output "Successfully loaded projects on $HOME/.projects"
}
=======
      (fd . $HOME/dev/personal $HOME/dev/work --min-depth 1 --max-depth 1 --type directory | Resolve-Path).path | Out-File $HOME/.projects
  Write-Output "$env:LOCALAPPDATA/nvim" | Out-File $HOME/.projects -Append
  Write-Output "Successfully loaded projects on $HOME/.projects"
}




>>>>>>> f0174c3e6650ee9248031fac3b07a1fc6c432628
function Run-Step([string] $Description, [ScriptBlock]$script) {
  Write-Host -NoNewline "Loading " $Description.PadRight(20)
  & $script
  Write-Host "`u{2705}" # checkmark emoji
}

[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
Write-Host "Loading PowerShell $($PSVersionTable.PSVersion)..." -ForegroundColor 3
# Write-Host

Run-Step "PSReadline" {
  Import-Module PSReadLine
  Set-PSReadLineOption -Colors @{ Selection = "`e[92;7m"; InLinePrediction = "`e[2m" } -PredictionSource HistoryAndPlugin
  # Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
  Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
  Set-PSReadLineOption -EditMode vi # alternative are windows Vi and Emacs
  Set-PSReadLineKeyHandler -Chord Shift+Tab -Function MenuComplete
  Set-PSReadLineKeyHandler -Chord Ctrl+b -Function BackwardWord
  Set-PSReadLineKeyHandler -Chord Ctrl+w -Function ForwardWord
  Set-PSReadLineKeyHandler -Chord F2 -Function SwitchPredictionView
  Set-PSReadLineKeyHandler -Chord Ctrl+Shift+c -Function Copy
  Set-PSReadLineKeyHandler -Chord Ctrl+Shift+v -Function Paste

  # ## Helper functions
  # Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
  #   param($wordToComplete, $commandAst, $cursorPosition)
  #   [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
  #   $Local:word = $wordToComplete.Replace('"', '""')
  #   $Local:ast = $commandAst.ToString().Replace('"', '""')
  #   winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
  #     [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  #   }
  # }

  # PowerShell parameter completion shim for the dotnet CLI
  # Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
  #   param($commandName, $wordToComplete, $cursorPosition)
  #   dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
  #     [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  #   }
  # }
  #

  Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('wezterm_sessionizer')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
  }

  Set-PSReadLineKeyHandler -Chord 'Ctrl+l' -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('load_azdevops')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
  }


  # Stolen and modified from https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1
  # F1 for help on the command line - naturally
  # Set-PSReadLineKeyHandler -Key F1 `
  #   -BriefDescription CommandHelp `
  #   -LongDescription 'Open the help window for the current command' `
  #   -ScriptBlock {
  #   param($key, $arg)
  #
  #   $ast = $null
  #   $tokens = $null
  #   $errors = $null
  #   $cursor = $null
  #   [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)
  #
  #   $commandAst = $ast.FindAll( {
  #       $node = $args[0]
  #       $node -is [CommandAst] -and
  #       $node.Extent.StartOffset -le $cursor -and
  #       $node.Extent.EndOffset -ge $cursor
  #     }, $true) | Select-Object -Last 1
  #
  #   if ($commandAst -ne $null) {
  #     $commandName = $commandAst.GetCommandName()
  #     if ($commandName -ne $null) {
  #       $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
  #       if ($command -is [Management.Automation.AliasInfo]) {
  #         $commandName = $command.ResolvedCommandName
  #       }
  #
  #       if ($commandName -ne $null) {
  #         #First try online
  #         try {
  #           Get-Help $commandName -Online -ErrorAction Stop
  #         } catch [InvalidOperationException] {
  #           if ($PSItem -notmatch 'The online version of this Help topic cannot be displayed') {
  #             throw
  #           }
  #           Get-Help $CommandName -ShowWindow
  #         }
  #       }
  #     }
  #   }
  # }

}

Run-Step "Terminal-Icons" {
  Import-Module -Name "Terminal-Icons"
}
#
Run-Step "PsFzf" {
  Import-Module -Name "PSFzf"
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# Run-Step "z" {
#   Import-Module -Name "z"
# }

Run-step "zoxide" {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
# posh-git
# Run-Step "Posh-Git" {
#   Import-Module posh-git
#   $env:POSH_GIT_ENABLED = $true
# }
#
Run-Step "Environment" {
  $env:environment = "dev"
  $env:EDITOR = 'nvim'
  $env:TERM   = 'xterm-256color'
  $env:SHELL  = $(Get-Command pwsh).source

  # Alias
  Set-Alias vim nvim
  Set-Alias cz chezmoi
  Set-Alias ll ls
<<<<<<< HEAD
  Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
=======
  # Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'

>>>>>>> f0174c3e6650ee9248031fac3b07a1fc6c432628
  # Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
  #$(/opt/homebrew/bin/brew shellenv) | Invoke-Expression
  # try {
  #   Invoke-Expression (&starship init powershell)
  # } catch {
  #   & ([ScriptBlock]::Create((oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\powerlevel10k_lean.omp.json" --print) -join "`n"))
  # }
  # Invoke-Expression (& { (zoxide init powershell | Out-String) })
  # }
  #   if ($global:profile_initialized -ne $true) {
  #     $global:profile_initialized = $true
  #     Initialize-Profile
  #   }
  # }
<<<<<<< HEAD
  ###############################################################################################
  # Utilities
=======
>>>>>>> f0174c3e6650ee9248031fac3b07a1fc6c432628

}

Run-Step "Starship" {
  Invoke-Expression (&starship init powershell)
}
#   }
#   if ($global:profile_initialized -ne $true) {
#     $global:profile_initialized = $true
#     Initialize-Profile
#   }
# }
# setup PSReadLine
# set PowerShell to UTF-8
# Env
