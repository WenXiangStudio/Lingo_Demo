@AGENTS.md

## Claude Code Notes

- Follow the shared project instructions in `AGENTS.md`.
- Before switching windows or agents, update the active task state and durable project state when facts should carry across tasks.
- Use handoff files only when they are referenced by state or requested by the user.

<!-- BEGIN AGENT-CONTEXT -->
## Agent Task Context

- Follow the shared project instructions in `AGENTS.md`.
- Prefer `agent-mem` commands; `agent-task.ps1` remains available as a compatibility wrapper.
- Before switching windows or agents, update the active task state and durable project state when facts should carry across tasks.
- Use `.\am.ps1 enter <tool>` and `.\agent-mem.ps1 prompt <resume|handoff|new-task>` for short daily workflows.
- Use handoff files only when they are referenced by state or requested by the user.
<!-- END AGENT-CONTEXT -->
