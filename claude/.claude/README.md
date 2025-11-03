# Claude Code Configuration

This directory contains Claude Code slash commands and agent prompts adapted from the opencode agent system.

## Directory Structure

```
.claude/
├── commands/          # Slash commands (invoked with /command-name)
│   ├── workflow.md    # Main orchestration workflow
│   └── plan-tasks.md  # Task planning and breakdown
└── agents/            # Agent prompts (used via Task tool)
    └── (future agent prompts)
```

## Architecture Differences: OpenCode vs Claude Code

### OpenCode Structure
```markdown
---
description: "Agent description"
mode: primary|subagent
model: opencode/model-name
temperature: 0.1
tools:
  read: true
  edit: true
---
# Agent Content
```

### Claude Code Structure
```markdown
# Agent/Command Name

Agent content and instructions...

Use $ARGUMENTS for command arguments
Use Task tool to invoke sub-agents
Use AskUserQuestion for user confirmations
```

## Key Differences

| Feature | OpenCode | Claude Code |
|---------|----------|-------------|
| Invocation | `@agent-name` | `/command-name` |
| Config | YAML frontmatter | N/A (controlled by main agent) |
| Sub-agents | `@subagent` | Task tool with prompts |
| Model selection | Per-agent YAML | Runtime (Task tool parameter) |
| Tools | YAML permissions | Available by default |

## Using the Slash Commands

### Workflow Command

Orchestrates a complete feature development workflow with multiple phases:

```bash
/workflow Add user authentication with JWT
```

Phases:
1. **Git Branch Check** - Ensures you're on a feature branch
2. **Pattern Analysis** - Explores codebase for similar implementations
3. **Task Planning** - Breaks down feature into subtasks
4. **Implementation** - Codes the feature
5. **Quality Assurance** - Reviews code
6. **Build Validation** - Validates build
7. **Documentation** - Updates docs
8. **PR Creation** - Creates pull request

### Plan Tasks Command

Breaks down a feature into atomic subtasks:

```bash
/plan-tasks Add user authentication
```

Creates:
- `tasks/subtasks/{feature}/README.md` - Feature index
- `tasks/subtasks/{feature}/01-task.md` - Individual task files

## Creating New Slash Commands

1. Create a new `.md` file in `.claude/commands/`
2. Use the command name as the filename (e.g., `review.md` → `/review`)
3. Structure the prompt with clear instructions
4. Use `$ARGUMENTS` to capture command arguments

Example:
```markdown
# Code Review

Review the code changes for: $ARGUMENTS

## Review Checklist

- [ ] Code quality and readability
- [ ] Security vulnerabilities
- [ ] Performance issues
- [ ] Test coverage

Provide detailed feedback on each item.
```

## Using the Task Tool for Sub-Agents

Instead of OpenCode's `@subagent` syntax, use Claude Code's Task tool:

### OpenCode Way
```markdown
Invoke @coder-agent to implement the feature
```

### Claude Code Way
```markdown
Use the Task tool with a detailed prompt:

Task tool parameters:
- subagent_type: "general-purpose"
- description: "Implement user authentication"
- prompt: "You are a coder agent. Implement user authentication with JWT..."
```

## Converting OpenCode Agents to Claude Code

### Step 1: Remove YAML Frontmatter
OpenCode YAML config is not used in Claude Code. Tool permissions and model selection are handled differently.

### Step 2: Convert Agent Invocations
Replace `@agent-name` with Task tool invocations or direct implementation.

### Step 3: Add User Interaction
Use `AskUserQuestion` tool for user confirmations instead of assuming approval.

### Step 4: Create Slash Command or Agent Prompt
- **Primary agents** (like workflow-orchestrator) → Slash commands
- **Sub-agents** (like coder-agent, tester) → Agent prompts or inline instructions

## Example: Converting an OpenCode Agent

**OpenCode Agent** (`agent/reviewer.md`):
```markdown
---
description: "Reviews code for quality"
mode: subagent
model: opencode/claude-sonnet-4-5
---
# Reviewer Agent
Review the code and provide feedback...
```

**Claude Code Options:**

**Option 1: Slash Command** (`.claude/commands/review.md`):
```markdown
# Code Review

Review the code changes in: $ARGUMENTS

Provide detailed feedback on quality, security, and performance.
```

**Option 2: Inline in Workflow**:
```markdown
# In workflow.md
[Perform code review using these guidelines:]
- Check code quality
- Review security
- Assess performance
```

## Tips for Migration

1. **Simplify**: Claude Code doesn't need as much metadata
2. **Be explicit**: Include all instructions in the prompt
3. **Use tools**: Leverage AskUserQuestion, Task, Bash, etc.
4. **Test incrementally**: Start with one command, test, then add more
5. **Combine small agents**: Multiple small opencode agents can be one Claude Code command

## Available Commands

Run `/help` in Claude Code to see all available commands.

## Next Steps

1. Try the workflow: `/workflow Your feature request`
2. Test task planning: `/plan-tasks Your feature`
3. Create custom commands for your workflow
4. Adapt remaining opencode agents as needed

## References

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)
- [Slash Commands Guide](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [Task Tool Reference](https://docs.claude.com/en/docs/claude-code/task-tool)
