# Skills catalog

110 skills across 5 external packages + 1 vendored skill, plus 18 SEO subagents. Invoke any
of them by typing `/<skill-name>` in Claude Code, or Claude auto-invokes when your request
matches.

**How they're installed** (see [`../../skills/managed-skills.json`](../../skills/managed-skills.json)):
- **gstack** → provided by the `gstack` binary (self-registers)
- **claude-seo** → its own pinned installer (`v2.2.0`), copies skills + `~/.claude/agents`
- **taste-skill** → cloned from `github.com/Leonxlnx/taste-skill`, symlinked in
- **clerk** → Clerk agent toolkit into `~/.agents/skills`, symlinked in
- **omarchy** → symlink to the Omarchy desktop install
- **vendored** → shipped inside this repo (`skills/vendored/`)

---

## gstack (workflow / dev automation)

Routing note: your `CLAUDE.md` tells Claude to auto-invoke these on intent match.

| Skill | What it does |
|---|---|
| `/office-hours` | YC-style product/brainstorming office hours (two modes). |
| `/plan-ceo-review` | CEO/founder-mode review of a plan (strategy, scope, priority). |
| `/plan-eng-review` | Eng-manager-mode technical plan review. |
| `/plan-design-review` | Designer's-eye plan review. |
| `/plan-devex-review` | Developer-experience plan review. |
| `/plan-tune` | Self-tuning question sensitivity for planning skills. |
| `/autoplan` | Runs the full CEO+design+eng+DX review pipeline automatically. |
| `/design-consultation` | Proposes a complete design system + font/color previews. |
| `/design-shotgun` | Generate multiple design variants + comparison board. |
| `/design-html` | Produce production-quality Pretext-native HTML/CSS. |
| `/design-review` | Designer's-eye visual QA + fixes. |
| `/investigate` | Systematic root-cause debugging. |
| `/qa` | QA a web app in a browser and fix bugs found. |
| `/qa-only` | Report-only QA (no fixes). |
| `/review` | Pre-landing PR/diff review. |
| `/ship` | Ship workflow: tests, review, version bump, CHANGELOG, commit, push, PR. |
| `/land-and-deploy` | Land + deploy workflow. |
| `/canary` | Post-deploy canary monitoring. |
| `/benchmark` | Performance regression detection via the browse daemon. |
| `/benchmark-models` | Cross-model benchmark for gstack skills. |
| `/browse` | Fast headless browser for QA/dogfooding (your default browser tool). |
| `/open-gstack-browser` / `/connect-chrome` | Launch AI-controlled Chromium with sidebar. |
| `/scrape` | Pull data from a web page. |
| `/skillify` | Codify a successful `/scrape` flow into a permanent browser skill. |
| `/setup-browser-cookies` | Import real-browser cookies into the headless session. |
| `/pair-agent` | Pair a remote AI agent with your browser. |
| `/cso` | Chief Security Officer / security-audit mode. |
| `/careful` | Safety guardrails for destructive commands. |
| `/freeze` / `/unfreeze` | Restrict / release edits to a directory for the session. |
| `/guard` | Full safety mode (destructive warnings + scoped edits). |
| `/health` | Code-quality dashboard. |
| `/retro` | Weekly engineering retrospective. |
| `/spec` | Turn vague intent into an executable spec (5 phases). |
| `/diagram` | English/mermaid → editable `.excalidraw` diagram. |
| `/make-pdf` | Markdown → publication-quality PDF. |
| `/document-generate` | Generate missing docs from scratch. |
| `/document-release` | Post-ship documentation update. |
| `/codex` | OpenAI Codex CLI wrapper (three modes). |
| `/learn` | Manage project learnings. |
| `/context-save` / `/context-restore` | Save / restore working context. |
| `/setup-deploy` | Configure deployment for `/land-and-deploy`. |
| `/setup-gbrain` / `/sync-gbrain` | Set up / sync gbrain memory for the agent. |
| `/landing-report` | Read-only queue dashboard for workspace-aware ship. |
| `/gstack-upgrade` | Upgrade gstack to the latest version. |
| `/devex-review` | Live developer-experience audit. |
| `/ios-qa` `/ios-fix` `/ios-design-review` `/ios-sync` `/ios-clean` | Live-device iOS QA, autonomous bug-fix, design audit, debug-bridge sync/removal. |

## claude-seo (SEO / GEO)

Pinned to `v2.2.0`. `/seo` is the umbrella entry point and routes to the rest; each
sub-skill also works standalone. Python (>= 3.10) scripts run from
`~/.claude/skills/seo/.venv`.

| Skill | What it does |
|---|---|
| `/seo` | Umbrella SEO skill — routes to the right sub-skill for any SEO request. |
| `/seo-audit` | Full-site audit (crawls up to 500 pages), fans out to specialist subagents, health score. |
| `/seo-page` | Deep single-page analysis (on-page, meta, schema, images, performance). |
| `/seo-plan` | Strategic SEO plan: industry templates, competitive analysis, roadmap. |
| `/seo-technical` | Crawlability, indexability, security, URLs, mobile, Core Web Vitals, JS rendering, IndexNow. |
| `/seo-content` | Content quality + E-E-A-T, readability, thin-content and AI-citation readiness. |
| `/seo-content-brief` | Competitive content briefs with per-section word counts + keyword guidance. |
| `/seo-schema` | Detect, validate, and generate Schema.org JSON-LD. |
| `/seo-sitemap` | Validate existing XML sitemaps or generate new ones from industry templates. |
| `/seo-images` | Alt text, file size, formats, lazy loading, CLS, WebP/AVIF conversion, image SERPs. |
| `/seo-image-gen` | Generate OG/social/hero/schema images (via the `banana` extension). |
| `/seo-local` | Local SEO: GBP, NAP consistency, citations, reviews, local schema, multi-location. |
| `/seo-maps` | Maps intelligence: geo-grid rank tracking, GBP audit, review velocity, competitor radius. |
| `/seo-geo` | GEO: AI Overviews, ChatGPT, Perplexity, Copilot — crawler access, llms.txt, citability. |
| `/seo-sxo` | Search-experience optimization — SERP-backwards analysis, intent mismatch, persona scoring. |
| `/seo-cluster` | SERP-overlap semantic clustering → hub-and-spoke architecture + internal link matrix. |
| `/seo-competitor-pages` | Generate "X vs Y" / "alternatives to X" comparison pages. |
| `/seo-programmatic` | Programmatic SEO at scale: templates, URL patterns, thin-content and index-bloat guards. |
| `/seo-hreflang` | Hreflang / international SEO audit, validation, and generation. |
| `/seo-drift` | Baseline + diff SEO-critical elements to catch regressions ("git for SEO"). |
| `/seo-backlinks` | Backlink profile, anchor distribution, toxic links, competitor link gap. |
| `/seo-ecommerce` | Product schema, Google Shopping / Amazon visibility, pricing gaps. |
| `/seo-flow` | FLOW framework (Find → Leverage → Optimize → Win) stage-specific prompts. |
| `/seo-google` | Google APIs: Search Console, PageSpeed, CrUX field data, Indexing API, GA4 organic. |

**Extensions** (all 8 install by default; each needs its own API key/MCP server, none of
which are stored in this repo):

| Skill | Provider |
|---|---|
| `/seo-dataforseo` | DataForSEO — live SERPs, keyword metrics, backlinks, AI visibility. |
| `/seo-ahrefs` | Ahrefs API — referring domains, organic keywords, content explorer. |
| `/seo-seranking` | SE Ranking — AI Share-of-Voice across 5 AI platforms in one query. |
| `/seo-profound` | Profound — time-series LLM brand-citation tracking. |
| `/seo-bing` | Bing Webmaster Tools + IndexNow URL submission. |
| `/seo-firecrawl` | Firecrawl — full-site crawl/scrape/map with JS rendering. |
| `/seo-unlighthouse` | Unlighthouse CLI — multi-page Lighthouse without API quota. |

**Subagents** installed into `~/.claude/agents/` (spawned by the skills above, not invoked
directly): `seo-backlinks`, `seo-cluster`, `seo-content`, `seo-dataforseo`, `seo-drift`,
`seo-ecommerce`, `seo-flow`, `seo-geo`, `seo-google`, `seo-image-gen`, `seo-local`,
`seo-maps`, `seo-performance`, `seo-schema`, `seo-sitemap`, `seo-sxo`, `seo-technical`,
`seo-visual`.

## taste-skill (design / image generation)

| Skill | What it does |
|---|---|
| `/design-taste-frontend` | Anti-slop frontend skill (v2 default) — real design systems, audit-first redesigns. |
| `/design-taste-frontend-v1` | Original v1 taste skill (backward-compat). |
| `/high-end-visual-design` | Agency-grade design standards (fonts, spacing, shadows, motion). |
| `/redesign-existing-projects` | Upgrade existing sites/apps to premium quality without breaking them. |
| `/minimalist-ui` | Clean editorial monochrome UI (no gradients/heavy shadows). |
| `/industrial-brutalist-ui` | Swiss-print × military-terminal brutalist interfaces. |
| `/gpt-taste` | GSAP motion + editorial typography engineer (randomized layouts). |
| `/brandkit` | Premium brand-guideline boards, logo systems, identity decks. |
| `/image-to-code` | Generate design images, analyze, then implement to match. |
| `/imagegen-frontend-web` | One horizontal reference image **per section** for web design. |
| `/imagegen-frontend-mobile` | Premium mobile app screen concepts in phone mockups. |
| `/stitch-design-taste` | DESIGN.md generator for Google Stitch (premium UI standards). |
| `/full-output-enforcement` | Bans placeholders; enforces complete, unabridged code output. |

## clerk (auth)

| Skill | What it does |
|---|---|
| `/clerk-setup` | Add Clerk auth to any project via official quickstarts. |
| `/clerk-cli` | **(vendored)** Operate the `clerk` binary — users/orgs/sessions/env/API. |
| `/clerk-backend-api` | Browse & execute Clerk Backend REST API endpoints. |
| `/clerk-orgs` | Clerk Organizations for B2B SaaS (RBAC, multi-tenant). |
| `/clerk-custom-ui` | Custom auth flows + component appearance/theming. |
| `/clerk-nextjs-patterns` | Advanced Next.js patterns (middleware, Server Actions, caching). |
| `/clerk-react-patterns` | React SPA auth (Vite/CRA, hooks, protected routes). |
| `/clerk-testing` | E2E auth-flow testing (Playwright/Cypress). |
| `/clerk-webhooks` | Clerk webhooks for real-time events / data sync. |

## omarchy (Linux desktop)

| Skill | What it does |
|---|---|
| `/omarchy` | Customize Hyprland/Waybar/Walker/terminal/theme config on an Omarchy desktop. |

---

### Adding a new vendored skill to this repo
Drop the skill folder (with its `SKILL.md`) into `skills/vendored/<name>/`, commit, and
re-run `./install.sh` — it copies each vendored skill into `~/.claude/skills/`.
