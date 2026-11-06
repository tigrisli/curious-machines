# What can a camera capture beyond images?

![Curious Machines: stack, prompt, and play](images/cover.jpg)

What could a screen, a camera, and a tiny computer become in your hands?

This first project is about giving your ideas physical form. You'll combine a Raspberry Pi, a touchscreen and a camera module (around £160 of parts), then use Claude Code to bring your own concepts to life. No soldering or coding experience is needed.

Just because we have the parts for a camera, doesn't mean it just has to take pictures - it could be a camera that **pixelates** your face, tells you how fast a Londoner is walking, or maybe it's a Berghain bouncer!

It's a chance to play, experiment, and surprise yourself with what your imagination can bring to life!

**About 90 minutes** start to finish, and roughly half of that is waiting while the Pi installs things.

## What you need

![What's on our table](images/parts.jpg)

![What's a Raspberry Pi](images/what-is-a-pi.jpg)

**Parts**

- Raspberry Pi 4 (4GB recommended, 2GB works): £65+
- Waveshare 2.8" DPI touchscreen (480×640): £34
- Raspberry Pi Camera Module 3: £25
- LiPo battery HAT (optional): £18
- 32GB microSD card: £9
- USB-C power supply (5V/3A): £9

Prices are rough, and Pi prices have been rising, so check before you order.

Any Raspberry Pi camera module works. The setup script is made for this Waveshare screen, so a different screen needs its own settings in `setup.sh`.

**On your laptop**

- [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- A way to plug in the SD card
- A terminal. On Mac, press ⌘+space and type `terminal`. On Windows, open the start menu and type `powershell`.

**Account**

- A paid Claude plan (Pro or above)

---

## 1. Flash the SD card

![Pi Imager: choose Raspberry Pi OS 64-bit](images/flash-pi-os.jpg)

This erases the card.

Download [Raspberry Pi Imager](https://www.raspberrypi.com/software/) if you don't have it yet. Open it and fill in each screen, clicking **NEXT** to move on.

**Device:** choose Raspberry Pi 4.

![Pi Imager device screen with Raspberry Pi 4 selected](images/pi-imager-setup-1.jpeg)

**OS:** choose Raspberry Pi OS (64-bit).

![Pi Imager operating system screen with Raspberry Pi OS 64-bit selected](images/pi-imager-setup-2.jpeg)

**Storage:** choose your SD card.

![Pi Imager storage screen with the SD card selected](images/pi-imager-setup-3.jpeg)

**Hostname:** type `camera`.

![Pi Imager hostname screen with camera typed in](images/pi-imager-setup-4.jpeg)

**Localisation:** choose your capital city.

![Pi Imager localisation screen with London selected](images/pi-imager-setup-5.jpeg)

**User:** type the username `pi` and choose a password.

![Pi Imager user screen with the username pi and a password filled in](images/pi-imager-setup-6.jpeg)

**Wi-Fi:** type your network name and password.

![Pi Imager Wi-Fi screen with fields for the network name and password](images/pi-imager-setup-7.jpeg)

**Remote access:** turn on Enable SSH, then choose Use password authentication.

![Pi Imager SSH screen with SSH on and password authentication selected](images/pi-imager-setup-8.jpeg)

**Raspberry Pi Connect:** leave this off.

![Pi Imager Raspberry Pi Connect screen with the switch off](images/pi-imager-setup-9.jpeg)

**Write:** check the summary, then click **WRITE**.

![Pi Imager summary screen listing the chosen settings](images/pi-imager-setup-10.jpeg)

Click **I UNDERSTAND, ERASE AND WRITE**.

![Pi Imager warning that all data on the SD card will be erased](images/pi-imager-setup-11.jpeg)

Wait for it to finish. It takes about 10 minutes.

![Pi Imager writing to the SD card with a progress bar](images/pi-imager-setup-12.jpeg)

When you see **Write complete!**, click **FINISH** and take out the SD card.

![Pi Imager write complete screen with the FINISH button](images/pi-imager-setup-13.jpeg)

## 2. Connect the camera

![Connect the camera](images/connect-camera.jpg)

1. Lift the black clip on the Pi's camera connector.
2. Slide the ribbon in with the blue tab facing the USB ports.
3. Press the clip down.

## 3. Add the battery HAT (optional)

![Stacking hardware with HATs](images/hats.jpg)

![Stacking the LiPo battery HAT](images/lipo-hat.jpg)

1. Connect the battery to the board.
2. Attach the battery with double-sided tape.
3. Screw on the spacers.
4. Press the board onto the Pi's pins.

Leave the battery switch off.

## 4. Add the touchscreen

![And now the touchscreen](images/touchscreen.jpg)

Press the screen onto the pins until it sits flat. Check that every pin is in its row.

## 5. Power on

![Flip the Pi over and insert the SD card](images/sd-card.jpg)

![Power on your Pi](images/power-on.jpg)

1. Insert the SD card.
2. Plug in the USB-C power supply.
3. Wait 3 minutes.

The little screen stays dark for now. Check that the red light on the Pi is on.

<!-- photo: red power light -->

## 6. Connect from your laptop

![Setting up our laptop keyboard to our Pi](images/ssh-explained.jpg)

Put your laptop on the same wifi as the Pi, then open a terminal and run:

```bash
ssh pi@camera.local
```

![Terminal with the ssh command typed in](images/pi-ssh-firstime-1.jpeg)

The first time, it asks if you want to continue connecting.

![Terminal asking whether to continue connecting](images/pi-ssh-firstime-2.jpeg)

Type `yes` and press enter.

![Terminal with yes typed after the question](images/pi-ssh-firstime-3.jpeg)

Type your password and press enter. Nothing shows while you type it.

![Terminal asking for the password](images/pi-ssh-firstime-4.jpeg)

When it works, your prompt says `pi@camera`.

![Terminal logged in to the Pi, with the prompt pi@camera](images/pi-ssh-firstime-5.jpeg)

## 7. Run the setup script

Run these three commands, one at a time:

```bash
git clone https://github.com/tigrisli/curious-machines.git
cd curious-machines/01-camera
bash setup.sh
```

The install takes a while, often 10 minutes or more. Here's what you'll see along the way.

**Download the project.** Run the first command and wait for your prompt to come back.

![Terminal with the git clone command typed in](images/pi-setup-script-1.jpeg)

![Terminal showing Cloning into curious-machines](images/pi-setup-script-2.jpeg)

![Terminal showing the download finished and the prompt back](images/pi-setup-script-3.jpeg)

**Go into the folder.** Run the second command.

![Terminal with the cd command typed in](images/pi-setup-script-4.jpeg)

**Start the script.** Run the third command.

![Terminal with bash setup.sh typed in](images/pi-setup-script-5.jpeg)

**Leave it on this screen.** It stays here for about 5 minutes while it downloads updates. Nothing moves, and that's normal, so don't panic or close the terminal. It will carry on by itself.

If nothing has changed after 15 minutes, there may be a problem. Press `ctrl+c` and run `bash setup.sh` again.

![Terminal paused on Updating the system, with no output below it](images/pi-setup-script-6.jpeg)

**Let it install.** Lots of text scrolls past from here. You don't need to do anything.

![Terminal showing the update starting](images/pi-setup-script-7.jpeg)

![Terminal showing packages being unpacked and set up](images/pi-setup-script-8.jpeg)

![Terminal showing later install steps](images/pi-setup-script-9.jpeg)

**Reboot.** When it says **Done**, run:

```bash
sudo reboot
```

![Terminal showing Done, with the prompt back](images/pi-setup-script-10.jpeg)

![Terminal with sudo reboot typed in](images/pi-setup-script-11.jpeg)

Your terminal disconnects and may say `Connection closed` or `Broken pipe`. That's normal. The Pi is restarting, and your terminal is back on your laptop.

![Terminal showing the connection closed and the laptop prompt back](images/pi-setup-script-12.jpeg)

After about 30 seconds, the Pi turns back on and text appears on the little screen.

<img src="images/setup-script-reboot.jpg" alt="The Pi held in a hand, with startup text on the little screen" width="400">

## 8. Install Claude Code

Connect to the Pi again:

```bash
ssh pi@camera.local
```

![Terminal with the ssh command typed in after the reboot](images/claude-pi-install-1.jpeg)

Type your password and press enter. It won't ask you to type `yes` this time.

![Terminal asking for the password](images/claude-pi-install-2.jpeg)

Install Claude Code:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

![Terminal with the install command typed in](images/claude-pi-install-3.jpeg)

![Terminal showing Installing Claude Code native build](images/claude-pi-install-4.jpeg)

Wait for **Installation complete!** Under **Setup notes**, it gives you one more line to run.

![Terminal showing Claude Code installed, with a setup note about PATH](images/claude-pi-install-5.jpeg)

Run that line:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

![Terminal with the PATH line typed in](images/activate-claude-1.jpeg)

Start Claude Code:

```bash
claude
```

![Login to Claude](images/login-to-claude.jpg)

**Choose a text style.** Use the up and down arrows, then press enter.

![Claude Code asking you to choose a text style](images/activate-claude-2.jpeg)

**Choose how to log in.** Choose **Claude account with subscription** and press enter.

![Claude Code login options with Claude account with subscription selected](images/activate-claude-3.jpeg)

**Open the link.** Press `c` to copy the link, then paste it into your laptop's browser. If that doesn't work, select the link with your mouse and copy it.

![Claude Code showing a sign-in link](images/activate-claude-4.jpeg)

![Claude Code showing the sign-in link selected and copied](images/activate-claude-5.jpeg)

**Authorize.** Log in if it asks you to, then click **Authorize**.

![Browser page asking to connect Claude Code to your account](images/activate-claude-6.jpeg)

**Copy the code.** Click **Copy code**.

![Browser page showing an authentication code and a Copy code button](images/activate-claude-7.jpeg)

**Paste the code.** Go back to your terminal, paste it in and press enter. It shows as stars, and that's normal.

![Terminal with the code pasted in as stars](images/activate-claude-8.jpeg)

**Press enter twice** to move past these two screens.

![Claude Code showing that login was successful](images/activate-claude-9.jpeg)

![Claude Code security notes](images/activate-claude-10.jpeg)

**Trust the folder.** Choose **Yes, I trust this folder** and press enter.

![Claude Code asking whether you trust the folder](images/activate-claude-11.jpeg)

Claude Code is ready.

![Claude Code open and waiting for a prompt](images/activate-claude-12.jpeg)

## 9. Make a camera

Your camera's files live in the project folder, so start Claude Code there. Press `ctrl+d` twice to leave Claude, then run:

```bash
cd ~/camera
claude
```

If it asks you to trust the folder, say yes.

![Give Claude access to our project folder](images/trust-folder.jpg)

Now describe the camera you want, in your own words. Ask for the script to be called `camera.py`, because the later steps look for that name.

![Let's make a simple camera shutter](images/first-prompt.jpg)

Not sure where to start? Try one of these.

A simple camera:

```
write me a python script called camera.py that shows a live preview on the
screen and takes a photo when I press enter. save it with the time in the
filename, and flash the photo up on screen for a second before going back
to preview
```

A camera that pixelates everything:

```
write me a python script called camera.py that shows a live preview on the
screen, pixelated with big chunky blocks about 20 pixels wide. take a photo
when I press enter and save it with the time in the filename
```

A camera with a bouncer:

```
write me a python script called camera.py that shows a live preview on the
screen. when it sees a face, flash green or red at random and show a verdict
on screen. only save the photo if it's green
```

![Let's run it](images/run-it.jpg)

Press `ctrl+d` twice to leave Claude, then run it:

```bash
python camera.py
```

Try it out. Press `ctrl+c` to stop.

### Optional: check the camera yourself

Use this if the picture doesn't appear, or if you want to see the camera working without Claude. Stop your script first, then run:

![Activate our camera](images/activate-camera.jpg)

```bash
rpicam-hello --list-cameras
rpicam-hello -t 0
```

The first command lists your camera. The second shows a live picture on the little screen. Press `ctrl+c` to stop it.

## 10. Change it

![The method: describe, run, feedback](images/the-method.jpg)

Go back to your conversation with Claude:

```bash
claude --continue
```

Add tap to shoot:

![Adjust the shutter camera and activate the touchscreen](images/touch-shutter.jpg)

```
now make the touchscreen work so tapping the screen takes a photo. it's a
Waveshare 2.8" capacitive IPS LCD (480×640, DPI). the display already works,
but the touch needs activating
```

Claude may ask you to reboot. If it does, connect again and run:

```bash
cd ~/camera
claude --continue
```

Then try another change:

![Play with the camera capture display](images/pixelate.jpg)

```
make the picture pixelated, with big chunky blocks about 20 pixels wide
```

Leave Claude and run `python camera.py` after each change. More ideas are in [prompts.md](prompts.md).

![Play, experiment and make it your own](images/ideas.jpg)

![Designing the screen display and buttons](images/screen-design.jpg)

## 11. Make it portable

Once tap to shoot works, run:

```bash
sudo systemctl enable --now camera
```

Your camera now starts whenever the Pi turns on. Unplug from the wall and switch the battery on.

Ask Claude to add a shutdown button before you take it out. Cutting the power can corrupt the card.

To change it again:

```bash
sudo systemctl stop camera
cd ~/camera
claude --continue
```

To start it again:

```bash
sudo systemctl start camera
```

<!-- photo: finished camera -->

---

## Get your photos

Run this in a terminal on your laptop, not one connected to the Pi:

```bash
scp "pi@camera.local:~/camera/*.jpg" ~/Desktop/
```

On Windows PowerShell, end the command with `$HOME\Desktop\` instead of `~/Desktop/`.

## Turn it off

```bash
sudo poweroff
```

Wait for the lights to stop, then unplug it.

## Pick it up later

```bash
ssh pi@camera.local
cd ~/camera
claude --continue
```

## If something goes wrong

See [troubleshooting.md](troubleshooting.md). To use it away from your wifi, see [away-from-home.md](away-from-home.md).

---

Made by [Tigris](https://instagram.com/tigrisli), in partnership with [Claude](http://clau.de/tigrisli)
