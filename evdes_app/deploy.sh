#!/usr/bin/env bash

set -euo pipefail

# -------- CONFIG --------
REMOTE_USER="lg"
REMOTE_HOST="192.168.0.176"
REMOTE_PATH="/home/lg/Documents/evdes_app"
SERVICE_NAME="evdes-app.service"
APP_PORT="4173"
NODE_VERSION="lts/*"
# ------------------------

REMOTE="$REMOTE_USER@$REMOTE_HOST"

echo "[1/4] Ensuring remote project directory exists..."
ssh "$REMOTE" "mkdir -p '$REMOTE_PATH'"

echo "[2/4] Syncing project files to remote host..."
rsync -av --delete \
  --exclude="node_modules" \
  --exclude="dist" \
  --exclude=".git" \
  --exclude=".DS_Store" \
  ./ "$REMOTE:$REMOTE_PATH"

echo "[3/4] Installing dependencies and building app on remote host..."
ssh "$REMOTE" "
  set -euo pipefail
  export NVM_DIR=\"\$HOME/.nvm\"

  if [ ! -s \"\$NVM_DIR/nvm.sh\" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  fi

  . \"\$NVM_DIR/nvm.sh\"
  nvm install '$NODE_VERSION'
  nvm use '$NODE_VERSION'
  nvm alias default '$NODE_VERSION'

  cd '$REMOTE_PATH'
  npm install
  npm run build
"

echo "[4/4] Creating/updating systemd service and restarting it..."
ssh -tt "$REMOTE" "
  set -euo pipefail
  sudo tee '/etc/systemd/system/$SERVICE_NAME' >/dev/null <<EOF
[Unit]
Description=EVDES Vue App (Vite Preview)
After=network.target

[Service]
Type=simple
User=$REMOTE_USER
WorkingDirectory=$REMOTE_PATH
Environment=NODE_ENV=production
ExecStart=/bin/bash -lc 'source /home/$REMOTE_USER/.nvm/nvm.sh && npm run preview -- --host 0.0.0.0 --port $APP_PORT --strictPort'
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl daemon-reload
  sudo systemctl enable --now '$SERVICE_NAME'
  sudo systemctl restart '$SERVICE_NAME'
  sudo systemctl --no-pager --full status '$SERVICE_NAME' | head -n 20
"

echo "Deployment completed successfully."
echo "Service: $SERVICE_NAME"
echo "URL: http://$REMOTE_HOST:$APP_PORT"

