# Anbeeld's Global AGENTS.md / CLAUDE.md

A global instruction file for coding agents that fixes what they most commonly get wrong: jumping to code without evidence, expanding scope unchecked, or shipping changes that haven't been validated.

Every instruction came from the same pipeline: observe what agents get wrong, compare it with public examples and [recommendations from industry leaders](https://github.com/Anbeeld/AGENTS.md/commit/f796d26c30402dc0aab12cb02e9e448504047d98), test my own solution when needed, then add or tighten a rule.

Battle-tested in daily use, tuned across multiple agents and models. Use the full set, borrow what you need, or build something different from it.

[![Support my work!](https://anbeeld.com/images/support.jpg)](https://anbeeld.com/support)

## What I use it with

The rules work with any agent that reads AGENTS.md or CLAUDE.md, because every coding agent benefits from explicit priorities, evidence-first execution, small scoped changes, and validated completions. I use Codex, Claude, Gemini, and a number of open weight models through OpenCode, and they all work well with these rules.

They're especially useful with models like GLM, Kimi, MiniMax that tend to work sequentially, avoid parallelization, and skip evidence-gathering steps that a frontier model might do on its own. The explicitness compensates for tooling instincts that aren't always built in. Better parallelization can lead to faster execution and deeper analysis from independent tracks exploring different parts of the problem.

Nothing in the file is harness-specific or model-specific. Some rules may be redundant with certain model/harness combinations, but they shouldn't create outright conflicts.

## What it does

- No wrong-path work: asks before guessing on ambiguous tasks, investigates proportionally to risk, and doesn't improvise when goals conflict.
- Hard boundaries: no fabrication, no gamed verification, no exposed secrets, no destructive commands without explicit confirmation.
- Structured execution order: explore, gather evidence, scan skills, implement, verify. Independent work runs in parallel when it helps, either through parallel tool calls or a batch of two or more subagents.
- Keeps changes small. No scope creep, no unprompted refactors, no new dependencies without checking what's already available.
- Protects existing code: tests match the risk level, behavior isn't silently changed, errors aren't swallowed. If verification fails, the agent makes one targeted fix when the cause is clear; otherwise it stops and reports.
- Validates before finishing: the agent confirms the change solves the problem, validation ran, no side effects or secrets slipped in, and the format is correct.
- Ops work in a fixed order: environment, services, configs, logs, then fix. Config validated before reload, service names from project instructions, not guesses.
- Short answers by default. No filler, no sycophancy, no restated requirements. For reviews and debugging: findings with references, then conclusion, then approach.
- Local project instructions override this file when they conflict.

## How to use it

One file, no dependencies. Copy AGENTS.md to your agent's config directory and you're done.

Personally I keep one canonical version of this file and use the sync scripts to copy it to each agent's expected config location, whether that agent calls it AGENTS.md or CLAUDE.md.

Other options: symlinks, manual copies, or for Claude Code, writing `@AGENTS.md` inside your `CLAUDE.md` to import it directly (no script needed).

```bash
./scripts/sync.sh          # macOS / Linux
./scripts/sync.ps1         # Windows PowerShell
```

Both support `--dry-run` / `-DryRun` and `--help` / `-Help`, and you can override the default target paths with flags. The default paths are whatever the agent tools themselves expect: `~/.config/opencode/AGENTS.md`, `~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md` on macOS and Linux, with the script-detected Windows equivalents.

## See also

- [Anbeeld's WRITING.md — LLM Writing Rules](https://github.com/Anbeeld/WRITING.md)

[![Support my work!](https://anbeeld.com/images/support.jpg)](https://anbeeld.com/support)