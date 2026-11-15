# Build a portable sampler with live recording

<!-- photo: the finished field sampler held in a hand, lights on -->

**Record everyday sounds and play them back on twelve touch pads.**

For this second project, we're building a small sampler you can take with you. Record a door closing, a passing train, or your own voice, then use those sounds and turn them into a beat.

It has a built-in microphone and speaker with a 3.5mm jack, so you can record and play wherever you are.

**Parts cost:** around £105  
**Build time:** about 2 hours, most of it will be installing libraries to your Pi.

### A different setup from the camera

In Project 01, Claude Code ran on the Pi itself. This project uses a Pi Zero 2 W with 512MB of memory, so we'll run Claude Code on your laptop and connect to the Pi over the network instead.

Claude Code writes the code on your laptop, copies it to the Pi, and runs it there. You'll use your laptop during the build; afterwards, the field sampler works on its own.

Thanks to Anthropic, the team behind [Claude](http://clau.de/tigrisli), for sponsoring this series and supporting these open-source projects! <3

## What you need

<!-- photo: all the parts laid out on the cutting mat -->

### Parts

- [Raspberry Pi Zero 2 **WH**](https://thepihut.com/products/raspberry-pi-zero-2-w) — choose the version with the GPIO header already attached: £22
- [ReSpeaker 2-Mics pHAT](https://thepihut.com/products/respeaker-2-mics-phat) — two microphones, a speaker output and a button: £12
- [Grove 12-key capacitive touch sensor](https://thepihut.com/products/grove-12-key-capacitive-i2c-touch-sensor-v3) — twelve touch pads: £7
- [Grove Encoder](https://thepihut.com/products/grove-encoder) — a rotary control: £5
- [Pimoroni 1.12" mono OLED breakout](https://shop.pimoroni.com/products/1-12-oled-breakout) — a small screen: £17
- [Blinkt!](https://shop.pimoroni.com/products/blinkt) — eight RGB lights: £6
- [GPIO splitter, 1 to 3](https://www.amazon.co.uk/dp/B0HG8FCZFT) — connects the boards to the Pi’s GPIO header, and comes with standoffs: £8
- [Mini speaker, 4Ω 3W with JST-PH connector](https://shop.pimoroni.com/products/mini-speaker-4-3w-with-jst-ph-connector) — plugs straight into the ReSpeaker, and has M2.5 mounting holes 32.5mm apart if you want to fix it to something: £6
- microSD card, 32GB or bigger: £15
- Micro-USB power supply — the Zero uses micro-USB: £8
- M2.5 standoffs and screws, usually included with the splitter

> **Check your ReSpeaker version before you start.** This guide uses **v2**. The v1 board has a different audio chip and needs a different driver. [Seeed’s wiki](https://wiki.seeedstudio.com/ReSpeaker_2_Mics_Pi_HAT/) explains how to identify your board.

**The OLED needs soldering.** Its five-pin header comes loose, so you’ll need a soldering iron and solder. You’ll also need four jumper wires to connect it to the splitter. A [Grove OLED](https://thepihut.com/products/grove-oled-display-1-12-sh1107-v3-0-spi-iic-3-3v-5v) is an alternative if you want a plug-in connection, but its cabling differs from the wiring shown below.

### On your laptop

- [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- An SD card reader
- A terminal. On macOS, press ⌘+Space and search for `Terminal`. On Windows, open the Start menu and search for `PowerShell`.
- [Claude Code](http://clau.de/tigrisli), installed on your laptop

### Account

- A paid Claude plan (Pro or above)

## How the parts fit together

The GPIO splitter lets the ReSpeaker, Blinkt! and screen connect to the Pi’s single GPIO header. The touch pads and encoder plug into the ReSpeaker.

Here’s how the connections are shared. GPIO numbers in this guide use **BCM numbering**, rather than physical header positions:

| Part | How it connects | Pins | Address |
|---|---|---|---|
| ReSpeaker | onto the splitter | I2S (18, 19, 20, 21), button on 17 | — |
| Touch pads | Grove **I2C** socket on the ReSpeaker | I2C (2, 3) | 0x5b |
| Encoder | Grove **digital** socket on the ReSpeaker | 12 and 13 | — |
| OLED | four jumper wires to the splitter | I2C (2, 3) | 0x3c |
| Blinkt! | onto the splitter | 23 and 24 | — |

The touch pads and screen share the two I2C signal wires. Each has its own address, which lets the Pi communicate with them separately.

---

## 1. Flash the SD card

Download [Raspberry Pi Imager](https://www.raspberrypi.com/software/).

**Device:** Raspberry Pi Zero 2 W.

**OS:** go into **Raspberry Pi OS (other)** and choose **Raspberry Pi OS Lite (64-bit)**.

Lite has no desktop interface, which leaves more of the Pi’s limited memory available for audio. The sampler uses its own OLED screen.

**Storage:** your SD card.

**Hostname:** `field-sampler`.

**User:** `pi` and a password you'll remember.

**Wi-Fi:** enter your network name and password. This guide uses Wi-Fi to connect your laptop to the Pi.

**Remote access:** enable SSH and choose password authentication.

Click **Write** and wait for Imager to finish. Allow about 10 minutes.

<!-- photo: Pi Imager with field-sampler settings -->

## 2. Solder the OLED

<!-- photo: the five-pin header going onto the OLED -->

Use the **straight** header supplied with the screen. This lets you connect it with jumper wires and choose where to mount it.

1. Push the header through from the back so the pins stick out.
2. Heat the pad and the pin together for a couple of seconds.
3. Feed solder into the joint, not onto the iron.
4. Repeat for all five pins.

Heat both the metal pad and the pin before adding solder. The solder should flow around the joint and form a small, neat cone.

If you’re using the Grove OLED, you can skip the soldering step. Check its connection instructions before continuing.

## 3. Build the stack

<!-- photo: the splitter going onto the Pi -->

Keep the Pi disconnected from power while you assemble and wire it.

1. **Fit the splitter to the Pi.** Line up all forty pins and press down evenly.
2. **Fit the ReSpeaker to the splitter.**
3. **Fit Blinkt! to the splitter.** It uses two GPIO signal pins, but sits on a full header.
4. **Secure the boards with standoffs.** These support the stack and take strain off the pins.

<!-- photo: the assembled stack from the side -->

Check the alignment from the side as well as from above. It’s easy to fit a board one row out.

## 4. Plug in the pads and the knob

<!-- photo: grove cables going into the ReSpeaker -->

Use the Grove cables supplied with the pads and encoder to connect them to the ReSpeaker:

- **Touch pads → I2C socket**
- **Encoder → digital socket**

Check the labels before connecting them. The sockets look alike, but serve different functions.

## 5. Wire the screen

<!-- photo: the OLED wired to the splitter -->

Connect the OLED to the splitter’s spare pins with four jumper wires:

| OLED pad | Pi pin |
|---|---|
| 3-6V | 3V3 |
| SDA | GPIO2 |
| SCL | GPIO3 |
| GND | GND |

The fourth pad is marked with a crossed-out circle, which means not connected. Skip it.

**Check each connection before powering on**, especially 3V3 and GND. Incorrect power wiring can damage the boards.

## 6. Connect the speaker and power on

<!-- photo: speaker plugged into the JST socket -->

1. Plug the speaker into the ReSpeaker’s JST socket.
2. Insert the SD card into the Pi.
3. Connect micro-USB power to the port marked **PWR**.
4. Allow about 3 minutes for the first boot.

The screen will stay blank until you run code to draw on it. The Pi’s green activity light should flicker as it starts.

## 7. Connect from your laptop

Connect your laptop to the same Wi-Fi network as the Pi, then open a terminal and run:

```bash
ssh pi@field-sampler.local
```

On your first connection, type `yes` to accept the host key, then enter your Pi password. The terminal won’t show characters as you type the password.

Once connected, your prompt will show `pi@field-sampler`. Commands entered here run on the Pi.

## 8. Run the setup script

In the terminal connected to the Pi, download the setup script:

```bash
curl -fsSL https://raw.githubusercontent.com/tigrisli/curious-machines/main/02-field-sampler/setup.sh -o setup.sh
```

You can read the script with `less setup.sh`; press `q` to exit. Then run it:

```bash
bash setup.sh
```

Allow about 15 minutes. Some installation steps may produce no output for a while. Keep the terminal open until the script finishes.

When it finishes, **don’t reboot yet**. Test the lights first, then install the audio driver.

## 9. Test the lights

Check that the Pi can control Blinkt!:

```bash
python3 -c "import blinkt; blinkt.set_all(255,0,0); blinkt.show()"
```

All eight LEDs should turn red. Then switch them off:

```bash
python3 -c "import blinkt; blinkt.clear(); blinkt.show()"
```

The LEDs should go out.

## 10. Install the audio driver

The audio driver lets the Pi use the ReSpeaker’s microphones and audio outputs. These commands are for the **v2 board**.

**Run one command at a time.** Wait for each to finish and check for errors before continuing.

```bash
git clone https://github.com/Seeed-Studio/seeed-linux-dtoverlays.git
```

```bash
cd seeed-linux-dtoverlays
```

```bash
make overlays/rpi/respeaker-2mic-v2_0-overlay.dtbo
```

```bash
sudo cp overlays/rpi/respeaker-2mic-v2_0-overlay.dtbo /boot/firmware/overlays/respeaker-2mic-v2_0.dtbo
```

```bash
echo "dtoverlay=respeaker-2mic-v2_0" | sudo tee -a /boot/firmware/config.txt
```

```bash
sudo reboot
```

> The original Pi Zero W and the Pi Zero 2 W are different boards. When consulting Seeed’s documentation, check that the instructions match your Pi, ReSpeaker version and operating system.

The reboot will close your SSH connection. Give the Pi time to restart, then reconnect and list its audio devices:

```bash
ssh pi@field-sampler.local
```

```bash
aplay -l
```

Look for **`seeed2micvoicec`** and note its card number. The examples below use **card 0**. If yours has a different number, update the audio commands and the `CLAUDE.md` file in step 16 to match.

## 11. Test the sound

Before testing playback, check the mixer settings. Outputs may be muted or set to zero after installation.

```bash
alsamixer -c 0
```

Press **F3** for the Playback controls. Then use **left and right arrows** to move between them and **up arrow** to raise each one:

- **PCM** → around 90
- **Line DAC** → 100
- **Line PGA** → 100
- **Line** → 100
- **HP** → 100

Continue moving right to check for controls beyond the edge of the window.

If a control shows **MM** at the bottom it's muted — press **M** to switch it to **OO**.

Press **Esc** to exit, then save the settings so they persist after a reboot:

```bash
sudo alsactl store
```

**Line** is what drives the JST speaker socket. **HP** feeds the 3.5mm jack.

**Record a five-second test.** Speak into the microphones while this command runs:

```bash
arecord -D plughw:0,0 -f S16_LE -r 48000 -c 2 -d 5 test.wav
```

```bash
aplay -D plughw:0,0 test.wav
```

You should hear your recording through the speaker. If you don’t, check the card number, mixer settings and speaker connection before continuing.

## 12. Test the screen

<!-- photo: the OLED showing FIELD SAMPLER -->

Give your user access to the hardware interfaces and install the packages used by the screen library. Run these commands one at a time:

```bash
sudo usermod -a -G i2c,spi,gpio pi
```

```bash
sudo apt install -y python3-dev python3-numpy libfreetype6-dev libjpeg-dev build-essential
```

```bash
exit
```

The new permissions take effect when you log in again:

```bash
ssh pi@field-sampler.local
```

Run the screen test installed by `setup.sh`:

```bash
python3 ~/sampler/test-screen.py
```

The screen should show a white border with **FIELD SAMPLER** in the centre.

**If nothing appears**, open the file and change `ADDRESS = 0x3C` to `0x3D` — some boards ship with the other address set. **If the picture isn't the way up you want it**, change `ROTATE` — `0`, `1`, `2` and `3` are 0, 90, 180 and 270 degrees clockwise.

```bash
nano ~/sampler/test-screen.py
```

Press `Ctrl+O`, then Enter to save, and `Ctrl+X` to exit. Run the test again to check your changes.

## 13. Test the pads

<!-- photo: a finger on one of the touch pads -->

```bash
python3 ~/sampler/test-pads.py
```

Touch each pad in turn. You should see `pad 0` through to `pad 11`.

Make a note of which physical pad gives which number — the order may not be what you'd guess from looking at the board, and you'll want to know when you're deciding what each one does.

`Ctrl+C` to stop.

**If it can't find the controller**, scan the I2C bus to see what's there:

```bash
i2cdetect -y 1
```

You're looking for `5b`. If it's missing, check the Grove cable is in the **I2C** socket. If you see `5a` instead, change `ADDRESS` in the test file to `0x5A` and use that value in `CLAUDE.md` later too.

## 14. Test the knob

```bash
python3 ~/sampler/test-encoder.py
```

Turn it. The count should go up one way and down the other.

`Ctrl+C` to stop.

That's every part tested. Now for the software.

## 15. Install Claude Code on your laptop

Open a new terminal **on your laptop** — not one connected to the Pi — and install Claude Code:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

If Claude Code is already installed, you can skip that.

**On macOS you'll probably need one more line.** The installer puts `claude` in `~/.local/bin`, which isn't somewhere the shell looks by default — so you get `command not found` straight after it says the install worked. Add it to your path:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

```bash
source ~/.zshrc
```

Check it worked:

```bash
claude --version
```

If that prints a version number you're set. The installer tells you the same thing in its setup notes, but it's easy to miss under the "Installation complete" message.

Don't start Claude yet — there's some setup to do first, and it's easier outside a running session.

## 16. Set up access to the Pi

Claude needs to reach the Pi without being asked for a password every time, and it needs to know what hardware it's dealing with. Both are quicker to sort before you start it.

Still on your laptop, first check whether you already have an SSH key:

```bash
ls ~/.ssh/*.pub
```

**If that lists anything**, you have a key already — skip the next command and go straight to `ssh-copy-id`.

**If it says "No such file or directory"**, make one:

```bash
ssh-keygen -t ed25519
```

> Only run `ssh-keygen` if you don't already have a key. If you do and you run it anyway, it offers to overwrite — and saying yes would lock you out of anything else using that key, GitHub included.

Then copy it to the Pi:

```bash
ssh-copy-id pi@field-sampler.local
```

This asks for your Pi password once, to install the key.

Test it:

```bash
ssh pi@field-sampler.local 'echo it works'
```

You should see `it works` without a Pi password prompt. Resolve any connection or key issues before continuing.

Now make the project folder:

```bash
mkdir ~/field-sampler
cd ~/field-sampler
```

And create a file in it called `CLAUDE.md`. This is what tells Claude about the hardware and how to deploy to it.

Paste this whole block into the terminal at once — it's a single command, so it won't get mangled the way a list of them would:

```bash
cat > ~/field-sampler/CLAUDE.md <<'EOF'
# Field Sampler

The target device is a Raspberry Pi Zero 2 W at pi@field-sampler.local.
Code is written here on the laptop and runs on the Pi.

To deploy and run:
  rsync -av --exclude '.git' ./ pi@field-sampler.local:~/sampler/
  ssh pi@field-sampler.local 'cd ~/sampler && python sampler.py'

Hardware on the Pi:
- ReSpeaker 2-Mics pHAT v2. Audio in and out is ALSA card 0,
  "seeed2micvoicec". Use plughw:0,0 at 48000Hz, 16-bit, stereo.
  Button on GPIO17.
- Grove MPR121 capacitive touch, 12 pads, I2C 0x5B.
- Pimoroni 1.12" OLED, 128x128 mono, I2C 0x3C. Drive it with luma.oled's
  `sh1106` class at width=128, height=128, rotate=2.
- Grove rotary encoder on GPIO12 and GPIO13. No push switch.
- Pimoroni Blinkt!, 8 APA102 RGB LEDs, GPIO23 and GPIO24.
  Use the `blinkt` python library.

Keep in mind:
- 512MB of RAM and no desktop. Draw to the OLED over I2C, never X11.
- Load samples into memory once; don't re-read files on every pad hit.
- Keep audio buffers small so pads trigger without noticeable delay,
  but not so small that playback crackles.
- Write recordings to a temporary filename and rename once finished,
  so an interrupted save can't leave a broken file behind.
- Wrap file loading in try/except. A bad file should be skipped,
  never crash the sampler on startup.
- Set `d.persist = True` on the OLED device, or luma blanks the screen
  every time a script exits.
- Recordings go in ~/sampler/recordings.
EOF
```

**If your tests gave different values**, edit them in afterwards — the audio card number from step 10, or the pad address from step 13:

```bash
nano ~/field-sampler/CLAUDE.md
```

Getting these right matters more than anything else in this step. Every bit of code Claude writes from here on depends on them.

## 17. Write the sampler software

Now start Claude, from inside the project folder so it can see your `CLAUDE.md`:

```bash
cd ~/field-sampler
claude
```

Follow the prompts to sign in with your Claude account and trust the folder.

Then describe how you want the sampler to work. Ask Claude to write the code, deploy it to the Pi and run it so you can test the controls.

Ask for the script to be called `sampler.py`, because the later steps look for that name.

Choose one of these prompts as a starting point:

**A sampler that records and plays back:**

```
write me a python script called sampler.py for the device described in
CLAUDE.md. hold the button on GPIO17 to record from the microphones, let go
to stop. save it and assign it to the next free touch pad. tapping a pad
plays its sound. show on the OLED which pads are loaded, and use the eight
Blinkt! LEDs to indicate recording and playback activity. deploy it to the pi and run it
so I can hear it
```

**A looper:**

```
write me a python script called sampler.py that records short loops and
plays them on top of each other. the button starts and stops recording a
loop. each pad holds one loop and tapping it mutes or unmutes it. the
encoder sets the master volume. use the blinkt LEDs as a playhead running
left to right in time with the loop
```

**A keyboard:**

```
write me a python script called sampler.py that records one sound when I
hold the button, then lets me play it back at twelve different pitches, one
per pad, like a keyboard. the encoder changes how long each note rings for
```

## 18. Change it

Once the basic controls work, you can add features or change how they behave. To return to your previous Claude session, run this from the project folder on your laptop:

```bash
claude --continue
```

Try one change at a time, then test it on the device. For example:

```
add an eight-step sequencer mode. let me select a sound before entering
that mode, then use the first eight pads to toggle its steps on and off.
use the Blinkt! LEDs to show the current step. give me a way to return
to normal pad playback
```

```
make the pads play their sound backwards when I turn the encoder past halfway
```

```
show a waveform of each sound on the OLED when I tap its pad
```

More ideas are in [prompts.md](prompts.md).

## 19. Optional: use it as a USB MIDI controller

You can also use the pads to control instruments in Ableton, Logic or other music software by setting up the Pi as a USB MIDI device. MIDI sends note and control messages; to copy the audio you’ve recorded, use the **Get your recordings** section below.

```
as well as playing sounds itself, set up the pi as a USB MIDI gadget so when
I plug it into my laptop it also appears as a MIDI device. each pad sends a
different note, the encoder sends a CC. the sampler should keep working on
its own exactly as before
```

Then plug it in with a micro-USB cable, using the port marked **USB** rather than **PWR**, and look for it in your music software.

This step is optional. The sampler can still record and play on its own.

## 20. Take it outside

Once you’re happy with how it works, enable the sampler service so it starts automatically:

```bash
ssh pi@field-sampler.local
```

```bash
sudo systemctl enable --now sampler
```

The sampler will now start when the Pi boots. Connect a USB battery pack to the **PWR** port to use it away from your desk.

Before taking it outside, ask Claude to add a shutdown control that won’t conflict with recording. Test it while you’re still at your desk. Shut the Pi down before disconnecting power to avoid corrupting the SD card.

To make further changes, stop the running service and reopen Claude Code from your laptop:

```bash
ssh pi@field-sampler.local 'sudo systemctl stop sampler'
cd ~/field-sampler
claude --continue
```

---

## Get your recordings

Run this on your laptop, not on the Pi:

```bash
scp "pi@field-sampler.local:~/sampler/recordings/*.wav" ~/Desktop/
```

On Windows PowerShell, end with `$HOME\Desktop\` instead of `~/Desktop/`.

## Turn it off

```bash
ssh pi@field-sampler.local 'sudo poweroff'
```

Allow the Pi to finish shutting down before disconnecting power.

## Pick it up later

Open a terminal on your laptop and return to the project:

```bash
cd ~/field-sampler
claude --continue
```

## If something goes wrong

See [troubleshooting.md](troubleshooting.md) for help with connections, audio and the display.

---

Made by [Tigris](https://instagram.com/tigrisli), in partnership with [Claude](http://clau.de/tigrisli)
