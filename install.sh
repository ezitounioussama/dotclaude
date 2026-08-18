#!/usr/bin/env bash
#
# One-click installer for this AI coding config (Claude Code + other platforms).
#
#   ./install.sh                 # install the full Claude Code setup
#   ./install.sh --skip-skills   # config + MCP + plugins only
#   ./install.sh --skip-mcp      # skip MCP server registration
#   ./install.sh --dry-run       # print what would happen, change nothing
#
# Other platforms (MCP servers + agent instructions):
#   ./install.sh --opencode      # also set up opencode
#   ./install.sh --codex         # also set up Codex CLI
#   ./install.sh --gemini        # also set up Gemini CLI
#   ./install.sh --all-platforms # Claude + opencode + codex + gemini
#   ./install.sh --only=opencode,codex   # ONLY these platforms, skip Claude
#
# Safe to re-run. Existing config files are backed up before being changed.

set -uo pipefail

# ------------------------------------------------------------------ paths / args
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
BACKUP_DIR="$CLAUDE_DIR/backups/config-restore-$(date +%Y%m%d-%H%M%S 2>/dev/null || echo manual)"

DO_SKILLS=1; DO_MCP=1; DO_PLUGINS=1; DRY=0
DO_CLAUDE=1; PLATFORMS=""
for arg in "$@"; do
  case "$arg" in
    --skip-skills)  DO_SKILLS=0 ;;
    --skip-mcp)     DO_MCP=0 ;;
    --skip-plugins) DO_PLUGINS=0 ;;
    --dry-run)      DRY=1 ;;
    --opencode)     PLATFORMS="$PLATFORMS opencode" ;;
    --codex)        PLATFORMS="$PLATFORMS codex" ;;
    --gemini)       PLATFORMS="$PLATFORMS gemini" ;;
    --all-platforms) PLATFORMS="$PLATFORMS opencode codex gemini" ;;
    --only=*)       DO_CLAUDE=0; PLATFORMS="$PLATFORMS $(echo "${arg#--only=}" | tr ',' ' ')" ;;
    -h|--help)      grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown flag: $arg"; exit 1 ;;
  esac
done

# ------------------------------------------------------------------ pretty print
c() { printf "\033[%sm%s\033[0m" "$1" "$2"; }
say()  { printf "\n%s %s\n" "$(c '1;35' '▶')" "$(c '1' "$1")"; }
ok()   { printf "  %s %s\n" "$(c '32' '✓')" "$1"; }
warn() { printf "  %s %s\n" "$(c '33' '!')" "$1"; }
skip() { printf "  %s %s\n" "$(c '90' '·')" "$1"; }
run()  { if [ "$DRY" = 1 ]; then printf "  %s %s\n" "$(c '90' 'dry')" "$*"; else "$@"; fi; }

SUMMARY=()
note() { SUMMARY+=("$1"); }

printf "%s\n" "$(c '1;35' '═══ Claude Code config installer ═══')"
echo "repo:   $REPO_DIR"
echo "target: $CLAUDE_DIR"
[ "$DRY" = 1 ] && warn "dry-run: no changes will be made"

# ------------------------------------------------------------------ load secrets
if [ -f "$REPO_DIR/.env" ]; then
  set -a; . "$REPO_DIR/.env"; set +a
  ok "loaded secrets from .env"
else
  warn "no .env found — MCP secrets (e.g. CONTEXT7_API_KEY) will be blank"
  warn "copy .env.example to .env and fill it in for full functionality"
fi

# ================================================================== CLAUDE CODE
if [ "$DO_CLAUDE" = 0 ]; then
  say "Claude Code"
  skip "skipped (--only=... requested other platforms)"
else

# ------------------------------------------------------------------ 1. config
say "1/4  Config files"
mkdir -p "$CLAUDE_DIR"
for f in CLAUDE.md settings.json settings.local.json statusline-command.sh; do
  src="$REPO_DIR/config/$f"; dst="$CLAUDE_DIR/$f"
  [ -f "$src" ] || { skip "$f (not in repo)"; continue; }
  if [ -f "$dst" ]; then
    run mkdir -p "$BACKUP_DIR"
    run cp "$dst" "$BACKUP_DIR/$f"
  fi
  run cp "$src" "$dst"
  ok "$f"
done
[ "$DRY" = 1 ] || chmod +x "$CLAUDE_DIR/statusline-command.sh" 2>/dev/null || true
[ -d "$BACKUP_DIR" ] && note "previous config backed up to $BACKUP_DIR"

# ------------------------------------------------------------------ 2. MCP
say "2/4  MCP servers"
if [ "$DO_MCP" = 0 ]; then
  skip "skipped (--skip-mcp)"
elif ! command -v claude >/dev/null 2>&1; then
  warn "claude CLI not found — skipping MCP registration"
  note "MCP: install Claude Code, then re-run to register servers"
elif ! command -v jq >/dev/null 2>&1; then
  warn "jq not found — skipping MCP registration (needed to read servers.json)"
  note "MCP: install jq, then re-run"
else
  # Store the config with the literal ${CONTEXT7_API_KEY} reference — NOT the real
  # key. Claude Code expands ${VARS} in headers/url/env from the shell environment
  # at startup, so the secret never lands in ~/.claude.json.
  for name in $(jq -r 'keys[]' "$REPO_DIR/mcp/servers.json"); do
    cfg="$(jq -c --arg n "$name" '.[$n]' "$REPO_DIR/mcp/servers.json")"
    run claude mcp remove "$name" -s user >/dev/null 2>&1
    if [ "$DRY" = 1 ]; then
      skip "would add MCP: $name"
    elif claude mcp add-json "$name" "$cfg" -s user >/dev/null 2>&1; then
      ok "MCP: $name"
    else
      warn "MCP: $name failed (add manually with: claude mcp add-json $name '<json>')"
    fi
  done
  note "export CONTEXT7_API_KEY in your shell (see .env) — context7 reads it at startup"
fi

# ------------------------------------------------------------------ 3. plugins
say "3/4  Plugins (marketplace)"
if [ "$DO_PLUGINS" = 0 ]; then
  skip "skipped (--skip-plugins)"
else
  # settings.json already declares the marketplace + enabled plugins, so Claude
  # Code auto-installs on next launch. We also try the CLI for an immediate install.
  if command -v claude >/dev/null 2>&1; then
    run claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1 \
      && ok "marketplace: claude-plugins-official" \
      || warn "marketplace add via CLI failed (settings.json will handle it on launch)"
    run claude plugin install vercel@claude-plugins-official >/dev/null 2>&1 \
      && ok "plugin: vercel" \
      || skip "vercel will auto-install from settings.json on next launch"
    # caveman: official plugin path only. The upstream curl|bash installer also
    # rewrites Claude Code hooks + statusline, which would clobber ours.
    run claude plugin marketplace add JuliusBrussee/caveman >/dev/null 2>&1 \
      && ok "marketplace: caveman" \
      || warn "marketplace add via CLI failed (settings.json will handle it on launch)"
    run claude plugin install caveman@caveman >/dev/null 2>&1 \
      && ok "plugin: caveman" \
      || skip "caveman will auto-install from settings.json on next launch"
  else
    skip "claude CLI absent — plugins auto-install from settings.json on launch"
  fi
fi

# ------------------------------------------------------------------ 4. skills
say "4/4  Skills"
if [ "$DO_SKILLS" = 0 ]; then
  skip "skipped (--skip-skills)"
else
  mkdir -p "$SKILLS_DIR"

  # 4a. vendored standalone skills (shipped in this repo)
  for d in "$REPO_DIR"/skills/vendored/*/; do
    [ -d "$d" ] || continue
    n="$(basename "$d")"
    run rm -rf "$SKILLS_DIR/$n"
    run cp -r "$d" "$SKILLS_DIR/$n"
    ok "vendored skill: $n"
  done

  # 4b. gstack (self-managing; installs its own skills once the binary exists)
  if command -v gstack >/dev/null 2>&1; then
    ok "gstack present — its skills self-register"
  else
    warn "gstack not installed — see https://github.com/garrytan/gstack (installs ~55 skills)"
    note "gstack: install from https://github.com/garrytan/gstack, then re-run"
  fi

  # 4c. taste-skill (clone repo + symlink each mapped skill)
  TASTE_DIR="$HOME/.local/share/opencode/taste-skill"
  TASTE_REPO="https://github.com/Leonxlnx/taste-skill.git"
  if command -v git >/dev/null 2>&1; then
    if [ -d "$TASTE_DIR/.git" ]; then
      run git -C "$TASTE_DIR" pull --quiet && ok "taste-skill updated"
    else
      run mkdir -p "$(dirname "$TASTE_DIR")"
      if run git clone --quiet "$TASTE_REPO" "$TASTE_DIR"; then ok "taste-skill cloned"; else warn "taste-skill clone failed"; fi
    fi
    if [ -d "$TASTE_DIR" ] && command -v jq >/dev/null 2>&1; then
      while IFS=$'\t' read -r name rel; do
        [ -n "$name" ] || continue
        run ln -sfn "$TASTE_DIR/$rel" "$SKILLS_DIR/$name"
      done < <(jq -r '.packages["taste-skill"].skill_map | to_entries[] | "\(.key)\t\(.value)"' "$REPO_DIR/skills/managed-skills.json")
      ok "taste-skill: 13 skill symlinks"
    fi
  else
    warn "git not found — cannot install taste-skill"
  fi

  # 4d. clerk agent skills (installed via Clerk agent toolkit into ~/.agents/skills)
  AGENTS_SKILLS="$HOME/.agents/skills"
  if [ -d "$AGENTS_SKILLS" ]; then
    while read -r name; do
      [ -d "$AGENTS_SKILLS/$name" ] && run ln -sfn "../../.agents/skills/$name" "$SKILLS_DIR/$name"
    done < <(jq -r '.packages.clerk.skills[]' "$REPO_DIR/skills/managed-skills.json" 2>/dev/null)
    ok "clerk: linked skills from ~/.agents/skills"
  else
    warn "~/.agents/skills missing — install Clerk agent skills, e.g.:"
    warn "    npx @clerk/agent-toolkit@latest install   (then re-run)"
    note "clerk: install Clerk agent toolkit, then re-run to link 8 skills"
  fi

  # 4e. graphify (PyPI CLI + skill + MCP; global install does not register hooks,
  #      so config/settings.json carries the PreToolUse hook-guard entries)
  if command -v uv >/dev/null 2>&1; then
    run uv tool install "graphifyy[mcp,sql,watch]" >/dev/null 2>&1 \
      && ok "graphify installed" \
      || warn "graphify install failed (uv tool install graphifyy[mcp,sql,watch])"
    if command -v graphify >/dev/null 2>&1 || [ -x "$HOME/.local/bin/graphify" ]; then
      run "${HOME}/.local/bin/graphify" install --platform claude >/dev/null 2>&1 \
        && ok "graphify: skill + CLAUDE.md registered" \
        || warn "graphify skill registration failed"
    fi
  else
    warn "uv not found — skipping graphify (install uv, then re-run)"
    note "graphify: install uv (pacman -S uv), then re-run"
  fi

  # 4f. omarchy (system desktop install)
  OMARCHY="$HOME/.local/share/omarchy/default/omarchy-skill"
  if [ -e "$OMARCHY" ]; then
    run ln -sfn "$OMARCHY" "$SKILLS_DIR/omarchy" && ok "omarchy linked"
  else
    skip "omarchy not present on this machine (desktop-only)"
  fi

  # 4g. claude-seo (ships its own installer: 31 skills + 18 agents + python venv)
  SEO_TAG="$(jq -r '.packages["claude-seo"].version' "$REPO_DIR/skills/managed-skills.json" 2>/dev/null || echo v2.2.0)"
  if [ -f "$SKILLS_DIR/seo/SKILL.md" ]; then
    skip "claude-seo already installed (re-run its installer to update: CLAUDE_SEO_TAG=$SEO_TAG)"
  elif ! command -v python3 >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
    warn "claude-seo needs python3 (>=3.10) + curl — skipping"
    note "claude-seo: install python3/curl, then re-run to get 31 SEO skills + 18 agents"
  elif [ "$DRY" = 1 ]; then
    skip "would install claude-seo $SEO_TAG (31 skills + 18 agents)"
  elif CLAUDE_SEO_TAG="$SEO_TAG" bash -c 'curl -fsSL "https://raw.githubusercontent.com/AgriciDaniel/claude-seo/${CLAUDE_SEO_TAG}/install.sh" | bash' >/dev/null 2>&1; then
    ok "claude-seo $SEO_TAG: 31 skills + 18 agents"
  else
    warn "claude-seo install failed (network/python?) — install manually:"
    warn "    curl -fsSL https://raw.githubusercontent.com/AgriciDaniel/claude-seo/$SEO_TAG/install.sh | bash"
    note "claude-seo: install manually, then re-run"
  fi
fi

fi  # ================================================================ end CLAUDE

# ============================================================= OTHER PLATFORMS
PLATFORMS="$(echo "$PLATFORMS" | xargs 2>/dev/null || echo "$PLATFORMS")"
if [ -n "$PLATFORMS" ]; then
  say "Other platforms: $PLATFORMS"
  if command -v python3 >/dev/null 2>&1; then
    if [ "$DRY" = 1 ]; then
      DRY_RUN=1 python3 "$REPO_DIR/bin/install-platform.py" $PLATFORMS
    else
      python3 "$REPO_DIR/bin/install-platform.py" $PLATFORMS
    fi
  else
    warn "python3 not found — cannot configure other platforms"
    note "install python3, then: python3 bin/install-platform.py $PLATFORMS"
  fi
fi

# ------------------------------------------------------------------ done
say "Done"
if [ "${#SUMMARY[@]}" -gt 0 ]; then
  echo "Follow-ups:"
  for s in "${SUMMARY[@]}"; do warn "$s"; done
fi
echo
ok "Restart your AI tool(s) to pick up the new config, MCP servers, and instructions."
