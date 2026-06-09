---
name: Bug Report
about: Report a bug to help improve NEXUS
title: '[Bug] '
labels: bug
assignees: ''
---

## Describe the Bug

A clear and concise description of what the bug is.

## To Reproduce

Steps to reproduce the behavior:

1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior

A clear and concise description of what you expected to happen.

## Actual Behavior

What actually happened. Include any error messages, unexpected output, or screenshots.

## Screenshots / Logs

If applicable, add screenshots or paste relevant server logs.

<details>
<summary>Server logs (if applicable)</summary>

```
Paste server output here
```
</details>

## Environment

Complete the relevant sections based on how you run NEXUS:

### Self-Hosted (Docker / Local)

- **Deployment method:** Docker / Local development / Other
- **NEXUS version/commit:** [e.g., commit hash or branch]
- **Ollama version (if using local LLMs):** [e.g., 0.3.0]
- **Models in use:** [e.g., llama3.1:8b, mistral:7b]
- **Hardware:** [e.g., 32 GB RAM, 8 GB VRAM, Apple Silicon M2]
- **OS:** [e.g., Ubuntu 24.04, macOS 15.2]
- **Docker version (if applicable):** [e.g., 24.0.7]

### Environment Variables

```
# Paste relevant .env settings (redact secrets):
MODEL_CHATBOT=
MODEL_EMBEDDINGS=
DISABLE_WEB_SEARCH=
OPENROUTER_API_KEY=*** (redacted)
```

### Hosted (Web App)

- **Browser:** [e.g., Chrome 120, Firefox 121]
- **OS:** [e.g., Windows 11, macOS 14]

## Agent / Persona Affected

Which agent/persona exhibits the issue?

- [ ] Nexus Assistant
- [ ] Voyage Architect
- [ ] Deep Search
- [ ] Support Desk
- [ ] Vision Canvas
- [ ] Academic Tutor
- [ ] Medical Core
- [ ] Cinephile Expert
- [ ] Legal Helper
- [ ] Stock Broker
- [ ] Career Navigator
- [ ] Orchestrator (multi-agent)
- [ ] Slack / OpenClaw integration

## Additional Context

- Does this happen consistently or intermittently?
- Does it happen with all LLM providers or just one (e.g., Ollama vs OpenRouter)?
- Does it happen with specific models or all models?
- Were there any recent changes to your setup before the issue appeared?

## Possible Solution (optional)

If you have an idea of what might be causing the issue or how to fix it, describe it here.
