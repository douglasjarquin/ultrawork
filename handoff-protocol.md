---
description: Agent communication standards and handoff protocol documentation
---

# Agent Handoff Protocol

This document defines standard communication formats between agents in the ultrawork system.

## Status Codes

All agents should use these standard status codes when reporting results:

### Implementation Status
- `SUCCESS`: Task completed successfully, all tests pass
- `PARTIAL_SUCCESS`: Task completed but with known limitations or warnings
- `NEEDS_REVISION`: Task completed but issues found, revision required
- `FAILED`: Task could not be completed, blocking issues encountered
- `TIMEOUT`: Task exceeded time/resource limits
- `BLOCKED`: Task cannot proceed, waiting on external dependency

### Review Status
- `APPROVED`: Changes meet all requirements, ready to commit
- `APPROVED_WITH_RECOMMENDATIONS`: Minor improvements suggested but not blocking
- `NEEDS_REVISION`: Issues found that must be fixed before approval
- `FAILED`: Critical issues found, implementation does not meet requirements

### Research Status
- `COMPLETE`: Research finished, all findings documented
- `PARTIAL`: Some findings available, more research may be helpful
- `INSUFFICIENT`: Unable to find enough information to proceed
- `AMBIGUOUS`: Multiple interpretations found, clarification needed

## Confidence Scoring

All research and exploration agents should include a confidence score:

- **90-100%**: High confidence, proceed with implementation
- **70-89%**: Good confidence, minor uncertainties remain
- **50-69%**: Moderate confidence, significant unknowns exist
- **30-49%**: Low confidence, more research strongly recommended
- **0-29%**: Very low confidence, findings may be incorrect

**Format:** `Confidence: 85%` or `<confidence>85</confidence>`

## Standard Output Formats

### Explorer-subagent Output

```xml
<analysis>
Brief description of exploration strategy and what you're looking for
</analysis>

<!-- Tool usage happens here -->

<results>
  <files>
    - /absolute/path/to/file1.ts: Brief relevance note
    - /absolute/path/to/file2.ts: Brief relevance note
    - ...
  </files>
  
  <answer>
    Concise explanation of what was found and how it works (2-4 sentences)
  </answer>
  
  <next_steps>
    1. Actionable next step for parent agent
    2. Another actionable step
    3. ...
  </next_steps>
  
  <confidence>85</confidence>
</results>
```

### Oracle-subagent Output

```markdown
## Research Results: {Topic}

**Status:** COMPLETE | PARTIAL | INSUFFICIENT | AMBIGUOUS
**Confidence:** {0-100}%

### Relevant Files
- {file}: {purpose and what will change}
- ...

### Key Functions/Classes
- {symbol} in {file}: {role in implementation}
- ...

### Patterns & Conventions
- {pattern}: {how codebase follows it}
- ...

### Dependencies
- {library/framework}: {how it's used}
- ...

### Implementation Options
1. **Option A:** {approach}
   - Pros: {benefits}
   - Cons: {drawbacks}
   
2. **Option B:** {approach}
   - Pros: {benefits}
   - Cons: {drawbacks}

**Recommendation:** {suggested approach with reasoning}

### Open Questions
- {What remains unclear or needs clarification}
- ...

### Next Steps
1. {Actionable step for parent agent}
2. ...
```

### Sisyphus/Frontend-Engineer Output

```markdown
## Implementation Complete: {Phase/Feature Name}

**Status:** SUCCESS | PARTIAL_SUCCESS | FAILED | BLOCKED
**Confidence:** {0-100}%

### Summary
{1-3 sentence overview of what was implemented}

### Files Created/Modified
- {file}: {what changed}
- ...

### Functions/Classes Created/Modified
- {symbol}: {purpose}
- ...

### Tests Created/Modified
- {test name}: {what it validates}
- ...

### Test Results
- Individual test file: ✅ PASSED | ❌ FAILED
- Full test suite: ✅ PASSED | ❌ FAILED
- Linter: ✅ PASSED | ❌ FAILED

### Issues Encountered
- {Issue description and how it was resolved}
- ...

### Next Steps
{What the conductor should do next: review, proceed to next phase, etc.}
```

### Code-Review-subagent Output

```markdown
## Code Review: {Phase/Feature Name}

**Status:** APPROVED | APPROVED_WITH_RECOMMENDATIONS | NEEDS_REVISION | FAILED
**Confidence:** {0-100}%

### Summary
{1-2 sentence overview of review findings}

### Strengths
- {What was done well}
- {Good practices followed}
- ...

### Issues Found
{If none, explicitly state "None"}

**[CRITICAL]** {Issue description}
- File: {path}
- Line: {number or range}
- Recommendation: {how to fix}

**[MAJOR]** {Issue description}
- File: {path}
- Recommendation: {how to fix}

**[MINOR]** {Issue description}
- File: {path}
- Recommendation: {how to fix}

### Test Coverage Assessment
- Unit tests: ✅ Adequate | ⚠️ Partial | ❌ Insufficient
- Integration tests: ✅ Adequate | ⚠️ Partial | ❌ Insufficient
- Edge cases: ✅ Covered | ⚠️ Partially covered | ❌ Not covered

### Security/Performance Concerns
{Any security or performance issues identified, or "None"}

### Recommendations
- {Specific, actionable suggestion}
- ...

### Next Steps
{What should happen next: approve and commit, revise specific issues, etc.}
```

### Prometheus (Planner) Output

Prometheus writes plan files following this structure:

```markdown
# Plan: {Task Title}

**Created:** {Date}
**Status:** Ready for Atlas Execution

## Summary

{2-4 sentence overview: what, why, how}

## Context & Analysis

**Relevant Files:**
- {file}: {purpose and what will change}
- ...

**Key Functions/Classes:**
- {symbol} in {file}: {role in implementation}
- ...

**Dependencies:**
- {library/framework}: {how it's used}
- ...

**Patterns & Conventions:**
- {pattern}: {how codebase follows it}
- ...

## Implementation Phases

### Phase 1: {Phase Title}

**Objective:** {Clear goal for this phase}

**Files to Modify/Create:**
- {file}: {specific changes needed}
- ...

**Tests to Write:**
- {test name}: {what it validates}
- ...

**Steps:**
1. {TDD step: write test}
2. {TDD step: run test (should fail)}
3. {TDD step: write minimal code}
4. {TDD step: run test (should pass)}
5. {Quality: lint/format}

**Acceptance Criteria:**
- [ ] {Specific, testable criteria}
- [ ] All tests pass
- [ ] Code follows project conventions

---

{Repeat for 3-10 phases, each incremental and self-contained}

## Open Questions

1. {Question}? 
   - **Option A:** {approach with tradeoffs}
   - **Option B:** {approach with tradeoffs}
   - **Recommendation:** {your suggestion with reasoning}

## Risks & Mitigation

- **Risk:** {potential issue}
  - **Mitigation:** {how to address it}

## Success Criteria

- [ ] {Overall goal 1}
- [ ] {Overall goal 2}
- [ ] All phases complete with passing tests
- [ ] Code reviewed and approved

## Notes for Atlas

{Any important context Atlas should know when executing this plan}
```

**File Location:** `<plan-directory>/<task-name>-plan.md`

## Agent Capability Matrix

Each agent should declare its capabilities in the front matter:

```yaml
capabilities:
  can_edit_code: true | false
  can_execute_commands: true | false
  can_invoke_subagents: true | false
  allowed_subagents: [list of agent names]
  max_parallel_instances: N
  read_only: true | false
  can_web_research: true | false
```

### Example Capability Matrices

**Atlas (Conductor):**
```yaml
capabilities:
  can_edit_code: false
  can_execute_commands: false
  can_invoke_subagents: true
  allowed_subagents: ["Oracle-subagent", "Sisyphus-subagent", "Code-Review-subagent", "Explorer-subagent", "Frontend-Engineer-subagent"]
  max_parallel_instances: 1
  read_only: true
  can_web_research: false
```

**Explorer-subagent:**
```yaml
capabilities:
  can_edit_code: false
  can_execute_commands: false
  can_invoke_subagents: false
  allowed_subagents: []
  max_parallel_instances: 10
  read_only: true
  can_web_research: false
```

**Sisyphus-subagent:**
```yaml
capabilities:
  can_edit_code: true
  can_execute_commands: true
  can_invoke_subagents: true
  allowed_subagents: ["Explorer-subagent", "Oracle-subagent"]
  max_parallel_instances: 3
  read_only: false
  can_web_research: true
```

## Error Reporting Format

When an agent encounters an error:

```markdown
## Error Report: {Agent Name}

**Error Type:** TIMEOUT | INSUFFICIENT_CONTEXT | TOOL_FAILURE | AMBIGUOUS_INSTRUCTIONS | EXTERNAL_DEPENDENCY

**Status:** FAILED | BLOCKED

**Description:**
{Clear explanation of what went wrong}

**Context:**
- Task: {what was being attempted}
- Last successful step: {what worked}
- Failure point: {where it failed}

**Attempted Solutions:**
1. {What was tried}
2. {What was tried}

**Recommendation:**
{What the parent agent or user should do to resolve this}

**Partial Results:**
{Any useful findings before failure, or "None"}
```

## Handoff Checklist

When handing off from one agent to another:

### From Conductor to Implementer
- [ ] Clear phase objective provided
- [ ] Specific files/functions identified
- [ ] Test requirements listed
- [ ] Acceptance criteria defined
- [ ] Any special conventions or constraints noted

### From Implementer to Reviewer
- [ ] Implementation status declared
- [ ] Files modified listed
- [ ] Test results provided
- [ ] Any known issues documented
- [ ] Success criteria met (or reasons why not)

### From Reviewer back to Conductor
- [ ] Review status declared (APPROVED/NEEDS_REVISION/FAILED)
- [ ] Specific issues identified with severity
- [ ] Recommendations provided
- [ ] Clear next steps indicated

### From Researcher to Conductor
- [ ] Research status declared
- [ ] Confidence level provided
- [ ] Relevant files listed with explanations
- [ ] Implementation options presented
- [ ] Open questions documented
- [ ] Next steps actionable

## Version

Protocol Version: 1.0
Last Updated: 2026-02-11
