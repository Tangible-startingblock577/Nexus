<p align="center">
  <img src="https://img.shields.io/badge/status-active%20development-6366f1?style=flat-square" alt="Status" />
  <img src="https://img.shields.io/badge/local--first-✓-10b981?style=flat-square" alt="Local First" />
  <img src="https://img.shields.io/badge/license-MIT-10b981?style=flat-square" alt="License" />
  <img src="https://img.shields.io/badge/stack-Bun.js%2BHono%2BReact-3b82f6?style=flat-square" alt="Stack" />
  <img src="https://img.shields.io/badge/llm-Ollama%20%7C%20OpenRouter-ec4899?style=flat-square" alt="LLM" />
  <img src="https://img.shields.io/badge/ai%20agents-11-f59e0b?style=flat-square" alt="Agents" />
  <img src="https://img.shields.io/badge/deploy-Docker%20%7C%20Bare%20Metal-06b6d4?style=flat-square" alt="Deploy" />
</p>

<h1 align="center">
  ⋆｡°✩ NEXUS ✩°｡⋆
</h1>

<h3 align="center">
  <em>Multi-Agent AI Orchestration Platform — 100% Local & Private</em>
</h3>

<p align="center">
  <strong>Describe a goal. NEXUS dispatches a team of specialist AI agents — in parallel — and delivers one unified answer.</strong><br />
  <strong>Run it entirely on your own machine. No cloud dependency. No data leaves your hardware.</strong>
</p>

<p align="center">
  <a href="#-quick-start"><strong>Quick Start</strong></a> ·
  <a href="#-why-self-host"><strong>Why Self-Host?</strong></a> ·
  <a href="#-local-llm-setup-ollama"><strong>Local LLM Setup</strong></a> ·
  <a href="#-11-specialist-agents"><strong>Agents</strong></a> ·
  <a href="#-the-orchestrator-pipeline"><strong>Orchestrator</strong></a> ·
  <a href="#-architecture"><strong>Architecture</strong></a> ·
  <a href="#-memory--context-graph"><strong>Memory</strong></a>
</p>

---

## ✦ Overview

**NEXUS** is not a chatbot. It is a **multi-agent runtime** where a planner agent decomposes your goals into parallel sub-tasks and dispatches them to specialist agents — a legal researcher, a financial analyst, a career strategist, a medical advisor, a travel architect, an academic tutor, and more — all working simultaneously. Their findings are merged into a single structured response streamed in real-time.

**In plain terms:** Instead of asking one AI to do everything (like ChatGPT), NEXUS has a team of specialist AIs that work together. Tell it what you need, and it figures out which experts to use, runs them all at the same time, and gives you one combined answer.

### ✦ 100% Local & Private by Design

NEXUS is built from the ground up as a **local-first, self-hosted platform**. Unlike every major AI platform, you can run NEXUS entirely on your own machine — no cloud dependency, no data sent to third parties, no vendor lock-in.

| What "Local-First" Means | How NEXUS Delivers |
|---|---|
| **Run on your hardware** | Any machine with Docker or Bun installed — laptop, desktop, Raspberry Pi cluster, or your own server |
| **Use local LLMs** | Connect to [Ollama](https://ollama.ai) running on your machine. Use Llama 3, Mistral, Qwen, DeepSeek, Gemma — any model you want, fully offline |
| **All data stays local** | SQLite databases, uploaded files, conversation history, context graph — everything lives on your machine. No data ever leaves |
| **OpenClaw runs with you** | The Slack bridge agent can run locally alongside NEXUS for a fully self-contained messaging + AI platform |
| **Maximum safety** | No external API calls if you use local LLMs + disable web search. Air-gap capable |
| **Your models, your rules** | No rate limits, no token costs, no censorship (unless you choose it). Run 24/7 with unlimited usage |

### ✦ Why NEXUS?

| | **NEXUS** | **ChatGPT / Claude / Gemini** |
|---|---|---|
| **Architecture** | Multi-agent parallel runtime | Single-agent sequential chat |
| **Can you run it locally?** | ✅ **Yes — 100% self-hosted** with Ollama, Docker | ❌ Cloud-only |
| **LLM Freedom** | Any model via Ollama or OpenRouter — swap models per agent | Vendor locked to one model |
| **Specialists** | 11 domain-tuned agents | One model for everything |
| **Memory** | Persistent cross-session context graph | Session-only or limited recall |
| **Privacy** | **All data stays on your machine** | All data processed on their servers |
| **Execution** | Live SSE trace of all agents at work | Black-box output |
| **Model Strategy** | Model-agnostic — best model per task | Single model, vendor lock-in |
| **India-First** | Legal, finance, career tailored for India | US/Europe centric |
| **Cost** | **Free** (your own compute + free LLMs via Ollama) | Subscription required for advanced features |

---

## ✦ Why Self-Host?

### 🔒 Privacy & Data Sovereignty

When you self-host NEXUS, **every byte stays on your hardware**:
- Conversations and decisions stored in local SQLite databases — never transmitted
- Uploaded documents stay in local file storage — no cloud sync
- Context graph (your profile, preferences, history) lives on your machine
- No telemetry, no analytics pings, no background data collection
- If you use Ollama for LLMs and disable web search, NEXUS can run **completely air-gapped** — no external network connections at all

### 💰 Zero Operating Cost

Self-hosting with Ollama means:
- **No OpenAI/Anthropic subscription** — use free, open-source LLMs
- **No per-token costs** — pay only for electricity and hardware
- **Unlimited usage** — no message caps, no rate limits (only your hardware limits)
- **Run multiple agents simultaneously** — orchestration scales with your hardware

### 🧠 Model Freedom

Swap models per agent dynamically:
- Use a small fast model (Llama 3.1 8B) for the Planner agent (fast decomposition)
- Use a larger model (Mistral Large, Qwen 72B) for Legal Helper (deep reasoning)
- Use a code-specialized model (DeepSeek Coder) for code execution tasks
- Use a multilingual model (Qwen 2.5) for Hindi/regional language queries
- Switch models whenever you want — no vendor lock-in

### ⚡ Local OpenClaw — Your Private AI Bridge

The entire Slack × OpenClaw integration runs locally too:
- Deploy OpenClaw alongside NEXUS on the same machine
- All Slack notifications processed locally — no external API
- Works with Ollama for fast, local message handling
- Fully self-contained messaging + AI orchestration stack

> **NEXUS is designed for the person who values privacy, control, and freedom.** Everyone else's AI runs on someone else's computer. Yours runs on yours.

---

## ✦ Local LLM Setup (Ollama)

NEXUS supports any LLM provider through OpenRouter, but the **recommended setup** is to run entirely locally with [Ollama](https://ollama.ai).

### One-Command Local Setup

```bash
# 1. Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# 2. Pull your models (pick what fits your hardware)
ollama pull llama3.1:8b      # Fast, general purpose (~4.7GB)
ollama pull mistral:7b        # Good reasoning (~4.1GB)
ollama pull qwen2.5:7b        # Multilingual, strong on coding (~4.3GB)
ollama pull nomic-embed-text  # For vector embeddings (~274MB)

# 3. Start NEXUS (see Quick Start below)
docker compose up
```

### Model Configuration

Configure which model each agent uses via environment variables:

```env
# ── Use Ollama (local, free, private) ──
MODEL_CHATBOT=ollama/llama3.1:8b
MODEL_LEGAL=ollama/mistral:7b
MODEL_BROKER=ollama/qwen2.5:7b
MODEL_MEDICAL=ollama/llama3.1:8b
MODEL_PLANNER=ollama/llama3.1:8b        # Orchestrator planner
MODEL_EMBEDDINGS=ollama/nomic-embed-text

# ── Or use OpenRouter (cloud models, pay per token) ──
# OPENROUTER_API_KEY=sk-or-xxx
# MODEL_CHATBOT=openrouter/meta-llama/llama-3.1-8b-instruct
```

### Hardware Requirements

| Setup | RAM | Disk | GPU | Concurrent Agents |
|---|---|---|---|---|
| **Minimal** (8B models) | 16 GB | 10 GB | Not required (CPU works) | 1–2 |
| **Recommended** (8B–70B) | 32 GB | 30 GB | 8 GB VRAM | 3–5 |
| **Power User** (70B+ models) | 64 GB | 100 GB | 24 GB VRAM | 5–11 |

> 💡 **Running on CPU only?** Use quantized models (e.g., `llama3.1:8b-q4_K_M`) — they use ~60% less RAM with minimal quality loss.

### Running Fully Air-Gapped

For maximum security — no internet connection at all:

```bash
# 1. Install everything on an offline machine
# 2. Pull models once while online, then disconnect
# 3. Disable web search in agent config:
DISABLE_WEB_SEARCH=true
# 4. Run with no external dependencies:
docker compose up
```

No telemetry, no API calls, no data leaving your network. **NEXUS becomes a fully self-contained AI platform on your local network.**

---

## ✦ 11 Specialist Agents

| Agent | Domain | Key Capabilities |
|---|---|---|
| **Nexus Assistant** 🧠 | General AI / Life OS | Web search (or local-only mode), project tracking, cross-agent memory synthesis, proactive nudges, daily brief |
| **Voyage Architect** 🗺️ | Travel Planning | Flight search, hotel lookup, itinerary builder, visa info for Indian passports, INR pricing, Indian airline routing |
| **Deep Search** 🔍 | Research & Analysis | Multi-angle parallel research, source synthesis, contradiction detection, timeline builder, export reports |
| **Support Desk** 🎧 | Customer Support | Document Q&A, ticket creation, confidence-aware responses (high/medium/low), Hindi language support |
| **Vision Canvas** 🎨 | Image & Brand Design | AI image generation (FLUX), brand identity creation — palette, logos, taglines, packaging copy, brand kit export |
| **Academic Tutor** 📚 | Education | Socratic drilling, Python code execution, quiz generation, study plans, concept mind maps, flashcards |
| **Medical Core** ❤️ | Health Info *(educational)* | Symptom triage, lab report analysis, drug interaction checks, ICD-10 lookup, Ayurveda guidance |
| **Cinephile Expert** 🎬 | Movies & TV | Personalized recommendations, streaming availability (India), watchlist tracking, regional cinema knowledge |
| **Legal Helper** ⚖️ | Legal Research *(not advice)* | Web-augmented Indian statute & case law search (or local document-only mode), contract audit, compliance scoring |
| **Stock Broker** 📈 | Market Intelligence *(educational)* | Live stock prices (Yahoo Finance), market news, portfolio analysis, NSE/BSE ticker support |
| **Career Navigator** 💼 | Career Strategy | ATS resume audit with scoring, salary benchmarks (INR), mock interviews (STAR), skill gap analysis |

> All agents work identically whether you use local Ollama models or cloud models. The experience is the same — **only the privacy and cost differ.**

---

## ✦ The Orchestrator Pipeline

```
User Goal → Planner Decomposition → Context Assembly
    ↓
Parallel Agent Execution (Promise.all)
    ├── Legal Helper → analyzes notice period rights
    ├── Career Navigator → drafts negotiation strategy
    └── Stock Broker → calculates salary gap & ESOP impact
    ↓
Result Merger → Structured Briefing → Memory Storage → SSE Delivery
```

### How It Works — Step by Step

| Step | What Happens | Technology |
|---|---|---|
| **1. Goal Intake** | User submits a goal via the chat interface | `POST /api/orchestrate` |
| **2. Context Assembly** | NEXUS reads your profile, past conversations, active projects, and uploaded documents | `contextGraphService.buildContextHeader()` |
| **3. Planning** | The Planner agent (LLM) decomposes your goal into 1–4 specialist sub-tasks with dependency tiers | `planGoal()` — works with local or cloud LLM |
| **4. Parallel Execution** | Tasks grouped by tier, executed via `Promise.all()`. Each runs through an agent loop with tool calls | `agentLoop()` — runs entirely on your machine |
| **5. Result Merging** | All outputs collected, LLM called to compile a structured briefing | `mergeResults()` |
| **6. Memory Storage** | Session saved to context graph and conversation history for future reference | Local SQLite + pgvector |

### Key Pipeline Features

- **Real-time streaming** via Server-Sent Events — watch each agent work live with progress indicators
- **Execution trace** — see exactly which agents ran, what tools they used, and what they found
- **Smart early termination** — detects complete answers to exit the loop, saving tokens (relevant even with local models)
- **Tool result caching** — same tool + args within the same request returns cached result
- **Consecutive failure handling** with automatic retries across fallback models
- **Project awareness** — the orchestrator automatically scans for overdue, due-soon, and stalled projects, and injects a check-in task in parallel

---

## ✦ Architecture

```ascii
┌──────────────────────────────────────────────────────────┐
│          YOUR LOCAL MACHINE / SELF-HOSTED SERVER          │
│                                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │              CLIENT (React + Vite)                  │  │
│  │  ┌──────────┐  ┌──────────┐  ┌───────────────┐    │  │
│  │  │  Chat    │  │   Docs   │  │  Integration   │    │  │
│  │  │  Views   │  │  & APIs  │  │  Page (Slack)  │    │  │
│  │  └────┬─────┘  └────┬─────┘  └───────┬───────┘    │  │
│  │       │             │                │             │  │
│  │       └─────────────┼────────────────┘             │  │
│  │                    │                               │  │
│  │   Framer Motion · Tailwind CSS · Zustand            │  │
│  │   React Router · SSE Streaming Client               │  │
│  └──────────────────┬──────────────────────────────────┘  │
│                     │ HTTP / SSE (localhost only!)         │
│                     ▼                                      │
│  ┌────────────────────────────────────────────────────┐  │
│  │              SERVER (Bun.js + Hono)                 │  │
│  │  ┌──────────────┐  ┌────────────────┐  ┌──────┐  │  │
│  │  │   Router     │  │  OpenClaw      │  │Slack │  │  │
│  │  │   (Hono)     │  │  Bridge (local)│  │ OAuth│  │  │
│  │  └──────┬───────┘  └───────┬────────┘  └──────┘  │  │
│  │         │                  │                      │  │
│  │  ┌──────▼──────────────────▼────────────────────┐  │  │
│  │  │               ORCHESTRATOR ENGINE              │  │  │
│  │  │  ┌──────────┐  ┌───────────┐  ┌───────────┐  │  │  │
│  │  │  │ Planner  │  │  Agent    │  │  Context  │  │  │  │
│  │  │  │ (Ollama) │  │  Loop     │  │  Graph    │  │  │  │
│  │  │  └──────────┘  └───────────┘  └───────────┘  │  │  │
│  │  │  Tool Registry · Memory Service · Project     │  │  │
│  │  │  Style Inferrer · Daily Brief                 │  │  │
│  │  └───────────────────────────────────────────────┘  │  │
│  │                                                      │  │
│  │  ┌──────────────┐  ┌────────────────┐  ┌──────────┐│  │
│  │  │   SQLite     │  │   Ollama        │  │  File    ││  │
│  │  │   Database   │  │   (local LLM)   │  │  Storage ││  │
│  │  └──────────────┘  └────────────────┘  └──────────┘│  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──── OpenClaw (runs locally too!) ──────────────────┐  │
│  │  Slack Bridge → Polls notifications → Local agent  │  │
│  │  Simple queries handled locally (no LLM needed)     │  │
│  │  Complex queries → local NEXUS orchestrator         │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

> **Everything in this diagram runs on your local machine.** No cloud services required. No data leaves this boundary.

### Tech Stack — All Self-Hosted

| Layer | Technology | Local Alternative |
|---|---|---|
| **Frontend** | React, Vite, Framer Motion, Tailwind CSS, Zustand, React Router | Bundled with Docker, served locally |
| **Backend** | Bun.js, Hono, TypeScript | Runs on your machine |
| **Database** | SQLite (better-sqlite3) | **Fully local** — no external DB needed |
| **Vector Store** | SQLite + pgvector or Supabase pgvector | **SQLite only** for full local mode; Supabase optional for cloud sync |
| **AI Models** | Ollama (local) or OpenRouter (cloud) | **Ollama recommended** — models run on your GPU/CPU |
| **Embeddings** | Ollama embeddings or OpenAI embeddings | Ollama `nomic-embed-text` — fully local |
| **Auth** | JWT, OAuth 2.0 (Google, GitHub) | Optional — run without auth on localhost |
| **Messaging** | Slack API, OpenClaw bridge agent, Webhooks | OpenClaw runs locally alongside NEXUS |
| **Deployment** | Docker, Docker Compose | One command: `docker compose up` |
| **Speech/Media** | Edge TTS, Groq Whisper, HuggingFace inference | Local TTS + Whisper for offline use |
| **Icons** | Lucide React, @dev.icons/react | Bundled — no external CDN needed |

---

## ✦ Memory & Context Graph

Every interaction feeds into a persistent, cross-agent memory system that every agent reads before responding:

| Layer | Storage | What It Stores | Superpower |
|---|---|---|---|
| **Episodic** | SQLite (local) | Conversation summaries, decisions, topics explored | _"Last time you evaluated job offers, you prioritized work-life balance over salary"_ |
| **Semantic** | Vector embeddings (local SQLite) | Uploaded documents, stated preferences, recurring goals | Silent context injection before every agent response |
| **Procedural** | SQLite (local) | Cross-agent action history — legal queries, portfolio analyses, itineraries | Cross-domain synthesis no other tool offers |
| **Profile** | Inferred (SQLite, local) | Communication style, risk appetite, decision patterns | Adapts tone, depth, and structure to you over time |

> All four layers are stored **locally on your machine**. Nothing is sent to external servers. Your memory is yours.

### What This Enables

- **Cross-agent memory synthesis**: _"Based on your legal query last week and your portfolio analysis, here's what to watch for in your ESOP clause."_
- **Proactive nudges**: _"You haven't revisited your apartment search in 5 days and the deadline is approaching."_
- **Decision pattern mirroring**: _"When you evaluated your last 3 job offers, stability consistently ranked above salary. Here's how this offer compares."_
- **Style echo**: After enough conversations, the agent adapts to your communication style.

**NEXUS gets smarter the more you use it.** Every new interaction compounds the system's knowledge. Switch between agents seamlessly — they all read from and write to the same context graph. All of it stays local.

---

## ✦ Slack × OpenClaw Integration — Runs Locally Too

NEXUS integrates with **Slack** through **OpenClaw** — a persistent AI agent that bridges messaging platforms with multi-agent orchestration. **OpenClaw runs alongside NEXUS on the same machine.**

### What You Can Do from Slack

- Send a DM to OpenClaw with any question — legal, financial, medical, travel
- Use the `/nexus` slash command in any Slack channel to summon specialist agents
- Receive proactive alerts for overdue projects and approaching deadlines
- Get a daily morning briefing with project status and market updates
- Switch between web app and Slack seamlessly — conversations are remembered
- **All messages processed locally** — OpenClaw uses the same Ollama instance as NEXUS

### Local Architecture Flow

```ascii
Slack App (your workspace) → OpenClaw Bridge (your machine)
    ↓
Simple queries handled locally (greeting, weather) → instant response
Complex queries → NEXUS Orchestrator (your machine)
    ↓
Multi-agent parallel execution using your local Ollama models
    ↓
Merged briefing streamed back to Slack via your local bridge
```

### Notification System

| Type | Trigger | Frequency |
|---|---|---|
| **Overdue Alerts** | Project past its deadline | On detection (every 60-min cycle, local scheduler) |
| **Deadline Reminders** | Project due within 3 days | Once per day |
| **Stalled Project Alerts** | No activity for 7+ days | Once per day |
| **Daily Briefing** | Morning summary (projects, reminders, market) | 8 AM daily |
| **Evening Summary** | End-of-day recap | 6 PM daily |

### Security — End-to-End Local

- All bot tokens and webhook URLs encrypted at rest with **AES-256-GCM**
- Slack OAuth tokens exchanged server-side, never exposed to the client
- HMAC-SHA256 signature verification for Slack slash commands
- Anti-replay protection (5-minute timestamp window)
- Multi-workspace: each Nexus user connects their own Slack workspace independently
- **Zero external data transmission** when using local models

---

## ✦ Quick Start

### Option 1: Try the Web App (Quickest)

1. **Visit** the NEXUS homepage
2. **Choose an agent** from the sidebar (Legal Helper, Stock Broker, etc.) or just type a complex goal
3. **Watch agents work** — responses stream in real-time with live execution trace
4. **Login** for unlimited access (10 messages/day without login)
5. **Connect Slack** from Settings → Notifications to get proactive alerts

> The hosted version uses OpenRouter for LLMs. For full privacy and local control, use Option 2.

### Option 2: Self-Host with Docker (Recommended)

Get the full local experience — all data stays on your machine:

```bash
# 1. Install Docker & Docker Compose
#    (https://docs.docker.com/engine/install/)

# 2. Clone the repository
git clone https://github.com/saarlabs/nexus
cd nexus

# 3. Install Ollama and pull models
curl -fsSL https://ollama.ai/install.sh | sh
ollama pull llama3.1:8b
ollama pull nomic-embed-text

# 4. Configure .env — point to your local models
cp .env.example .env
# Set: MODEL_CHATBOT=ollama/llama3.1:8b
# Set: MODEL_EMBEDDINGS=ollama/nomic-embed-text

# 5. Launch everything
docker compose up -d
```

Open `http://localhost:3000` in your browser. **That's it. You're running your own local multi-agent AI platform.**

### Option 3: Local Development (Full Control)

```bash
# Terminal 1: Start Ollama (if using local models)
ollama serve

# Terminal 2: Start NEXUS server
cd server
bun install
bun run dev

# Terminal 3: Start NEXUS client
cd client
npm install
npm run dev
```

### Environment Variables

```
# ── Required ──────────────────────────────────
# Pick ONE LLM provider:
#   Ollama (local, free, private):
OLLAMA_BASE_URL=http://localhost:11434
MODEL_CHATBOT=ollama/llama3.1:8b
#   OR OpenRouter (cloud, pay per token):
# OPENROUTER_API_KEY=sk-or-xxx

# ── Optional (extended features) ──────────────
DISABLE_WEB_SEARCH=false        # Set true for fully air-gapped operation
TAVILY_API_KEY=                 # Web search (1000 free queries/month)
NEXUS_OPENCLAW_API_KEY=         # Slack integration bridge auth (runs locally)
SLACK_CLIENT_ID=                # Slack OAuth (optional for local-only)
SLACK_CLIENT_SECRET=            # Slack OAuth (optional for local-only)
GOOGLE_CLIENT_ID=               # Google OAuth (optional for local-only)
GOOGLE_CLIENT_SECRET=           # Google OAuth (optional for local-only)
MODEL_PLANNER=                  # Override default LLM model per component
MODEL_LEGAL=
MODEL_BROKER=
MODEL_EMBEDDINGS=ollama/nomic-embed-text    # Local embeddings model
```

---

## ✦ Running Fully Air-Gapped

For environments with zero internet access (secure facilities, remote locations, air-gapped networks):

```bash
# 1. On an internet-connected machine, download:
#    - NEXUS source code
#    - Docker images (docker save/load)
#    - Ollama models (ollama pull)
# 2. Transfer everything via USB drive
# 3. On the air-gapped machine:
DISABLE_WEB_SEARCH=true
docker compose up
```

**Result:** A fully functional multi-agent AI platform with zero external network dependencies. All LLM inference, vector embeddings, storage, and tools run entirely on the local machine.

---

## ✦ API Endpoints

### Chat & Orchestration

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/chat` | Chat with a specialist agent (SSE streaming). Header: `X-Persona` |
| `POST` | `/api/orchestrate` | Multi-agent orchestration — dispatches specialists in parallel (SSE) |
| `POST` | `/api/image` | Generate an AI image from a text prompt |
| `GET` | `/api/stats` | Public platform statistics |

### Context Graph & Memory (all local)

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/context` | Get user profile, projects, conversations, reminders |
| `GET` | `/api/context/graph` | Enriched graph data with relationships for visualization |
| `POST` | `/api/context/profile` | Create/update user communication style and preferences |
| `POST` | `/api/context/reminders` | Create a reminder |
| `GET` | `/api/daily-brief` | Generate personal daily brief |

### Slack & OpenClaw Bridge (local)

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/openclaw/chat` | Send message for orchestration from OpenClaw |
| `GET` | `/api/openclaw/tools` | List all 40+ tools |
| `GET` | `/api/openclaw/context` | Get user context graph |
| `GET` | `/api/openclaw/daily-brief` | Generate daily brief |
| `POST` | `/api/openclaw/notify` | Create push notification for delivery |

### File Processing (all local)

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/upload` | Upload file (PDF, image, DOCX, CSV, etc.) — parses, chunks, embeds, and analyzes |
| `GET` | `/api/files/:id/download` | Download original uploaded file |
| `GET` | `/api/files/:id/preview` | Preview file in browser |
| `POST` | `/api/files/query` | Query uploaded documents (RAG) |

---

## ✦ Documentation

| Resource | What You'll Find |
|---|---|
| **`/docs` page** | Full user guide with Simple & Technical modes — agents, orchestrator, memory, local setup, Slack integration |
| **`/integration` page** | Complete Slack × OpenClaw interactive guide with live flow simulator |
| **`README.md`** | *(you are here)* — platform overview, architecture, quick start, local setup |
| **`NEXUSV3.0.md`** | Complete product strategy — persona definitions, market positioning (internal doc) |
| **`USER_MANUAL.md`** | Detailed user manual for end-users |
| **`OPENCLAW_SETUP.md`** | Deployment guide for the OpenClaw Slack bridge |
| **`openclaw/SETUP.md`** | Technical setup instructions for the OpenClaw agent |

---

## ✦ Limitations & Honesty

- **Legal Helper** uses web search (if enabled) or local document analysis to find legal information. It does **not** have a built-in database of Indian statutes. Always verify important legal matters with a qualified advocate.
- **Stock Broker** provides educational market data via Yahoo Finance. Not a dedicated Bloomberg terminal or SEBI database. Do **not** make investment decisions solely on AI advice.
- **Medical Core** provides educational health information **only**. Not a substitute for professional medical advice, diagnosis, or treatment.
- **File uploads** are limited to 20MB per file. Supported: PDF, TXT, CSV, MD, JSON, DOCX, images (JPG, PNG, GIF, WebP).
- **Ollama performance** depends on your hardware. Larger models (70B+) require significant RAM/VRAM. Quantized models are recommended for resource-constrained setups.
- **Web search** (Tavily API) requires internet access. Disable with `DISABLE_WEB_SEARCH=true` for fully local operation.
- **Image generation** (FLUX) currently requires an external API. When running locally, use the Vision Canvas persona for text-based brand guidance.
- **Model fallbacks**: If using Ollama and it's not running, the platform will return an error. Ensure `ollama serve` is running before starting NEXUS.

---

## ✦ Repository & Open Source

This repository is currently under active development and being prepared for public release under the **MIT License**.

**Coming soon:**
- [ ] Public repository launch with contributor guidelines
- [ ] Enhanced self-hosting documentation
- [ ] One-command installer (curl | sh)
- [ ] Plugin system for custom personas
- [ ] CLI tool for headless operation
- [ ] Pre-built Docker images for Raspberry Pi / ARM64

> 🚀 **The code is being prepared for open-source release.** The MIT license gives you freedom to use, modify, and distribute NEXUS for any purpose — personal, commercial, or educational.

---

## ✦ Security

- **All data stays local** — SQLite databases, uploaded files, context graph — everything on your machine
- **No telemetry** — NEXUS does not phone home. No analytics, no crash reports, no usage data
- **Encryption at rest** — all sensitive tokens (Slack bot tokens, webhook URLs) encrypted with AES-256-GCM
- **API key authentication** — bridge endpoints require `X-Nexus-Api-Key` header
- **Slack OAuth tokens** exchanged server-side, never exposed to the client
- **HMAC-SHA256 signature verification** for Slack slash commands with anti-replay protection
- **Air-gap capable** — with `DISABLE_WEB_SEARCH=true` and local LLMs, NEXUS requires zero network connectivity

> **Self-hosting is the most secure way to use NEXUS.** When you run everything locally, there's no data to intercept, no server to breach, no third-party to trust. Your AI platform. Your hardware. Your data. Your rules.

---

## ✦ Acknowledgments

- **AI Models**: [Ollama](https://ollama.ai/) — run LLMs locally, fully offline. [OpenRouter](https://openrouter.ai/) — cloud model access when needed
- **Icons**: [Lucide](https://lucide.dev/) and [@dev.icons](https://dev.icons/)
- **UI Animations**: [Framer Motion](https://www.framer.com/motion/)
- **Messaging**: [Slack API](https://api.slack.com/)
- **Inspiration**: The open-source AI community. NEXUS is built on the shoulders of Llama, Mistral, Qwen, DeepSeek, and the entire Ollama ecosystem.

---

<p align="center">
  <strong>Built by Saar Labs</strong><br />
  <em>India's first fully self-hostable multi-agent AI orchestration platform</em><br />
  <em>Run it anywhere. Own everything. Trust nothing but your own hardware.</em>
</p>

<p align="center">
  <a href="https://saarlabs.in"><strong>saarlabs.in</strong></a> ·
  <a href="https://ollama.ai"><strong>Ollama</strong></a>
</p>
