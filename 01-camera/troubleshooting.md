# When it breaks

It will, and that's fine. **Nothing you type can permanently damage the Pi.** Worst case you re-flash the SD card and start again, which takes about half an hour.

These are the things that actually went wrong while I was making this, plus the ones people hit most often on their first run. Step numbers refer to the [main guide](README.md).

**Before anything else:** if you're stuck and Claude Code is already installed, paste the error straight into it and ask what it means. It's sitting on the Pi and can see the same files you can.

---

## Jump to

- [I can't connect to the Pi](#i-cant-connect-to-the-pi) — step 6
- [The screen stays dark](#the-screen-stays-dark) — step 7
- [The camera won't start](#the-camera-wont-start) — step 9
- [Claude Code problems](#claude-code-problems) — step 8
- [The camera app crashes](#the-camera-app-crashes) — step 9+
- [Starting over](#starting-over)

---

## I can't connect to the Pi

*Step 6. The most common place to get stuck.*

### "Could not resolve hostname camera.local"

Windows often can't resolve `.local` names, and some locked-down work laptops can't either.

First try it without the suffix:

```bash
ssh pi@camera
```

If that fails too, **use the IP address instead.** Once the little screen is working, it shows the address at startup, next to `My IP address is`. If not, log into your router's admin page and look for a device called `camera` in the connected-devices list.

```bash
ssh pi@192.168.1.123
```

### "Permission denied, please try again"

Either the password is wrong, or **the username is wrong.**

The guide uses `pi` everywhere. If you typed your own name into Pi Imager back in step 1, then `ssh pi@camera.local` will never work — you need:

```bash
ssh yourname@camera.local
```

That gets you in, but the auto-start service in [Make it portable](README.md#11-make-it-portable) expects `/home/pi/camera` and will fail silently later. Easiest fix is to re-flash the card with the username `pi`. It saves a confusing half hour later.

### "Connection refused" on port 22

Something answered, but SSH isn't running. Usually it means **Enable SSH** wasn't ticked in Pi Imager.

Re-flash the card with SSH enabled this time. The little screen isn't working yet at this point, so that's the only easy fix.

### "Connection timed out"

Nothing answered at all. Either the Pi isn't on your network, or you've got the wrong address.

- Did you give Imager the **right wifi name and password**, and choose your **capital city** on the Localisation screen? Wifi won't start without the country it sets.
- Is your laptop on the **same network** as the Pi? A 5GHz-only guest network will do this.
- Is it a **captive portal** network — the kind where you log in on a web page? The Pi can't get past those. Use your phone's hotspot.

### "REMOTE HOST IDENTIFICATION HAS CHANGED"

You re-flashed the card, so the Pi has a new identity and your laptop is being careful. Clear the old one, then connect as normal:

```bash
ssh-keygen -R camera.local
```

### Nothing appears when I type my password

That's correct behaviour. Terminals don't show anything for passwords — no dots, no stars, no cursor movement. Type it and press enter.

### Pi Imager never asked me about settings

In Imager 2 the settings are the **Customisation** step, straight after Storage. On an older version, update Imager first. If you've already flashed without them, flash again — it's much easier than fixing it afterwards.

---

## The screen stays dark

*Step 7.*

**It's supposed to be dark before step 7.** The driver gets configured by the setup script. If you're on step 5 and the screen is black, that's normal — keep going.

**After step 7, check it's seated properly.** Power off with `sudo poweroff`, wait for the lights to stop, unplug, then lift the screen straight up and press it back down evenly. One row of pins out of line is the most common cause and it looks fine at a glance.

**Check the script actually ran.** The screen needs its overlay in `/boot/firmware/config.txt`:

```bash
grep dpi-generic /boot/firmware/config.txt
```

If that prints nothing, the setup script didn't finish. Run it again with `cd ~/curious-machines/01-camera && bash setup.sh`.

**Different screen?** The setup script only knows the Waveshare 2.8" DPI LCD. Yours needs its own timings — find them on its wiki, or paste the model name into Claude Code and ask.

### It's sideways

Add this to the **start** of the single long line in `/boot/firmware/cmdline.txt`:

```
video=DPI-1:480x640M@60,rotate=270
```

Try `90` if `270` goes the wrong way. Reboot after.

---

## The camera won't start

*Step 9.*

### No cameras listed at all

```bash
rpicam-hello --list-cameras
```

If that comes back empty, the ribbon cable is loose or in the wrong way round.

**Power off properly first** — `sudo poweroff`, wait for the lights to stop blinking, then unplug. Re-seat both ends of the ribbon. Blue tab facing the USB ports on the Pi side.

### "Failed to queue buffer" / "Input/output error"

Not a broken camera — it's running out of contiguous memory for the big image buffers.

Open `/boot/firmware/config.txt`, find the `vc4-kms-v3d` line and give it more:

```
dtoverlay=vc4-kms-v3d,cma-256
```

Then reboot. The setup script does this for you, so seeing this usually means the script didn't finish.

### "Failed to create egl preview"

Not an error. It just means there's no desktop, so it's drawing straight to the screen instead. You'll see `Made drm preview window` right after it.

---

## Claude Code problems

*Step 8.*

### "command not found: claude"

If you've just installed it, run the line it gave you at the end of the install:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

Still not found? Run the install command from step 8 again and read what it prints. Then check you're on the 64-bit OS:

```bash
uname -m       # needs to say aarch64
```

If `uname -m` says `armv7l`, you've flashed the 32-bit OS. Re-flash with **Raspberry Pi OS (64-bit)** and start again from step 1 — Claude Code won't run on 32-bit.

### The login link won't open / the code won't paste

Copy the whole link, including the long string of characters after the `?`. Terminals sometimes wrap it across two lines — you need both halves, joined with no space.

Pasting into a terminal is ⌘+V on Mac, right-click on Windows PowerShell.

### It doesn't remember my camera

You probably started a fresh conversation. Run `cd ~/camera`, then `claude --continue` rather than plain `claude`, to pick up where you left off.

### Everything is really slow

Check what's using memory:

```bash
free -h
htop
```

On a 2GB Pi, make sure the setup script's zram and console-boot steps actually ran. A desktop session alone eats 300–400MB you don't have spare.

---

## The camera app crashes

*Step 9 onwards.*

### "UnidentifiedImageError: cannot identify image file"

One of your saved photos is corrupt — usually because power was pulled mid-save. The app tries to load the most recent photo as a thumbnail and falls over.

Delete the bad file:

```bash
ls -la ~/camera/*.jpg     # look for one that's 0 bytes
rm ~/camera/the-bad-one.jpg
```

Then ask Claude to make it more robust:

> wrap the thumbnail loading in a try/except so a corrupt file gets skipped instead of crashing, and write photos to a temporary name and rename them once complete

### The screen is frozen on an old frame

A camera process died without releasing the display. It looks frozen but isn't:

```bash
sudo pkill -f camera.py
sudo chvt 1
```

### It worked, then I enabled auto-start and now I can't change anything

The service grabs the camera and the screen on boot. Stop it while you work:

```bash
sudo systemctl stop camera
cd ~/camera
claude --continue
```

And start it again when you're done.

### Auto-start does nothing on boot

Check what the service thinks happened:

```bash
systemctl status camera
```

The usual cause is **a username that isn't `pi`** — the service looks for `/home/pi/camera/camera.py` and runs as `pi`. Either re-flash with the username `pi`, or edit `/etc/systemd/system/camera.service` to match your actual username, then:

```bash
sudo systemctl daemon-reload
sudo systemctl restart camera
```

The other cause is that your file isn't called `camera.py`. The service runs that exact name.

---

## Starting over

Nothing here is permanent. If a Pi gets into a state you can't fix, re-flash the SD card and run the setup script again — it takes about half an hour and you lose nothing except the code, which you can ask for again.

### Rolling back one experiment

Worth doing the moment something works and you're about to try something risky:

```bash
mkdir -p ~/camera-backup && cp ~/camera/camera.py ~/camera-backup/
```

Then if an experiment goes nowhere, you're one line from the last good version:

```bash
cp ~/camera-backup/camera.py ~/camera/
```

Claude Code can also just undo it — tell it "go back to how it was before the last change" and it usually can.
