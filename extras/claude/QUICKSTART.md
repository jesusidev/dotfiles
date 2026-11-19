# Claude Code - Quick Start Guide

This guide will get you up and running with Claude Code configuration in 2 minutes.

## Installation

### Option 1: Use the Setup Script (Recommended)

From your home directory:

```bash
cd ~/.dotfiles
./setupConfig.sh
```

This will stow all packages including `claude`.

### Option 2: Manual Stow

```bash
cd ~/.dotfiles
stow claude
```

This creates: `~/.claude/` → `~/.dotfiles/claude/.claude/`

## Verify Installation

Check that the symlink was created:

```bash
ls -la ~/.claude
# Should show: .claude -> .dotfiles/claude/.claude
```

## Try It Out

### 1. Start a Complete Workflow

```bash
# In Claude Code, type:
/workflow Add user authentication with JWT
```

This will guide you through:
- ✅ Git branch check and creation
- ✅ Pattern analysis (searches codebase for similar code)
- ✅ Task planning (breaks down into subtasks)
- ✅ Implementation
- ✅ Code review
- ✅ Build validation
- ✅ Documentation
- ✅ PR creation

### 2. Plan a Feature

```bash
/plan-tasks Add dark mode support
```

This will:
- Analyze the feature
- Break it into atomic tasks
- Create task files in `tasks/subtasks/{feature}/`
- Wait for your approval before creating files

## What Gets Created

After running workflows, you'll see:

```
your-project/
├── tasks/
│   └── subtasks/
│       └── {feature-name}/
│           ├── README.md              # Feature index
│           ├── 01-task-name.md        # Individual tasks
│           └── 02-another-task.md
└── docs/
    └── feature-analysts/
        └── {feature-name}.md          # Pattern analysis
```

## Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/workflow` | Complete feature development | `/workflow Add API endpoints` |
| `/plan-tasks` | Break down into subtasks | `/plan-tasks Add caching layer` |

## Common Workflows

### Adding a New Feature

```bash
# 1. Start the workflow
/workflow Add user profile page

# 2. Claude will:
#    - Check you're on a feature branch (creates one if needed)
#    - Ask for confirmation at each phase
#    - Analyze patterns in your codebase
#    - Plan the implementation
#    - Implement the code
#    - Review the code
#    - Validate the build
#    - Update documentation
#    - Create a PR
```

### Just Planning (No Implementation)

```bash
# If you just want to see the task breakdown:
/plan-tasks Add user profile page

# This creates the task files but doesn't implement
# You can then implement manually or use /workflow later
```

## Understanding the Workflow Phases

### Phase 0: Git Branch Check
- Checks if you're on `main`/`master`
- Offers to create a feature branch
- **Why?** Keep main clean and enable PR workflow

### Phase 1: Pattern Analysis
- Searches your codebase for similar implementations
- Documents patterns it finds
- **Why?** Follow existing conventions and patterns

### Phase 2: Task Planning
- Breaks feature into atomic subtasks
- Creates task files with acceptance criteria
- **Why?** Clear roadmap and progress tracking

### Phase 3: Implementation
- Implements each subtask sequentially
- Updates task status as it progresses
- **Why?** Systematic, traceable development

### Phase 4: Code Review
- Reviews all changes for quality and security
- Checks against acceptance criteria
- **Why?** Catch issues before they go to production

### Phase 5: Build Validation
- Runs type checking, build, and linting
- Ensures everything compiles
- **Why?** Catch build errors early

### Phase 6: Documentation
- Updates README, docs, and comments
- Keeps documentation in sync with code
- **Why?** Maintain up-to-date documentation

### Phase 7: PR Creation
- Commits changes and pushes branch
- Creates PR with summary
- **Why?** Ready for team review

## Customization

### Add a New Command

Create a new file in `~/.dotfiles/claude/.claude/commands/`:

```bash
# Example: Create a code review command
cat > ~/.dotfiles/claude/.claude/commands/review.md << 'EOF'
# Code Review

Review the code for: $ARGUMENTS

Check for:
- Code quality and readability
- Security vulnerabilities
- Performance issues
- Test coverage

Provide detailed, actionable feedback.
EOF
```

Now you can use `/review` in Claude Code!

### Modify Existing Commands

Edit files directly:

```bash
# Edit the workflow
vim ~/.dotfiles/claude/.claude/commands/workflow.md

# Or use your editor of choice
code ~/.dotfiles/claude/.claude/commands/workflow.md
```

Changes take effect immediately (no restart needed).

## Tips

### 1. You Control the Pace
Every phase asks for confirmation. You can:
- Review what it's about to do
- Say "no" to skip a phase
- Ask questions before proceeding

### 2. It's Iterative
If something goes wrong:
- The workflow stops
- You get recovery options
- You can retry, debug, skip, or abort

### 3. Task Files Are Documentation
The task files created are:
- Implementation guides
- Progress trackers
- Documentation of decisions
- **Save them** for future reference

### 4. Works With Your Project
The workflow:
- Adapts to your project structure
- Follows your naming conventions
- Uses your build tools
- Respects your git workflow

## Troubleshooting

### Command Not Found

```bash
# Check if stowed correctly
ls -la ~/.claude

# If missing, re-stow
cd ~/.dotfiles && stow claude
```

### Can't Find Similar Patterns

If pattern analysis doesn't find anything:
- It's okay! Claude will still create a plan
- The plan just won't reference existing patterns
- Provide more context in your request

### Workflow Seems Stuck

If a phase seems to hang:
- Check the output for questions
- Look for confirmation prompts
- You may need to approve to proceed

## Next Steps

1. **Try it:** Run `/workflow Add a simple feature`
2. **Explore:** Check what gets created in `tasks/` and `docs/`
3. **Customize:** Add your own commands
4. **Learn more:** Read `.claude/MIGRATION-GUIDE.md` for advanced usage

## Help

- **Commands:** Check `.claude/commands/` for available commands
- **Migration:** See `.claude/MIGRATION-GUIDE.md` to understand OpenCode → Claude Code
- **Usage:** Read `.claude/README.md` for detailed documentation

## Example Session

```bash
# Start Claude Code in your project
cd ~/my-project

# Run a workflow
> /workflow Add API rate limiting

Claude: "Analyzing request...
This appears to be a medium complexity task.
Would you like to proceed with the complete workflow? (yes/no)"

> yes

Claude: "═══════════════════════════════════════
📋 PHASE 1: Pattern Analysis
═══════════════════════════════════════
Proceed with Phase 1? (yes/no)"

> yes

# ... Claude analyzes patterns ...

Claude: "Found 3 similar rate limiting implementations.
Documented in docs/feature-analysts/rate-limiting.md

═══════════════════════════════════════
📝 PHASE 2: Task Planning
═══════════════════════════════════════
Proceed with Phase 2? (yes/no)"

> yes

# ... continues through all phases ...
```

That's it! You're ready to use Claude Code with your OpenCode-inspired workflow.
