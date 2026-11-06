# Taking your camera somewhere else

Your Pi only knows the wifi you gave it when you flashed the card in step 1. Take it anywhere else and it won't find a network — and since there's no keyboard on it, you can't tell it about the new one.

The fix is to have the Pi **make its own network** when it can't find one it recognises. Your laptop joins that instead, and you're back in.

> **Do this before you leave the house.** Everything here needs you to already be connected to the Pi, which is exactly what you won't be once you've gone somewhere new.

**You don't need this to finish the main guide** — it's for afterwards, when you want to take the camera out.

---

## Set it up before you go

SSH into your Pi and run:

```bash
sudo nmcli device wifi hotspot ifname wlan0 ssid camera password cameracamera
```

**Your terminal will disconnect.** That's how you know it worked — the Pi has taken over its own radio to broadcast instead of joining.

Now look in your laptop's wifi menu, join the network called `camera`, and SSH back in exactly as before:

```bash
ssh pi@camera.local
```

Then tell it to only do this when there's nothing else available:

```bash
sudo nmcli connection modify Hotspot connection.autoconnect yes
sudo nmcli connection modify Hotspot connection.autoconnect-priority -10
```

The negative priority means a known network always wins. At home it joins your wifi; anywhere else it makes its own.

**Test it before you rely on it.** Reboot with your usual wifi in range and check it joins that rather than hotspotting:

```bash
nmcli connection show --active
```

---

## Adding a new network

Once you're connected over the hotspot, you can teach the Pi a new wifi network:

```bash
sudo nmcli connection add type wifi con-name "HOME" ifname wlan0 ssid "YOUR-WIFI" \
  wifi-sec.key-mgmt wpa-psk wifi-sec.psk "YOUR-PASSWORD" \
  connection.autoconnect yes connection.autoconnect-priority 10
sudo reboot
```

This writes a saved network without touching the live connection, so you don't get kicked off halfway through.

After the reboot the Pi joins your own wifi. Put your laptop back on the same network and you can SSH in normally again.

> **One thing worth knowing:** while you're connected over the Pi's own hotspot there's no internet, so Claude Code won't work until you've added a real network.

To change the camera once you're connected, follow the end of [step 11](README.md#11-make-it-portable).
