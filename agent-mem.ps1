param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Args
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script = Join-Path $Root ".agents\tools\agent_mem.py"

if (-not (Test-Path -LiteralPath $Script)) {
  throw "agent-mem core script not found: $Script"
}

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
  throw "python is required to run agent-mem."
}

& $python.Source $Script --root $Root @Args
exit $LASTEXITCODE
