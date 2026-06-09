#!/bin/bash
# =========================================================================
# OpenClaw + Nexus Bridge — One-Click Deploy for Hostinger VPS
# =========================================================================
# This script deploys the OpenClaw persistent AI agent on your Hostinger VPS
# and connects it to your Nexus platform at api.saarlabs.in.
#
# Prerequisites:
#   1. You have a Hostinger VPS with SSH access
#   2. Node.js / Bun is installed on this machine (for local config generation)
#   3. Nexus is already deployed and running
#
# Usage:
#   chmod +x deploy-openclaw.sh
#   ./deploy-openclaw.sh
#
# Environment variables (set before running):
#   VPS_IP=82.29.162.53                    # Your Hostinger VPS IP
#   NEXUS_API_KEY=your-secret-key-here     # Must match NEXUS_OPENCLAW_API_KEY on Nexus server
# =========================================================================

set -e

# ── Config ──────────────────────────────────────────────────────────────────
VPS_IP="${VPS_IP:-82.29.162.53}"
VPS_USER="${VPS_USER:-root}"
VPS_PATH="${VPS_PATH:-/opt/openclaw}"
NEXUS_API_BASE="${NEXUS_API_BASE:-https://api.saarlabs.in/api/openclaw}"
NEXUS_API_KEY="${NEXUS_API_KEY:?ERROR: Set NEXUS_API_KEY — must match NEXUS_OPENCLAW_API_KEY on Nexus server}"
OPENCLAW_VERSION="${OPENCLAW_VERSION:-latest}"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   OpenClaw + Nexus Bridge — Hostinger Deploy                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "🔧 VPS:     $VPS_USER@$VPS_IP"
echo "🔧 Path:    $VPS_PATH"
echo "🔧 Nexus:   $NEXUS_API_BASE"
echo ""

# ── Step 1: Install OpenClaw on VPS ────────────────────────────────────────
echo "📦 Step 1/6: Installing OpenClaw on VPS..."
ssh "$VPS_USER@$VPS_IP" "bash -c '"
  # Install system dependencies
  apt-get update -qq
  apt-get install -y -qq curl git nodejs npm 2>/dev/null

  # Create directory
  mkdir -p $VPS_PATH

  # Install OpenClaw via npm (or clone from GitHub)
  if command -v openclaw &> /dev/null; then
    echo "   OpenClaw already installed, updating..."
    npm update -g @openclaw/cli 2>/dev/null || true
  else
    echo "   Installing OpenClaw CLI..."
    npm install -g @openclaw/cli 2>/dev/null || {
      echo "   npm install failed, cloning from GitHub..."
      if [ ! -d "$VPS_PATH/openclaw" ]; then
        git clone https://github.com/openclaw/openclaw.git $VPS_PATH/openclaw
        cd $VPS_PATH/openclaw
        npm install
      fi
    }
  fi
'"

# ── Step 2: Generate SOUL.md with correct config ────────────────────────────
echo "📝 Step 2/6: Generating SOUL.md configuration..."
cat > /tmp/openclaw_soul.md << SOULMD
# OpenClaw SOUL — Nexus Integration Profile

## Identity
I am an autonomous persistent AI agent running on my Hostinger VPS.
For simple queries I respond directly. For complex multi-agent tasks,
I delegate to the NEXUS platform at $NEXUS_API_BASE.

## Connection
nexus_api_base: "$NEXUS_API_BASE"
nexus_api_key:  "$NEXUS_API_KEY"

## Behavior
- **Simple queries** (weather, time, math, quick facts): Respond directly.
- **Complex queries** (legal, medical, stocks, research): Forward to Nexus via POST /chat.
- **Proactive alerts**: Every morning at 8am, call /daily-brief and /projects/alerts.
- **Tool access**: Use POST /tools/:name on Nexus for specialist tools.
- **Memory**: Sync every interaction to Nexus via POST /memory.

## Scheduled Tasks
1. Daily Brief (8:00 AM): GET /daily-brief
2. Project Check (8:05 AM): GET /projects/alerts
3. Health Check (hourly): GET /health

## Personality
Professional, warm, proactive. Credit Nexus for specialist analysis.
SOULMD

scp /tmp/openclaw_soul.md "$VPS_USER@$VPS_IP:$VPS_PATH/SOUL.md"
rm /tmp/openclaw_soul.md

# ── Step 3: Create systemd service for persistent operation ──────────────────
echo "⚙️  Step 3/6: Creating systemd service for auto-start..."
ssh "$VPS_USER@$VPS_IP" "bash -c '"
cat > /etc/systemd/system/openclaw.service << SERVICE
[Unit]
Description=OpenClaw Persistent AI Agent — Nexus Bridge
After=network.target

[Service]
Type=simple
User=$VPS_USER
WorkingDirectory=$VPS_PATH
ExecStart=$(which openclaw 2>/dev/null || echo /usr/local/bin/openclaw || echo /usr/bin/openclaw) daemon --soul $VPS_PATH/SOUL.md
Restart=always
RestartSec=10
Environment=NODE_ENV=production
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable openclaw.service
'"

# ── Step 4: Configure environment ───────────────────────────────────────────
echo "🔑 Step 4/6: Setting up environment..."
ssh "$VPS_USER@$VPS_IP" "bash -c '"
cat > $VPS_PATH/.env << ENV
NEXUS_API_BASE=$NEXUS_API_BASE
NEXUS_API_KEY=$NEXUS_API_KEY
OPENCLAW_LOG_LEVEL=info
ENV
'"

# ── Step 5: Start the service ───────────────────────────────────────────────
echo "🚀 Step 5/6: Starting OpenClaw service..."
ssh "$VPS_USER@$VPS_IP" "systemctl start openclaw.service"

# ── Step 6: Verify deployment ───────────────────────────────────────────────
echo "✅ Step 6/6: Verifying deployment..."
sleep 3
ssh "$VPS_USER@$VPS_IP" "systemctl status openclaw.service --no-pager"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   ✅ OpenClaw + Nexus Bridge Deployed!                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "   OpenClaw is now running persistently on your Hostinger VPS."
echo "   It will auto-start on system boot."
echo ""
echo "   Commands:"
echo "     View logs:    ssh $VPS_USER@$VPS_IP \"journalctl -u openclaw -f\""
echo "     Restart:      ssh $VPS_USER@$VPS_IP \"systemctl restart openclaw\""
echo "     Status:       ssh $VPS_USER@$VPS_IP \"systemctl status openclaw\""
echo "     Stop:         ssh $VPS_USER@$VPS_IP \"systemctl stop openclaw\""
echo ""
echo "   To test the bridge from your VPS:"
echo "     curl -X POST $NEXUS_API_BASE/chat \\"
echo "       -H \"Content-Type: application/json\" \\"
echo "       -H \"X-Nexus-Api-Key: $NEXUS_API_KEY\" \\"
echo "       -d '{\"message\":\"Hello Nexus, what projects are on track?\"}'"
echo ""
