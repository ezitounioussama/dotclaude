# Skills catalog

79 skills across 4 external packages + 1 vendored skill. Invoke any of them by typing
`/<skill-name>` in Claude Code, or Claude auto-invokes when your request matches.

**How they're installed** (see [`../../skills/managed-skills.json`](../../skills/managed-skills.json)):
- **gstack** → provided by the `gstack` binary (self-registers)
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
