---
description: Run this request as an orchestration - decompose, fan out parallel subagents, verify
agent: orchestrator
---

Operate as the orchestrator for this request.

$ARGUMENTS

Rules:

- Enumerate the full work surface before dispatching; expand every referenced audit, plan, checklist, and file list.
- Launch all independent slices as parallel `task` calls in one message (`background: true` for work not integrated immediately).
- Every brief is self-contained and follows the brief contract in AGENTS.md; state sibling scopes when agents run concurrently.
- Verify each phase green before advancing; fix gaps with corrective subagents, never silently.
- Do not stop at a phase boundary. Stop only when everything requested is done or a concrete blocker needs me.
