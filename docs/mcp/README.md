# MCP servers

Three MCP servers are configured (see [`../../mcp/servers.json`](../../mcp/servers.json)).
The installer registers them at **user scope** with `claude mcp add-json`, substituting
secrets from your `.env`.

| Server | Transport | Secret needed | Purpose |
|---|---|---|---|
| `chrome-devtools` | stdio | — | Drive a real Chrome via DevTools protocol (navigate, click, screenshot, network, performance/Lighthouse). |
| `magicui` | stdio (npx) | — | Browse & fetch Magic UI component registry items for UI building. |
| `context7` | http | `CONTEXT7_API_KEY` | Fetch up-to-date library/framework/API documentation on demand. |

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
- **Auth:** header `CONTEXT7_API_KEY`. Get a key at https://context7.com and put it in `.env`:
  ```
  CONTEXT7_API_KEY=ctx7sk-...
  ```
- **Use it for:** current docs for libraries/SDKs/CLIs (React, Next.js, Prisma, Tailwind, etc.) — prefer it over web search for library docs.

---

### Verify / manage
```bash
claude mcp list                      # show configured servers
claude mcp get context7              # inspect one
claude mcp remove <name> -s user     # remove
```

### Rotating the context7 key
The key is **never** stored in this repo — only in your local `.env`. To rotate:
edit `.env`, then re-run `./install.sh` (or `./install.sh` and it re-adds the server).
