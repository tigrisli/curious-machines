# Ideas

Starter prompts for the field sampler. Paste one in, see what you get, then break it.

Everything here assumes the `CLAUDE.md` from the guide is in your folder, so Claude already knows the hardware.

---

## The basics

**A simple sampler**

```
hold the button on GPIO17 to record from the microphones, let go to stop.
save it and assign it to the next free touch pad. tapping a pad plays its
sound. show on the OLED which pads are loaded
```

**A looper**

```
record short loops and play them on top of each other. the button starts
and stops recording a loop. each pad holds one loop, and tapping it mutes
or unmutes that loop. the encoder sets the master volume
```

**A keyboard**

```
record one sound, then let me play it back at twelve different pitches,
one per pad, like a keyboard. the encoder changes how long each note rings
```

---

## Using the eight lights

**A playhead**

```
use the blinkt LEDs as a playhead running left to right in time with the
loop, so I can see where in the bar I am
```

**A step sequencer**

```
turn the blinkt into an 8 step sequencer. tapping a pad picks a sound, then
tapping one of the first 8 pads places it on that step. the lights run left
to right as it plays, and light brighter on steps that have something on them
```

**A level meter**

```
use the blinkt as a level meter while recording, so I can see how loud the
thing I'm pointing at is before I commit to it
```

**One colour per sound**

```
give each recording a colour and show it on the blinkt when I tap its pad,
so the device has eight colours I start to recognise
```

---

## Making it strange

**Backwards**

```
make the pads play their sound backwards when I turn the encoder past halfway
```

**Decay**

```
every time a pad is played, degrade its sound slightly — a little more
noise, a little less top end. after twenty plays it should be barely
recognisable
```

**The eavesdropper**

```
listen continuously and automatically sample anything louder than the
room. assign each one to the next pad. I never press record, it just
collects things
```

**One take only**

```
each pad can only be recorded once. to record over it I have to hold the
pad down for five seconds first, and the OLED should count down while I do
```

**Chop it**

```
record one long sound, then slice it into twelve equal pieces and put one
on each pad, so I can rearrange it by tapping
```

**Timestamped**

```
show on the OLED when each sample was recorded — the time and how long ago.
"gravel, 14:32, two hours ago"
```

**Choir**

```
when I hold a pad, loop its sound continuously. holding several at once
should layer them, so I can build a chord out of recorded sounds
```

---

## Going further

**Mix as you go**

```
let me hold two pads at once and hear both sounds together. the encoder
should set the volume of whichever pad I touched last, so I can balance
them by ear without stopping
```

**MIDI out, if you want it**

```
as well as playing sounds itself, set up the pi as a USB MIDI gadget so
when I plug it into my laptop it also appears as a MIDI device. each pad
sends a different note, the encoder sends a CC. the sampler should keep
working on its own exactly as before
```

**A metronome**

```
add a click track at a tempo I set with the encoder, and make recordings
snap to the nearest beat
```

**Waveforms**

```
show a waveform of each sound on the OLED when I tap its pad
```

**A shutdown button**

```
holding the button for five seconds should shut the pi down safely, with a
countdown on the OLED
```

---

## How to prompt well

**Say what you want, not how to build it.** "Make it play backwards past halfway" works better than describing array slicing.

**One change at a time.** Ask for a thing, run it, hear it, then ask for the next. A list of six changes gets you six half-working ones.

**Tell it what you heard.** "It crackles when two pads play together" is more useful than "it doesn't work." Claude can't hear your device, so you're its ears.

**Use `claude --continue`** so it remembers the thing you've been building rather than starting fresh.

## Keeping it fast

A pad that triggers 200ms after you touch it feels broken, even if it's technically working. If things get sluggish:

```
the pads feel slow to respond. keep the samples loaded in memory and make
the audio buffer smaller so there's less delay between touching a pad and
hearing it
```

And if it crackles instead, the buffer has gone too small:

```
the playback crackles. make the audio buffer bigger until it's clean
```

Somewhere between those two is the sweet spot, and it differs depending on what else your code is doing.
