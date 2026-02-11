---
description: Shared configuration and guidelines for the ultrawork agent system
plan_directory: plans/
---

# Ultrawork Agent System Configuration

This document contains shared configuration and guidelines referenced by all agents in the ultrawork system.

## Plan Directory Configuration

All agents that create or reference plan files should follow this convention:

1. Check if the workspace has an `AGENTS.md` file at the repository root
2. If it exists, look for a `plan_directory` specification in the front matter or content
3. Use that directory for all plan files (e.g., `.sisyphus/plans`, `plans/`, `.plans/`, etc.)
4. If no `AGENTS.md` exists or no plan directory is specified, default to `plans/`

**Example AGENTS.md front matter:**
```yaml
---
plan_directory: .sisyphus/plans
---
```

## Context Conservation Strategy

All conductor and research agents must actively manage their context window:

### When to Delegate

- Task requires exploring >10 files
- Task involves deep research across multiple subsystems (>3)
- Task requires specialized expertise (frontend, exploration, deep research)
- Multiple independent subtasks can be parallelized
- Heavy file reading/analysis that can be summarized by a subagent

### When to Handle Directly

- Simple analysis requiring <5 file reads
- High-level orchestration and decision making
- Writing plan/completion documents (conductor's core responsibility)
- User communication and approval gates

### Multi-Subagent Strategy

- You can invoke multiple subagents (up to 10) per phase if needed
- Parallelize independent research tasks across multiple subagents
- Example: "Invoke Explorer for file discovery, then Oracle for 3 separate subsystems in parallel"
- Collect results from all subagents before making decisions

### Context-Aware Decision Making

- Before reading files yourself, ask: "Would a subagent summarize this better?"
- If a task requires >1000 tokens of context, strongly consider delegation
- Prefer delegation when in doubt - subagents are cheaper and focused

## Parallel Execution Heuristics

Use these concrete guidelines to determine how many parallel subagents to invoke:

### File-Based Heuristics
- **1-5 files**: Handle directly with semantic search
- **6-20 files**: 1 Explorer subagent
- **21-50 files**: 2-3 Explorer subagents (by domain/directory)
- **50+ files**: 3-5 Explorer subagents (by subsystem)

### Subsystem-Based Heuristics
- **1 subsystem**: 1 Oracle subagent
- **2-3 subsystems**: 1 Oracle per subsystem (2-3 parallel)
- **4-6 subsystems**: 1 Oracle per major subsystem (4-6 parallel)
- **7+ subsystems**: Group related subsystems, 1 Oracle per group (max 10)

### Combined Strategy
1. Start with Explorer(s) to map the landscape
2. Review Explorer findings to identify subsystems
3. Launch Oracle instances based on subsystem count
4. Maximum 10 total parallel subagents per research phase

### Independence Check
Only parallelize subagents when:
- They work on different files/directories
- They research independent subsystems
- They don't need each other's results to proceed
- Their work won't conflict (no shared state)

## Error Recovery

### Subagent Failures

**If a subagent times out:**
1. Review partial output if available
2. Try rerunning with narrower scope
3. If repeated timeout, handle the task directly (smaller chunks)

**If a subagent returns incomplete results:**
1. Invoke again with more specific instructions
2. Provide context about what was missing
3. After 2 failed attempts, handle directly or ask user for guidance

**If multiple subagents fail:**
1. Stop and assess: Is the task too complex?
2. Break down into smaller, more focused tasks
3. Consider whether the codebase is in an unstable state
4. Report to user and request guidance

### User Disappears

**During planning phase:**
- Continue research autonomously
- Document all assumptions and open questions
- Present complete plan when user returns
- Don't wait indefinitely if ambiguous

**During implementation phase:**
- STOP at phase boundaries
- Do NOT proceed to next phase without explicit approval
- Keep state clean for easy resume

**After review:**
- Wait at commit point
- Do NOT auto-commit
- Keep changes staged for easy verification

## Agent Reference Guide

### Available Subagents

1. **Oracle-subagent**: Research and context gathering expert
   - Use for: Deep subsystem analysis, pattern discovery
   - Parallelize: Yes (one per subsystem)
   - Max instances: 10

2. **Sisyphus-subagent**: Backend/core implementation expert
   - Use for: TDD-driven code implementation
   - Parallelize: Cautiously (only for clearly disjoint work)
   - Max instances: 3

3. **Code-Review-subagent**: Code quality and correctness reviewer
   - Use for: Verifying implementations meet requirements
   - Parallelize: Yes (one per phase/feature)
   - Max instances: 5

4. **Explorer-subagent**: Fast codebase exploration expert
   - Use for: File discovery, usage analysis, dependency mapping
   - Parallelize: Yes (one per domain/directory)
   - Max instances: 10

5. **Frontend-Engineer-subagent**: UI/UX implementation specialist
   - Use for: Frontend features, styling, responsive design
   - Parallelize: Cautiously (only for independent components)
   - Max instances: 2

## Best Practices

### For Conductors (Atlas, Prometheus)
- Delegate early and often
- Use parallel execution for independent tasks
- Synthesize subagent findings, don't just forward them
- Track which subagents you've invoked to avoid duplication

### For Implementers (Sisyphus, Frontend-Engineer)
- Follow strict TDD: test → fail → code → pass
- Run individual test file first, then full suite
- Request help from Oracle/Explorer if stuck >30 minutes
- Report back clearly: what was done, what tests pass

### For Researchers (Oracle, Explorer)
- Stop at 90% confidence, not 100%
- Use structured output formats (see handoff-protocol.md)
- Document what you didn't find (important negative results)
- Provide actionable next steps

### For Reviewers (Code-Review)
- Focus on correctness and test coverage first
- Note style issues but don't block on them
- Verify tests actually validate the requirement
- Check for common security issues

## Configuration Override

Individual projects can override these defaults by creating a `.copilot/agents-config.md` file with project-specific settings.
