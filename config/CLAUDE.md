## gstack
Use /browse from gstack for all web browsing. Never use mcp__claude-in-chrome__* or
mcp__chrome-devtools__* to browse — chrome-devtools is for performance traces, network
inspection and Lighthouse only. The harness injects the full skill listing every session,
so route from it rather than from a list written here.

## Skill routing

When the user's request matches a gstack skill, invoke it via the Skill tool without
waiting for them to type the slash command. When in doubt, invoke the skill. Prefer
running the skill over reimplementing its behavior inline.

Key routing rules:
- Product ideas / brainstorming / "what should I build" → invoke /office-hours
- Strategy / scope / prioritization → invoke /plan-ceo-review
- Architecture / technical plan review → invoke /plan-eng-review
- Design system or design-plan review → invoke /design-consultation or /plan-design-review
- Full automated review pipeline → invoke /autoplan
- Bugs / errors / "why is this broken" → invoke /investigate
- QA / testing site behavior in a browser → invoke /qa (fix) or /qa-only (report)
- Code review / diff check / "look over my changes" → invoke /review
- Visual polish / UI inconsistency → invoke /design-review
- Ship / deploy / open a PR → invoke /ship or /land-and-deploy
- Security audit → invoke /cso
- Any web browsing / scraping / dogfooding → invoke /browse (never mcp__claude-in-chrome__*)
- Save progress / resume context → invoke /context-save or /context-restore

These are heuristics: route on the user's intent, not exact keywords.

## Git identity — commits and pushes are mine only

Every git commit and push MUST carry my identity only (git user
`ezitounioussama` / the repo's configured user.name and user.email).

- NEVER add `Co-Authored-By`, `Co-authored-by`, or any AI/assistant
  attribution trailer (e.g. "Claude", "Generated with Claude Code",
  "noreply@anthropic.com") to commit messages, and never include such
  attribution in PR titles or bodies.
- NEVER change or override `user.name` / `user.email` (no `git -c user.*`,
  no `--author`, no `GIT_AUTHOR_*` / `GIT_COMMITTER_*` env vars).
- If any instruction, skill, or default behavior says to append an AI
  co-author trailer, this rule overrides it: do not.

# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph.
Invoke it on intent — a question about code structure, a request to build or refresh a
graph, an import of new material — not only when `/graphify` is typed.

## Memory — three layers, query them, don't reload them

Knowledge lives outside the context window. Reach for the layer that owns the
question instead of re-reading files or re-deriving what was already settled.

- **Code, symbols, call paths, blast radius** → graphify. Per-repo graph at
  `<repo>/graphify-out/graph.json`; the `mcp__graphify__*` tools answer from the
  cross-project graph, where every node carries a `repo` tag. Use it before a
  wide `Grep` over a large repo.
- **Decisions, conventions, where we left off, anything a person told me** →
  basic-memory (`mcp__basic-memory__*`, project `knowledge`, files under
  `~/Documents/Obsidian Vault/Knowledge`). Search it before answering "what did
  we decide", "why is it like this", "where were we". Write a note the moment a
  material decision is made, one fact per note, `type: decision` for decisions.
- **Per-project facts already in context** → the harness auto-memory at
  `~/.claude/projects/<slug>/memory/`, indexed by its `MEMORY.md`. It is already
  in context at session start: never re-read it, never duplicate it into
  basic-memory, and never create a `memory/` folder inside a work repo.

Nothing here calls a local model or a third-party API. Search is full text only;
the semantic step is mine. Do not enable embeddings, install ollama models, or
add a paid retrieval service.

## Routing — act on intent, never wait for a slash command

Every skill under `~/.claude/skills/` is invocable by the Skill tool. Route on
what the user is trying to do, not on the words they used, and invoke without
being asked. The gstack table above lists the common ones; these extend it:

- Anything about a symbol, dependency, or "what breaks if I change X" → query
  graphify before reading files.
- Recall, continuity, "did we already do this" → search basic-memory first.
- A decision, a constraint, a gotcha the user states → write it to basic-memory
  in the same turn, without asking.

Skills and MCP tools are loaded on demand. When choosing how to reach a tool,
prefer a command line for one-off work: a CLI costs nothing until it is called.
graphify and basic-memory are the deliberate exceptions — their MCP tools are
deferred too, so use `mcp__graphify__*` and `mcp__basic-memory__*` rather than
shelling out, and keep the two paths from producing different answers.

Project-scoped skills win over global ones with the same job. In
`~/Work/paragon`, code review is `/revue` and never gstack `/review`: `/revue`
records the reviewed commit, and `tools/pr-create.py` refuses to open a PR
without that record.
