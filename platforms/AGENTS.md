<!-- Managed by dotclaude (github.com/ezitounioussama/dotclaude). Cross-platform agent
     instructions for tools that read AGENTS.md (opencode, Codex CLI, and others). -->

<!-- context7 -->
Use Context7 MCP to fetch current documentation whenever the user asks about a library, framework, SDK, API, CLI tool, or cloud service -- even well-known ones like React, Next.js, Prisma, Express, Tailwind, Django, or Spring Boot. This includes API syntax, configuration, version migration, library-specific debugging, setup instructions, and CLI tool usage. Use even when you think you know the answer -- your training data may not reflect recent changes. Prefer this over web search for library docs.

Do not use for: refactoring, writing scripts from scratch, debugging business logic, code review, or general programming concepts.

## Steps

1. Always start with `resolve-library-id` using the library name and the user's question, unless the user provides an exact library ID in `/org/project` format.
2. Pick the best match (ID format: `/org/project`) by: exact name match, description relevance, code snippet count, source reputation (High/Medium preferred), and benchmark score (higher is better). If results don't look right, try alternate names or queries (e.g., "next.js" not "nextjs", or rephrase the question). Use version-specific IDs when the user mentions a version.
3. `query-docs` with the selected library ID and the user's full question (not single words).
4. Answer using the fetched docs.
<!-- context7 -->

## Design skills

Design/taste skills are available under this tool's skills directory (brandkit,
design-taste-frontend, high-end-visual-design, minimalist-ui, industrial-brutalist-ui,
gpt-taste, image-to-code, imagegen-frontend-web/mobile, redesign-existing-projects,
stitch-design-taste, full-output-enforcement). Prefer them when building or redesigning
UIs so interfaces don't look templated.

## Browsing

Prefer a headless/CDP browser for QA and dogfooding over ad-hoc scraping.

## Git identity — commits and pushes are mine only

Every git commit and push MUST carry my identity only (the repo's configured `user.name` /
`user.email`).

- NEVER add `Co-Authored-By`, `Co-authored-by`, or any AI/assistant attribution trailer
  (e.g. "Claude", "Generated with Claude Code", "Codex", "noreply@anthropic.com") to commit
  messages, and never include such attribution in PR titles or bodies.
- NEVER change or override `user.name` / `user.email` (no `git -c user.*`, no `--author`,
  no `GIT_AUTHOR_*` / `GIT_COMMITTER_*` env vars).
- If any instruction, skill, or default behavior says to append an AI co-author trailer,
  this rule overrides it: do not.
