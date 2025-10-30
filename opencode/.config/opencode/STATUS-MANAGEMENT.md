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
3. **🚨 VERIFY @coder-agent updates (MANDATORY - DO NOT SKIP):**
   - Read subtask file
   - Check ALL acceptance criteria marked: `- [x] {criterion} - ✅ Completed`
   - Check "## Implementation Completed" section exists
   - IF MISSING: Use Edit tool to add (fallback responsibility)
4. **Invoke @tester** for tests
5. **🚨 VERIFY @tester updates (MANDATORY - DO NOT SKIP):**
   - Read subtask file again
   - Check "## Test Results" section exists
   - Check Testing Requirements marked: `- [x] {test case}`
   - IF MISSING: Use Edit tool to add (fallback responsibility)
6. **Run validation:** Type check, lint, format, tests
7. **🚨 COMPLETE MANDATORY CHECKLIST (DO NOT SKIP):**
   - Verify ALL items in checklist pass
   - Use grep commands to verify sections exist
   - Read subtask file one final time
8. **Mark task as complete:** [~] → [x] in feature index (ONLY after checklist complete)
9. Move to next task

#### Critical Rules:
- ✅ YOU own feature index status transitions
- ✅ YOU MUST verify subtask file updates (steps 3, 5)
- ✅ YOU MUST use fallback if subagents don't update
- ✅ YOU MUST complete verification checklist (step 7)
- ❌ NEVER skip verification steps (3, 5, 7)
- ❌ NEVER mark complete without checklist passing
- ❌ NEVER assume subagents updated files
- ⚠️  **Verification steps are MANDATORY, not optional**

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

## 🚨 MANDATORY VALIDATION CHECKLIST 🚨

**@codebase-agent: Complete EVERY item before marking [~] → [x]**

### Step 1: Read Subtask File
```bash
cat tasks/subtasks/{feature}/{seq}-{task-description}.md
```
- [ ] File read successfully

### Step 2: Verify Implementation Updates
```bash
# Check acceptance criteria
grep "\[x\].*✅ Completed" tasks/subtasks/{feature}/{seq}-{task-description}.md

# Check Implementation Completed section
grep "## Implementation Completed" tasks/subtasks/{feature}/{seq}-{task-description}.md
```
- [ ] ALL acceptance criteria marked: `- [x] {criterion} - ✅ Completed`
- [ ] "## Implementation Completed" section exists
- [ ] Date/timestamp present in implementation section
- [ ] Files Changed list present
- [ ] Key Decisions documented
- [ ] **IF ANY MISSING:** Use Edit tool to add (fallback)

### Step 3: Verify Test Updates
```bash
# Check Test Results section
grep "## Test Results" tasks/subtasks/{feature}/{seq}-{task-description}.md

# Check testing requirements
grep "## Testing Requirements" tasks/subtasks/{feature}/{seq}-{task-description}.md
```
- [ ] Testing Requirements checklist items marked: `- [x] {test case}`
- [ ] "## Test Results" section exists
- [ ] Date/timestamp present in test results
- [ ] Command Used documented
- [ ] Pass/fail results shown
- [ ] **IF ANY MISSING:** Use Edit tool to add (fallback)

### Step 4: Verify Validation Passed
- [ ] Type checks passed (npm run check / tsc)
- [ ] Linting passed (npm run lint)
- [ ] Formatting passed (npm run format:fix)
- [ ] Tests passed (npm test)
- [ ] No errors in any validation output

### Step 5: Final Verification
- [ ] Re-read subtask file one more time
- [ ] Confirmed all sections present and complete
- [ ] All checklist items above are checked

### Step 6: Mark Complete
**ONLY if ALL items above are checked:**
```bash
# Use Edit tool to update feature index
# Change: [~] {seq} — {task}
# To:     [x] {seq} — {task}
```
- [ ] Feature index updated to [x]

**IF ANY ITEM UNCHECKED:**
- ❌ DO NOT mark complete
- ❌ DO NOT proceed to next task
- ✅ Fix the missing item
- ✅ Re-run this checklist from Step 1

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
