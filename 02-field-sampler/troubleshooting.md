# If something goes wrong

Real problems from building this, and what fixed them.

---

## Connecting

**`ssh: connect to host field-sampler.local port 22: Connection refused`**

Something answered but SSH isn't running yet. Usually it's still booting — wait 30 seconds and try again.

**`ping: cannot resolve field-sampler.local: Unknown host`**

The name isn't resolving. On a Mac, flush the cache:

```bash
sudo killall -HUP mDNSResponder
```

If that doesn't help, find the Pi's IP in your router's admin page and use that instead:

```bash
ssh pi@192.168.1.XX
```

The IP always works, even when the name doesn't.

**Nothing shows when you type your password**

That's how SSH works — no dots, no stars, nothing moves. Type it and press enter.

---

## Commands failing in strange ways

**A screen full of `No such file or directory`, one per line**

You pasted several commands at once and the terminal joined them up. Run them **one at a time** — press enter, wait, then do the next. This is the single most common way this guide goes wrong.

**`-bash: git: command not found`**

Raspberry Pi OS Lite is a minimal image and doesn't include git. `setup.sh` installs it, so this means you've skipped ahead. Install it by hand:

```bash
sudo apt install -y git
```

**`ModuleNotFoundError: No module named 'blinkt'`** (or any other module)

The libraries come from `setup.sh`. If you're ahead of it:

```bash
sudo apt install -y python3-pip
pip3 install --break-system-packages blinkt
```

---

## The sound card

**`aplay -l` doesn't list `seeed2micvoicec`**

Check the overlay actually saved:

```bash
grep respeaker /boot/firmware/config.txt
```

You want `dtoverlay=respeaker-2mic-v2_0`.

If it's there and the card still doesn't appear, confirm the overlay file got copied:

```bash
ls /boot/firmware/overlays/ | grep respeaker
```

**You have a v1 board, not a v2**

These are completely different audio chips and the v2 driver will never work on a v1. The quickest way to tell is `i2cdetect -y 1`:

- **`1a`** → v1, with a WM8960 codec. On recent Raspberry Pi OS you can use the built-in overlay: `echo "dtoverlay=wm8960-soundcard" | sudo tee -a /boot/firmware/config.txt`
- **`18`** → v2, with a TLV320AIC3x. Follow this guide.

Seeed's wiki has a page on [telling the revisions apart](https://wiki.seeedstudio.com/ReSpeaker_2_Mics_Pi_HAT/).

**Don't build the kernel module**

Seeed's wiki has a collapsed section called "Prepare for Raspberry Pi Zero W" that clones the entire Linux kernel and compiles a driver. That's for the **original** Zero W. On a Zero 2 W it's hours of compiling for something you already have. Skip it.

**It records but playback is silent, or barely audible**

Every output on this codec starts at zero. This is the most common "my board is broken" moment and it's just settings:

```bash
alsamixer -c 0
```

Press **F3** for Playback. There's no control called "Speaker" — the ones that matter are **PCM**, **Line DAC**, **Line PGA**, **Line** and **HP**. Raise them all. Arrow right past HP in case there are more off-screen. **MM** at the bottom means muted; press **M**.

Then make it stick:

```bash
sudo alsactl store
```

Without that last command the levels reset every reboot.

**Still quiet with everything at 100**

That's the hardware. The v2 board drives the JST socket directly without much amplification, so a small speaker won't go very loud. Either use the 3.5mm jack into a powered speaker, or add a small amplifier board between the codec and the speaker.

**Crackling or dropouts**

Your audio buffer is too small for what the code is doing. Ask Claude to make it bigger. On 512MB with other things running you may need more headroom than you'd expect.

---

## The pads and the screen

**`i2cdetect -y 1` shows nothing at all**

I2C isn't turned on:

```bash
sudo raspi-config nonint do_i2c 0
sudo reboot
```

**`5b` is missing (touch pads)**

Check the pads are in the ReSpeaker's **I2C** Grove socket, not the digital one.

Note the address is **0x5b**, not the 0x5a most MPR121 documentation assumes — the Grove board ties its address pin differently.

**The screen draws, then goes blank a second later**

That's luma clearing the display when the script ends, which is its default. Set `persist` on the device so it leaves the image up:

```python
d.persist = True
```

The test script does this already. Worth knowing when Claude writes your sampler — if the screen keeps blanking between actions, this is why.

**`3c` is missing (OLED)**

Check all four wires, and check them twice. The usual culprits are a jumper on the wrong pin of the splitter, or the header not fully seated after soldering.

**Everything disappears from `i2cdetect` when you turn the knob**

The encoder is plugged into the I2C socket. Its contacts drag SDA and SCL around and take the whole bus down with them. Move it to the **digital** socket.

**The pads trigger when you're not touching them**

The MPR121 calibrates at startup and treats whatever it sees then as "not touched". If you were touching a pad as it powered up, it'll be confused. Restart without touching anything. If it persists, ask Claude to lower the sensitivity threshold.

---

## The lights

**`RPi.GPIO` errors when importing blinkt**

The old GPIO library doesn't work on newer kernels. Install the drop-in replacement:

```bash
sudo apt install -y python3-rpi-lgpio
```

`setup.sh` does this for you.

---

## Running your code

**The Pi runs out of memory**

```bash
free -h
```

If swap is heavily used, something is loading more than it should — usually samples being read from disk repeatedly rather than kept in memory. Tell Claude what you're seeing.

**`sampler.service` won't start**

```bash
sudo systemctl status sampler
journalctl -u sampler -n 50
```

The most common cause is a crash on startup from a broken or zero-length recording. Delete it from `~/sampler/recordings` and ask Claude to wrap the file loading in try/except.

**Everything is frozen and you can't get it back**

```bash
sudo systemctl stop sampler
sudo pkill -f sampler.py
```

---

## Claude Code on your laptop

**It asks for a password on every command**

The SSH key didn't take:

```bash
ssh-copy-id pi@field-sampler.local
```

Then test with `ssh pi@field-sampler.local 'echo it works'`. If that runs without a prompt, Claude will be fine.

**It says it can't reach the Pi**

Check you can:

```bash
ssh pi@field-sampler.local 'echo hello'
```

If you can't, Claude can't either — fix the connection first, it's not a Claude problem.

**Changes don't seem to do anything**

The code probably didn't get copied across:

```bash
ssh pi@field-sampler.local 'ls -la ~/sampler/'
```

Compare the timestamps to what you've just changed locally.
