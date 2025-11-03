# Claude Code Configuration (Stow Package)

This is a Stow package for Claude Code configuration, migrated from your OpenCode agent system.

## Installation

From your `~/.dotfiles` directory, run:

```bash
stow claude
```

This will create symlinks:
- `~/.claude/` → `~/.dotfiles/claude/.claude/`

## Uninstallation

```bash
cd ~/.dotfiles
stow -D claude
```

## What's Inside

```
claude/
└── .claude/
    ├── commands/           # Slash commands
    │   ├── workflow.md     # /workflow command
    │   └── plan-tasks.md   # /plan-tasks command
    ├── agents/             # Agent prompt templates
    │   └── coder-agent-example.md
    ├── README.md           # Usage guide
    └── MIGRATION-GUIDE.md  # OpenCode migration guide
```

## Usage

After stowing, you can use these commands in Claude Code:

### `/workflow [feature request]`
Complete feature development workflow with phases:
- Git branch management
- Pattern analysis
- Task planning
- Implementation
- Code review
- Build validation
- Documentation
- PR creation

Example:
```
/workflow Add user authentication with JWT
```

### `/plan-tasks [feature name]`
Break down features into atomic subtasks:

Example:
```
/plan-tasks Add dark mode toggle
```

## Documentation

After stowing, detailed documentation will be available at:
- `~/.claude/README.md` - Usage guide
- `~/.claude/MIGRATION-GUIDE.md` - Migration from OpenCode

## Directory Structure Pattern

This package follows the Stow pattern used by your other dotfiles:

- `nvim/.config/nvim/` → `~/.config/nvim/`
- `opencode/.config/opencode/` → `~/.config/opencode/`
- `claude/.claude/` → `~/.claude/` ← **This package**

Note: Claude Code uses `.claude/` instead of `.config/claude/` as it's not an XDG-compliant application.

## Making Changes

Edit files in `~/.dotfiles/claude/.claude/` (which is what `~/.claude/` links to after stowing).

Changes will be automatically reflected since they're symlinked.

## Adding New Commands

1. Create a new `.md` file in `claude/.claude/commands/`
2. Name it after the command (e.g., `review.md` for `/review`)
3. Write the command prompt with `$ARGUMENTS` for parameters

Example:
```bash
echo "# Code Review\n\nReview: \$ARGUMENTS" > claude/.claude/commands/review.md
```

The command will be immediately available as `/review` in Claude Code.

## Maintenance

Since files are symlinked, you can:
- Edit directly in `~/.claude/` (the symlink)
- Or edit in `~/.dotfiles/claude/.claude/` (the source)
- Commit changes to git as usual

## Next Steps

1. Run `stow claude` to create the symlinks
2. Test with `/workflow` or `/plan-tasks`
3. Add custom commands as needed
4. Commit changes to your dotfiles repo
