# MCP servers

Four MCP servers are configured (see [`../../mcp/servers.json`](../../mcp/servers.json)).
The installer registers them at **user scope** with `claude mcp add-json`, keeping secrets
as `${ENV_VAR}` references that Claude Code expands from your shell at startup.

| Server | Transport | Secret needed | Purpose |
|---|---|---|---|
| `chrome-devtools` | stdio | — | Drive a real Chrome via DevTools protocol (navigate, click, screenshot, network, performance/Lighthouse). |
| `magicui` | stdio (npx) | — | Browse & fetch Magic UI component registry items for UI building. |
| `context7` | http | `CONTEXT7_API_KEY` | Fetch up-to-date library/framework/API documentation on demand. |
| `graphify` | stdio | — | Query local code knowledge graphs (nodes, neighbors, paths, god nodes, PR impact). |

---

## chrome-devtools
- **Command:** `chrome-devtools-mcp` (must be on `PATH`).
- **Install:** `npm i -g chrome-devtools-mcp` (or ensure the binary exists), plus a Chrome/Chromium install.
- **Use it for:** navigating pages, filling forms, taking snapshots/screenshots, reading console & network, running Lighthouse and performance traces.
- Note: your `CLAUDE.md` prefers gstack `/browse` for general browsing; use this server for DevTools-level inspection.

## magicui
- **Command:** `npx -y @magicuidesign/mcp@latest` (auto-downloads; needs Node + network).
- **Use it for:** listing/searching the Magic UI registry and pulling component source when building interfaces.

## context7
- **Transport:** HTTP to `https://mcp.context7.com/mcp`.
- **Auth:** header `CONTEXT7_API_KEY`, stored as a `${CONTEXT7_API_KEY}` **reference** —
  Claude Code expands it from the shell environment at startup, so the real key never
  lands in `~/.claude.json`. Get a key at https://context7.com, put it in `.env`, and
  **export it in your shell** (e.g. `~/.bashrc`, or `set -a; source .env; set +a`).
- **Use it for:** current docs for libraries/SDKs/CLIs (React, Next.js, Prisma, Tailwind, etc.) — prefer it over web search for library docs.

---

### Verify / manage
```bash
claude mcp list                      # show configured servers
claude mcp get context7              # inspect one
claude mcp remove <name> -s user     # remove
```

### Rotating the context7 key
The key is **never** stored in this repo *or* in any generated config — only in your
local `.env`/shell environment. To rotate: get a new key, update `.env` and your shell
export, then restart your AI tool. No re-install needed (configs reference the env var,
not the value).

## graphify

Local code knowledge graphs over the Intelcia projects under `~/Work`.

- **Command:** `$HOME/.local/bin/graphify-mcp` (from `uv tool install "graphifyy[mcp,…]"`).
- **Default graph:** `$HOME/.graphify/global-graph.json` — the cross-project graph built
  by `graphify extract --global`. It is passed as the server's only positional argument,
  so tools answer against it when no `project_path` is given.
- **Multi-project:** every tool (`query_graph`, `get_node`, `get_neighbors`,
  `shortest_path`, `god_nodes`, `get_pr_impact`, …) also takes an optional `project_path`,
  and the server keeps `GRAPHIFY_MAX_CONTEXTS` (24) graphs hot in an LRU.
- **No API key** — extraction is local tree-sitter and community labels come from a local
  ollama model, so client code never leaves the laptop.

```bash
graphify extract <repo> --code-only     # rebuild a project graph (free, local)
graphify update <repo>                  # incremental refresh after code changes
graphify query "<question>" --graph <repo>/graphify-out/graph.json
```

Each indexed repo has `graphify-out/` and `.graphifyignore` in its `.git/info/exclude`,
so none of this shows up in the work repos' git status.
