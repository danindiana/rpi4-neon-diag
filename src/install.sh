#!/bin/bash
set -euo pipefail

# RPI4 Neon Diagnostics - Idempotent Install Script
echo "Starting installation/conditioning..."

# 1. Install Dependencies
sudo apt-get update -y
sudo apt-get install -y graphviz nginx bc

# 2. Setup Directories
DIAG_DIR="/home/jeb/rpi4_diagnostics_20260515"
mkdir -p "$DIAG_DIR/src" "$DIAG_DIR/assets/lib" "$DIAG_DIR/docs/diagrams" "$DIAG_DIR/systemd" "$DIAG_DIR/motd"

# 3. Setup Configuration
if [ ! -f "$DIAG_DIR/config.env" ]; then
    cat << EOC > "$DIAG_DIR/config.env"
# RPI4 Neon Diagnostics Configuration
DIAG_DIR="$DIAG_DIR"
DOT_DIR="\$DIAG_DIR/docs/diagrams"
ASSET_DIR="\$DIAG_DIR/assets"
BG_COLOR="#0D0D0D"
TEXT_COLOR="#00FFFF"
BORDER_COLOR="#FF00FF"
NODE_COLOR="#1A1A1A"
EOC
fi

# 4. Configure Nginx
if [ ! -f "/etc/nginx/sites-available/rpi4-neon-diag" ]; then
    cat << EON | sudo tee /etc/nginx/sites-available/rpi4-neon-diag
server {
    listen 8888;
    server_name _;
    root $DIAG_DIR;
    index index.html;
    location / {
        try_files \$uri \$uri/ =404;
    }
    location ~* \.dot$ {
        add_header Content-Type text/plain;
    }
}
EON
    sudo ln -sf /etc/nginx/sites-available/rpi4-neon-diag /etc/nginx/sites-enabled/
    sudo systemctl reload nginx
fi

# 5. Configure Systemd Generator & Timer
sudo cp "$DIAG_DIR/systemd/rpi4-neon-diag-generator.service" /etc/systemd/system/ || true
sudo cp "$DIAG_DIR/systemd/rpi4-neon-diag-generator.timer" /etc/systemd/system/ || true
sudo systemctl daemon-reload
sudo systemctl enable --now rpi4-neon-diag-generator.timer

# 6. Configure MOTD
if [ ! -f "/etc/update-motd.d/99-neon-diagnostics" ]; then
    cat << EOM | sudo tee /etc/update-motd.d/99-neon-diagnostics
#!/bin/bash
printf "\033[1;36mNEON DIAGNOSTICS:\033[0m http://192.168.1.165:8888\n"
printf "\033[1;35mGENERATOR:\033[0m \$(systemctl is-active rpi4-neon-diag-generator.timer)\n"
EOM
    sudo chmod +x /etc/update-motd.d/99-neon-diagnostics
fi

echo "Installation complete. Dashboard live at http://192.168.1.165:8888"
