Import-Module posh-git
Import-Module -Name C:\Users\hugh\workspace\PSColor\src\PSColor.psm1
Import-Module -Name C:\Users\hugh\Documents\PowerShell\rustup-completions.ps1
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\default.omp.json" | Invoke-Expression

New-Alias ~ $HOME
function .. { Set-Location .. }

function l  { ls -Force $args }
New-Alias ll ls
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

New-Alias g git
function gst { git status }

function u { wsl -u hugh }

$PSReadLineOptions = @{
    EditMode = "Emacs"
    BellStyle = "None"
    PredictionSource = "History"
    Color = @{
        Command =   'DarkGreen'
        Number  =   'DarkGreen'
        Member  =   'Magenta'
        InlinePrediction = 'Cyan'
    }
}
Set-PSReadLineOption @PSReadLineOptions
 
Set-PSReadlineKeyHandler -Key Tab -Function Complete # 设置 Tab 键补全
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo # 设置 Ctrl+z 为撤销
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward # 设置向上键为后向搜索历史记录
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward # 设置向下键为前向搜索历史纪录

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Fnm
fnm env --use-on-cd | Out-String | Invoke-Expression
$env:PNPM_HOME=$env:FNM_MULTISHELL_PATH

$global:OnehalflightColor = @{
    background= '#FAFAFA'
    black= '#383A42'
    blue= '#0184BC'
    brightBlack= '#4F525D'
    brightBlue= '#61AFEF'
    brightCyan= '#56B5C1'
    brightGreen= '#98C379'
    brightPurple= '#C577DD'
    brightRed= '#DF6C75'
    brightWhite= '#FFFFFF'
    brightYellow= '#E4C07A'
    cursorColor= '#4F525D'
    cyan= '#0997B3'
    foreground= '#383A42'
    green= '#50A14F'
    name= 'One Half Light'
    purple= '#A626A4'
    red= '#E45649'
    selectionBackground= '#FFFFFF'
    white= '#FAFAFA'
    yellow= '#C18301'
}
$global:PSColor = @{
    File = @{
        Default    = @{ Color = $global:OnehalflightColor.black }
        Directory  = @{ Color = $global:OnehalflightColor.blue }
        Hidden     = @{ Color = $global:OnehalflightColor.brightBlue; Pattern = '^\.' } 
        Code       = @{ Color = $global:OnehalflightColor.black; Pattern = '\.(java|c|cpp|cs|js|css|html)$' }
        Executable = @{ Color = $global:OnehalflightColor.brightGreen; Pattern = '\.(exe|bat|cmd|pl|ps1|psm1|vbs|rb|reg)$' }
        Text       = @{ Color = $global:OnehalflightColor.black; Pattern = '\.(txt|cfg|conf|ini|csv|log|config|xml|yml|md|markdown)$' }
        Compressed = @{ Color = $global:OnehalflightColor.brightRed; Pattern = '\.(zip|tar|gz|rar|jar|war)$' }
    }
    Service = @{
        Default = @{ Color = $global:OnehalflightColor.black }
        Running = @{ Color = $global:OnehalflightColor.brightGreen }
        Stopped = @{ Color = $global:OnehalflightColor.brightRed }     
    }
    Match = @{
        Default    = @{ Color = $global:OnehalflightColor.brightBlack }
        Path       = @{ Color = $global:OnehalflightColor.brightCyan }
        LineNumber = @{ Color = $global:OnehalflightColor.brightYellow }
        Line       = @{ Color = $global:OnehalflightColor.brightBlack }
    }
	NoMatch = @{
        Default    = @{ Color = $global:OnehalflightColor.black }
        Path       = @{ Color = $global:OnehalflightColor.cyan }
        LineNumber = @{ Color = $global:OnehalflightColor.yellow }
        Line       = @{ Color = $global:OnehalflightColor.black }
    }
}
Set-PSColor($global:PSColor)

function showColors {
    $colors = [enum]::GetValues([System.ConsoleColor])
    Foreach ($bgcolor in $colors){
        Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine }
        Write-Host " on $bgcolor"
    }
}
