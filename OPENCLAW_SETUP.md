# OpenClaw & Notification System — Complete Setup Guide

> **Version:** 1.0 · **Last Updated:** June 2026  
> **Applies to:** Nexus Platform V3 · OpenClaw Bridge v1

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Prerequisites](#2-prerequisites)
3. [Nexus Server Configuration](#3-nexus-server-configuration)
4. [Setting Up OpenClaw on Your VPS](#4-setting-up-openclaw-on-your-vps)
5. [Setting Up Slack Integration](#5-setting-up-slack-integration)
6. [Setting Up Telegram Integration](#6-setting-up-telegram-integration)
7. [Multi-User Notification Routing](#7-multi-user-notification-routing)
8. [How Notifications Flow Through the System](#8-how-notifications-flow-through-the-system)
9. [API Reference for OpenClaw ↔ Nexus](#9-api-reference-for-openclaw--nexus)
10. [User-Facing Setup Guide](#10-user-facing-setup-guide)
11. [Admin Operational Guide](#11-admin-operational-guide)
12. [Security & Encryption](#12-security--encryption)
13. [Troubleshooting](#13-troubleshooting)
14. [Appendix: Environment Variables](#14-appendix-environment-variables)

---

## 1. Architecture Overview

The Nexus notification system has three layers:

```
┌─────────────────────────────────────────────────────────────┐
│                     NEXUS SERVER                             │
│                                                              │
│  ┌─────────────────────┐   ┌──────────────────────────────┐  │
│  │  Scheduled Checker  │   │  Slack OAuth (Multi-Workspace)│  │
│  │  (checkAndCreate-   │   │  - /auth/oauth/slack         │  │
│  │   Notifications)    │   │  - /auth/oauth/slack/callback │  │
│  │  Runs every 60 min  │   │  - /auth/slack/revoke        │  │
│  │                     │   │  - /auth/slack/status        │  │
│  └────────┬────────────┘   └──────────────┬───────────────┘  │
│           │                                │                  │
│           ▼                                ▼                  │
│  ┌──────────────────────────────────────────────────────┐    │
│  │           out_notifications + user_notification_     │    │
│  │           channels tables (SQLite)                   │    │
│  └──────────────────────┬───────────────────────────────┘    │
│                         │                                    │
│              ┌──────────▼──────────┐                        │
│              │  OpenClaw Bridge    │                        │
│              │  (openclaw-bridge.ts)│                       │
│              │  Protected by API   │                        │
│              │  key authentication │                        │
│              └──────────┬──────────┘                        │
│                         │                                    │
└─────────────────────────┼───────────────────────────────────┘
                          │  HTTPS
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   OPENCLAW AGENT (VPS)                       │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  OpenClaw polls every N seconds:                     │   │
│  │  GET /api/openclaw/notifications/pending?userId=X    │   │
│  │  GET /api/openclaw/channels/:userId                  │   │
│  │                                                      │   │
│  │  OpenClaw delivers to user's configured channel:     │   │
│  │  → Slack (via bot_token / webhook_url)               │   │
│  │  → Telegram (via bot token + chat ID)                │   │
│  │                                                      │   │
│  │  OpenClaw marks delivered:                           │   │
│  │  POST /api/openclaw/notifications/:id/ack            │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  Users send messages to OpenClaw via:                       │
│  → Slack DM / channel mention                               │
│  → Telegram DM / group                                      │
│                                                              │
│  OpenClaw forwards to Nexus:                                │
│  POST /api/openclaw/chat  (simple persona)                  │
│  POST /api/openclaw/chat  (orchestration, persona=chatbot)  │
└─────────────────────────────────────────────────────────────┘
```

### Key Concepts

| Term | Description |
|------|-------------|
| **Nexus Server** | The main application server (this repo). Runs the API, database, OAuth flows, and the OpenClaw Bridge. |
| **OpenClaw** | A persistent AI agent running on your Hostinger (or any) VPS. Acts as the bridge between messaging platforms and Nexus. |
| **OpenClaw Bridge** | A REST API within Nexus (`/api/openclaw/*`) that OpenClaw communicates with. Protected by `NEXUS_OPENCLAW_API_KEY`. |
| **Slack OAuth** | Nexus's built-in Slack multi-workspace installation flow. Each user connects their own Slack workspace through the Settings UI. |
| **Scheduled Checker** | `checkAndCreateNotifications()` runs every 60 minutes inside Nexus, checks all active projects, and creates push notifications for overdue/due-soon/stalled items. |
| **`nexux_outgoing_notifications`** | SQLite table that acts as a push notification queue. OpenClaw polls pending notifications from here. |
| **`user_notification_channels`** | SQLite table that stores each user's configured delivery channels (Slack workspace tokens, Telegram chat IDs, etc.). |

---

## 2. Prerequisites

Before you begin, make sure you have:

- **Nexus Server** running (this project) — publicly accessible via HTTPS (not localhost)
- **A VPS** (Hostinger, DigitalOcean, etc.) to run OpenClaw — OpenClaw needs to be able to reach your Nexus server
- **A Slack App** created at [api.slack.com/apps](https://api.slack.com/apps) with OAuth v2 enabled
- **(Optional) A Telegram Bot** created via [@BotFather](https://t.me/botfather)
- **Node.js / Bun** on both the Nexus server and the VPS

---

## 3. Nexus Server Configuration

### 3.1 Environment Variables

Add these to your Nexus server's `.env` file:

```env
# ── OpenClaw Bridge ──
NEXUS_OPENCLAW_API_KEY=your-super-secret-api-key-change-this

# ── Slack OAuth (Multi-Workspace) ──
SLACK_CLIENT_ID=1234567890.1234567890123
SLACK_CLIENT_SECRET=abc123def456ghi789

# ── Token Encryption (at rest) ──
NEXUS_ENCRYPTION_KEY=a-long-random-string-at-least-32-characters

# ── Frontend URL (for OAuth redirects) ──
FRONTEND_URL=https://your-nexus-domain.com
OAUTH_REDIRECT_URL=https://your-nexus-domain.com/api/auth/oauth
```

### 3.2 Generate the Encryption Key

```bash
# Generate a 64-character random key
openssl rand -hex 32
# Or use: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Add the output as your `NEXUS_ENCRYPTION_KEY`.

### 3.3 Verify the Nexus Server Is Running

```bash
# Check the OpenClaw bridge health
curl -H "x-nexus-api-key: your-api-key" https://your-nexus-domain.com/api/openclaw/health

# Expected response:
# { "status": "ok", "service": "openclaw-bridge", "features": ["chat","tools","context",...] }
```

---

## 4. Setting Up OpenClaw on Your VPS

OpenClaw is not part of this repository — it's a separate agent that runs on your VPS. This section explains what OpenClaw needs to do.

### 4.1 What OpenClaw Does

OpenClaw is a persistent AI agent that:

1. **Listens** for incoming messages from users on Slack, Telegram, or WhatsApp
2. **Forwards** those messages to Nexus via the OpenClaw Bridge API
3. **Polls** Nexus for pending notifications every few seconds
4. **Delivers** those notifications to the right user on their preferred channel
5. **Marks** notifications as delivered after successful delivery

### 4.2 OpenClaw Polling Loop

The core of OpenClaw is a polling loop. Here's the pseudocode:

```python
# OpenClaw's main loop (pseudocode)
while True:
    # 1. For each user who has connected a Slack workspace...
    for user_id in get_connected_users():
        
        # 2. Get the user's channel config (bot token, workspace info)
        channels = GET /api/openclaw/channels/{user_id}
        # Header: x-nexus-api-key: <your-key>
        
        # 3. Poll for pending notifications for this user
        notifs = GET /api/openclaw/notifications/pending?userId={user_id}&channel=slack
        # Header: x-nexus-api-key: <your-key>
        
        # 4. Deliver each notification
        for notif in notifs.notifications:
            channel_config = channels.channels[0]  # user's Slack config
            bot_token = channel_config.config_json.bot_token  # Already decrypted by Nexus
            
            # Send to Slack via the bot token
            response = POST https://slack.com/api/chat.postMessage
                Authorization: Bearer {bot_token}
                Body: { channel: channel_config.channel_identifier, 
                        text: notif.title + "\n" + notif.body }
            
            # 5. Mark as delivered
            POST /api/openclaw/notifications/{notif.id}/ack
                Header: x-nexus-api-key: <your-key>
                Body: { status: "delivered" }
    
    sleep(5)  # Poll every 5 seconds
```

### 4.3 OpenClaw Incoming Message Handler

When a user sends a message to OpenClaw on Slack/Telegram:

```python
# OpenClaw receives a Slack message (pseudocode)
def handle_slack_message(slack_user_id, channel_id, text):
    # Map Slack user to Nexus user
    nexus_user_id = slack_to_nexus_user_map[slack_user_id]
    
    # Send to Nexus for orchestration
    response = POST /api/openclaw/chat
        Header: x-nexus-api-key: <your-key>
        Body: {
            "message": text,
            "userId": nexus_user_id,
            "persona": "chatbot"  # Uses multi-agent orchestration
        }
    
    # Send the response back to Slack
    POST https://slack.com/api/chat.postMessage
        Authorization: Bearer {channel_config.bot_token}
        Body: { channel: channel_id, text: response.response }
```

---

## 5. Setting Up Slack Integration

### 5.1 Create a Slack App

1. Go to [https://api.slack.com/apps](https://api.slack.com/apps)
2. Click **"Create New App"** → **"From an app manifest"**
3. Choose a workspace (you can install to any workspace later)
4. Paste this manifest:

```yaml
display_information:
  name: Nexus Notifications
  description: "AI-powered project notifications from Nexus"
  background_color: "#1a1a2e"
features:
  bot_user:
    display_name: nexus
    always_online: false
oauth_config:
  scopes:
    bot:
      - channels:history
      - channels:read
      - chat:write
      - commands
      - incoming-webhook
      - reactions:write
  redirect_urls:
    - https://your-nexus-domain.com/api/auth/oauth/slack/callback
settings:
  event_subscriptions:
    request_url: https://your-openclaw-domain.com/slack/events
    bot_events:
      - message.channels
      - message.im
  interactivity:
    request_url: https://your-openclaw-domain.com/slack/interactions
  org_deploy_enabled: false
```

5. Click **"Create"**
6. Go to **"Basic Information"** → copy **"Client ID"** and **"Client Secret"**
7. Add them to your `.env` as `SLACK_CLIENT_ID` and `SLACK_CLIENT_SECRET`
8. Go to **"Install App"** → **"Install to Workspace"** and authorize

### 5.2 How Slack OAuth Works (Multi-Workspace)

Nexus supports **multi-workspace Slack installation**. Each Nexus user connects their OWN Slack workspace independently.

**The flow:**

```
1. User opens Nexus Settings → clicks "Connect Slack"
2. Browser opens a popup to: /api/auth/oauth/slack?token=<user_token>
3. Server redirects to Slack's OAuth consent screen
4. User selects a Slack workspace and authorizes
5. Slack redirects back to: /api/auth/oauth/slack/callback?code=xxx&state=yyy
6. Server exchanges code for a bot_token (xoxb-...)
7. Server encrypts the bot_token with AES-256-GCM
8. Server stores it in user_notification_channels for that user
9. Redirects to frontend: /auth-callback?slack_success=true&slack_workspace=MyCorp
10. Frontend shows "Connected to MyCorp!" and sends postMessage to SettingsModal
```

### 5.3 User Endpoints (for the Frontend)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/auth/oauth/slack` | GET | Header or `?token=` | Redirect to Slack OAuth consent |
| `/api/auth/slack/status` | GET | Header | Returns `{ connected: true/false, workspace_name }` |
| `/api/auth/slack/revoke` | POST | Header | Disconnects Slack + calls `auth.revoke` API |

### 5.4 Supported Notification Types (Slack)

When a user has Slack connected, they will receive these types of notifications (configurable per user):

| Type | Trigger | Example |
|------|---------|---------|
| **🔴 Overdue** | Project deadline has passed | `🔴 Project Overdue: Tax Filing — 3 day(s) overdue!` |
| **⚠️ Due Soon** | Project deadline within 3 days | `⚠️ Deadline Approaching: Tax Filing — due in 1 day(s)` |
| **💤 Stalled** | No activity for 7+ days | `💤 Stalled Project: Tax Filing — no activity for 14 day(s)` |
| **☀️ Daily Brief** | Daily morning summary (opt-in) | `☀️ Your Nexus Brief — 2 projects due soon, 1 overdue` |

---

## 6. Setting Up Telegram Integration

### 6.1 Create a Telegram Bot

1. Open Telegram and search for [@BotFather](https://t.me/botfather)
2. Send `/newbot` and follow the prompts
3. Save the bot token (looks like `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`)
4. Send `/setprivacy` → choose **"Disable"** so the bot can see all messages in groups

### 6.2 Storing Telegram Config (via API)

Since Telegram doesn't have an OAuth flow like Slack, users configure Telegram manually. Use the OpenClaw Bridge API to store a user's Telegram config:

```bash
# As an admin, store a user's Telegram chat ID
curl -X POST https://your-nexus-domain.com/api/openclaw/channels/user_abc123 \
  -H "x-nexus-api-key: your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "platform": "telegram",
    "channel_identifier": "123456789",  # The user's Telegram chat ID
    "config_json": {
      "bot_token": "123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11",  # Encrypted at rest
      "username": "@john_doe"
    },
    "notify_overdue": 1,
    "notify_deadline": 1,
    "notify_stalled": 1,
    "notify_daily_brief": 1,
    "is_active": 1
  }'
```

> **Note:** The `bot_token` is automatically encrypted by the `encryptConfigFields()` function before being stored in the database.

### 6.3 OpenClaw Telegram Delivery

When OpenClaw polls and finds a notification with `target_channel = 'telegram'`, it should deliver it using the Telegram Bot API:

```python
# OpenClaw delivering a Telegram notification (pseudocode)
def deliver_telegram_notification(chat_id, bot_token, title, body):
    text = f"*{title}*\n\n{body}"
    POST https://api.telegram.org/bot{bot_token}/sendMessage
        Body: { "chat_id": chat_id, "text": text, "parse_mode": "Markdown" }
```

### 6.4 Telegram Schema Support

The `user_notification_channels` table already supports Telegram:

```sql
-- Stored in user_notification_channels:
-- platform = 'telegram'
-- channel_identifier = '123456789'  (Telegram chat ID)
-- config_json = { "bot_token": "enc:...", "username": "@john" }
```

---

## 7. Multi-User Notification Routing

### 7.1 The `user_notification_channels` Table

Each user can have multiple notification channels (e.g., Slack + Telegram):

```
user_notification_channels
┌─────────┬──────────┬──────────────┬──────────────────┐
│ user_id │ platform │ is_active    │ config_json       │
├─────────┼──────────┼──────────────┼──────────────────┤
│ user_1  │ slack    │ 1            │ {bot_token:enc:..}│
│ user_1  │ telegram │ 1            │ {bot_token:enc:..}│
│ user_2  │ slack    │ 1            │ {bot_token:enc:..}│
│ user_3  │ telegram │ 0            │ {bot_token:enc:..}│  ← paused
└─────────┴──────────┴──────────────┴──────────────────┘
```

### 7.2 How Routing Works

When `checkAndCreateNotifications()` runs:

1. It finds all users with active projects
2. For each project, it checks overdue/deadline/stalled status
3. It looks up the user's active channels (`user_notification_channels WHERE user_id = ? AND is_active = 1`)
4. It creates **one notification per active channel** with `target_channel` set to the platform name
5. The notification is stored in `nexux_outgoing_notifications` with `status = 'pending'`

### 7.3 How OpenClaw Routes to the Right User

OpenClaw fetches notifications per-user:

```python
# OpenClaw polls for each connected user
for user_id in all_connected_users:
    # Get notifications for THIS user only
    notifs = GET /api/openclaw/notifications/pending?userId={user_id}&channel=slack
    
    # Get the user's Slack channel config
    channels = GET /api/openclaw/channels/{user_id}
    
    # Find the Slack config
    slack_config = [c for c in channels if c.platform == 'slack'][0]
    
    # Deliver each notification using the user's bot token
    for notif in notifs.notifications:
        send_slack_message(slack_config.bot_token, 
                            slack_config.channel_identifier, 
                            notif)
```

### 7.4 Per-User Notification Toggles

Each channel config has per-notification-type toggles:

| Column | Default | Description |
|--------|---------|-------------|
| `notify_overdue` | 1 | Send overdue project alerts |
| `notify_deadline` | 1 | Send upcoming deadline reminders |
| `notify_stalled` | 1 | Send stalled project alerts |
| `notify_daily_brief` | 0 | Send daily morning brief (opt-in) |
| `is_active` | 1 | Master toggle — 0 to pause all |

Users can update these via the OpenClaw Bridge API:

```bash
# Update notification preferences for a user
curl -X POST https://nexus-server.com/api/openclaw/channels/user_abc123 \
  -H "x-nexus-api-key: your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "platform": "slack",
    "config_json": { ... },
    "notify_overdue": 1,
    "notify_deadline": 0,      # Don't send deadline reminders
    "notify_stalled": 1,
    "notify_daily_brief": 1,   # Send daily brief
    "is_active": 1
  }'
```

---

## 8. How Notifications Flow Through the System

### 8.1 Full End-to-End Flow

```
1. SCHEDULED CHECK (Nexus, every 60 min)
   └─ checkAndCreateNotifications() runs
      ├─ Iterates all users with active projects
      ├─ For each project:
      │   ├─ Overdue? → Create notification (priority: high)
      │   ├─ Due in ≤3 days? → Create notification (priority: normal)
      │   ├─ Stalled ≥7 days? → Create notification (priority: low)
      │   └─ None? → Skip
      ├─ Deduplicates by dedup_key (don't create same notif twice)
      └─ Stores in nexux_outgoing_notifications (status: pending)

2. OPENCLAW POLLS (every ~5 seconds)
   └─ For each user with a configured channel:
      ├─ GET /api/openclaw/channels/{userId}
      │   └─ Returns decrypted bot_token, channel_identifier, etc.
      ├─ GET /api/openclaw/notifications/pending?userId={userId}
      │   └─ Returns pending notifications for this user
      └─ For each notification:
          ├─ Send to Slack/Telegram using the user's bot token
          ├─ POST /api/openclaw/notifications/{id}/ack
          │   └─ Marks as "delivered" in the database
          └─ Removes from pending queue

3. USER REACTS (via Slack/Telegram)
   └─ User sends a message to OpenClaw
      ├─ OpenClaw identifies the user (Slack user ID → Nexus user ID)
      ├─ POST /api/openclaw/chat
      │   ├─ message: user's text
      │   ├─ userId: mapped Nexus user ID
      │   └─ persona: "chatbot" (orchestration)
      ├─ Nexus runs multi-agent orchestration
      ├─ Returns merged response
      └─ OpenClaw sends response back to user on Slack/Telegram
```

### 8.2 Notification Lifecycle

```
created_at               delivered_at
    │                         │
    ▼                         ▼
┌────────┐    ┌─────────┐    ┌──────────┐
│ PENDING │───▶│DELIVERED│───▶│ACKNOWLEDG│
└────────┘    └─────────┘    └──────────┘
     │
     │ (after 30 days auto-deleted)
     ▼
  DELETED
```

### 8.3 Deduplication

Notifications are deduplicated by `dedup_key` (format: `${userId}:${projectId}:${type}`):

- If a pending notification already exists with the same `dedup_key`, a new one is NOT created
- This prevents duplicate alerts for the same project+event combination
- Once a notification is delivered/acknowledged, a new one can be created for the same event
- Old delivered notifications are cleaned up after 30 days

### 8.4 Database Schema Reference

```sql
-- The notification queue
CREATE TABLE nexux_outgoing_notifications (
  id TEXT PRIMARY KEY,
  user_id TEXT DEFAULT 'default',                -- The target user
  target_channel TEXT NOT NULL DEFAULT 'slack',  -- 'slack' | 'telegram' | 'all'
  title TEXT NOT NULL,                            -- Notification title
  body TEXT NOT NULL,                             -- Notification body
  type TEXT NOT NULL DEFAULT 'alert',             -- 'alert' | 'brief' | 'notification' | 'reminder'
  priority TEXT NOT NULL DEFAULT 'normal',        -- 'high' | 'normal' | 'low'
  status TEXT NOT NULL DEFAULT 'pending',         -- 'pending' | 'delivered' | 'failed' | 'acknowledged'
  source TEXT,                                    -- 'scheduler' | 'manual' | 'project_check' | 'daily_brief'
  metadata TEXT,                                  -- Optional JSON
  dedup_key TEXT,                                 -- Unique dedup key
  created_at TEXT NOT NULL,
  delivered_at TEXT,
  error_message TEXT
);

-- Per-user notification channel config
CREATE TABLE user_notification_channels (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  platform TEXT NOT NULL,                         -- 'slack' | 'telegram' | 'email'
  channel_identifier TEXT,                        -- Slack channel ID / Telegram chat ID
  config_json TEXT,                               -- Encrypted bot tokens, webhook URLs
  notify_overdue INTEGER DEFAULT 1,               -- Per-type toggles
  notify_deadline INTEGER DEFAULT 1,
  notify_stalled INTEGER DEFAULT 1,
  notify_daily_brief INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1,                    -- 0 = paused
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE(user_id, platform)
);
```

---

## 9. API Reference for OpenClaw ↔ Nexus

### 9.1 OpenClaw Bridge Endpoints

All OpenClaw Bridge endpoints require the header:

```
x-nexus-api-key: <your NEXUS_OPENCLAW_API_KEY>
```

#### `POST /api/openclaw/chat`

Send a user message to Nexus. Uses multi-agent orchestration when `persona` is `"chatbot"`.

**Request:**
```json
{
  "message": "What are my legal options for 90-day notice?",
  "userId": "user_abc123",
  "persona": "chatbot",            // Uses orchestration (multi-agent)
  "model": "auto",
  "country": "IN",
  "currency": "INR"
}
```

**Response (orchestrated):**
```json
{
  "response": "## Legal Analysis\n\nUnder the Indian...",
  "tasks": [
    { "id": "task_1", "persona": "legal", "goal": "Search BNS notice period law" },
    { "id": "task_2", "persona": "broker", "goal": "Calculate clawback exposure" }
  ],
  "taskResults": {
    "task_1": "Under Section 9 of the BNS...",
    "task_2": "Based on your portfolio of..."
  }
}
```

**Response (single persona):**
```json
{
  "response": "Here's the legal analysis you requested...",
  "persona": "legal",
  "model": "meta-llama/llama-3.3-70b-instruct:free"
}
```

---

#### `GET /api/openclaw/notifications/pending`

OpenClaw polls this endpoint to fetch pending notifications.

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `channel` | string | `"slack"` | Filter by target channel: `"slack"`, `"telegram"`, or `"all"` |
| `limit` | integer | `10` | Maximum notifications to return |
| `userId` | string | `null` | Filter by user ID (returns all if omitted) |

**Response:**
```json
{
  "notifications": [
    {
      "id": "notif_1718000000_abc123",
      "user_id": "user_abc123",
      "target_channel": "slack",
      "title": "🔴 Project Overdue: Tax Filing",
      "body": "\"Tax Filing\" is 3 day(s) overdue! Deadline was Jun 1, 2026.",
      "type": "alert",
      "priority": "high",
      "status": "pending",
      "source": "project_check",
      "metadata": null,
      "created_at": "2026-06-04T10:00:00.000Z",
      "dedup_key": "user_abc123:proj_1:overdue"
    }
  ],
  "total": 1
}
```

---

#### `POST /api/openclaw/notifications/:id/ack`

Mark a notification as delivered/failed.

**Request:**
```json
{
  "status": "delivered",  // "delivered" | "failed" | "acknowledged"
  "error_message": null   // Optional, set if failed
}
```

**Response:**
```json
{
  "success": true,
  "status": "delivered"
}
```

---

#### `GET /api/openclaw/channels/:userId`

Get all notification channel configs for a user. **Bot tokens are automatically decrypted** by the Bridge before being returned.

**Response:**
```json
{
  "channels": [
    {
      "id": "slack_user_abc123",
      "user_id": "user_abc123",
      "platform": "slack",
      "channel_identifier": "C1234567890",
      "config_json": {
        "workspace_name": "My Corp",
        "workspace_id": "T123456",
        "bot_token": "xoxb-1234567890-abc123def456",  // Decrypted!
        "bot_user_id": "U123456",
        "webhook_url": null,
        "scopes": "channels:read,chat:write,channels:history,incoming-webhook"
      },
      "notify_overdue": 1,
      "notify_deadline": 1,
      "notify_stalled": 1,
      "notify_daily_brief": 0,
      "is_active": 1
    }
  ],
  "total": 1
}
```

> **Important:** The `bot_token` and `webhook_url` fields are decrypted by Nexus before being returned. OpenClaw receives them in plaintext and can use them immediately to send messages.

---

#### `POST /api/openclaw/channels/:userId`

Create or update a notification channel config for a user. **Bot tokens are automatically encrypted** by the Bridge before being stored.

**Request:**
```json
{
  "platform": "slack",
  "channel_identifier": "C1234567890",
  "config_json": {
    "workspace_name": "My Corp",
    "bot_token": "xoxb-1234567890-abc123def456",
    "webhook_url": "https://hooks.slack.com/services/..."
  },
  "notify_overdue": 1,
  "notify_deadline": 1,
  "notify_stalled": 1,
  "notify_daily_brief": 0,
  "is_active": 1
}
```

**Response:**
```json
{
  "success": true,
  "id": "slack_user_abc123"
}
```

---

#### `DELETE /api/openclaw/channels/:userId/:platform`

Remove a notification channel config for a user.

**Response:**
```json
{
  "success": true
}
```

---

#### `POST /api/openclaw/notify`

Manually create a push notification (for custom integrations or testing).

**Request:**
```json
{
  "target_channel": "slack",
  "title": "🚀 Deployment Complete",
  "body": "Version 2.4.1 has been deployed to production.",
  "type": "notification",
  "priority": "normal",
  "source": "ci_cd_pipeline",
  "metadata": {
    "version": "2.4.1",
    "environment": "production"
  }
}
```

**Response:**
```json
{
  "success": true,
  "id": "notif_1718000000_def456",
  "status": "pending"
}
```

---

#### `GET /api/openclaw/health`

Health check.

**Response:**
```json
{
  "status": "ok",
  "service": "openclaw-bridge",
  "version": "1.0.0",
  "timestamp": "2026-06-04T10:00:00.000Z",
  "features": ["chat", "tools", "context", "daily-brief", "projects", "memory", "push", "notify", "channels"],
  "authenticated": true
}
```

---

#### `GET /api/openclaw/tools`

List all tools available across personas (deduplicated).

**Response:**
```json
{
  "tools": [
    { "name": "web_search", "description": "Search the web...", "parameters": { ... } },
    { "name": "get_stock_price", "description": "Get current stock price...", "parameters": { ... } }
  ],
  "total": 40
}
```

---

#### `GET /api/openclaw/context`

Get context graph for a user.

**Query Params:** `?userId=user_abc123`

**Response:**
```json
{
  "profile": { "user_id": "...", "preferences": "..." },
  "projects": [...],
  "conversations": [...],
  "reminders": [...]
}
```

---

#### `POST /api/openclaw/memory`

Store a conversation memory.

**Request:**
```json
{
  "userId": "user_abc123",
  "persona": "chatbot",
  "role": "user",
  "content": "What's the status of my tax filing project?"
}
```

---

### 9.2 User-Facing Auth Endpoints

These endpoints are used by the frontend (Settings UI) and use the user's `x-auth-token` header:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/oauth/slack` | GET | Initiate Slack OAuth (header or `?token=`) |
| `/api/auth/slack/status` | GET | Check if user has Slack connected |
| `/api/auth/slack/revoke` | POST | Disconnect Slack workspace |
| `/api/auth/slack/callback` | GET | Slack OAuth redirect handler |

**Example: Check Slack connection status**
```bash
curl https://nexus-server.com/api/auth/slack/status \
  -H "x-auth-token: <user-session-token>"
# Response: { "connected": true, "workspace_name": "My Corp", "channel": "C12345" }
```

**Example: Disconnect Slack**
```bash
curl -X POST https://nexus-server.com/api/auth/slack/revoke \
  -H "x-auth-token: <user-session-token>"
# Response: { "success": true, "message": "Slack workspace disconnected.", "revoked_on_slack": true }
```

---

## 10. User-Facing Setup Guide

This section is what you can share with your users.

### 10.1 Connecting Slack (via Settings UI)

1. **Log in** to your Nexus account
2. **Open Settings** (gear icon in the sidebar)
3. **Scroll to "Notifications"** section
4. Click **"Connect"** next to Slack
5. A popup will open showing Slack's authorization screen
6. **Select the Slack workspace** where you want notifications
7. **Choose a channel** (or let Nexus pick the default)
8. Click **"Allow"**
9. The popup will close and you'll see **"Connected — receiving notifications"**
10. You can now receive project alerts directly in Slack!

### 10.2 Managing Slack Connection

- **Reconnect:** Click "Reconnect" if you want to switch to a different workspace
- **Disconnect:** Click "Disconnect" → "Yes, Disconnect" to remove Slack access
- **Check status:** The Settings page automatically shows whether Slack is connected when you open it

### 10.3 Setting Up Telegram (Admin/Manual)

Currently, Telegram connection is managed by the admin. Contact your Nexus administrator to:

1. Provide your **Telegram chat ID** (you can get it by messaging @userinfobot)
2. Request that Slack be enabled for your account
3. The admin will configure it via the OpenClaw Bridge API

### 10.4 What Notifications to Expect

| Notification | When | Example |
|-------------|------|---------|
| 🔴 **Project Overdue** | A project deadline has passed | *"Project Overdue: Tax Filing is 3 day(s) overdue!"* |
| ⚠️ **Deadline Approaching** | Within 3 days of deadline | *"Deadline Approaching: Tax Filing is due in 1 day(s)"* |
| 💤 **Stalled Project** | No activity for 7+ days | *"Stalled Project: Tax Filing — no activity for 14 day(s)"* |
| ☀️ **Daily Brief** | Each morning (if opted in) | *"Your Nexus Brief: 2 projects due soon, 1 overdue"* |

### 10.5 Pausing Notifications

You can temporarily pause all notifications by having an admin update your channel config's `is_active` flag to `0`. No code changes needed — all your settings are preserved.

---

## 11. Admin Operational Guide

### 11.1 Manual Notification Check

Trigger the notification checker immediately (useful for testing):

```bash
curl -X POST https://nexus-server.com/api/openclaw/notifications/check \
  -H "x-nexus-api-key: your-key"
# Response: { "success": true, "pendingCount": 5 }
```

### 11.2 View Pending Notifications

```bash
curl "https://nexus-server.com/api/openclaw/notifications/pending?limit=50" \
  -H "x-nexus-api-key: your-key"
```

### 11.3 View a User's Channel Config

```bash
curl "https://nexus-server.com/api/openclaw/channels/user_abc123" \
  -H "x-nexus-api-key: your-key"
```

### 11.4 Manually Add a Telegram Channel for a User

```bash
curl -X POST https://nexus-server.com/api/openclaw/channels/user_abc123 \
  -H "x-nexus-api-key: your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "platform": "telegram",
    "channel_identifier": "123456789",
    "config_json": {
      "bot_token": "123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11",
      "username": "@john_doe"
    },
    "notify_overdue": 1,
    "notify_deadline": 1,
    "notify_stalled": 1,
    "is_active": 1
  }'
```

### 11.5 Remove a User's Channel

```bash
curl -X DELETE https://nexus-server.com/api/openclaw/channels/user_abc123/slack \
  -H "x-nexus-api-key: your-key"
```

### 11.6 Monitoring Logs

Key log lines to monitor in the Nexus server logs:

```
[Nexus Notifications] Checked 12 user(s) for project alerts.
[Nexus Notifications] Cleaned up 45 old notification(s).
[OpenClaw Bridge] Notification created: id=notif_xxx channel=slack
[OpenClaw Bridge] Notification notif_xxx marked as delivered
[OAuth Slack] Workspace "My Corp" installed by userId=user_abc123
[Slack Revoke] Workspace disconnected for userId=user_abc123 (revoked_on_slack=true)
[Slack Status] Error checking status: ...
```

### 11.7 Database Maintenance

The notification cleanup is automatic:
- Delivered/acknowledged notifications older than **30 days** are deleted on each check
- Pending notifications are preserved until delivered
- The `user_notification_channels` table is only modified by OAuth flows or admin API calls

### 11.8 Cron Job Equivalent

The built-in scheduler runs `checkAndCreateNotifications()` every 60 minutes and also once on startup (with a 30-second delay).

If you want to change the interval, find these lines in `router.ts`:

```typescript
// Run project check every 60 minutes
setInterval(checkAndCreateNotifications, 60 * 60 * 1000);
// Also run once on startup (with a 30s delay)
setTimeout(checkAndCreateNotifications, 30_000);
```

---

## 12. Security & Encryption

### 12.1 Token Encryption at Rest

All sensitive tokens (Slack `bot_token`, `webhook_url`) are encrypted using **AES-256-GCM** before being stored in the database.

**How it works:**
- Each token is encrypted with a **random 16-byte IV** (unique per encryption)
- The key is derived by **SHA-256 hashing** the `NEXUS_ENCRYPTION_KEY` environment variable
- Encrypted values are stored as: `enc:<base64iv>.<base64authTag>.<base64ciphertext>`
- The `enc:` prefix allows the system to detect encrypted vs unencrypted values

**What this means:**
- An attacker with database access **cannot read tokens**
- The encryption key is only in the environment, never in the database
- Backward compatible: unencrypted legacy values are still readable

**To generate a strong encryption key:**
```bash
openssl rand -hex 32
# Output: 7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a
```

### 12.2 Token Exchange During OAuth

When a user connects Slack:
1. User authorizes on Slack's domain (not ours)
2. Slack sends a one-time code to our callback URL
3. Nexus exchanges the code for a `bot_token` via Slack's API
4. The `bot_token` is **immediately encrypted** before storage
5. The plaintext token never touches the database

### 12.3 Token Revocation

When a user disconnects Slack:
1. Nexus calls Slack's `auth.revoke` API to invalidate the token on Slack's side
2. Then deletes the channel config from the database
3. Token is rendered unusable even if someone had a copy

### 12.4 API Key Security

- `NEXUS_OPENCLAW_API_KEY` must be kept secret
- This key grants access to all OpenClaw Bridge endpoints
- Rotate it periodically and update both Nexus and OpenClaw
- The key is passed via the `x-nexus-api-key` header (not in URLs)

### 12.5 OpenClaw Bridge Authentication

All OpenClaw Bridge endpoints are protected by API key middleware:

```typescript
function requireApiKey(c: any): Response | null {
  if (!API_KEY) return c.json({ error: 'Bridge not configured' }, 503);
  const key = c.req.header('x-nexus-api-key');
  if (!key || key !== API_KEY) return c.json({ error: 'Unauthorized' }, 401);
  return null;
}
```

If `NEXUS_OPENCLAW_API_KEY` is not set, all endpoints return **503 Service Unavailable** — the bridge is effectively disabled.

---

## 13. Troubleshooting

### 13.1 "OpenClaw bridge is not configured"

**Error:** `{ error: 'OpenClaw bridge is not configured. Set NEXUS_OPENCLAW_API_KEY in .env' }`

**Fix:** Add `NEXUS_OPENCLAW_API_KEY` to your `.env` file.

---

### 13.2 "Slack integration not configured"

**Error:** Redirected to frontend with `error=Slack+integration+not+configured`

**Fix:** Set `SLACK_CLIENT_ID` and `SLACK_CLIENT_SECRET` in your `.env`.

---

### 13.3 "Invalid OAuth state"

**Error:** Redirected to frontend with `error=Invalid+OAuth+state`

**Fix:**
- The OAuth state expired (10-minute window)
- Try connecting again
- Make sure the frontend and backend use the same domain for cookie/state matching

---

### 13.4 Slack connection shows "Connected" but no notifications arrive

**Checklist:**
1. Does the user have active projects with deadlines?
2. Run the manual notification check:
   ```bash
   curl -X POST https://nexus-server.com/api/openclaw/notifications/check \
     -H "x-nexus-api-key: your-key"
   ```
3. Check pending notifications:
   ```bash
   curl "https://nexus-server.com/api/openclaw/notifications/pending?userId=user_abc123" \
     -H "x-nexus-api-key: your-key"
   ```
4. Verify OpenClaw is polling:
   - Check OpenClaw logs for polling activity
   - Check Nexus logs for notification delivery

---

### 13.5 "Not authenticated" on Slack status check

The `/auth/slack/status` endpoint returns `{ connected: false, error: "Not authenticated" }` when:
- User is not logged in
- The auth token has expired

**Fix:** Log in again to get a fresh token.

---

### 13.6 Multiple users, but all notifications go to one user

**Check:**
1. Does each user have their own `user_notification_channels` entry? Check the database:
   ```sql
   SELECT * FROM user_notification_channels;
   ```
2. Does `checkAndCreateNotifications()` iterate all users? It does — but only users with active projects.
3. Each notification is tagged with the correct `user_id`:
   ```sql
   SELECT user_id, COUNT(*) FROM nexux_outgoing_notifications WHERE status = 'pending' GROUP BY user_id;
   ```

---

### 13.7 OpenClaw can't reach Nexus

**Check:**
1. Is Nexus publicly accessible? `curl https://nexus-server.com/api/openclaw/health`
2. Is the API key correct in OpenClaw's configuration?
3. Is there a firewall blocking the VPS from reaching Nexus?
4. Are HTTPS certificates valid and not expired?

---

### 13.8 Encryption errors in logs

**Error:** `[Encryption] Decryption failed: ...`
**Error:** `[Encryption] NEXUS_ENCRYPTION_KEY not set. Using fallback key`

**Fix:**
- Set `NEXUS_ENCRYPTION_KEY` in `.env` (generate with `openssl rand -hex 32`)
- If the key changes after tokens are already encrypted, existing tokens will fail to decrypt
- In that case, users need to reconnect Slack (re-run OAuth)

---

### 13.9 Notification shows "pending" but never gets delivered

**Check:**
1. Is OpenClaw running and polling?
2. Is the user's bot token valid? (Could have been revoked from Slack's end)
3. Check OpenClaw logs for delivery errors
4. The notification might be filtered by channel type — check `target_channel` matches what OpenClaw is polling

---

### 13.10 Rate limiting from Slack

Slack API has rate limits. If you have many users, OpenClaw should implement backoff:

```python
import time
import requests

def send_slack_notification(bot_token, channel, text):
    for attempt in range(3):
        response = requests.post(
            'https://slack.com/api/chat.postMessage',
            headers={'Authorization': f'Bearer {bot_token}'},
            json={'channel': channel, 'text': text}
        )
        data = response.json()
        
        if data.get('ok'):
            return True
        
        if data.get('error') == 'ratelimited':
            retry_after = int(response.headers.get('Retry-After', 5))
            time.sleep(retry_after)
            continue
    
    return False
```

---

## 14. Appendix: Environment Variables

### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `NEXUS_OPENCLAW_API_KEY` | API key for OpenClaw ↔ Nexus communication | `sk-oc-abc123def456` |
| `SLACK_CLIENT_ID` | Slack App client ID | `1234567890.1234567890123` |
| `SLACK_CLIENT_SECRET` | Slack App client secret | `abc123def456ghi789` |
| `FRONTEND_URL` | Frontend URL for OAuth redirects | `https://nexus.example.com` |
| `OAUTH_REDIRECT_URL` | OAuth callback base URL | `https://nexus.example.com/api/auth/oauth` |

### Recommended

| Variable | Description | Example |
|----------|-------------|---------|
| `NEXUS_ENCRYPTION_KEY` | AES-256-GCM key for token encryption | `a1b2c3d4e5f6...` (64 hex chars) |

### Optional

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Nexus server port | `3001` |
| `DATABASE_URL` | SQLite database path | `./nexus.db` |

---

## Quick Start Summary

```
1. Set environment variables (SLACK_CLIENT_ID, SLACK_CLIENT_SECRET, NEXUS_OPENCLAW_API_KEY)
2. Generate and set NEXUS_ENCRYPTION_KEY
3. Restart Nexus server
4. Create a Slack App with OAuth v2 enabled
5. Add redirect URL: https://your-domain.com/api/auth/oauth/slack/callback
6. Users connect Slack via Settings > Notifications > Connect
7. Set up OpenClaw on VPS to poll /api/openclaw/notifications/pending
8. Notifications flow automatically every 60 minutes
```

---

*For questions or issues, contact the Nexus development team.*
