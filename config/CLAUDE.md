## gstack
Use /browse from gstack for all web browsing. Never use mcp__claude-in-chrome__* tools.
Available skills: /office-hours, /plan-ceo-review, /plan-eng-review, /plan-design-review,
/design-consultation, /design-shotgun, /design-html, /review, /ship, /land-and-deploy,
/canary, /benchmark, /browse, /open-gstack-browser, /qa, /qa-only, /design-review,
/setup-browser-cookies, /setup-deploy, /setup-gbrain, /sync-gbrain, /retro, /investigate,
/document-release, /document-generate, /codex, /cso, /autoplan, /pair-agent, /careful,
/freeze, /guard, /unfreeze, /gstack-upgrade, /learn.

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
