# Task Status Management System

## Overview

This document defines the clear separation of responsibilities for task status management across agents to ensure tasks are properly tracked and marked complete.

## Status Locations

### 1. Feature Index (`tasks/subtasks/{feature}/README.md`)
- **Owner:** @codebase-agent
- **Format:** `[ ]` (not started), `[~]` (in progress), `[x]` (complete)
- **Purpose:** High-level task tracking and feature progress

### 2. Subtask Files (`tasks/subtasks/{feature}/{seq}-{task-description}.md`)
- **Owners:** @coder-agent and @tester
- **Format:** 
  - Acceptance Criteria: `- [x] {criterion} - ✅ Completed`
  - Testing Requirements: `- [x] {test case}`
  - Implementation Completed section
  - Test Results section
- **Purpose:** Detailed tracking of implementation and test completion

## Agent Responsibilities

### @codebase-agent (Coordinator)
**Primary Responsibility:** Feature Index Status Management

#### Workflow:
1. **Mark task as started:** [ ] → [~] in feature index
2. **Invoke @coder-agent** for implementation
3. **Invoke @tester** for tests
4. **Verify subtask file updates:**
   - Acceptance criteria marked complete
   - Implementation section added
   - Test results section added
5. **Fallback:** If subagents didn't update, update it yourself
6. **Mark task as complete:** [~] → [x] in feature index
7. Move to next task

#### Critical Rules:
- ✅ YOU own feature index status transitions
- ✅ YOU verify subtask file updates
- ✅ YOU have fallback responsibility if subagents don't update
- ❌ NEVER skip verification step
- ❌ NEVER mark complete without validation passing

### @coder-agent (Implementer)
**Primary Responsibility:** Subtask File Implementation Tracking

#### Workflow:
1. Implement the code as specified
2. **Mark acceptance criteria** in subtask file: `- [x] {criterion} - ✅ Completed`
3. **Add Implementation Completed section** to subtask file with:
   - Date/time
   - Files changed
   - Key decisions
   - Deviations from plan
   - Validation results
4. Signal completion to @codebase-agent

#### Critical Rules:
- ✅ YOU update acceptance criteria in subtask file
- ✅ YOU add implementation section to subtask file
- ❌ DO NOT update feature index status
- ❌ DO NOT mark [ ] → [~] → [x] in README.md
- ⚠️  @codebase-agent manages feature index status

### @tester (Tester)
**Primary Responsibility:** Subtask File Test Tracking

#### Workflow:
1. Write and run tests
2. **Mark Testing Requirements checklist** in subtask file: `- [x] {test case}`
3. **Mark Success Criteria Checklist** in subtask file
4. **Add Test Results section** to subtask file with:
   - Date/time
   - Command used
   - Results (passed/failed/coverage)
   - Output
5. Signal completion to @codebase-agent

#### Critical Rules:
- ✅ YOU update testing requirements in subtask file
- ✅ YOU add test results section to subtask file
- ❌ DO NOT update feature index status
- ❌ DO NOT mark [ ] → [~] → [x] in README.md
- ⚠️  @codebase-agent manages feature index status

## Status Update Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ FEATURE INDEX (README.md)                                       │
│ Managed by: @codebase-agent                                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [ ] 01 — Create service hook                                  │
│       ↓ @codebase-agent marks as started                       │
│  [~] 01 — Create service hook                                  │
│       ↓                                                         │
│       ├─> @coder-agent implements code                         │
│       │   └─> Updates acceptance criteria in subtask file      │
│       │                                                         │
│       ├─> @tester writes tests                                 │
│       │   └─> Updates testing requirements in subtask file     │
│       │                                                         │
│       ├─> @codebase-agent validates                            │
│       │   └─> Verifies subtask file updates                    │
│       │                                                         │
│       ↓ @codebase-agent marks as complete                      │
│  [x] 01 — Create service hook                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ SUBTASK FILE (01-create-service-hook.md)                       │
│ Managed by: @coder-agent + @tester                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ ## Acceptance Criteria                                         │
│ - [x] Hook created - ✅ Completed (@coder-agent)               │
│ - [x] Hook tested - ✅ Completed (@coder-agent)                │
│                                                                 │
│ ## Testing Requirements                                        │
│ - [x] Unit test passes (@tester)                               │
│ - [x] Integration test passes (@tester)                        │
│                                                                 │
│ ## Implementation Completed (@coder-agent)                     │
│ Date: 2025-10-30 14:30                                         │
│ Files Changed: ...                                             │
│ Key Decisions: ...                                             │
│                                                                 │
│ ## Test Results (@tester)                                      │
│ Date: 2025-10-30 14:35                                         │
│ Command Used: npm test                                         │
│ Results: All tests passed                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Common Issues & Solutions

### Issue: Tasks not marked complete in feature index
**Cause:** @codebase-agent not updating status after validation
**Solution:** Ensure @codebase-agent follows step 6 in its workflow

### Issue: Acceptance criteria not checked in subtask file
**Cause:** @coder-agent not updating subtask file
**Solution:** 
1. @coder-agent should update (primary responsibility)
2. @codebase-agent verifies and updates if missing (fallback)

### Issue: Test results missing from subtask file
**Cause:** @tester not adding Test Results section
**Solution:**
1. @tester should add results (primary responsibility)
2. @codebase-agent verifies and can add if missing (fallback)

### Issue: Confusion about who updates what
**Solution:** Refer to this document's "Agent Responsibilities" section

## Validation Checklist

Before @codebase-agent marks a task as complete [~] → [x]:

- [ ] @coder-agent implemented the code
- [ ] @tester wrote and ran tests
- [ ] Type checks pass
- [ ] Linting passes
- [ ] Tests pass
- [ ] **Acceptance criteria marked in subtask file**
- [ ] **Implementation section added to subtask file**
- [ ] **Test results section added to subtask file**
- [ ] All validation commands successful

## Key Principles

1. **Single Source of Truth:** Feature index (`README.md`) is the authoritative source for task completion status
2. **Clear Ownership:** @codebase-agent owns feature index, subagents own subtask files
3. **Verification Required:** Always verify subtask file updates before marking complete
4. **Fallback Responsibility:** @codebase-agent updates subtask files if subagents don't
5. **Never Skip Steps:** Complete workflow must be followed for every task

## References

- **Workflow Diagram:** `.config/opencode/workflow-diagram.md`
- **Codebase Agent:** `.config/opencode/agent/codebase-agent.md`
- **Coder Agent:** `.config/opencode/agent/subagents/coder-agent.md`
- **Tester Agent:** `.config/opencode/agent/subagents/tester.md`
