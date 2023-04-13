Import-Module posh-git
Import-Module Get-ChildItemColor
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\default.omp.json" | Invoke-Expression

New-Alias ~ $HOME
function .. { Set-Location .. }

function l  { ls -Force $args }
New-Alias ll Get-ChildItemColor
New-Alias touch New-Item
New-Alias which Get-Command
function du {
    Param (
        [PSDefaultValue(Help = '.')]
        [ValidateScript({Test-Path $_})]
        [string]$Path
    )
    $len = (gci -Force -Recurse $Path | Measure-Object -Sum -Property Length).sum
    if ($len -lt 1MB) {
        echo ("{0, -6} KB" -f ($len / 1KB).ToString('F2'))
    } elseif ($len -lt 1GB) {
        echo ("{0, -6} MB" -f ($len / 1MB).ToString('F2'))
    } else {
        echo ("{0, -6} GB" -f ($len / 1GB).ToString('F2'))
    }
}

function arch {
    wsl -d archlinux -u hugh --cd /home/hugh
}

New-Alias g git
function gst { git status }

function v { nvim-qt.exe $args }
function Get-GUID { curl https://guid.it/string }

$PSReadLineOptions = @{
    EditMode         = "Emacs"
    BellStyle        = "None"
    PredictionSource = "History"
    Color            = @{
        Command          = 'DarkGreen'
        Number           = 'DarkGreen'
        Member           = 'Magenta'
        Parameter        = 'White'
        Operator         = 'White'
        InlinePrediction = 'Cyan'
        Default          = 'White'
    }
}
Set-PSReadLineOption @PSReadLineOptions
 
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete # 设置 Tab 键补全
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo # 设置 Ctrl+z 为撤销
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward # 设置向上键为后向搜索历史记录
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward # 设置向下键为前向搜索历史纪录

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Batcat
$env:BAT_THEME="GitHub"


function showColors {
    $colors = [enum]::GetValues([System.ConsoleColor])
    Foreach ($bgcolor in $colors){
        Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine }
        Write-Host " on $bgcolor"
    }
}


$env:http_proxy="http://127.0.0.1:7890"
$env:https_proxy="http://127.0.0.1:7890"
New-Alias vcpkg ~\workspace\vcpkg\vcpkg.exe

# Fnm
fnm env --use-on-cd | Out-String | Invoke-Expression
$env:PNPM_HOME=$env:FNM_MULTISHELL_PATH
$env:npm_config_registry="https://registry.npm.taobao.org"

