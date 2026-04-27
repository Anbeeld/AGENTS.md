# Changelog

## v1.1.2

- Expanded sync scripts from 3 to 9 targets — added Amp, Goose, Gemini CLI, Roo Code, Kilo Code, Cline, and Augment Code. GitHub Copilot is covered via the existing Claude Code target.
- Fixed PowerShell `Detect-Targets` scoping bug and removed broken `Assert-HasTargetArgs`. Fixed Codex and Claude Windows paths from `%APPDATA%` to `%USERPROFILE%`.
- Fixed bash `set -e` exit in `detect_targets` and `set -u` compatibility with empty arrays on macOS bash 3.2.

## v1.1.1

- Changed bundling rule in Uncertainty to "When bundling, ensure each question can be answered independently" — fixes failure where related points bundled into a tool call that only returned one answer.
- Converted Uncertainty example from instruction format to demonstration format for stronger pattern matching.

## v1.1.0

- Reduced length by ~600 characters.
- Merged Role section into intro line to reduce structural overhead.
- Cut redundant "Before acting, check local instructions, verification commands, and path-scoped rules" from intro — covered by "local instructions override" and Workflow step 6.
- Changed "Small independent reads" to "Small reads" in Workflow — removed conflicting use of "independent" that overlapped with the subagent routing on line 55.
- Compressed Workflow step 3 subagent routing from 28 words to 8 — moved batching mechanics to Subagents paragraph, cardinality to line 67, leaving pure routing.
- Added self-correction grounding to Evidence.
- Elevated subagent batching constraint from bullet to standalone paragraph — it's an API-level mechanical constraint, not a heuristic.
- Replaced vague "Scope the whole batch" with concrete decomposition procedure.
- Replaced abstract independence explanation with actionable test.
- Added concrete deliverable requirement with anti-patterns.
- Removed redundant Subagents bullets — consolidated into existing lines 67, 71, 73-75.

## v1.0.1

- Clarified subagent guidance to keep proactive usage while requiring main-agent scoping to split work into 2+ parallel independent tracks first.
