#!/usr/bin/env bash
#
# Curious Machines, Field Sampler setup
# Prepares a Pi Zero 2 W (64-bit Raspberry Pi OS Lite) with everything
# you need to build a field sampler.
#
#   curl -fsSL https://raw.githubusercontent.com/tigrisli/curious-machines/main/02-field-sampler/setup.sh -o setup.sh
#   less setup.sh        # read it first, always
#   bash setup.sh
#
# This does NOT install the audio driver. That's a separate step in the
# README, because it depends on which version of the ReSpeaker you have.
#
# Claude Code isn't installed here either. On this project it runs on your
# laptop, not on the Pi.
#
set -euo pipefail

CONFIG=/boot/firmware/config.txt
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'
say()  { echo -e "\n${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}  ! ${NC}$1"; }
die()  { echo -e "\n${RED}==> $1${NC}\n"; exit 1; }

PIP="pip3 install --break-system-packages --no-warn-script-location -q"

# --------------------------------------------------------------------------
say "Checking your Pi"

[ "$(uname -m)" = "aarch64" ] || die "This needs 64-bit Raspberry Pi OS. Reflash with the 64-bit Lite image and run this again."
[ -f "$CONFIG" ] || die "Can't find $CONFIG. Is this Raspberry Pi OS Bookworm or newer?"

TOTAL_RAM=$(awk '/MemTotal/ {printf "%.0f", $2/1024}' /proc/meminfo)
echo "  64-bit: yes"
echo "  RAM: ${TOTAL_RAM}MB"
[ "$TOTAL_RAM" -lt 1000 ] && warn "Under 1GB, so this script turns on zram to help."

# --------------------------------------------------------------------------
say "Updating the system (the slow bit, ~10 minutes)"
sudo apt-get update -qq
sudo apt-get full-upgrade -y -qq

# --------------------------------------------------------------------------
# Raspberry Pi OS Lite is a minimal image, git and pip aren't in it.
say "Installing the basics Lite doesn't come with"
sudo apt-get install -y -qq \
  git \
  build-essential \
  device-tree-compiler \
  python3-pip \
  i2c-tools \
  rsync

# --------------------------------------------------------------------------
say "Turning on I2C (for the touch pads and the screen)"
sudo raspi-config nonint do_i2c 0

# --------------------------------------------------------------------------
say "Installing the audio and hardware libraries"
# Package names move around between Raspberry Pi OS releases, so install
# one at a time and carry on if any single one isn't available.
for p in python3-numpy python3-pygame python3-smbus2 python3-pil \
         python3-gpiozero python3-rpi-lgpio python3-rtmidi \
         libportaudio2 alsa-utils; do
  if sudo apt-get install -y -qq "$p" 2>/dev/null; then
    echo "  $p"
  else
    warn "$p not available on this release, skipping"
  fi
done

say "Installing the screen, touch, light and audio libraries"
$PIP luma.oled adafruit-circuitpython-mpr121 blinkt sounddevice \
  || warn "One of these didn't install. See troubleshooting.md"

# --------------------------------------------------------------------------
say "Setting up zram (compressed swap, 512MB needs the help)"
sudo apt-get install -y -qq zram-tools
if ! grep -q "^PERCENT=200" /etc/default/zramswap 2>/dev/null; then
  sudo sed -i '/^ALGO=/d; /^PERCENT=/d' /etc/default/zramswap
  printf 'ALGO=zstd\nPERCENT=200\n' | sudo tee -a /etc/default/zramswap >/dev/null
  sudo systemctl restart zramswap || true
fi
echo "  Swap now: $(free -h | awk '/Swap/ {print $2}')"

# --------------------------------------------------------------------------
say "Turning on USB gadget mode (so it can be a MIDI controller later)"
if grep -q "^dtoverlay=dwc2" "$CONFIG"; then
  echo "  Already set"
else
  echo "dtoverlay=dwc2" | sudo tee -a "$CONFIG" >/dev/null
  echo "  Added"
fi
if ! grep -q "dwc2" /etc/modules 2>/dev/null; then
  echo "dwc2" | sudo tee -a /etc/modules >/dev/null
fi

# --------------------------------------------------------------------------
say "Making your project folder"
mkdir -p ~/sampler/recordings
cat > ~/sampler/CLAUDE.md <<'EOF'
# Field Sampler

A Raspberry Pi Zero 2 W with a ReSpeaker 2-Mics pHAT v2, twelve capacitive
touch pads, a rotary encoder, eight RGB lights and a small mono OLED.
There is no desktop. The Pi boots to a terminal, so anything drawn goes
to the screen over I2C, never X11.

Hardware:
- Audio in and out: ALSA card 0, device "seeed2micvoicec".
  Use plughw:0,0 at 48000Hz, 16-bit, stereo. The codec is a TLV320AIC3x.
  Check with `aplay -l` if the card number looks wrong.
- Button on GPIO17.
- Grove MPR121 capacitive touch, 12 pads, I2C 0x5B.
- Pimoroni 1.12" OLED, 128x128 mono, I2C 0x3C. Drive it with luma.oled's
  `sh1106` class at width=128, height=128, rotate=1.
- Grove rotary encoder on GPIO12 and GPIO13. No push switch.
- Pimoroni Blinkt!, 8 APA102 RGB LEDs, GPIO23 and GPIO24.
  Use the `blinkt` python library.

Keep these in mind when writing code here:
- 512MB of RAM. Load samples into memory once; don't re-read files
  on every pad hit.
- Keep audio buffers small so pads trigger without noticeable delay,
  but not so small that playback crackles.
- Write recordings to a temporary filename and rename once complete,
  so an interrupted save can never leave a broken file behind.
- Wrap file loading in try/except. A bad file should be skipped,
  never crash the app on startup.
- Set `d.persist = True` on the OLED device, or luma blanks the screen
  every time a script exits.
- Recordings go in ~/sampler/recordings.
EOF
cat > ~/sampler/test-screen.py <<'EOF'
# Draws a border and some text on the OLED, so you know it works.
from luma.core.interface.serial import i2c
from luma.oled.device import sh1106
from PIL import Image, ImageDraw

ADDRESS = 0x3C   # try 0x3D if nothing appears
ROTATE  = 1      # 0, 1, 2, 3 = 0, 90, 180, 270 degrees clockwise

d = sh1106(i2c(port=1, address=ADDRESS), width=128, height=128, rotate=ROTATE)
d.persist = True   # leave the image up when the script ends
img = Image.new("1", d.size)
dr = ImageDraw.Draw(img)
dr.rectangle((0, 0, 127, 127), outline=1)
dr.text((22, 52), "FIELD", fill=1)
dr.text((22, 66), "SAMPLER", fill=1)
d.display(img)
print("Drawn. Look at the screen.")
EOF
cat > ~/sampler/test-pads.py <<'EOF'
# Prints a line each time you touch one of the twelve pads.
import time
import board, busio, adafruit_mpr121

ADDRESS = 0x5B   # try 0x5A if this one isn't found

i2c = busio.I2C(board.SCL, board.SDA)
mpr = adafruit_mpr121.MPR121(i2c, address=ADDRESS)

print("Touch the pads. Ctrl+C to stop.")
while True:
    for i in range(12):
        if mpr[i].value:
            print(f"pad {i}")
    time.sleep(0.1)
EOF

cat > ~/sampler/test-encoder.py <<'EOF'
# Counts up and down as you turn the knob.
from gpiozero import RotaryEncoder
from signal import pause

enc = RotaryEncoder(12, 13, max_steps=0)
enc.when_rotated = lambda: print(f"steps: {enc.steps}")

print("Turn the knob. Ctrl+C to stop.")
pause()
EOF
echo "  ~/sampler is ready"

# --------------------------------------------------------------------------
say "Adding the auto-start service (not enabled yet)"
sudo tee /etc/systemd/system/sampler.service >/dev/null <<'EOF'
[Unit]
Description=Field Sampler
After=multi-user.target sound.target

[Service]
ExecStart=/usr/bin/python /home/pi/sampler/sampler.py
WorkingDirectory=/home/pi/sampler
User=pi
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
echo "  Turn it on later with: sudo systemctl enable --now sampler"

# --------------------------------------------------------------------------
echo -e "\n${GREEN}=====================================================${NC}"
cat <<'EOF'
 Done, but there's no sound yet.

 The audio driver is the next step in the README, and it's
 done by hand because it depends on which ReSpeaker you have.

 Go back to the guide and carry on from "Install the audio driver".
EOF
echo -e "${GREEN}=====================================================${NC}\n"
