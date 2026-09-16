# Working agreements

Primary agents orchestrate, subagents execute one slice. These rules apply to every session.

## Delegation (primary agents)

- Delegate research and independent work to subagents with `task`. Keep the main session for planning, integration, and verification.
- Launch independent slices as multiple `task` calls in ONE message. Use `background: true` when you will not integrate the result immediately; use foreground when the next step depends on it.
- Never poll or duplicate a running subagent's work. While it runs, work on non-overlapping files or wait.
- Prefer resuming an existing subagent with `task_id` over spawning a fresh one; it already has the context.
- Decide cross-slice contracts (interfaces, names, shapes) before dispatch and put them in every brief.

## Brief contract (what every `task` prompt must contain)

- Context: goal, constraints, shared contracts. Subagents start blank - no conversation history, no shared plan.
- Target: exact paths and symbols, plus explicit non-goals.
- Change: concrete steps and the patterns/APIs to follow.
- Acceptance: an observable result. Never project-wide commands.
- When several agents run at once: state each sibling's scope and the rule "stay inside your assigned paths".

## Concurrency rules (subagents)

- You may be one of several agents editing the repo at the same time. Stay inside your assigned paths.
- Never revert, reformat, or "fix" changes you did not make.
- NEVER run formatters, linters, whole-project builds, or full test suites - the parent runs those once after all agents land. Scoped proof of your own change (a single test file, a targeted repro) is fine.
- Need a change outside your scope? Report it instead of making it.
- Keep the repo working: no half-applied changes.

## Report contract (subagents, final message)

End with these four labeled sections, and no narrative log before them (a role prompt may define a richer format on top):

- **Status** - done or blocked, one line.
- **Files changed** - `path:line` and what changed per file, or `none`.
- **Evidence** - commands run and observed results.
- **Open questions** - decisions the parent must make, or `none`.

## Integrator duties (primary agents)

- Verify every phase yourself: project checks, targeted tests, diagnostics on changed files.
- A broken or incomplete subagent result gets a corrective subagent naming the gap, never a silent inline fix.
- Run formatters and linters once, on the union of changed files, after the phase lands.
- Never commit unrequested work; never declare a red tree done.
