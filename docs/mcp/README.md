# MCP servers

Five MCP servers are configured (see [`../../mcp/servers.json`](../../mcp/servers.json)).
The installer registers them at **user scope** with `claude mcp add-json`, keeping secrets
as `${ENV_VAR}` references that Claude Code expands from your shell at startup.

| Server | Transport | Secret needed | Purpose |
|---|---|---|---|
| `chrome-devtools` | stdio | — | Drive a real Chrome via DevTools protocol (navigate, click, screenshot, network, performance/Lighthouse). |
| `magicui` | stdio (npx) | — | Browse & fetch Magic UI component registry items for UI building. |
| `context7` | http | `CONTEXT7_API_KEY` | Fetch up-to-date library/framework/API documentation on demand. |
| `graphify` | stdio | — | Query local code knowledge graphs (nodes, neighbors, paths, god nodes, PR impact). |
| `basic-memory` | stdio | — | Read and write the Markdown knowledge graph of decisions, conventions, and session checkpoints. |

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
- **No API key** — extraction is local tree-sitter. Community labels are written by the
  `claude` binary (`graphify label <repo> --backend=claude-cli`), which runs on the Claude
  subscription; no API key and no local model are involved.

```bash
graphify extract <repo> --code-only     # rebuild a project graph (free, local)
graphify update <repo>                  # incremental refresh after code changes
graphify query "<question>" --graph <repo>/graphify-out/graph.json
```

Each indexed repo has `graphify-out/` and `.graphifyignore` in its `.git/info/exclude`,
so none of this shows up in the work repos' git status.

## basic-memory

The long-term memory layer: a Markdown knowledge graph of decisions, conventions, and
session checkpoints, indexed in SQLite and served over MCP. Code structure is graphify's
job; this is for everything a person said, decided, or left half-finished.

- **Command:** `$HOME/.local/bin/basic-memory mcp` (from `uv tool install basic-memory`).
- **Vault:** `~/Documents/Obsidian Vault/Knowledge`, registered as the project `knowledge`
  and passed to the server as `BASIC_MEMORY_DEFAULT_PROJECT`. The notes are plain Markdown
  with YAML frontmatter, readable and editable in Obsidian without this tool.
- **Config:** `${XDG_CONFIG_HOME:-~/.config}/basic-memory/config.json` (chmod 600).
- **21 tools**, about 11k tokens of definitions if they were all loaded eagerly. Claude Code
  defers tool schemas until one is called, which is what makes a server this size
  affordable — see the same argument in the repo README.

### No local model, by configuration

basic-memory ships `fastembed`, `onnxruntime`, and `sqlite_vec`, and turns semantic search
on automatically whenever those import — which downloads an ONNX embedding model on first
use. This setup runs on the Claude subscription alone, so the installer pins three keys:

```json
{
  "semantic_search_enabled": false,
  "default_search_type": "text",
  "reranker_enabled": false
}
```

Search is then SQLite full-text only. The semantic step is Claude's, reading the results.
Do not flip these back on without deciding to run a local model.

### Loaded in every session

Two lifecycle hooks are declared in [`../../config/settings.json`](../../config/settings.json),
not installed by `basic-memory hook install` — same convention as the graphify hook-guard
entries, so the repo stays the single source of truth for hooks:

| Hook | Command | What it does |
|---|---|---|
| `SessionStart` | `basic-memory hook session-start --harness claude` | Prints the recall brief (recent sessions, open decisions, active tasks) into the new session's context. |
| `PreCompact` | `basic-memory hook pre-compact --harness claude` | Writes a durable checkpoint before the context window is compacted. |

The `basicMemory` block in `settings.json` tunes them (`primaryProject`, `captureEvents`,
`captureFolder`, `recallTimeframe`, `checkpointOnCompact`). Setting it in the repo is also
what suppresses the `/basic-memory:bm-setup` prompt — nothing here needs a slash command.

### Frontmatter that the brief actually reads

The session brief queries `type: decision` with `status: open`, and `type: task` with
`status: active`. Tags alone are not enough — a note written without `note_type` stays
`type: note` and will never appear in a brief.

```bash
basic-memory tool write-note --title "Why X" --folder decisions \
  --note-type decision --content "..."
basic-memory tool search-notes "query"        # query is positional
basic-memory project list
basic-memory hook status                      # inbox depth, settings, versions
```
