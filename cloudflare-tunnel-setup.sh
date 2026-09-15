#!/bin/bash

# ============================================================
# Cloudflare Tunnel Setup Script for Jellyfin
# Description: My ISP blocked port 80 so many things do not work as intended. 
# ============================================================

TUNNEL_NAME="kashyyyk-tunnel"
HOSTNAME="video.juissy.net"
JELLYFIN_PORT="8096"
CONFIG_DIR="/etc/cloudflared"

echo "=== Installing cloudflared ==="
sudo apt update
sudo apt install -y cloudflared

echo
echo "=== Logging into Cloudflare (browser will open) ==="
cloudflared tunnel login

echo
echo "=== Creating tunnel: $TUNNEL_NAME ==="
cloudflared tunnel create $TUNNEL_NAME

# Find the generated credentials file
CRED_FILE=$(ls ~/.cloudflared/*.json | head -n 1)

echo
echo "=== Credentials file detected: $CRED_FILE ==="

echo
echo "=== Creating config directory: $CONFIG_DIR ==="
sudo mkdir -p $CONFIG_DIR

echo
echo "=== Writing config.yml ==="
sudo bash -c "cat > $CONFIG_DIR/config.yml" <<EOF
tunnel: $TUNNEL_NAME
credentials-file: $CRED_FILE

ingress:
  - hostname: $HOSTNAME
    service: http://127.0.0.1:$JELLYFIN_PORT
  - service: http_status:404
EOF

echo
echo "=== Creating DNS route for $HOSTNAME ==="
cloudflared tunnel route dns $TUNNEL_NAME $HOSTNAME

echo
echo "=== Installing cloudflared as a system service ==="
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

echo
echo "============================================================"
echo " Cloudflare Tunnel setup complete!"
echo " Jellyfin should now be accessible at: https://$HOSTNAME"
echo "============================================================"
echo "You can add more ingress entries at /etc/cloudflared/config.yml"
echo "tunnel: kashyyyk-tunnel
credentials-file: /home/justin/.cloudflared/9d198b07-2401-4398-97aa-118d3effcd8b.json

ingress:
  - hostname: video.juissy.net
    service: http://127.0.0.1:8096

  - hostname: photos.juissy.net
    service: http://127.0.0.1:2283

  - service: http_status:404
"
