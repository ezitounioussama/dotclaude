# dotclaude

My portable AI coding setup — configuration, MCP servers, plugins, skills, and agent
instructions — with a **one-command install** to reproduce it on any machine.
Works with [Claude Code](https://claude.com/claude-code) **and** opencode, Codex CLI,
and Gemini CLI.

```bash
git clone https://github.com/ezitounioussama/dotclaude ~/dotclaude && cd ~/dotclaude
cp .env.example .env        # then fill in your secrets (e.g. CONTEXT7_API_KEY)
./install.sh                # Claude Code
./install.sh --all-platforms   # Claude + opencode + Codex + Gemini
```

That's it. Restart your AI tool(s) and everything is in place.

## Supported platforms

| Platform | MCP servers | Instructions | Skills |
|---|---|---|---|
| Claude Code | ✅ | ✅ CLAUDE.md | ✅ (115) + 21 subagents |
| opencode | ✅ | ✅ AGENTS.md | ✅ (shared taste-skills) |
| Codex CLI | ✅ | ✅ AGENTS.md | — |
| Gemini CLI | ✅ | ✅ GEMINI.md | — |

Details + how to add Cursor/Windsurf: **[platforms/README.md](platforms/README.md)**.

---

## What's in here

```
dotclaude/
├── install.sh                 # one-click installer (idempotent, backs up existing config)
├── .env.example               # secret template → copy to .env (git-ignored)
├── config/                    # Claude Code source-of-truth config
│   ├── CLAUDE.md              #   global instructions + skill routing
│   ├── settings.json          #   model, statusline, plugins, theme, effort
│   ├── settings.local.json    #   local permission allowlist
│   └── statusline-command.sh  #   custom status line
├── mcp/
│   └── servers.json           # 5 MCP servers (secrets as ${ENV_VARS})
├── plugins/                   # marketplace + installed-plugin manifests
├── skills/
│   ├── vendored/              # hand-written skills shipped in-repo (clerk-cli)
│   └── managed-skills.json    # external skill packages + how to reinstall them
├── platforms/                 # multi-platform support (opencode, Codex, Gemini)
│   ├── AGENTS.md             #   shared cross-platform instructions
│   └── README.md             #   per-platform formats + usage
├── bin/
│   └── install-platform.py    # renders/merges MCP + instructions per platform
└── docs/
    ├── mcp/README.md          # instructions for every MCP server
    └── skills/README.md       # catalog + instructions for all 132 skills
```

## What the installer does

1. **Config** — copies `CLAUDE.md`, `settings.json`, `settings.local.json`, and the
   status line into `~/.claude/` (backing up any existing versions), and rewrites
   machine-specific home paths to the current `$HOME`.
2. **MCP** — registers `chrome-devtools`, `magicui`, `context7`, `graphify`, and
   `basic-memory` at user scope with `claude mcp add-json`, keeping secrets as `${ENV_VAR}`
   references.
3. **Plugins** — adds the `claude-plugins-official` marketplace and installs the `vercel`
   plugin (also declared in `settings.json`, so it auto-installs on launch).
4. **Skills** — copies vendored skills; reinstalls the managed packages from source
   (gstack, taste-skill, clerk, graphify, omarchy, claude-seo) and recreates their symlinks.
   `claude-seo` runs its own pinned installer, which also drops 18 SEO subagents into
   `~/.claude/agents/` and builds a Python venv at `~/.claude/skills/seo/.venv`.
5. **Memory** — installs `basic-memory`, registers the `knowledge` project at
   `~/Documents/Obsidian Vault/Knowledge`, and forces text-only search so nothing pulls a
   local embedding model. The lifecycle hooks come from `settings.json`, not from
   `basic-memory hook install`.
6. **Other platforms** (opt-in) — merges the MCP servers + instructions into opencode,
   Codex, and/or Gemini in their native formats. See [platforms/](platforms/README.md).

Each step is **best-effort and skippable** — if a source needs network, auth, or a tool
that's missing, the installer warns and prints a follow-up instead of failing.

```bash
./install.sh --dry-run           # preview, change nothing
./install.sh --skip-skills       # config + MCP + plugins only
./install.sh --skip-mcp          # don't touch MCP registration
./install.sh --all-platforms     # also set up opencode + Codex + Gemini
./install.sh --only=opencode     # ONLY opencode (skip Claude Code)
```

## Memory — three layers, nothing paid, nothing local

Knowledge lives outside the context window and is queried, never reloaded. Each layer owns
a different kind of question, and `CLAUDE.md` routes between them without a slash command.

| Layer | Owns | Backend | Cost |
|---|---|---|---|
| Code structure | symbols, call paths, blast radius | graphify (CLI + MCP, local tree-sitter) | free |
| Knowledge | decisions, conventions, where we left off | basic-memory (Markdown + SQLite FTS, MCP) | free |
| Project facts | per-repo notes already in context | `~/.claude/projects/<slug>/memory/` | free |

Two rules hold this together:

- **No local models and no paid retrieval.** graphify labels communities with the `claude`
  binary on the existing subscription; basic-memory runs with semantic search disabled, so
  search is SQLite full-text and the semantic step is Claude's own reading. `CLAUDE.md`
  states this so a later session does not silently turn embeddings back on.
- **A CLI costs nothing until it is called.** MCP tool definitions are re-sent on every
  request, so a server is only worth registering when the agent must reach it unprompted.
  basic-memory's 21 tools are about 11k tokens if loaded eagerly; Claude Code defers the
  schemas until one is used, which is what makes it affordable.

## Skills — reinstalled, not vendored

The heavy/managed skill packages (gstack alone is ~1.6 GB with binaries) are **not**
committed. The installer fetches them from their real sources so the repo stays small and
always up to date. Full list and per-skill instructions: **[docs/skills](docs/skills/README.md)**.

| Package | Source | Skills |
|---|---|---|
| gstack | `github.com/garrytan/gstack` | ~55 |
| claude-seo | `github.com/AgriciDaniel/claude-seo` @ `v2.2.0` | 31 (+ 18 subagents) |
| taste-skill | `github.com/Leonxlnx/taste-skill` | 13 |
| clerk | Clerk agent toolkit → `~/.agents/skills` | 8 |
| caveman | `github.com/JuliusBrussee/caveman` (Claude Code plugin) | 20 (+ 3 Cavecrew subagents) |
| graphify | `graphifyy` on PyPI (CLI + skill + MCP) | 1 |
| omarchy | Omarchy desktop install | 2 |
| vendored | this repo | 1 (`clerk-cli`) |

`~/.claude/agents/` isn't tracked here either — every subagent on this setup comes from
`claude-seo`, so its installer recreates them.

## Secrets

No secrets live in this repo. `mcp/servers.json` stores them as `${ENV_VARS}`; real values
go in `.env` (git-ignored). Currently just `CONTEXT7_API_KEY` (get one at
[context7.com](https://context7.com)). See **[docs/mcp](docs/mcp/README.md)**.

## Keeping this repo in sync

After changing your live setup, refresh the repo copies:

```bash
cp ~/.claude/CLAUDE.md ~/.claude/settings.local.json \
   ~/.claude/statusline-command.sh config/    # then git commit
```

`settings.json` is the one file to copy **by hand**, because the live version carries two
things this repo deliberately does not:

- **Absolute home paths** — hook and status-line commands are stored here as `$HOME/...`
  so the config is portable; Claude Code rewrites them to `/home/<you>/...` on its side.
  This applies to the graphify `PreToolUse` guards, the gstack `Stop` hook, and the
  basic-memory `SessionStart` / `PreCompact` hooks alike.
- **`autoMode.environment`** — the machine- and repo-specific trust profile Claude Code
  generates itself (org, remotes, branches, sensitive targets). It is regenerated per
  machine and would leak internal infrastructure detail into git, so it stays untracked.

The live `model` field is also left out: the model is a per-session choice, not part of
the setup.

For MCP changes, edit `mcp/servers.json` (keep secrets as `${VARS}`). To add a hand-written
skill, drop it in `skills/vendored/<name>/`. Plugin-provided skills (vercel, caveman) are
not symlinked into `~/.claude/skills`, so only the plugin manifests need updating when
they change version.
