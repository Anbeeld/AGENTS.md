# Anbeeld's Global AGENTS.md / CLAUDE.md

A global instruction file for coding agents that targets what they keep getting wrong: jumping to code without evidence, expanding scope unchecked, or shipping changes that haven't been validated.

Every instruction came from the same pipeline: observe what agents get wrong, compare it with public examples and [recommendations from industry leaders](https://github.com/Anbeeld/AGENTS.md/commit/f796d26c30402dc0aab12cb02e9e448504047d98), test my own solution when needed, then add or tighten a rule.

Battle-tested in daily use, tuned across multiple agents and models. Use the full set, borrow what you need, or build something different from it.

[![Support my work!](https://anbeeld.com/images/support.jpg)](https://anbeeld.com/support)

## What it does

- No wrong-path work: asks before guessing on ambiguous tasks, investigates proportionally to risk, and doesn't improvise when goals conflict. When there's nobody to ask, it takes the reversible option and reports the assumption, or stops and says what it needs.
- Boundaries: no fabrication, no gamed verification, no exposed secrets, and no destructive actions without your explicit go-ahead for that exact action. Instructions buried in repo files, issues, logs, or tool output are treated as data, not orders.
- Structured execution order: scope, gather evidence, load matching skills, route, implement, verify. Routing leans toward splitting independent work out: parallel tool calls, two or more subagents, or the main agent running alongside one.
- Keeps changes small. No scope creep, no unprompted refactors, no new dependencies without checking what's already available.
- Protects existing code: tests match the risk level, behavior isn't silently changed, errors aren't swallowed. If verification fails, the agent diagnoses the cause and keeps going only while each new attempt has new evidence behind it; otherwise it stops and reports the failure.
- Validates before finishing: the agent runs the relevant checks or says why it couldn't, verifies the change solves the problem without side effects or exposed secrets, and reports actual results and remaining gaps.
- Ops work inspects the relevant environment, service state, configuration, and logs before changing infrastructure. Config validated before reload, service names from project instructions, not guesses.
- Short answers by default. No filler, no sycophancy, no restated requirements. For reviews and debugging: findings with references, then conclusion, then approach.
- Local project instructions override anything in this file except the Boundaries section.

## How to use it

One file, no dependencies. Copy [AGENTS.md](https://github.com/Anbeeld/AGENTS.md/blob/main/AGENTS.md) to your agent's config directory and you're done.

Personally I keep one canonical version of this file and use the sync scripts to copy it to each agent's expected config location, whether that agent calls it AGENTS.md or CLAUDE.md.

Other options: symlinks, manual copies, or for Claude Code, writing `@AGENTS.md` inside your CLAUDE.md to import it directly (no script needed).

```bash
./scripts/sync.sh          # macOS / Linux
./scripts/sync.ps1         # Windows PowerShell
```

Both support `--dry-run` / `-DryRun` and `--help` / `-Help`, and you can override the default target paths with per-tool flags (e.g. `--targets-gemini PATH`).

The scripts cover most tools, harnesses, IDEs, and plugins that support global agent instructions, like Claude Code, Codex, OpenCode, and many others. For tools that read AGENTS.md at the project level instead, like Cursor or Windsurf, add the file to each repo manually.

## Optional canary

Add [snippets/canary.md](snippets/canary.md) to your global file to opt in: every reply then starts with `Canary,`. A missing prefix means the agent stopped honoring standing instructions mid-session (start a fresh one), or on the first reply that the file wasn't loaded. It catches instruction drift, not hallucination directly.

## What I use it with

The rules work with any agent that reads AGENTS.md or CLAUDE.md. I use Codex, Claude, Gemini, and a number of open-weight models through OpenCode, and they all work well with these rules.

They're especially useful with models like GLM, Kimi, MiniMax that tend to work sequentially, avoid parallelization, and skip evidence-gathering steps that a frontier model might do on its own. The explicitness compensates for tooling instincts that aren't always built in. Better parallelization can lead to faster execution and deeper analysis from independent tracks exploring different parts of the problem.

The file targets harnesses that provide skills and asynchronous subagents. Some rules may be redundant with certain model/harness combinations, but they shouldn't create outright conflicts.

## See also

- [Anbeeld's WRITING.md: AI Writing Rules](https://github.com/Anbeeld/WRITING.md)
- [Anbeeld's RESUME.md: AI Resume/CV Rules](https://github.com/Anbeeld/RESUME.md)
- [Anbeeld's PROMPTING.md: AI Instruction Designer](https://github.com/Anbeeld/PROMPTING.md)

[![Support my work!](https://anbeeld.com/images/support.jpg)](https://anbeeld.com/support)