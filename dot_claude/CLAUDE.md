# Global Claude Code Instructions

## Plan Directory

Always store plan files in `~/.claude/plan/{folder_name}/` where `{folder_name}` is the basename of the current working directory (`$(basename $PWD)`).

- **Never** create a `plans/` folder in the current working directory.
- The exact path is injected at session start via the SessionStart hook.
- Example: working in `/home/user/myproject` → plans go to `~/.claude/plan/myproject/`
