# NEXUS — Antigravity IDE Superpowers

## Project Identity
**NEXUS** is a multi-persona AI agent platform.
- **5 Personas**: Travel Planner, Genius Friend (Chatbot), Customer Support (RAG), Image Studio, Research Analyst
- **Backend**: `server/` — Bun.js + Hono, port 3001
- **Frontend**: `client/` — Vite + React + Tailwind CSS v4, port 5173
- **Not a monorepo**: server and client are independent, each with their own `.env`, `package.json`, and dev scripts.

## Stack & Rules
- TypeScript everywhere in the server. Use generics on `c.req.json<T>()`, never implicit `any`.
- All LLM calls go through `/server/src/services/openrouter.ts`.
- All image calls go through `/server/src/services/huggingface.ts`.
- Persona routing via `X-Persona` HTTP header.
- SSE streaming using `hono/streaming` — never buffer LLM responses.
- CSS: Tailwind v4 with `@import "tailwindcss"` + `@theme {}` tokens. No `tailwind.config.js`.
- State: Zustand stores in `client/src/stores/`.
- Tests: `bun test` in `server/`. `npm test` (Vitest) in `client/`.

## Environment Files
- `server/.env` — API keys, models, PORT (3001)
- `client/.env` — `VITE_*` vars only (e.g., `VITE_API_URL`, `VITE_APP_NAME`)
- Never commit real keys. Use `.env.example` for templates.

## Superpowers
### Superpower: `new_persona`
When adding a new persona:
1. Create `server/src/agents/<name>.agent.ts` with system prompt + handler
2. Register route in `server/src/router.ts` under the persona's path
3. Add model env var `MODEL_<NAME>` to `server/.env`
4. Create `client/src/personas/<name>/` folder with view component
5. Add persona entry to `client/src/stores/personaStore.ts`
6. Write tests for both agent handler and UI component

### Superpower: `new_service`
When adding a backend service (e.g., web search):
1. Create `server/src/services/<name>.ts`
2. Add required env vars to `server/.env` with comments
3. Write unit test in `server/src/services/<name>.test.ts`
4. Export and import from the relevant agent

### Superpower: `premium_ui`
Every UI component must:
- Use Tailwind utility classes
- Support `data-persona` attribute for dynamic accent color
- Include hover transitions (`transition-all duration-200`)
- Use `glass` utility class for card/panel surfaces
- Be mobile-responsive (flex/grid, sm:/md: breakpoints)

## Automated Testing Rules
- **Always run tests before marking a task done.**
- Server: `cd server && bun test`
- Client: `cd client && npm test`
- Never ship code with failing tests.
- Test file naming: `<name>.test.ts` (server), `<name>.test.jsx` (client)
