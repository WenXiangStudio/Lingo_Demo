param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Args
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$AgentMem = Join-Path $Root "agent-mem.ps1"

if (-not (Test-Path -LiteralPath $AgentMem)) {
  throw "agent-mem wrapper not found: $AgentMem"
}

& $AgentMem @Args
exit $LASTEXITCODE
