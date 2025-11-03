# OpenCode to Claude Code Migration Guide

This guide helps you migrate your OpenCode agents to Claude Code.

## Quick Reference: Agent Mapping

| OpenCode Agent | Claude Code Implementation | Location |
|---------------|---------------------------|----------|
| `@workflow-orchestrator` | `/workflow` command | `.claude/commands/workflow.md` |
| `@task-manager` | `/plan-tasks` command | `.claude/commands/plan-tasks.md` |
| `@codebase-agent` | Task tool (general-purpose) | Inline in commands |
| `@feature-analyst` | Task tool (Explore subagent) | Inline in commands |
| `@coder-agent` | Task tool (general-purpose) | `.claude/agents/coder-agent-example.md` |
| `@tester` | Task tool (general-purpose) | Create as needed |
| `@reviewer` | Task tool or `/review` command | Create as needed |
| `@build-agent` | Bash tool commands | Inline in workflow |
| `@documentation` | Task tool (general-purpose) | Create as needed |

## Migration Steps for Each Agent Type

### 1. Primary Orchestration Agents → Slash Commands

**Examples:** `workflow-orchestrator`, `task-manager`

**Steps:**
1. Create `.claude/commands/{name}.md`
2. Remove YAML frontmatter
3. Convert `@agent` invocations to Task tool calls
4. Add `$ARGUMENTS` for command parameters
5. Add `AskUserQuestion` for confirmations

**Before (OpenCode):**
```markdown
---
description: "Routes requests"
model: opencode/claude-sonnet-4-5
tools:
  read: true
---
# Workflow Orchestrator
Invoke @task-manager to plan...
```

**After (Claude Code):**
```markdown
# Workflow Orchestrator

Use Task tool with:
- subagent_type: "Plan"
- prompt: "Break down this feature..."
```

### 2. Analysis Agents → Task Tool with Explore

**Examples:** `codebase-agent`, `feature-analyst`

**Steps:**
1. Use Task tool with `subagent_type="Explore"`
2. Set thoroughness level: "quick", "medium", or "very thorough"
3. Provide clear search and analysis instructions

**Implementation:**
```markdown
# In your workflow

## Phase 1: Analysis

Use the Task tool:
- subagent_type: "Explore"
- thoroughness: "very thorough"
- description: "Analyze authentication patterns"
- prompt: "Search the codebase for authentication implementations.
  Find similar patterns for JWT, session management, and user validation.
  Document patterns in docs/feature-analysts/auth.md"
```

### 3. Implementation Agents → Task Tool (General-Purpose)

**Examples:** `coder-agent`, `tester`, `documentation`

**Steps:**
1. Create agent prompt template in `.claude/agents/`
2. Use Task tool with `subagent_type="general-purpose"`
3. Include specific task instructions in prompt
4. Reference the template when needed

**Implementation:**
```markdown
# In your workflow

## Phase 3: Implementation

Use the Task tool:
- subagent_type: "general-purpose"
- model: "haiku" (or "sonnet" for complex tasks)
- description: "Implement task 01"
- prompt: "You are a coder agent implementing task 01.

  Task file: tasks/subtasks/auth/01-jwt-setup.md

  Requirements:
  - Install JWT library
  - Create auth middleware
  - Add type definitions

  Follow the acceptance criteria and update the task file when complete."
```

### 4. Build/Test Agents → Direct Tool Usage

**Examples:** `build-agent`

**Steps:**
1. Use Bash tool directly for build commands
2. Use built-in test running capabilities
3. No need for separate agent

**Implementation:**
```markdown
# In your workflow

## Phase 5: Build Validation

Run build validation:
```bash
# Type checking
npm run type-check

# Build
npm run build

# Lint
npm run lint
```

Check output and report errors.
```

## Converting Specific OpenCode Patterns

### Pattern: Agent Invocation
```markdown
# OpenCode
Invoke @coder-agent with task 01

# Claude Code
Use the Task tool with:
- subagent_type: "general-purpose"
- model: "haiku"
- prompt: "[Coder agent instructions for task 01]"
```

### Pattern: Permission Control
```markdown
# OpenCode
---
permissions:
  bash:
    "*": "deny"
  edit:
    "**/*.env*": "deny"
---

# Claude Code
# Permissions are handled by the orchestrating agent
# Include security reminders in agent prompts:
"Security: Never modify .env, .key, or .secret files"
```

### Pattern: Model Selection
```markdown
# OpenCode
---
model: opencode/claude-haiku-4-5
---

# Claude Code
Use the Task tool with:
- model: "haiku" # or "sonnet" or "opus"
```

### Pattern: Temperature Control
```markdown
# OpenCode
---
temperature: 0.1
---

# Claude Code
# Temperature is controlled by Claude Code's runtime
# No per-agent temperature in slash commands
# For consistency, mention "Be precise and deterministic" in prompts
```

## Step-by-Step Migration Checklist

### For Each OpenCode Agent:

- [ ] **Identify agent type** (orchestration / analysis / implementation / build)
- [ ] **Choose Claude Code pattern:**
  - [ ] Slash command (for user-invoked workflows)
  - [ ] Task tool integration (for sub-tasks)
  - [ ] Direct tool usage (for builds/tests)
- [ ] **Create new file:**
  - [ ] `.claude/commands/{name}.md` for slash commands
  - [ ] `.claude/agents/{name}.md` for agent templates
- [ ] **Adapt content:**
  - [ ] Remove YAML frontmatter
  - [ ] Convert agent invocations to Task tool
  - [ ] Add user interaction (AskUserQuestion)
  - [ ] Add $ARGUMENTS where needed
- [ ] **Test:**
  - [ ] Invoke the command/agent
  - [ ] Verify it works as expected
  - [ ] Refine based on results

## Common Pitfalls

### ❌ Don't: Copy YAML frontmatter
```markdown
---
description: "Agent"
model: opencode/claude-sonnet-4-5
---
```
Claude Code doesn't use this format.

### ✅ Do: Use Task tool parameters
```markdown
Use Task tool with model: "sonnet"
```

### ❌ Don't: Use @agent-name syntax
```markdown
Invoke @coder-agent to implement...
```
Claude Code doesn't have this syntax.

### ✅ Do: Use Task tool explicitly
```markdown
Use the Task tool with subagent_type: "general-purpose"...
```

### ❌ Don't: Assume user approval
```markdown
Creating files now...
```

### ✅ Do: Ask for confirmation
```markdown
Use AskUserQuestion tool to ask: "Proceed with file creation? (yes/no)"
```

## Testing Your Migration

1. **List available commands:**
   ```
   In Claude Code, available commands are automatically detected from .claude/commands/
   ```

2. **Test a slash command:**
   ```
   /workflow Add a new feature
   ```

3. **Verify outputs:**
   - Check if files are created in expected locations
   - Verify task files follow the template
   - Ensure user confirmations work

4. **Iterate:**
   - Refine prompts based on behavior
   - Add more detailed instructions if needed
   - Simplify where possible

## Example: Full Migration of Reviewer Agent

### Original OpenCode Agent

`opencode/.config/opencode/agent/subagents/reviewer.md`:
```markdown
---
description: "Reviews code for quality and security"
mode: subagent
model: opencode/claude-sonnet-4-5
temperature: 0.1
tools:
  read: true
  grep: true
  glob: true
---

# Reviewer Agent

Review the code changes and provide feedback on:
- Code quality
- Security issues
- Performance concerns
- Test coverage
```

### Option 1: Slash Command

`.claude/commands/review.md`:
```markdown
# Code Review

Review the code changes for: $ARGUMENTS

## Review Areas

1. **Code Quality:**
   - Readability and maintainability
   - Follows project conventions
   - Proper error handling

2. **Security:**
   - No hardcoded secrets
   - Input validation
   - SQL injection prevention
   - XSS vulnerabilities

3. **Performance:**
   - Efficient algorithms
   - Proper caching
   - Database query optimization

4. **Test Coverage:**
   - Unit tests present
   - Edge cases covered
   - Integration tests if needed

Provide detailed, actionable feedback for each area.
```

### Option 2: Inline in Workflow

In `.claude/commands/workflow.md`:
```markdown
## Phase 4: Quality Assurance

Perform a thorough code review:

1. Read all changed files using Read tool
2. Check for:
   - Security vulnerabilities (hardcoded secrets, injection risks)
   - Code quality (readability, conventions)
   - Performance issues (inefficient code)
   - Test coverage (missing tests)
3. Provide detailed feedback with file:line references
```

## Resources

- **Claude Code Docs:** https://docs.claude.com/en/docs/claude-code
- **Slash Commands:** https://docs.claude.com/en/docs/claude-code/slash-commands
- **Task Tool:** https://docs.claude.com/en/docs/claude-code/task-tool
- **This Setup:** `.claude/README.md`

## Getting Help

If you encounter issues:

1. Check `.claude/README.md` for architecture overview
2. Review `.claude/agents/coder-agent-example.md` for Task tool usage
3. Test with simple slash commands first
4. Gradually add complexity

## Next Steps

1. ✅ Review this guide
2. ✅ Start with `/workflow` command
3. ⬜ Create additional slash commands for your needs
4. ⬜ Adapt remaining OpenCode agents
5. ⬜ Test and refine
