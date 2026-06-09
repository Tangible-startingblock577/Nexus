#!/bin/bash
set -e

echo "🚀 Starting NEXUS Local Deployment Runner..."

# 1. Run Client Tests
echo "🧪 Running client tests..."
cd client
npm test
cd ..

# 2. Run Server Tests
echo "🧪 Running server tests..."
cd server
bun test
cd ..

VPS_IP="82.29.162.53"
VPS_PATH="/var/www/saarlabs.in"

echo "📦 Syncing codebase to remote VPS ($VPS_IP)..."
# Create remote directory
ssh root@$VPS_IP "mkdir -p $VPS_PATH"

# Rsync client source (exclude local node_modules & dist build folder)
rsync -avz --delete --exclude 'node_modules' --exclude 'dist' client/ root@$VPS_IP:$VPS_PATH/client/

# Rsync server source (exclude local node_modules, DBs, and env files)
rsync -avz --delete --exclude 'node_modules' --exclude '.env' --exclude 'nexus_memory.sqlite' server/ root@$VPS_IP:$VPS_PATH/server/

# Rsync WebDB source (exclude local target, git, modules, etc)
# rsync -avz --delete --exclude 'target' --exclude '.git' --exclude '.github' --exclude 'node_modules' ../WebDB/ root@$VPS_IP:$VPS_PATH/WebDB/

# Rsync docker compose file
rsync -avz docker-compose.yml root@$VPS_IP:$VPS_PATH/

echo "🔑 Injecting environment variables to VPS..."
# Read local server/.env and upload it, appending production overrides
cat server/.env > /tmp/nexus_vps_env
echo "" >> /tmp/nexus_vps_env
echo "PORT=6000" >> /tmp/nexus_vps_env
echo "NODE_ENV=production" >> /tmp/nexus_vps_env
echo "FRONTEND_URL=https://saarlabs.in" >> /tmp/nexus_vps_env
echo "OAUTH_REDIRECT_URL=https://api.saarlabs.in/api/auth/oauth" >> /tmp/nexus_vps_env
scp /tmp/nexus_vps_env root@$VPS_IP:$VPS_PATH/server/.env
rm /tmp/nexus_vps_env


echo "🐳 Building and starting Docker containers on VPS..."
ssh root@$VPS_IP "
  cd $VPS_PATH
  docker compose down --remove-orphans
  docker compose up --build -d
"

echo "🎉 Deployment successful!"
echo "Once Traefik finishes mapping, verify at:"
echo "Frontend: https://saarlabs.in"
echo "Backend:  https://api.saarlabs.in"
