# Global Claude Code Skills

This directory is symlinked to `~/.claude/skills/` via home-manager
(see `../claude-code.nix`). It is an out-of-store symlink, so skills added
or edited here take effect immediately without a `home-manager switch`.

## Adding a skill

Each skill is a subdirectory containing a `SKILL.md` with YAML frontmatter:

```
skills/
  my-skill/
    SKILL.md
```

```markdown
---
name: my-skill
description: One-line summary of when Claude should use this skill.
---

# My Skill

Instructions for the skill go here.
```

Skills placed here are global (available across all projects). Project-local
skills instead live in `<project>/.claude/skills/`.
