---
name: Feature Request
about: Suggest an idea for NEXUS
title: '[Feature] '
labels: enhancement
assignees: ''
---

## Is Your Feature Request Related to a Problem?

A clear and concise description of what the problem is.

**Example:** _I'm always frustrated when [...]_

## Describe the Solution You'd Like

A clear and concise description of what you want to happen. Be as specific as possible.

**Example for a new agent:**
- Agent name: [e.g., Real Estate Advisor]
- Domain: [e.g., Property analysis]
- Key capabilities: [e.g., Rental yield calculator, neighborhood crime stats, school district analysis]
- Suggested tools: [e.g., web_search, execute_code]

**Example for a platform feature:**
- What it should do
- Where it should appear (UI or API)
- How users would interact with it

## Describe Alternatives You've Considered

A clear description of any alternative solutions or features you've considered and why they don't meet your needs.

## Which Area Does This Affect?

- [ ] New agent / persona
- [ ] Existing agent improvement
- [ ] Core platform / orchestrator
- [ ] UI / frontend
- [ ] API / backend
- [ ] Slack / OpenClaw integration
- [ ] Self-hosting / deployment
- [ ] Documentation
- [ ] Performance
- [ ] Security

## Local-First Compatibility

NEXUS is designed to be **100% self-hostable**. Please consider:

- Would this feature work with **local Ollama models** (no cloud dependency)?
- Would this feature require any **external API calls**?
- Would this feature work in an **air-gapped environment** (`DISABLE_WEB_SEARCH=true`)?
- If cloud-dependent, is there a local alternative?

```
[ ] Works fully offline with Ollama
[ ] Requires cloud API but has a local fallback
[ ] Requires cloud API (no local equivalent)
```

## Additional Context

Add any other context, mockups, screenshots, or examples about the feature request here.

For new agents, include example prompts the agent should handle well:

<details>
<summary>Example prompts (click to expand)</summary>

- Prompt 1: _[...]_
- Prompt 2: _[...]_
- Prompt 3: _[...]_

</details>

## Would You Be Willing to Contribute?

- [ ] Yes, I can help implement this
- [ ] Yes, I can help test this
- [ ] I can provide use cases and feedback
- [ ] No, I'm just suggesting the idea
