param(
  [Parameter(Position = 0)]
  [ValidateSet("new", "use", "off", "status", "handoff", "clear-handoff", "remember")]
  [string]$Command = "status",

  [Parameter(Position = 1)]
  [string]$Task
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$AgentMem = Join-Path $Root "agent-mem.ps1"

if (-not (Test-Path -LiteralPath $AgentMem)) {
  throw "agent-mem wrapper not found: $AgentMem"
}

$agentMemArgs = @()
switch ($Command) {
  "new" {
    if (-not $Task) { throw "Usage: .\agent-task.ps1 new <task-name>" }
    $agentMemArgs = @("new", $Task)
  }
  "use" {
    if (-not $Task) { throw "Usage: .\agent-task.ps1 use <task-name>" }
    $agentMemArgs = @("use", $Task)
  }
  "remember" {
    if (-not $Task) { throw "Usage: .\agent-task.ps1 remember `"durable project fact`"" }
    $agentMemArgs = @("remember", $Task)
  }
  default {
    $agentMemArgs = @($Command)
  }
}

& $AgentMem @agentMemArgs
exit $LASTEXITCODE
