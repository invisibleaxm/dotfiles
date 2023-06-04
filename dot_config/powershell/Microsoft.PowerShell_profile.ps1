Import-Module -Name "PSFzf" -ErrorAction Ignore -WarningAction Ignore
Import-Module -Name "PSReadLine" -ErrorAction Ignore
Import-Module -Name "Terminal-Icons" -ErrorAction Ignore -WarningAction Ignore
Import-Module -Name "posh-git" -ErrorAction Ignore -WarningAction Ignore

<#
if([Environment]::OSVersion -match "Win") {

} else {
  oh-my-posh init pwsh --config "$(brew --prefix oh-my-posh)/themes/powerlevel10k_lean.omp.json" | Invoke-Expression
}
#>
#see wikipedia for build numbers: https://en.wikipedia.org/wiki/List_of_Microsoft_Windows_versions
$osbuild = [Environment]::OSVersion.Version.Build

$env:environment = "dev"
#if($osbuild -lt 2200 ) {
#  $NVIM_APPNAME = "vanilla" #prevent from loading more advanced neovim for windows 10 until i nail the config.
#}
$env:EDITOR = 'nvim'
$alias:vim  = 'nvim'
$alias:cz   = 'chezmoi'
$env:TERM   = 'xterm-256color'
$env:SHELL  = $(Get-Command pwsh).source#$(which pwsh)


Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
Set-PSReadLineOption -EditMode Windows # alternative are Vi and Emacs


## Helper functions
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
  $Local:word = $wordToComplete.Replace('"', '""')
  $Local:ast = $commandAst.ToString().Replace('"', '""')
  winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
  param($commandName, $wordToComplete, $cursorPosition)
  dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}


function unlock_bw_if_locked() {
  if ($env:BW_SESSION) {
    Write-Output 'bw locked - unlocking into a new session'
    $env:BW_SESSION="$(bw unlock --raw)"
  }
}

function load_azdevops() {
  unlock_bw_if_locked
  $devops_patid='108a1618-e6cc-43f9-957c-af3300002e66'
  $devops_token
  $devops_token="$(bw get notes $devops_patid)"
  $env:SYSTEM_ACCESSTOKEN="$devops_token"
  $env:PERSONAL_ACCESS_TOKEN="$devops_token"
}

function auto {
  Import-Module -Name "DockerCompletion" -ErrorAction Ignore -WarningAction Ignore
  Import-Module -Name "Az.Tools.Predictor" -ErrorAction Ignore -WarningAction Ignore
  $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
  if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
  }

}

function wezterm_sessionizer() {
  (fd . $HOME/dev/personal $HOME/dev/work --min-depth 1 --max-depth 1 --type directory | Resolve-Path).path | Out-File $HOME/.projects
  Write-Output "$env:LOCALAPPDATA/nvim" | Out-File $HOME/.projects -Append
  Write-Output "Successfully loaded projects on $HOME/.projects"
}

Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -ScriptBlock {
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
Set-PSReadLineKeyHandler -Key F1 `
  -BriefDescription CommandHelp `
  -LongDescription 'Open the help window for the current command' `
  -ScriptBlock {
  param($key, $arg)

  $ast = $null
  $tokens = $null
  $errors = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

  $commandAst = $ast.FindAll( {
      $node = $args[0]
      $node -is [CommandAst] -and
      $node.Extent.StartOffset -le $cursor -and
      $node.Extent.EndOffset -ge $cursor
    }, $true) | Select-Object -Last 1

  if ($commandAst -ne $null) {
    $commandName = $commandAst.GetCommandName()
    if ($commandName -ne $null) {
      $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
      if ($command -is [Management.Automation.AliasInfo]) {
        $commandName = $command.ResolvedCommandName
      }

      if ($commandName -ne $null) {
        #First try online
        try {
          Get-Help $commandName -Online -ErrorAction Stop
        } catch [InvalidOperationException] {
          if ($PSItem -notmatch 'The online version of this Help topic cannot be displayed') {
            throw
          }
          Get-Help $CommandName -ShowWindow
        }
      }
    }
  }
}# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
#$(/opt/homebrew/bin/brew shellenv) | Invoke-Expression
try {
  Invoke-Expression (&starship init powershell)
} catch {
  & ([ScriptBlock]::Create((oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\powerlevel10k_lean.omp.json" --print) -join "`n"))
}
Invoke-Expression (& { (zoxide init powershell | Out-String) })
