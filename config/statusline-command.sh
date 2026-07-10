#!/usr/bin/env bash
# Claude Code status line — mirrors Starship config (directory + git branch + git status + model)

input=$(cat)

# Directory: use cwd from JSON, truncate to last 2 parts
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
if [ -n "$cwd" ]; then
  # Truncate to last 2 path components, prefixed with …/ if truncated
  dir=$(echo "$cwd" | awk -F'/' '{
    n = NF
    if (n <= 2) {
      print $0
    } else {
      print "…/" $(n-1) "/" $n
    }
  }')
else
  dir="$(pwd | awk -F'/' '{n=NF; if(n<=2) print $0; else print "…/" $(n-1) "/" $n}')"
fi

# Git branch (skip optional locks)
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)

# Git status summary
git_status=""
if [ -n "$branch" ]; then
  status_output=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" status --porcelain 2>/dev/null)
  modified=$(echo "$status_output" | grep -c '^ M\| M' 2>/dev/null || true)
  untracked=$(echo "$status_output" | grep -c '^??' 2>/dev/null || true)
  staged=$(echo "$status_output" | grep -c '^[MADR]' 2>/dev/null || true)

  ahead_behind=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-list --left-right --count HEAD...@{u} 2>/dev/null || echo "")
  ahead=0; behind=0
  if [ -n "$ahead_behind" ]; then
    ahead=$(echo "$ahead_behind" | awk '{print $1}')
    behind=$(echo "$ahead_behind" | awk '{print $2}')
  fi

  [ "$modified" -gt 0 ] && git_status="${git_status} "
  [ "$untracked" -gt 0 ] && git_status="${git_status}? "
  [ "$staged" -gt 0 ]    && git_status="${git_status} "
  [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ] && git_status="${git_status}⇕⇡${ahead}⇣${behind} "
  [ "$ahead" -gt 0 ] && [ "$behind" -eq 0 ] && git_status="${git_status}⇡${ahead} "
  [ "$behind" -gt 0 ] && [ "$ahead" -eq 0 ] && git_status="${git_status}⇣${behind} "
  [ -z "$git_status" ] && git_status=" "
fi

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // ""')

# Context usage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Assemble the line using ANSI cyan (dimmed in status bar)
# Format: …/dir/path branch git_status | model [ctx%]
if [ -n "$branch" ]; then
  printf "\033[36m%s\033[0m \033[3;36m%s\033[0m\033[36m%s\033[0m" "$dir" "$branch" "$git_status"
else
  printf "\033[36m%s\033[0m" "$dir"
fi

if [ -n "$model" ]; then
  printf " \033[2m|\033[0m \033[2m%s\033[0m" "$model"
fi

if [ -n "$used_pct" ]; then
  printf " \033[2m[ctx: %.0f%%]\033[0m" "$used_pct"
fi

printf "\n"
