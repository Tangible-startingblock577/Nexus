# Contributing to NEXUS

Thank you for your interest in contributing to NEXUS! This document provides guidelines and instructions for contributing to the project.

**NEXUS is still being prepared for public release.** At this stage, contributions are not yet open to the public. This guide serves as the framework for when the repository goes public and for internal contributors.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
  - [Prerequisites](#prerequisites)
  - [One-Command Setup](#one-command-setup)
  - [Manual Setup](#manual-setup)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
  - [Branching](#branching)
  - [Making Changes](#making-changes)
  - [Commit Messages](#commit-messages)
  - [Pull Requests](#pull-requests)
- [Coding Standards](#coding-standards)
  - [TypeScript & JavaScript](#typescript--javascript)
  - [React Components](#react-components)
  - [CSS & Styling](#css--styling)
- [Testing](#testing)
- [Adding a New Agent / Persona](#adding-a-new-agent--persona)
- [Self-Hosting & Local Development](#self-hosting--local-development)
- [Security Guidelines](#security-guidelines)
- [Questions & Support](#questions--support)

---

## Code of Conduct

This project follows a simple principle: **be excellent to each other.** We welcome contributors of all backgrounds and experience levels. Harassment, discrimination, or disrespectful behavior will not be tolerated.

---

## Getting Started

NEXUS is a multi-agent AI orchestration platform built with:
- **Frontend:** React 18, Vite, Framer Motion, Tailwind CSS, Zustand
- **Backend:** Bun.js, Hono, TypeScript
- **Database:** SQLite (better-sqlite3) + optional Supabase pgvector
- **AI Models:** Ollama (local) or OpenRouter (cloud)

The platform is **local-first by design** — everything can run on your own hardware.

---

## Development Setup

### Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| [Bun](https://bun.sh/) | ≥ 1.1 | JavaScript runtime & package manager for the server |
| [Node.js](https://nodejs.org/) | ≥ 18 | Runtime for the client (or use Bun) |
| [Docker](https://docker.com/) | ≥ 24 | Containerized deployment (optional for dev) |
| [Ollama](https://ollama.ai/) | ≥ 0.3 | Local LLM inference (recommended) |

### One-Command Setup

```bash
# 1. Install Ollama and pull models
curl -fsSL https://ollama.ai/install.sh | sh
ollama pull llama3.1:8b
ollama pull nomic-embed-text

# 2. Clone and enter the repository
git clone https://github.com/saarlabs/nexus
cd nexus

# 3. Configure environment
cp .env.example .env
# Edit .env and set:
#   MODEL_CHATBOT=ollama/llama3.1:8b
#   MODEL_EMBEDDINGS=ollama/nomic-embed-text

# 4. Start everything with Docker
docker compose up -d
# Open http://localhost:3000
```

### Manual Setup

If you prefer to run the client and server separately for faster development:

```bash
# Terminal 1: Start Ollama
ollama serve

# Terminal 2: Start the server
cd server
bun install
bun run dev

# Terminal 3: Start the client
cd client
npm install     # or: bun install
npm run dev     # or: bun run dev
```

Open http://localhost:5173 (Vite dev server) and http://localhost:3000 (API server).

---

## Project Structure

```
nexus/
├── client/                    # React frontend (Vite)
│   ├── src/
│   │   ├── components/        # React components
│   │   ├── pages/             # Route pages
│   │   ├── hooks/             # Custom React hooks
│   │   ├── stores/            # Zustand state stores
│   │   ├── services/          # Client-side service modules
│   │   ├── icons/             # Custom SVG icon components
│   │   └── utils/             # Utility functions
│   ├── package.json
│   └── vite.config.js
├── server/                    # Bun.js + Hono backend
│   ├── src/
│   │   ├── core/              # Orchestrator, agent loop, planner
│   │   ├── services/          # Business logic services
│   │   ├── tools/             # Tool registry (40+ tools)
│   │   ├── agents/            # Agent-specific logic
│   │   ├── db/                # Database schema & migrations
│   │   └── router.ts          # API routes
│   ├── scripts/               # Development & debug scripts
│   ├── data/                  # Local data files
│   └── package.json
├── openclaw/                  # OpenClaw Slack bridge agent
├── docker-compose.yml         # Container orchestration
├── Dockerfile                 # Server container
└── README.md                  # Platform overview
```

---

## Development Workflow

### Branching

We follow a simple branch structure:

- `main` — Stable, tested code. Protected branch — PRs only.
- `develop` — Integration branch for features (once project is public).
- `feature/<name>` — Feature branches for active development.
- `fix/<name>` — Bug fix branches.
- `docs/<name>` — Documentation changes.

### Making Changes

1. Create a branch from `main` (or `develop` once public):
   ```bash
   git checkout -b feature/my-feature
   ```

2. Make your changes following the [coding standards](#coding-standards) below.

3. Run tests and typecheck:
   ```bash
   # Client tests (Vitest — the client uses Vite, not tsc)
   cd client && npx vitest run

   # Server typecheck (the server uses TypeScript)
   cd server && npx tsc --noEmit
   ```

4. Commit your changes with a descriptive message (see [Commit Messages](#commit-messages)).

5. Push and open a pull request.

### Commit Messages

We use conventional commit format:

```
<type>(<scope>): <description>

[optional body]
```

**Types:**
- `feat` — New feature or agent
- `fix` — Bug fix
- `docs` — Documentation changes
- `style` — Code style changes (formatting, etc.)
- `refactor` — Code restructuring without feature change
- `test` — Adding or updating tests
- `chore` — Build process, dependencies, tooling

**Examples:**
```
feat(voyage): add Indian passport visa lookup tool
fix(router): handle SSE stream close gracefully
docs(readme): add Ollama local setup section
test(orchestrator): add planner decomposition tests
```

### Pull Requests

When opening a PR:

1. **Title** should follow the conventional commit format.
2. **Description** should explain:
   - What the change does
   - Why it's needed
   - How to test it
3. Add **screenshots** for UI changes.
4. Reference any related **issues**.
5. Ensure all **tests pass** on CI.
6. Keep PRs **focused** — one feature or fix per PR.

---

## Coding Standards

### TypeScript & JavaScript

- **No `any` types** unless absolutely necessary. Use `unknown` and narrow with type guards.
- Prefer `const` over `let`. Prefer `function` declarations over arrow functions for top-level exports.
- Use descriptive variable names. Avoid single-letter names except in loops.
- Use TypeScript strict mode. Define interfaces/types for all function parameters.
- **No unused imports** — clean up before committing.
- **No `console.log`** in committed code. Use the project's logging service for server-side logging.

```typescript
// Good
interface SearchParams {
  query: string;
  maxResults?: number;
}

async function searchWeb(params: SearchParams): Promise<string> {
  const { query, maxResults = 10 } = params;
  // ...
}

// Avoid
async function searchWeb(params: any): Promise<any> {
  // ...
}
```

### React Components

- Use **functional components** with hooks (no class components).
- Keep components **focused** — one responsibility per component.
- Extract reusable UI into `client/src/components/shared/`.
- Use **Framer Motion** for animations consistently.
- Use **Tailwind CSS** for styling — avoid inline styles and CSS modules.
- Use the `isDark` prop pattern for theme support:

```jsx
function MyComponent({ isDark, ...props }) {
  return (
    <div className={`p-4 rounded-xl ${isDark ? 'bg-white/5' : 'bg-black/[0.03]'}`}>
      {/* ... */}
    </div>
  );
}
```

### CSS & Styling

- Use Tailwind utility classes. Avoid custom CSS files.
- For complex animations, use Framer Motion variants.
- Use the project's existing color scheme:
  - Dark mode base: `#020617`
  - Light mode base: `#fdfdfc`
  - Primary accent: indigo (`indigo-400` dark, `indigo-700` light)
  - Success: emerald (`emerald-400` dark, `emerald-700` light)
  - Warning: amber (`amber-400` dark, `amber-700` light)

---

## Testing

We use **Vitest** + **React Testing Library** for tests.

### Running Tests

```bash
# Run all client tests
cd client && npx vitest run

# Run specific test file
cd client && npx vitest run -- src/components/MyComponent.test.jsx

# Watch mode (dev)
cd client && npx vitest
```

### Writing Tests

- Test **behavior**, not implementation. Test what the user sees and interacts with.
- Use `describe`/`it` blocks for organization.
- Mock external services (API calls, browser APIs) with `vi.mock()`.
- Test both dark and light mode where applicable.

```jsx
import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import MyComponent from './MyComponent';

describe('MyComponent', () => {
  it('renders the title in dark mode', () => {
    render(<MyComponent isDark={true} />);
    expect(screen.getByText('Expected Title')).toBeDefined();
  });
});
```

### Test Coverage Goals

- **New components:** At least basic render + interaction tests.
- **Stores:** Test state transitions and actions.
- **Utilities:** Test edge cases and error handling.
- **Hooks:** Test loading, error, and success states.

---

## Adding a New Agent / Persona

Adding a new specialist agent is designed to be straightforward:

### Step 1: System Prompt

Add your persona's system prompt in `server/src/core/prompts.ts`:

```typescript
MY_PERSONA: {
  systemPrompt: `You are a specialist in [domain]. ...`,
  model: process.env.MODEL_MY_PERSONA || 'ollama/llama3.1:8b',
}
```

### Step 2: Model Assignment

Add the model environment variable in your `.env`:

```
MODEL_MY_PERSONA=ollama/llama3.1:8b
```

### Step 3: Tool Configuration

Register persona-specific tools in `server/src/tools/registry.ts` under `TOOLS_BY_PERSONA`.

### Step 4: React View

Create a view component in `client/src/components/`:

```jsx
export default function MyPersonaView({ isDark, onSendMessage, messages }) {
  // ... your UI
}
```

### Step 5: Register the Persona

Add the persona to the personaStore in `client/src/stores/personaStore.js`.

See `server/README.md` and the existing persona implementations for detailed examples.

---

## Self-Hosting & Local Development

NEXUS is designed to be **100% self-hostable**. All contributions should work with local development setups (Ollama + SQLite).

### Using Local LLMs

```env
OLLAMA_BASE_URL=http://localhost:11434
MODEL_CHATBOT=ollama/llama3.1:8b
MODEL_EMBEDDINGS=ollama/nomic-embed-text
```

### Air-Gapped Development

For fully offline development:

```env
DISABLE_WEB_SEARCH=true
OLLAMA_BASE_URL=http://localhost:11434
```

This ensures your changes work in environments with no internet access.

### No Cloud Dependencies

- **All database operations** should work with local SQLite (better-sqlite3). The Supabase pgvector integration is optional — never require it.
- **All LLM operations** should work with Ollama. OpenRouter is an alternative, not a requirement.
- **All file storage** should use local filesystem paths. Avoid hardcoding cloud storage paths.

---

## Security Guidelines

Since NEXUS processes potentially sensitive user data, security is a top priority:

### Data Protection

- **Never log user messages, uploaded file contents, or conversation data.** Log only metadata (timestamps, error codes, agent names).
- **All sensitive tokens** (API keys, Slack tokens, webhook URLs) must be encrypted at rest using AES-256-GCM. See `server/src/services/encryption.ts`.
- **Never expose tokens to the client.** All auth tokens should be exchanged server-side only.
- **Authentication headers** (`X-Nexus-Api-Key`) should be validated on every bridge endpoint.

### Code Security

- **No secrets in code.** Never hardcode API keys, tokens, or passwords. Always use environment variables via `.env`.
- **Input validation.** Validate and sanitize all user inputs on the server side.
- **Dependency auditing.** Before adding a new npm/Bun dependency, check for known vulnerabilities.

### Pull Request Security Checklist

Before submitting a PR, ask yourself:

- [ ] Does this change introduce any new external API calls?
- [ ] Are all secrets and tokens handled via environment variables?
- [ ] Is user data properly isolated (multi-user aware)?
- [ ] Are error messages safe to show to users (no stack traces)?
- [ ] Have I tested this with local-only mode (`DISABLE_WEB_SEARCH=true`)?

---

## Questions & Support

- **Documentation:** Check the `/docs` page within the app and the `README.md` for platform-level questions.
- **Issues:** Once the repository is public, open a GitHub issue for bugs and feature requests.
- **Security issues:** For critical security vulnerabilities, contact the maintainers directly rather than opening a public issue.

---

> **NEXUS is built for the person who values privacy, control, and freedom.** Every contribution should honor that principle. Your code should work equally well on a laptop in a coffee shop (with Ollama, offline) as on a production server (with OpenRouter, cloud-connected).

<p align="center">
  <em>Thank you for helping make NEXUS better.</em>
</p>
