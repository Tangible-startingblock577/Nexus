# OpenClaw + Nexus Integration — Setup Guide

This guide walks you through connecting your **OpenClaw persistent AI agent** (running on your Hostinger VPS) to your **Nexus platform** (running at api.saarlabs.in).

## Architecture

```
┌─────────────────┐       HTTPS/API Key       ┌──────────────────────┐
│  OpenClaw       │ ◄──────────────────────► │  Nexus Platform      │
│  (Hostinger VPS)│                           │  (api.saarlabs.in)   │
│                 │  POST /chat               │                      │
│  Telegram ──────┤  GET /tools               │  ┌────────────────┐  │
│  WhatsApp ──────┤  POST /tools/:name        │  │ Orchestration  │  │
│  Slack ─────────┤  GET /context             │  │ Engine         │  │
│  Discord ───────┤  GET /daily-brief         │  │ Legal Agent    │  │
│                 │  GET /projects/alerts      │  │ Stock Broker   │  │
│                 │  POST /memory             │  │ Medical Tools  │  │
│  User ◄─────────┤  POST /push (alerts)      │  │ Context Graph  │  │
│  (Phone/Desktop)│                           │  └────────────────┘  │
└─────────────────┘                           └──────────────────────┘
```

## What This Unlocks

| Capability | Before | After |
|------------|--------|-------|
| **Messaging** | Only via browser | Telegram, WhatsApp, Slack, Discord |
| **Agent Intelligence** | OpenClaw's built-in skills only | 10 specialist agents + orchestration |
| **Tools Available** | Limited built-in tools | 40+ tools (stocks, legal, medical, web, code, etc.) |
| **Memory** | OpenClaw's SOUL.md only | Shared context graph across all surfaces |
| **Proactive Alerts** | None | Daily briefs, project deadline alerts pushed to phone |
| **Response Quality** | Single model | Multi-agent orchestration |

## Prerequisites

1. ✅ Nexus is deployed and running at `https://api.saarlabs.in`
2. ✅ You have SSH access to your Hostinger VPS (IP: 82.29.162.53)
3. ✅ You have a Telegram / WhatsApp / Slack account for messaging

## Step 1: Generate a Shared API Key

Choose a strong random API key — this secures the bridge between OpenClaw and Nexus:

```bash
# Generate a strong key
openssl rand -hex 32
```

Example output: `a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1`

## Step 2: Add the Key to Nexus

Add the key to your Nexus server's `.env` file (on your VPS at `/var/www/saarlabs.in/server/.env`):

```bash
# SSH into your VPS
ssh root@82.29.162.53

# Edit the .env file
nano /var/www/saarlabs.in/server/.env
```

Add this line:
```
NEXUS_OPENCLAW_API_KEY=a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1
```

Then restart Nexus:
```bash
cd /var/www/saarlabs.in
docker compose restart server
```

## Step 3: One-Click OpenClaw Deploy

On your **local machine**, run the deploy script:

```bash
# Make it executable
chmod +x openclaw/deploy-openclaw.sh

# Run with your VPS IP and API key
NEXUS_API_KEY=a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1 \
VPS_IP=82.29.162.53 \
./openclaw/deploy-openclaw.sh
```

The script will:
1. Connect to your Hostinger VPS via SSH
2. Install OpenClaw and its dependencies
3. Generate the SOUL.md config pointing to your Nexus
4. Create a systemd service for auto-start on boot
5. Start the OpenClaw daemon
6. Verify everything is running

## Step 4: Verify the Bridge

### Test from VPS

```bash
ssh root@82.29.162.53

# Test the health endpoint
curl -s https://api.saarlabs.in/api/openclaw/health \
  -H "X-Nexus-Api-Key: YOUR_KEY" | jq .

# Test a chat
curl -s -X POST https://api.saarlabs.in/api/openclaw/chat \
  -H "Content-Type: application/json" \
  -H "X-Nexus-Api-Key: YOUR_KEY" \
  -d '{"message":"What projects am I working on?"}' | jq .
```

### Check OpenClaw Logs

```bash
ssh root@82.29.162.53
journalctl -u openclaw -f
```

## Step 5: Connect Messaging Platforms

Configure OpenClaw to listen on your preferred platforms. Edit the SOUL.md or OpenClaw's config:

**Telegram:**
```bash
# Set your Telegram bot token
openclaw configure --platform telegram --token YOUR_BOT_TOKEN
```

**WhatsApp (via WhatsApp Business API):**
```bash
openclaw configure --platform whatsapp --phone YOUR_NUMBER
```

**Slack:**
```bash
openclaw configure --platform slack --token YOUR_SLACK_TOKEN
```

## Step 6: Test the Full Flow

1. Send a message to your OpenClaw bot on Telegram: *"What's my legal position on 90-day notice period?"*
2. OpenClaw recognizes this as a complex query → forwards to Nexus `/chat`
3. Nexus runs its orchestration engine (Legal Agent + context graph)
4. Nexus returns a structured response → OpenClaw relays it to Telegram
5. The response includes citations, risk analysis, and next steps

## Manual Configuration (Alternative to Deploy Script)

If the one-click script doesn't work for your VPS setup, follow these manual steps:

### 1. Install OpenClaw

```bash
ssh root@82.29.162.53

# Install via npm
npm install -g @openclaw/cli

# Or clone from GitHub
git clone https://github.com/openclaw/openclaw.git /opt/openclaw
cd /opt/openclaw
npm install
```

### 2. Set Up SOUL.md

Copy `openclaw/SOUL.md` to your VPS and update the config values:

```bash
scp openclaw/SOUL.md root@82.29.162.53:/opt/openclaw/

# Edit the config
ssh root@82.29.162.53
nano /opt/openclaw/SOUL.md
```

Update these fields:
- `nexus_api_base`: `"https://api.saarlabs.in/api/openclaw"`
- `nexus_api_key`: `"YOUR_GENERATED_KEY"`

### 3. Create Systemd Service (Auto-Start on Boot)

```bash
ssh root@82.29.162.53

cat > /etc/systemd/system/openclaw.service << 'SERVICE'
[Unit]
Description=OpenClaw Persistent AI Agent — Nexus Bridge
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/openclaw
ExecStart=/usr/local/bin/openclaw daemon --soul /opt/openclaw/SOUL.md
Restart=always
RestartSec=10
Environment=NODE_ENV=production
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable openclaw
systemctl start openclaw
```

### 4. Verify

```bash
systemctl status openclaw
journalctl -u openclaw -f
```

## Testing the API Directly

You can test all bridge endpoints from your local machine:

```bash
# Replace YOUR_KEY with your generated API key
KEY="YOUR_KEY"
BASE="https://api.saarlabs.in/api/openclaw"

# Health check
curl -s "$BASE/health" -H "X-Nexus-Api-Key: $KEY" | jq .

# List tools
curl -s "$BASE/tools" -H "X-Nexus-Api-Key: $KEY" | jq '.tools[].name'

# Chat (simple)
curl -s -X POST "$BASE/chat" \
  -H "Content-Type: application/json" \
  -H "X-Nexus-Api-Key: $KEY" \
  -d '{"message":"Hello! What can you help me with?"}' | jq '.response'

# Chat (complex orchestration)
curl -s -X POST "$BASE/chat" \
  -H "Content-Type: application/json" \
  -H "X-Nexus-Api-Key: $KEY" \
  -d '{"message":"Analyze the current market trends for tech stocks"}' | jq '.response'

# Daily brief
curl -s "$BASE/daily-brief?userId=openclaw_user" -H "X-Nexus-Api-Key: $KEY" | jq .

# Project alerts
curl -s "$BASE/projects/alerts?userId=openclaw_user" -H "X-Nexus-Api-Key: $KEY" | jq .

# Execute a tool directly
curl -s -X POST "$BASE/tools/web_search" \
  -H "Content-Type: application/json" \
  -H "X-Nexus-Api-Key: $KEY" \
  -d '{"query":"latest AI news 2026"}' | jq '.result'
```

## Updating

When you update Nexus (new tools, agents, etc.), the OpenClaw bridge automatically benefits:

```bash
# Update Nexus
cd /var/www/saarlabs.in && docker compose pull && docker compose up -d

# No need to update OpenClaw — the /tools endpoint always returns the latest list
# Restart OpenClaw to pick up any new scheduled tasks from SOUL.md
ssh root@82.29.162.53 "systemctl restart openclaw"
```

## Troubleshooting

| Problem | Likely Cause | Solution |
|---------|-------------|----------|
| `401 Unauthorized` | Wrong API key | Check NEXUS_OPENCLAW_API_KEY in Nexus .env matches the key in SOUL.md |
| `503 Service Unavailable` | OpenClaw bridge not configured | Add NEXUS_OPENCLAW_API_KEY to Nexus .env and restart |
| `Connection refused` | OpenClaw not running | `systemctl restart openclaw` then `journalctl -u openclaw -f` |
| Empty tools list | Server can't import registry | Check Nexus server logs for import errors |
| OpenClaw not starting | Missing dependencies | `apt-get install -y curl git nodejs npm` |
| `ECONNREFUSED` on api.saarlabs.in | VPS firewall or Traefik down | Check `docker ps` and `ufw status` on VPS |

## Security Notes

1. **Keep the API key secret** — anyone with this key can access your Nexus tools
2. **Use HTTPS** — the bridge enforces HTTPS via Traefik on api.saarlabs.in
3. **No user data in logs** — OpenClaw logs are local to your VPS
4. **Rate limiting** — Nexus applies its own rate limits per IP per day
5. **Token efficiency** — The bridge uses non-streaming responses to minimize token usage
