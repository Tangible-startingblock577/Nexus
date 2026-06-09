# OpenClaw + Nexus Bridge — VPS Setup Guide

> **Your setup:** Both Nexus and OpenClaw are already deployed on your Hostinger VPS
> via Docker containers. This guide connects them and adds **Slack** as the primary
> messaging channel (Telegram stays as secondary).

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                Hostinger VPS (82.29.162.53)              │
│                                                          │
│  ┌──────────────────┐      Docker Network      ┌────────┐│
│  │  Nexus Container  │ ◄─────────────────────► │OpenClaw││
│  │  (saarlabs.in)    │  http://nexus-server:3001│Container││
│  │                   │                         │        ││
│  │  /api/openclaw/*  │                         │  Slack ││
│  │                   │                         │  Telgr.││
│  └──────────────────┘                         └────────┘│
│         │                                      │        │
│         ▼                                      ▼        │
│    Public Internet                      Slack API       │
│    (api.saarlabs.in)                   Telegram API     │
└─────────────────────────────────────────────────────────┘
```

---

## Prerequisites

| Item | Status |
|------|--------|
| ✅ Nexus running at saarlabs.in | Already deployed |
| ✅ OpenClaw installed on VPS | Already deployed |
| ✅ SSH access to VPS | You have it |
| ⬜ Slack workspace | You need admin or perms to install apps |
| ⬜ Slack Bot Token | Created in next steps |

---

## Step 1: Generate a Shared API Key

This key secures the OpenClaw ↔ Nexus bridge. Both sides must use the same key.

```bash
# On your local machine, generate a strong key:
openssl rand -hex 32
```

Save the output — it looks like: `a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1`

---

## Step 2: Add the Key to Nexus `.env`

SSH into your VPS and add the key to Nexus's environment:

```bash
ssh root@82.29.162.53

# Navigate to Nexus server directory
cd /var/www/saarlabs.in/server   # adjust path if different

# Edit .env
nano .env
```

Add this line:
```
NEXUS_OPENCLAW_API_KEY=a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1
```

Save and restart Nexus:
```bash
cd /var/www/saarlabs.in
docker compose restart server
```

### Verify the bridge endpoint is live:

```bash
curl -s https://api.saarlabs.in/api/openclaw/health \
  -H "X-Nexus-Api-Key: a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1"
```

Expected response:
```json
{"status":"ok","service":"openclaw-bridge","version":"1.0.0","features":["chat","tools","context","daily-brief","projects","memory","push"]}
```

---

## Step 3: Create a Slack App

You need a Slack Bot token so OpenClaw can read/write messages.

### 3a. Go to the Slack API Console
Open https://api.slack.com/apps in your browser.

### 3b. Create a New App
Click **"Create New App"** → **"From scratch"**

| Field | Value |
|-------|-------|
| App Name | `Nexus Assistant` (or whatever you like) |
| Workspace | Select your workspace |

### 3c. Add Bot Token Scopes
Go to **"OAuth & Permissions"** → **"Scopes"** → **"Bot Token Scopes"**

Add these scopes:
```
app_mentions:read     — Hear when @mentioned
channels:history      — Read channel messages
channels:read         — See channel list
chat:write            — Send messages
chat:write.public     — Send to channels without being invited
im:history            — Read DMs
im:read               — See DM list
im:write              — Initiate DMs
reactions:read        — Read emoji reactions
reactions:write       — Add emoji reactions
users:read            — Know user names
```

### 3d. Install App to Workspace
Click **"Install to Workspace"** → **"Allow"**

### 3e. Copy the Bot Token
After installation, you'll see a **"Bot User OAuth Token"** starting with `xoxb-`.

Copy it — you'll need it in Step 4.

### 3f. Enable Socket Mode (Recommended)
Go to **"Socket Mode"** → **"Enable Socket Mode"**.
Generate an **App-Level Token** with `connections:write` scope.

This lets OpenClaw connect to Slack without exposing a public HTTP endpoint.

### 3g. Subscribe to Bot Events
Go to **"Event Subscriptions"** → **"Subscribe to bot events"**:

Add these events:
```
app_mention          — When someone @mentions the bot
message.im           — When someone DMs the bot
message.channels     — When a message is posted in a channel the bot is in
```

Click **"Save Changes"**, then go back to **"OAuth & Permissions"** and
**"Reinstall to Workspace"** for the event changes to take effect.

---

## Step 4: Configure OpenClaw on Your VPS

SSH into your VPS and configure OpenClaw.

```bash
ssh root@82.29.162.53
```

### 4a. Find the OpenClaw config directory

```bash
ls ~/.openclaw/
# You should see: openclaw.json, workspace/, channels/, etc.
```

### 4b. Configure Slack Channel

```bash
# Use the OpenClaw CLI to log into Slack
openclaw channels login slack

# It will prompt for:
#   1. Bot Token (xoxb-...)  ← paste from Step 3e
#   2. App Token (xapp-...)  ← paste from Step 3f (if using Socket Mode)
#   3. DM Policy (pairing/open) → recommend "pairing" for security
```

Alternatively, manually edit the OpenClaw config:

```bash
nano ~/.openclaw/openclaw.json
```

Add this to the config:
```json
{
  "channels": {
    "slack": {
      "enabled": true,
      "botToken": "xoxb-YOUR-BOT-TOKEN-HERE",
      "appToken": "xapp-YOUR-APP-TOKEN-HERE",
      "dmPolicy": "pairing",
      "allowFrom": ["*"]
    },
    "telegram": {
      "enabled": true,
      "botToken": "YOUR-TELEGRAM-BOT-TOKEN"
    }
  }
}
```

### 4c. Copy the SOUL.md to OpenClaw's workspace

```bash
# If you have the SOUL.md on your local machine, scp it:
# (Run this from your LOCAL machine, not from the VPS)
scp openclaw/SOUL.md root@82.29.162.53:~/.openclaw/workspace/SOUL.md

# Or edit it directly on the VPS:
nano ~/.openclaw/workspace/SOUL.md
```

Make sure the `nexus_api_key` in SOUL.md matches the one you set in Step 2.

Also update the internal Docker URL:
```
nexus_api_base: "http://nexus-server:3001/api/openclaw"
```

---

## Step 5: Configure Docker Network Bridge

Both Nexus and OpenClaw need to be on the same Docker network so OpenClaw can
reach Nexus at `http://nexus-server:3001`.

```bash
ssh root@82.29.162.53

# Check the Nexus container name
docker ps | grep nexus
# Expected: something like "nexus-server" or "saarlabs-server"

# Check what network Nexus is on
docker inspect $(docker ps -q --filter "name=nexus") | jq '.[0].NetworkSettings.Networks | keys'

# Create a shared network if they're not already on the same one
docker network create nexus-bridge

# Connect Nexus to the shared network
docker network connect nexus-bridge nexus-server

# Connect OpenClaw to the shared network
docker network connect nexus-bridge openclaw

# Verify connectivity from inside OpenClaw
docker exec openclaw curl -s http://nexus-server:3001/api/openclaw/health \
  -H "X-Nexus-Api-Key: YOUR_KEY"
```

If `docker exec` doesn't have `curl`, install it:
```bash
docker exec openclaw apt-get update && docker exec openclaw apt-get install -y curl
```

---

## Step 6: Restart OpenClaw

```bash
# Restart OpenClaw to pick up the new config and SOUL.md
docker restart openclaw

# Check logs to verify Slack connected successfully
docker logs openclaw --tail 50
```

Look for lines like:
```
✅ Slack channel connected
✅ Telegram channel connected
🟢 Gateway ready on port 18789
```

---

## Step 7: Verify the Full Flow

### 7a. Test Nexus bridge directly

```bash
# From your local machine:
curl -s -X POST https://api.saarlabs.in/api/openclaw/chat \
  -H "Content-Type: application/json" \
  -H "X-Nexus-Api-Key: YOUR_KEY" \
  -d '{"message":"What projects am I working on?","persona":"chatbot"}' | jq '.response'
```

### 7b. Test Slack → OpenClaw → Nexus

1. Open Slack
2. DM your bot (the app you created in Step 3)
3. Send: `What's my legal position on serving a 90-day notice period?`
4. Expected behavior:
   - OpenClaw receives the DM
   - Identifies this as a legal query
   - Calls `POST /chat` with persona: "legal" on Nexus
   - Nexus's Legal Agent responds with BNS law analysis
   - OpenClaw relays the response back in Slack

### 7c. Test Telegram (still works)

1. Open Telegram
2. DM your bot
3. Send: `daily brief`
4. Expected: OpenClaw calls Nexus `/daily-brief` endpoint and summarizes

### 7d. Test proactive alert

Wait until 8:00 AM, or trigger manually:
```bash
# Manually trigger the morning briefing
docker exec openclaw openclaw agent --message "Run daily brief and project status" --thinking high
```

---

## Step 8: Make It Actually Useful — Suggested First Queries

Send these to your Slack bot to experience the Nexus superpowers:

| Query | What happens |
|-------|-------------|
| `daily brief` | Nexus summarizes projects, reminders, and recent activity |
| `what projects are overdue?` | Nexus queries project alerts → shows deadlines |
| `analyze this stock: RELIANCE` | Nexus broker agent → current price + analysis |
| `what's the latest AI news?` | Nexus research agent → web search + report |
| `help me understand BNS Section 69` | Nexus legal agent → Indian law citation |
| `check drug interaction between aspirin and ibuprofen` | Nexus medical agent → interaction analysis |
| `orchestrate my resume review` | Nexus runs multiple agents → career + legal + research in parallel |

---

## Troubleshooting

### "401 Unauthorized" on Nexus bridge

→ The API keys don't match. Check both places match:
- Nexus `.env`: `NEXUS_OPENCLAW_API_KEY`
- OpenClaw SOUL.md: `nexus_api_key`

### OpenClaw can't reach Nexus at `http://nexus-server:3001`

```bash
# Check they're on the same Docker network
docker network ls
docker inspect nexus-server | jq '.[0].NetworkSettings.Networks'
docker inspect openclaw | jq '.[0].NetworkSettings.Networks'

# If not on the same network, connect them:
docker network connect nexus-bridge nexus-server
docker network connect nexus-bridge openclaw
```

### Slack bot doesn't respond

```bash
# Check OpenClaw logs for Slack errors
docker logs openclaw | grep -i slack

# Verify the token is correct in openclaw.json
cat ~/.openclaw/openclaw.json | grep slack

# Re-authenticate Slack
openclaw channels login slack
```

### Telegram still works but Slack doesn't

→ The SOUL.md routing logic works the same for both channels. Check:
1. Slack token is valid (not expired)
2. Bot is invited to the channel/workspace
3. Socket Mode is enabled (if you're using it)

---

## Commands Reference

```bash
# View OpenClaw logs (real-time)
docker logs -f openclaw

# View Nexus logs
docker logs -f nexus-server

# Restart everything
docker restart openclaw && docker restart nexus-server

# Test bridge health
curl -s https://api.saarlabs.in/api/openclaw/health -H "X-Nexus-Api-Key: YOUR_KEY"

# List all Nexus tools (from OpenClaw)
curl -s https://api.saarlabs.in/api/openclaw/tools -H "X-Nexus-Api-Key: YOUR_KEY" | jq '.tools[].name'

# Re-configure Slack
docker exec -it openclaw openclaw channels login slack
```
