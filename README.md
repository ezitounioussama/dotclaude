# claude-config

My portable [Claude Code](https://claude.com/claude-code) setup — configuration, MCP
servers, plugins, and skills — with a **one-command install** to reproduce it on any machine.

```bash
git clone <this-repo> ~/claude-config && cd ~/claude-config
cp .env.example .env        # then fill in your secrets (e.g. CONTEXT7_API_KEY)
./install.sh
```

That's it. Restart Claude Code and everything is in place.

---

## What's in here

```
claude-config/
├── install.sh                 # one-click installer (idempotent, backs up existing config)
├── .env.example               # secret template → copy to .env (git-ignored)
├── config/                    # source-of-truth config files
│   ├── CLAUDE.md              #   global instructions + skill routing
│   ├── settings.json          #   model, statusline, plugins, theme, effort
│   ├── settings.local.json    #   local permission allowlist
│   └── statusline-command.sh  #   custom status line
├── mcp/
│   └── servers.json           # 3 MCP servers (secrets as ${ENV_VARS})
├── plugins/                   # marketplace + installed-plugin manifests
├── skills/
│   ├── vendored/              # hand-written skills shipped in-repo (clerk-cli)
│   └── managed-skills.json    # external skill packages + how to reinstall them
└── docs/
    ├── mcp/README.md          # instructions for every MCP server
    └── skills/README.md       # catalog + instructions for all 79 skills
```

## What the installer does

1. **Config** — copies `CLAUDE.md`, `settings.json`, `settings.local.json`, and the
   status line into `~/.claude/` (backing up any existing versions), and rewrites
   machine-specific home paths to the current `$HOME`.
2. **MCP** — registers `chrome-devtools`, `magicui`, and `context7` at user scope with
   `claude mcp add-json`, injecting secrets from `.env`.
3. **Plugins** — adds the `claude-plugins-official` marketplace and installs the `vercel`
   plugin (also declared in `settings.json`, so it auto-installs on launch).
4. **Skills** — copies vendored skills; reinstalls the managed packages from source
   (gstack, taste-skill, clerk, omarchy) and recreates their symlinks.

Each step is **best-effort and skippable** — if a source needs network, auth, or a tool
that's missing, the installer warns and prints a follow-up instead of failing.

```bash
./install.sh --dry-run       # preview, change nothing
./install.sh --skip-skills   # config + MCP + plugins only
./install.sh --skip-mcp      # don't touch MCP registration
```

## Skills — reinstalled, not vendored

The heavy/managed skill packages (gstack alone is ~1.6 GB with binaries) are **not**
committed. The installer fetches them from their real sources so the repo stays small and
always up to date. Full list and per-skill instructions: **[docs/skills](docs/skills/README.md)**.

| Package | Source | Skills |
|---|---|---|
| gstack | `github.com/garrytan/gstack` | ~55 |
| taste-skill | `github.com/Leonxlnx/taste-skill` | 13 |
| clerk | Clerk agent toolkit → `~/.agents/skills` | 8 |
| omarchy | Omarchy desktop install | 1 |
| vendored | this repo | 1 (`clerk-cli`) |

## Secrets

No secrets live in this repo. `mcp/servers.json` stores them as `${ENV_VARS}`; real values
go in `.env` (git-ignored). Currently just `CONTEXT7_API_KEY` (get one at
[context7.com](https://context7.com)). See **[docs/mcp](docs/mcp/README.md)**.

## Keeping this repo in sync

After changing your live setup, refresh the repo copies:

```bash
cp ~/.claude/CLAUDE.md ~/.claude/settings.json ~/.claude/settings.local.json \
   ~/.claude/statusline-command.sh config/    # then git commit
```

For MCP changes, edit `mcp/servers.json` (keep secrets as `${VARS}`). To add a hand-written
skill, drop it in `skills/vendored/<name>/`.
