# Doing the setup by hand

If you'd rather not run the script — or you're on different hardware and need to adapt it — here's everything it does, one command at a time.

---

## Check you're on 64-bit

```bash
uname -m
```

Must say `aarch64`. If it says `armv7l`, re-flash with the 64-bit image.

## Update everything

```bash
sudo apt update && sudo apt full-upgrade -y
```

## Node.js

The version in Raspberry Pi OS is too old for Claude Code, so use NodeSource:

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
node -v
```

Run these **one line at a time** — the first command ends in a `-` that's part of it, and pasting all three at once breaks it.

## The camera library

```bash
sudo apt install -y python3-picamera2 python3-pygame
```

## Compressed swap

Makes a 2GB Pi much happier:

```bash
sudo apt install -y zram-tools
echo -e "ALGO=zstd\nPERCENT=200" | sudo tee -a /etc/default/zramswap
sudo systemctl restart zramswap
free -h
```

## Boot to the terminal, not the desktop

Saves 300–400MB, and you don't need a desktop on a 2.8" screen:

```bash
sudo raspi-config nonint do_boot_behaviour B2
```

## Memory for the camera

```bash
sudo nano /boot/firmware/config.txt
```

Find the `vc4-kms-v3d` line and change it to:

```
dtoverlay=vc4-kms-v3d,cma-256
```

## The screen

Still in `config.txt`, add at the bottom:

```
dtoverlay=vc4-kms-dpi-generic
dtparam=hactive=480,hfp=26,hsync=16,hbp=10
dtparam=vactive=640,vfp=25,vsync=10,vbp=15
dtparam=clock-frequency=32000000
dtparam=hsync-invert,vsync-invert,pixclk-invert
dtparam=rgb666-padhi
```

That's for the Waveshare 2.8" DPI LCD. A different screen needs its own timings — check its wiki.

Save with `ctrl+o`, enter, `ctrl+x`.

### If it comes up sideways

```bash
sudo nano /boot/firmware/cmdline.txt
```

Add this at the **start** of the single long line:

```
video=DPI-1:480x640M@60,rotate=270
```

Try `90` if `270` goes the wrong way.

## The project folder

```bash
mkdir -p ~/camera
```

## The auto-start service

```bash
sudo nano /etc/systemd/system/camera.service
```

```ini
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
```

```bash
sudo systemctl daemon-reload
```

Don't enable it yet — that comes at the end, once your camera actually works.

## Reboot

```bash
sudo reboot
```
