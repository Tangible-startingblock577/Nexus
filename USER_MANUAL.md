# NEXUS User Manual

## For Everyone

Welcome to NEXUS — a multi-agent AI platform where specialist AI agents work together to solve your problems. Think of it like having a team of expert assistants at your fingertips: a lawyer, an accountant, a travel agent, a tutor, a researcher, and more — all working together, all remembering your preferences, and all free to use.

---

## Quick Start (For Non-Tech Users)

### 1. Open the App

Visit the NEXUS website. No installation needed. It runs in your browser.

### 2. Try It Without Logging In

You can send up to 10 messages per day without creating an account. Just start typing.

### 3. Choose a Persona

Each "persona" is a specialist AI agent with its own expertise:

| Persona | What It Does |
|---------|-------------|
| **Nexus Assistant** (🤖) | Your main assistant. Handles general questions, web search, project tracking |
| **Voyage Architect** (🗺️) | Plans trips, finds flights, suggests hotels, creates itineraries |
| **Deep Search** (🔍) | Deep research on companies, topics, competitors |
| **Support Desk** (🎧) | Answers customer support questions, searches knowledge bases |
| **Vision Canvas** (🎨) | Generates images and designs using AI |
| **Academic Tutor** (📚) | Helps study, creates quizzes, explains concepts |
| **Medical Core** (⚕️) | Educational medical information, symptom triage, lab analysis |
| **Cinephile Expert** (🎬) | Movie recommendations, streaming info, reviews |
| **Legal Helper** (⚖️) | Finds legal information, reviews contracts, explains laws |
| **Stock Broker** (📈) | Stock prices, market news, investment research |
| **Career Navigator** (💼) | Resume help, interview prep, salary research |

### 4. Or Use the Orchestrator (The Real Magic)

Instead of picking one persona, you can type a complex goal and NEXUS will automatically:
1. **Analyze** what you need
2. **Dispatch** the right specialist agents in parallel
3. **Merge** their findings into one clear answer

Example: *"My employer wants me to serve 90 days notice but I need to join a new company in 30 days"*

NEXUS will have the Legal Helper, Career Navigator, and Stock Broker all work on this simultaneously and give you a combined answer.

### 5. Log In for Unlimited Access

Create a free account to get:
- Unlimited messages (no daily limit)
- All 10 specialist personas
- Document upload (PDF, images, text)
- Permanent chat history
- Personal context that agents remember across sessions

---

## How It Works (Simple Explanation)

### The Orchestration Engine

NEXUS is different from ChatGPT or Gemini because it uses **multiple AI agents working together** instead of one AI trying to do everything.

```
You type a goal
      ↓
Planner Agent breaks it down
      ↓
Multiple specialist agents work in parallel
      ↓
Results are merged into one clear answer
      ↓
Everything is saved to your personal memory
      ↓
Answer appears in the chat
```

You can actually **watch this happen in real-time** in the Orchestration Playground on the Pricing page. It's like watching a control room where different experts work on your problem simultaneously.

### The Context Graph (Your Personal Memory)

Every time you use NEXUS, the platform remembers:
- **What happened** (your conversations)
- **What you care about** (your preferences, uploaded documents)
- **What agents did** (past actions across all personas)
- **Who you are** (your communication style, risk tolerance)

All of this is stored in your "context graph." Every agent reads this before responding, so NEXUS gets smarter the more you use it.

---

## Detailed Features

### Document Upload

You can upload PDFs, images, and text files. NEXUS will:
1. Extract the text content
2. Split it into searchable chunks
3. Generate AI-powered analysis and summary
4. Store it in your context graph
5. Answer questions about your documents

**How to upload:** Look for the upload button in the chat interface. Select a file (max 20MB), optionally ask a question about it, and NEXUS will analyze it.

### Web Search

Most personas can search the web in real-time. This means they can access current information, news, and data beyond their training. Results include source citations so you can verify.

### Code Execution

The Nexus Assistant and Academic Tutor can write and execute Python and JavaScript code. This is useful for:
- Complex calculations
- Data analysis
- Graphing mathematical functions
- Testing code snippets

---

## For Developers

### Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    React Frontend (Vite)                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │ ChatView │ │Dashboard │ │Playground│ │  Pages   │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
└──────────────────────┬──────────────────────────────────┘
                       │ SSE / REST
┌──────────────────────▼──────────────────────────────────┐
│              Bun.js Backend (Hono)                      │
│                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Orchestrator │  │  Agent Loop  │  │  Task Merger │ │
│  │  (plan →     │  │  (tool exec) │  │  (merge all  │ │
│  │   dispatch)  │  │              │  │   results)   │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Context    │  │    Memory    │  │    Router    │ │
│  │    Graph     │  │   Service    │  │  (personas)  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  File Proc.  │  │  Web Search  │  │  Analytics   │ │
│  │   (RAG)      │  │  (Tavily)    │  │  (tracking)  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│              Data Layer                                  │
│  ┌──────────────┐  ┌──────────────┐                     │
│  │   SQLite     │  │  Supabase    │                     │
│  │ (context,    │  │  (users,     │                     │
│  │  projects)   │  │   sessions)  │                     │
│  └──────────────┘  └──────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

### Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18, Vite, Tailwind CSS v4, Framer Motion, Zustand |
| Backend | Bun.js, Hono framework |
| Database | SQLite (local context) + Supabase PostgreSQL (auth/analytics) |
| LLM Providers | OpenRouter (primary), Groq, NVIDIA, Ollama (dev), HuggingFace (fallback) |
| Web Search | Tavily API (primary), ScrapeGraphAI (fallback) |
| Auth | Email/password (bcrypt) + Google OAuth + GitHub OAuth |
| Image Gen | HuggingFace FLUX model |

### Key Files

```
server/src/
├── core/
│   ├── orchestrator.ts     # Multi-agent orchestration engine
│   ├── planner.agent.ts    # Goal decomposition planner
│   ├── task-merger.ts      # Result merging agent
│   ├── agent-loop.ts       # Agentic loop (tool calling, streaming)
│   └── prompts.ts          # System prompts for all personas
├── services/
│   ├── context-graph.ts    # Personal context graph (SQLite)
│   ├── memory.ts           # Conversation memory (Supabase)
│   ├── websearch.ts        # Web search (Tavily + SGAI)
│   ├── fileProcessor.ts    # RAG document pipeline
│   ├── openrouter.ts       # Multi-provider LLM routing
│   ├── analytics.ts        # Usage tracking
│   ├── auth.ts             # Authentication service
│   └── database.ts         # Database abstraction layer
├── tools/
│   └── registry.ts         # Tool definitions by persona
├── router.ts               # All API routes
└── db/
    └── schema.sql          # SQLite schema

client/src/
├── components/
│   ├── ChatView.jsx        # Main chat interface
│   ├── Dashboard.jsx       # Persona dashboard
│   ├── Sidebar.jsx         # Navigation sidebar
│   ├── OrchestrationPlayground.jsx  # Interactive demo
│   ├── OrchestrationTrace.jsx       # Execution trace visualizer
│   ├── BrokerView.jsx      # Stock broker UI
│   ├── LegalView.jsx       # Legal helper UI
│   └── ...                 # Other persona views
├── stores/
│   ├── personaStore.js     # Zustand state management
│   └── authStore.js        # Auth state
├── hooks/
│   ├── useStream.js        # SSE streaming hook
│   └── useOrchestration.js # Orchestration hook
└── pages/
    ├── LandingPage.jsx
    ├── PricingPage.jsx
    ├── AboutPage.jsx
    ├── TeamPage.jsx
    └── AdminDashboard.jsx
```

### How the Orchestrator Works (Technical)

1. **User submits a goal** via `POST /api/orchestrate`
2. **Context assembly**: `contextGraphService.buildContextHeader()` fetches user profile, active projects, conversation history, and procedural logs
3. **Project scan**: `scanProjectsForAttention()` checks for overdue and stalled projects
4. **Planning**: `planGoal()` calls the LLM to decompose the goal into 1-4 specialist sub-tasks, with a rule-based fallback for common patterns (employment + legal + finance)
5. **Parallel execution**: Tasks are grouped into dependency tiers. All tasks in a tier execute concurrently via `Promise.all()`. Each task runs through `agentLoop()` which handles tool calling, streaming, caching, and smart early termination
6. **Result merging**: `mergeResults()` collects all specialist outputs and calls the LLM to compile them into a structured briefing with citations and recommendations
7. **Memory storage**: The session (goal, reasoning, task results, merged output) is saved to the context graph and conversation history
8. **SSE streaming**: All events (plan, task_start, task_done, task_error, merged, done) are streamed to the frontend in real-time

### How the Agent Loop Works (Technical)

The `agentLoop()` function drives each specialist agent through multiple reasoning/tool-execution iterations:

1. **Initialize**: Load persona-specific tools and set max iterations
2. **Stream LLM response**: Connect to the best available LLM provider (OpenRouter → Groq → NVIDIA → HuggingFace)
3. **Parse tool calls**: Extract function calls from the streaming JSON response
4. **Execute tools in parallel**: All detected tools run concurrently with result caching
5. **Feed results back**: Tool outputs are appended to the message history
6. **Repeat** until: complete answer detected, max iterations reached, or report generated
7. **Smart early termination**: Analyzes if the response contains a complete answer with closure phrases

Key features:
- **Tool result caching**: Same tool + arguments within a session returns cached result
- **Multi-provider fallback**: If one LLM fails (rate limit, error), automatically rotates to the next
- **Consecutive failure detection**: After 2 consecutive failures, breaks out to prevent infinite loops
- **Stream resilience**: Graceful handling of incomplete chunks and network drops

### Adding a New Persona

1. Add a system prompt in `server/src/core/prompts.ts`
2. Add a model in `PERSONA_MODELS` in `server/src/router.ts`
3. Add tools in `TOOLS_BY_PERSONA` in `server/src/tools/registry.ts`
4. Create a frontend component in `client/src/components/`
5. Add the persona to `PERSONAS` in `client/src/stores/personaStore.js`

### Self-Hosting (Coming Soon)

The entire NEXUS stack is designed for single-command deployment. When the repository goes public:

```bash
git clone https://github.com/Poi5eN/nexus
cd nexus
docker compose up
```

Open http://localhost:3000 in your browser.

Requirements:
- Docker and Docker Compose
- OpenRouter API key (free tier available)
- (Optional) Tavily API key for web search
- (Optional) Supabase DB URL for persistent auth

### API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/chat` | Chat with a persona (SSE streaming or non-streaming) |
| POST | `/api/orchestrate` | Multi-agent orchestration (SSE streaming) |
| POST | `/api/image` | Generate an image |
| POST | `/api/upload` | Upload and analyze a document |
| GET | `/api/stats` | Platform statistics (public) |
| GET | `/api/context` | User context graph |
| POST | `/api/auth/login` | Login |
| POST | `/api/auth/register` | Register |
| GET | `/api/auth/me` | Verify session |
| POST | `/api/search` | Web search |
| GET | `/api/weather` | Weather data |
| GET | `/api/rates` | Exchange rates |
| GET | `/api/daily-brief` | Daily briefing for user |

---

## FAQ

**Is NEXUS really free?**
Yes. NEXUS is free with a login and always will be. No tiers, no paywalls, no usage limits for logged-in users. Anonymous users get 3 messages/day.

**What makes NEXUS different from ChatGPT?**
ChatGPT is a single AI model. NEXUS uses multiple specialist AI agents that work together in parallel. When you submit a complex goal, a planner decomposes it and dispatches the right experts simultaneously — a lawyer, an accountant, and a career coach, for example — then merges their findings.

**Do I need to install anything?**
No. NEXUS runs entirely in your browser. Just visit the website. Self-hosting will be available when the code is open-sourced.

**Is the code open source?**
Not yet. The repository is being prepared for public release under the MIT license. You can join the waitlist on the Pricing page to be notified when it launches.

**How does the context graph work?**
Your conversations, uploaded documents, preferences, and past agent actions are stored across four memory layers:
- Episodic: what happened (conversation summaries)
- Semantic: what you care about (preferences, documents)
- Procedural: what agents did (past tasks across personas)
- Profile: who you are (communication style, risk tolerance)

Every agent reads this before responding, creating a deeply personalized experience.

**Can I upload my own documents?**
Yes. Upload PDFs, images, and text files. Agents analyze content, extract key insights, and answer questions based on your documents. Supported: PDF, TXT, CSV, MD, JSON, images (JPG, PNG, etc.).

**Is my data private?**
Your conversations, documents, and preferences are stored in your personal context graph. When you self-host, all data stays on your infrastructure. For cloud users, data is stored in encrypted databases.

**What AI models does NEXUS use?**
NEXUS routes requests through OpenRouter, which provides access to dozens of models. Different personas use different models optimized for their domain — Llama, Hermes, Gemini, Qwen, and others. The platform has zero vendor lock-in.

**What are the limitations?**
- Legal Helper uses web search to find legal information — it does NOT have a built-in database of Indian statutes or case law. Always verify with a qualified advocate.
- Stock Broker uses Yahoo Finance for stock prices and web search for news — it is NOT a dedicated Bloomberg terminal or SEBI database.
- Medical Core provides educational information only — NEVER substitute for professional medical advice.
- The open-source version has not been released yet (coming soon).

---

## Troubleshooting

**The chat is not responding**
- Check your internet connection
- Try refreshing the page
- If you're not logged in, check your daily message limit (3/day for anonymous users)

**The orchestrator returned an error**
- The underlying LLM provider may be rate-limited. Try again in a few seconds.
- For complex goals, try simplifying your request.

**Document upload failed**
- Maximum file size: 20MB
- Supported formats: PDF, TXT, CSV, MD, JSON, DOCX, images (JPG, PNG, GIF, WebP)
- If analysis fails, the raw text is still extracted and available

**I see "All LLM endpoints are exhausted"**
This means all AI model providers are temporarily unavailable. This is rare but can happen if free-tier rate limits are hit. Wait a few minutes and try again.

---

## Getting Help

- **Support**: Use the Support Desk persona in the app
- **GitHub**: https://github.com/Poi5eN (code coming soon)
- **Website**: saarlabs.in

---

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for the full release history.
