# When it breaks

These are the things that actually went wrong while I was making this.

---

## I can't connect to the Pi

### "Could not resolve hostname camera.local"

Windows often can't resolve `.local` names, and some locked-down work laptops can't either.

**Use the IP address instead.** It's printed on the Pi's screen when it boots — look for the line that says `My IP address is`.

```bash
ssh pi@192.168.1.123
```

### "Connection refused" on port 22

Something answered, but SSH isn't running. Usually it means SSH wasn't ticked in Raspberry Pi Imager.

Plug a USB keyboard into the Pi and run:

```bash
sudo systemctl enable --now ssh
```

Or re-flash the card with SSH enabled this time.

### "Connection timed out"

Nothing answered at all. Either the Pi isn't on your network, or you've got the wrong address. Check the Pi's screen for its IP.

### Nothing appears when I type my password

That's correct behaviour. Terminals don't show anything for passwords — no dots, no stars. Type it and press enter.

---

## The screen stays dark

**Check it's seated properly.** Power off, lift the screen straight up, and press it back down evenly. One row of pins out of line is the most common cause and it looks fine at a glance.

**Check the config.** The screen needs its overlay in `/boot/firmware/config.txt`. The setup script adds it, but if you're using a different screen you'll need the lines for yours.

---

## The camera won't start

### "Failed to queue buffer" / "Input/output error"

Not a broken camera — it's running out of contiguous memory for the big image buffers.

Open `/boot/firmware/config.txt`, find the `vc4-kms-v3d` line and give it more:

```
dtoverlay=vc4-kms-v3d,cma-256
```

Then reboot. The setup script does this for you.

### No cameras listed at all

```bash
rpicam-hello --list-cameras
```

If that comes back empty, the ribbon cable is loose or in the wrong way round. **Power off first**, then re-seat both ends. Blue tab facing the USB ports on the Pi side.

### "Failed to create egl preview"

Not an error. It just means there's no desktop, so it's drawing straight to the screen instead. You'll see `Made drm preview window` right after it.

---

## The camera app crashes

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

---

## Claude Code problems

### "command not found: claude"

It didn't install, or Node is too old. Check:

```bash
node -v        # needs to be 18 or higher
uname -m       # needs to say aarch64
```

If `uname -m` says `armv7l`, you've flashed the 32-bit OS. Re-flash with 64-bit.

### It doesn't remember my camera

You probably started a fresh conversation. Use `claude --continue` rather than plain `claude` to pick up where you left off.

### Everything is really slow

Check what's using memory:

```bash
free -h
htop
```

On a 2GB Pi, make sure the setup script's zram and console-boot steps actually ran. A desktop session alone eats 300–400MB you don't have spare.

---

## Starting over

Nothing here is permanent. If a Pi gets into a state you can't fix, re-flash the SD card and run the setup script again — it takes about fifteen minutes and you lose nothing except the code, which you can ask for again.

There's also a clean copy of your working camera at `~/camera-backup/` if you want to roll back one experiment:

```bash
cp ~/camera-backup/camera.py ~/camera/
```
