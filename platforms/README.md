# Multi-platform support

The MCP servers and agent instructions in this repo work across several AI coding
tools — each just needs them in its own config format. The installer renders and
**merges** them into each platform (existing config is backed up, never clobbered).

| Platform | MCP config file | Instructions file | How it's applied |
|---|---|---|---|
| **Claude Code** | `~/.claude.json` (user scope) | `~/.claude/CLAUDE.md` | `claude mcp add-json` + copy config |
| **opencode** | `~/.config/opencode/opencode.json` (`mcp`) | `~/.config/opencode/AGENTS.md` | JSON merge |
| **Codex CLI** | `~/.codex/config.toml` (`[mcp_servers.*]`) | `~/.codex/AGENTS.md` | `codex mcp add` |
| **Gemini CLI** | `~/.gemini/settings.json` (`mcpServers`) | `~/.gemini/GEMINI.md` | JSON merge |

## Usage

```bash
./install.sh --opencode              # Claude + opencode
./install.sh --all-platforms         # Claude + opencode + codex + gemini
./install.sh --only=opencode,codex   # ONLY these, skip Claude
./install.sh --all-platforms --dry-run   # preview, change nothing
```

Or run the platform installer directly:

```bash
python3 bin/install-platform.py opencode codex gemini
DRY_RUN=1 python3 bin/install-platform.py gemini   # preview one
```

## What each platform gets

All three MCP servers, in each tool's native schema:

- **chrome-devtools** — stdio (`chrome-devtools-mcp`)
- **magicui** — stdio (`npx -y @magicuidesign/mcp@latest`)
- **context7** — HTTP with a `CONTEXT7_API_KEY` header on Claude/opencode/Gemini;
  on Codex it's the portable stdio form (`npx -y @upstash/context7-mcp`) since Codex's
  remote transport expects bearer-token auth, not a custom header.

Plus the shared [`AGENTS.md`](AGENTS.md) instructions (Gemini reads the same content as
`GEMINI.md`).

## Secrets — no key is ever written to disk

The installers do **not** put your Context7 key into any config file. Each generated
config only *references* the environment variable:

| Platform | How context7 gets the key |
|---|---|
| Claude Code | `${CONTEXT7_API_KEY}` in the header (expanded at startup) |
| opencode | `{env:CONTEXT7_API_KEY}` in the header (opencode interpolation) |
| Gemini CLI | `${CONTEXT7_API_KEY}` in the header (Gemini substitution) |
| Codex CLI | stdio server inherits `CONTEXT7_API_KEY` from the environment |

So you must **export `CONTEXT7_API_KEY` in your shell** for context7 to authenticate —
add it to `~/.bashrc`/`~/.zshrc`, or `set -a; source .env; set +a`. Nothing secret is
stored in the repo or in the generated configs.

## Notes / limitations

- **Skills**: the design/taste skills (`taste-skill` package) already install into
  `~/.local/share/opencode` and are shared between Claude and opencode. Codex/Gemini
  don't have a Claude-style skill system, so only MCP + instructions apply there.
- **Adding Cursor / Windsurf / Cline**: they use the Claude-Desktop MCP format
  (`{ "mcpServers": { … } }`) — the same shape as `mcp/servers.json`. Ask and it's a
  small addition to `bin/install-platform.py`.
