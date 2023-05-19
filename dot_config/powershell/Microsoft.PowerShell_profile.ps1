Import-Module -Name "PSReadLine"
Import-Module -Name "Terminal-Icons"

oh-my-posh init pwsh --config "$(brew --prefix oh-my-posh)/themes/powerlevel10k_lean.omp.json" | Invoke-Expression
New-Alias -Name vim -Value "/opt/homebrew/bin/nvim" -ErrorAction SilentlyContinue

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows


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
    write-otput 'bw locked - unlocking into a new session'
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


function tmux_sessionizer() {
  $selected=$(fd . ~ ~/dev/personal ~/dev/work --min-depth 1 --max-depth 1 --type directory | fzf)
  $selected_name=$(basename "$selected" | tr . _)
  $arguments = "new -s $selected_name -c $selected"
  $tmux_running=Invoke-Expression "pgrep tmux"

  # If there is no tmux server running create the session
  if(!$tmux_running){
    Invoke-Expression "tmux $arguments"
    return
  }

  # There is at least a tmux server running
  if(!$env:TMUX) {
    $arguments += " -A"
    Invoke-Expression "tmux $arguments"
    return
  }
  # You're already inside tmux => [ -n "$TMUX" ] should be true
  # If session doesn't exist create it and then switch to it
  $session_name=$selected_name

  $tmux_has_sessions = Invoke-Expression "tmux has -t $session_name > /dev/null 2>&1"
  if(!  $tmux_has_sessions) {
    $argumentss+=" -d"
    Invoke-Expression "tmux $arguments"
    return
  }
  $arguments="switchc -t $session_name"
  Invoke-Expression "tmux $arguments"
}

Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -ScriptBlock { 
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('tmux_sessionizer')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Chord 'Ctrl+l' -ScriptBlock { 
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('load_azdevops')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

$(/opt/homebrew/bin/brew shellenv) | Invoke-Expression
