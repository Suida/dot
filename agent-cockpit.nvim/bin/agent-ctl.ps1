# agent-ctl.ps1: native PowerShell bridge to the agent-cockpit nvim instance.
# Same command surface and wire protocol as bin/agent-ctl (bash).
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Command,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Rest
)

function Find-Sock {
  if ($env:NVIM_AGENT_SOCK) { return $env:NVIM_AGENT_SOCK }
  $dir = (Get-Location).Path
  while ($true) {
    $p = Join-Path $dir '.agent\nvim.sock'
    if (Test-Path $p -PathType Leaf) {
      # Windows: pointer file whose contents are the named-pipe address.
      # Unix pwsh: a real socket — the path itself is the address.
      $content = $null
      try { $content = (Get-Content $p -Raw -ErrorAction Stop).Trim() } catch {}
      if ($content) { return $content }
      return $p
    }
    $parent = Split-Path $dir -Parent
    if (-not $parent -or $parent -eq $dir) { break }
    $dir = $parent
  }
  if ($env:NVIM_LISTEN_ADDRESS) { return $env:NVIM_LISTEN_ADDRESS }
  return $null
}

$sock = Find-Sock
if (-not $sock) {
  Write-Error "no agent-cockpit instance found for this project (looked for .agent/nvim.sock upward from $((Get-Location).Path))"
  exit 1
}

# Per-arg base64 lines (newlines inside args survive), then one outer base64
# so the payload embeds safely in a single-line --remote-expr.
$allArgs = @($Command)
if ($Rest) { $allArgs += $Rest }
$lines = $allArgs | ForEach-Object {
  [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($_))
}
$payload = [Convert]::ToBase64String(
  [Text.Encoding]::UTF8.GetBytes(($lines -join "`n")))

# --headless on the client keeps terminal probe sequences out of stdout.
# PS 5.1 does not escape embedded quotes when passing args to native exes,
# so escape them ourselves (the C runtime on the nvim side unescapes \").
$expr = "luaeval(`"require('agent-cockpit.ctl').run(vim.base64.decode('$payload'))`")"
$expr = $expr -replace '"', '\"'
$out = & nvim --headless --server $sock --remote-expr $expr
if ($LASTEXITCODE -ne 0) {
  Write-Error "agent-ctl: failed to reach nvim at $sock"
  exit 1
}
$out
if ("$out" -match '"ok":false') { exit 1 }
