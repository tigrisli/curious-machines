# Prompts to start from

None of these are finished ideas. Pick one, get it working, then change something and see where it takes you.

Type them into Claude Code while you're in your `~/camera` folder.

---

## Cameras that behave

### Kiss cam
> find faces in the preview, and when exactly two are visible, draw a big heart between them. if they stay there for 3 seconds, count down and take the photo automatically

**Then break it:** make it give them a compatibility score it has absolutely no way of knowing.

### Bouncer
> when you see a face, flash green or red at random and show a verdict on screen. only actually save the photo if it's green

**Then break it:** give it a reason. It only lets you in if you're wearing a certain colour.

### Hair ID
> crop the area just above the detected face, zoom into it, and show a confident one-line verdict naming the hairstyle on screen

**Then break it:** have it rate the hair out of ten and refuse to explain the criteria.

### Shy
> only take the photo when no face is detected — so it waits until I look away

**Then break it:** make it get impatient. Text on screen asking you to look away.

### The refuser
> about one time in three, refuse to take the photo. show the word "no" on screen and don't explain

**Then break it:** let it refuse for reasons. Too bright, too many people, Tuesday.

---

## Cameras that see differently

### Pixelate
> make the picture pixelated — big chunky blocks, about 20 pixels wide

**Then break it:** tie the block size to how close the face is, so people resolve as they walk toward it.

### Slit scan
> instead of a normal photo, build the image one column of pixels at a time, taking a new column every frame, so anything that moves gets stretched

**Then break it:** slow it right down. One column a minute, and you've got a photograph of a whole day.

### ASCII
> convert the live picture to text characters and show it on screen in a monospace font

**Then break it:** use only letters from your own name.

### Glitch
> shift the red and blue channels apart and displace random rows of the image

**Then break it:** make the glitch respond to movement, so holding still gives you a clean picture.

### Ten seconds ago
> keep the last ten seconds of frames in memory and show me those on screen instead of the live picture

**Then break it:** make the delay change depending on how fast you're moving.

---

## Cameras that keep things

### The average
> blend every photo taken so far into one cumulative image, so all the faces pile into a single blurry portrait

### Paranoid
> draw a box around every face with a made-up ID number, and write a log of everything it sees with timestamps

### Describer
> when I take a photo, don't show the image — show a line of text describing what was in it, in big letters on the screen

*(This one needs an internet connection, since it asks Claude what it's looking at.)*

---

## How to prompt well

**Say what you want to happen, not how to code it.** "Make it blocky" works better than naming a specific function.

**Run it after every change.** One change at a time, so you know what caused what.

**Describe what you actually saw.** "Too slow", "all grey", "it only works in the middle of the frame" — that's the most useful thing you can tell it.

**When something works, ask it to explain one line to you.** That's how the afternoon turns into something you can do on your own next time.

---

## Keeping it fast

The Pi 4 is a small computer and the camera is a big sensor, so:

- Preview at 640×480, stills no bigger than 2304×1296
- Run any face detection on a downscaled copy, every few frames rather than every frame
- Use OpenCV's haar cascades rather than anything heavier

There's a `CLAUDE.md` in your `~/camera` folder that tells Claude all of this already, so you shouldn't have to think about it.
