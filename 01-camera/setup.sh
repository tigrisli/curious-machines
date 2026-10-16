#!/usr/bin/env bash
#
# Curious Machines — Raspberry Pi camera setup
# Prepares a Pi 4 (64-bit Raspberry Pi OS) with everything you need
# to build a camera with Claude Code.
#
#   curl -fsSL https://raw.githubusercontent.com/tigrisli/curious-machines/main/01-camera/setup.sh -o setup.sh
#   less setup.sh        # read it first, always
#   bash setup.sh
#
set -euo pipefail

CONFIG=/boot/firmware/config.txt
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'
say()  { echo -e "\n${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}  ! ${NC}$1"; }
die()  { echo -e "\n${RED}==> $1${NC}\n"; exit 1; }

# --------------------------------------------------------------------------
say "Checking your Pi"

[ "$(uname -m)" = "aarch64" ] || die "This needs 64-bit Raspberry Pi OS. Reflash with the 64-bit image and run this again."
[ -f "$CONFIG" ] || die "Can't find $CONFIG — is this Raspberry Pi OS Bookworm or newer?"

TOTAL_RAM=$(awk '/MemTotal/ {printf "%.0f", $2/1024}' /proc/meminfo)
echo "  64-bit: yes"
echo "  RAM: ${TOTAL_RAM}MB"
[ "$TOTAL_RAM" -lt 3000 ] && warn "Under 4GB — this script enables zram to compensate."

# --------------------------------------------------------------------------
say "Updating the system (this is the slow bit, ~5 minutes)"
sudo apt-get update -qq
sudo apt-get full-upgrade -y -qq

# --------------------------------------------------------------------------
say "Installing Node.js 22"
if command -v node >/dev/null && [ "$(node -v | cut -c2- | cut -d. -f1)" -ge 18 ]; then
  echo "  Already have $(node -v)"
else
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - >/dev/null
  sudo apt-get install -y -qq nodejs
  echo "  Installed $(node -v)"
fi

# --------------------------------------------------------------------------
# Claude Code is NOT installed here — you do that yourself, in one command,
# once this script has finished. See the README.
# --------------------------------------------------------------------------
say "Installing the camera library"
sudo apt-get install -y -qq python3-picamera2 python3-pygame

# --------------------------------------------------------------------------
say "Setting up zram (compressed swap — keeps a 2GB Pi happy)"
sudo apt-get install -y -qq zram-tools
if ! grep -q "^PERCENT=200" /etc/default/zramswap 2>/dev/null; then
  sudo sed -i '/^ALGO=/d; /^PERCENT=/d' /etc/default/zramswap
  printf 'ALGO=zstd\nPERCENT=200\n' | sudo tee -a /etc/default/zramswap >/dev/null
  sudo systemctl restart zramswap || true
fi
echo "  Swap now: $(free -h | awk '/Swap/ {print $2}')"

# --------------------------------------------------------------------------
say "Booting to the terminal instead of the desktop (saves ~350MB)"
sudo raspi-config nonint do_boot_behaviour B2

# --------------------------------------------------------------------------
say "Reserving memory for the camera (CMA)"
if grep -q "vc4-kms-v3d" "$CONFIG" && ! grep -q "cma-256" "$CONFIG"; then
  sudo sed -i 's/^dtoverlay=vc4-kms-v3d$/dtoverlay=vc4-kms-v3d,cma-256/' "$CONFIG"
  echo "  Set to 256MB"
else
  echo "  Already set"
fi

# --------------------------------------------------------------------------
say "Turning on the 2.8\" touchscreen"
if grep -q "vc4-kms-dpi-generic" "$CONFIG"; then
  echo "  Already configured"
else
  sudo tee -a "$CONFIG" >/dev/null <<'EOF'

# Waveshare 2.8" DPI LCD (480x640)
dtoverlay=vc4-kms-dpi-generic
dtparam=hactive=480,hfp=26,hsync=16,hbp=10
dtparam=vactive=640,vfp=25,vsync=10,vbp=15
dtparam=clock-frequency=32000000
dtparam=hsync-invert,vsync-invert,pixclk-invert
dtparam=rgb666-padhi
EOF
  echo "  Added. Skip this block if you're using a different screen."
fi

# --------------------------------------------------------------------------
say "Making your project folder"
mkdir -p ~/camera
cat > ~/camera/CLAUDE.md <<'EOF'
# Curious Machines camera

A Raspberry Pi 4 with a camera module and a 480x640 DPI touchscreen.
There is no desktop — the Pi boots to a terminal, so anything drawn on
the screen goes straight to the framebuffer (pygame or DRM), never X11.

Keep these in mind when writing code here:
- Preview at 640x480, stills no larger than 2304x1296. Full resolution
  is too heavy for this board and nobody can see it on a 2.8" screen.
- Run any face detection on a downscaled copy, every few frames.
- Write photos to a temporary filename and rename once complete, so an
  interrupted save can never leave a corrupt file behind.
- Wrap image loading in try/except — a bad file should be skipped,
  never crash the app on startup.
EOF
echo "  ~/camera is ready"

# --------------------------------------------------------------------------
say "Adding the auto-start service (not enabled yet)"
sudo tee /etc/systemd/system/camera.service >/dev/null <<'EOF'
[Unit]
Description=Camera
After=multi-user.target

[Service]
ExecStart=/usr/bin/python /home/pi/camera/camera.py
WorkingDirectory=/home/pi/camera
User=pi
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
echo "  Turn it on later with: sudo systemctl enable --now camera"

# --------------------------------------------------------------------------
cat <<EOF

${GREEN}=====================================================${NC}
 Done. Now reboot:

   sudo reboot

 Then ssh back in and install Claude Code:

   sudo npm install -g @anthropic-ai/claude-code
   cd ~/camera
   claude

 Log in when it asks, press 1 to trust the folder, then
 describe the camera you want.
${GREEN}=====================================================${NC}

EOF
