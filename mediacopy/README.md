## Media Copy details & investigations

Media Copy is how one can take a screenshot from a VT340. It can be of
the entire screen or a region. Depending upon complexity of the
graphics, it can take a long time (~5m) to transmit. 

A script for making screenshots can be found in [mediacopy.sh](mediacopy.sh).

### Sequence for sending

0. Set VT340 to Level 2 graphics in Printing Set-Up menu.
1. Set printing options (color, transparent background).
2. Send REGIS "HardCopy" command.
3. Receive sixel data from VT340.

###

To send the screen to the host as sixel data, you set the MediaCopy
output to "2", optionally change settings, and then send the ReGIS
"Hard Copy" command. (For some reason, the normal "Media Copy"
command, `CSI i`, does not work. Perhaps because I don't have a
printer attached?)

```bash
CSI=$'\e['			# Control Sequence Introducer
DCS=$'\eP'			# Device Control String
ST=$'\e\\'			# String Terminator

# MC: Media Copy, "2" means send graphics to host, not printer
echo -n ${CSI}'?2i'		

# DECGEPM: Graphics Expanded Print Mode (only for Level 1 Graphics)
#echo -n ${CSI}'?43l'		# Compressed:  6" x 3" printout, 800x240
echo -n ${CSI}'?43h'		# Expanded:   12" x 8" printout, 1600x480

# DECGPCM: Print Graphics Color Mode
#echo -n ${CSI}'?44l'		# Print in Black and White
echo -n ${CSI}'?46h'		# Print in Color

# DECGPCS: Print Graphics Color Syntax
#echo -n ${CSI}'?45l'		# Print using HLS colors
echo -n ${CSI}'?45h'		# Print using RGB colors (ImageMagick reqs)

# DECGPBM: Print Graphics Background Mode
echo -n ${CSI}'?46l'		# Do not send background when printing
#echo -n ${CSI}'?46h'		# Include background when printing

echo -n ${DCS}'p'		# Enter REGIS mode
echo -n $'S(H)'			# Screen hard copy
echo -n ${ST}			# Exit REGIS mode
```

#### Media Copy response from VT340

The response varies depending upon what options you've chosen and
whether your VT340 is set up for Level 2 graphics. There appears to be
a bug in the Level 1 code where the final line of sixels, including
the ST (string terminator) are not sent to the host. Fortunately, you
don't want Level 1 anyway since it uses wacky rectangular pixels.

The typical `read` idiom, sending the inquiry in the prompt then
reading everything until a certain character is seen, does not work
because the VT340 sends ST (`Esc \`) at the beginning *and* the end of
the data. Also note that, while having ST at the beginning is valid,
it confuses ImageMagick and libsixel (as of August 2021).

Here is what a typical Level 2 Graphics response from a VT340 might
look like:

```
[Esc] \ [Newline]
[Esc] 2 [Space] I
[Esc] P 0 ; 1 ; 6 q
" 1 ; 1 ; 800 ; 480
# 1 ; 2 ; 20 ; 20 
# 1 !255? !133? !8_ !9o !8_ $-
# 1 !255? !108? __oooowwww{{{{}}}} !39~ }}}}{{{{wwwwoooo__ $-
...
[ Esc ] \
```

The purpose of the introductory sequence, `Esc 2 Space I`, is
currently unknown but likely was a signal to printers to prepare them
for the data that was coming. (The VT340 only outputs that sequence
when set to Level 2 graphics, which is a bit mysterious).


# Scattered notes as I figure things out

* There are multiple options that affect the sixel data:

1. __[Level 1]__/Level 2 graphics	  	# Only in Set-Up
2. __[No Terminator]__/Send formfeed,	# Only in Set-Up
3. __[Compressed]__/Expanded,		# DECGEPM, 43
4. __[Mono]__/Color,			# DECGPCM, 44
5. __[HLS]__/RGB,				# DECGPCS, 45
6. __[No Background]__/Print Background,	# DECGPBM, 46
7. __[Compressed+Expanded]__/Rotated,	# DECGRPM, 47
  
__[VT340 defaults are in square brackets.]__

* Level 2 prints are the only known way to get a proper 1:1 pixel
  aspect ratio. However, that requires the user to first go into the
  VT340 Set-Up menu to enable it as there appears to be no escape
  sequence to change from the default of Level 1. Phooey.

    [Set-Up] key -> Printer Set-Up -> Sixel Graphics Level = level 2

* Level 2 graphics ignores the compressed/expanded option.
  Rotation does work.

* Printout is shifted 50 pixels to the right by default, use the
  P[0,0] suboption to REGIS's H() command to undo that offset. Note
  that the order of nesting parentheses is *incorrect* in the VT3xx
  documentation:

	REGIS_H="S(H(P[0,0])[$X1,$Y1][$X2,$Y2])"	This works
	REGIS_H="S(H(P[0,0][$X1,$Y1][$X2,$Y2]))"	This does not

* It takes several minutes to send a full screen of sixel data, so
  you'll want to print just a cropped part if you're debugging this.

* Before sending the sixel data, the VT340 sends ST (`Esc \`). 
  However, ImageMagick gets confused by sixel images that start with
  the String Terminator (it thinks they have only one pixel).

* VT340 defaults to printing in "mono". Must set to "color" using
  the DECGPCM (`Esc [?44h`) escape sequence.
  
* ImageMagick cannot handle HLS sixel graphics. Must set to RGB by
  using DECGPCS (`Esc [?45h`).

### Level 2 bugs

For some reason, in the middle of transmission, the VT340 will send a
byte with the eighth bit high (which should never happen) and then
pause for several minutes. ^Q does not wake it up. If I let it sit, it
eventually finishes sending the entire image, but there will be a
small glitch for every time the 8-bit bug happened.

* The eighth-bit glitch is most apparent with large complex images,
  but that may simply because they take longer to send. 

* The glitch is not completely repeatable in that the exact value of
  the byte that gets mangled is not always the same.

#### Questions about 8-bit glitch:

* Shabby serial line connection? Checked and seems okay.

* Try using printer port. Try second serial port.

* Does it happen with Level 1 printing? I don't recall that being the case.

* Are there certain pictures that trigger the glitch? It seems so as
  j4james's color_selection.sh was very difficult to get a media copy
  of until I switched the terminal to 132 column mode.

* Why did 132 column mode help? Or did it just move the glitch to an
  unnoticeable area?

* If it's a firmware bug, can I alter the ROM?

### Level 1 printing does not work well and should be avoided

Design misfeatures and bugs make Level 1 Graphics not worth it for
print outs from the VT340. Just use Level 2.

* Level 1 Compressed prints lose vertical resolution as they use the
  printer's 2:1 pixel aspect ratio, giving an effective resolution of
  800x240.

* Level 1 Expanded prints have the proper vertical resolution, but
  they double the horizontal resolution (1600x480) in an attempt to
  make printouts look right on DEC printers' 2:1 pixel aspect ratio.

* Rotating level 1 prints does not help as they still suffer the pixel
  aspect ratio problems depending on compressed or expanded setting.
  (400x480 or 800x960)

* Level 1 Compressed Print Mode (the default) has a few problems

  * Fonts look grotty (due to lower resolution)

  * String Terminator (ESC \) at end of file gets shown on screen
    instead of sent to the host which makes it hard (impossible?) to
    tell when the the VT340 has finished.

  * There is some other garbage shown on the screen after the ST,
    looks like the first 80 characters of the printout.
  
  * ImageMagick and XTerm get the geometry wrong because they do not
    understand a pixel aspect ratio of 2:1. They show the image as
    800x240 instead of 800x480.

* Level 1 Expanded Print Mode is better than Compressed in that no
  resolution is lost, but it still has a few problems:

  * ImageMagick can't read it if the starting ST isn't removed.
    (Treats the images as a single pixel)

  * ImageMagick and XTerm get the geometry wrong. They show expanded
    prints as 1600x480 instead of 1600x960.

  * Image is too large to fit on screen when catted to VT340. Repair
    with `convert -sample 50%x100% print.six print.png`.

### Level 1 Compressed Bugs

* When sending level 1 compressed prints, I can't seem to read the
  VT340 String Terminator sequence that marks the end of the print.
  Weirdly, it *does* display on the screen as "^[\". It shows even
  with 'stty -echo' set, which should have prevented anything from
  showing. It must be some bizzaro vt340 firmware fluke.
  Fortunately, it's unlikely anybody wants a compressed print.
  Unfortunately, that is the default setting for the VT340.

  Here is the kludge I used before I found out about Level 2:

    # The final line is not received in "compressed" mode.
    # Kludge: Don't leave terminal in sixel mode after catting file.
    echo -n ${ST} >> print.six

* Since I couldn't read the end of print message (ST), I tried using
  a repeated 1 second time out. However, that doesn't always work.
  In particular, the VT340 takes a long pause in the middle of
  sending an image when, perhps, Print Graphics Background Mode is turned
  off. There may be other circumstances... Oops, spoke too soon, now
  the delay is happening even when the Background Mode is turned on.
  Moral: Timeouts cannot be relied on with using Media Copy to host.

* Since I can't rely on getting the String Terminator with level 1
  compressed graphics, nor can I use a timeout if no data has been
  received for a while, one solution is to wait for a Form Feed (^L)
  at the end. However, that only gets sent if you enable it manually
  in the VT340 Set-up. I do not see a way to enable the Print
  Terminator via escape sequences. Also, it only seems to work in
  Compressed graphics mode, not Expanded.

  Again: this is probably not worth fixing as people can just use
  level 2 or expanded prints.

* Level 1 aspect ratio is displayed incorrectly in ImageMagick and
  xterm. Width seem fine, height is squashed by half. I believe
  these programs simply ignore sixel's ability to change the pixel
  aspect ratio to 2:1.

### Level 1 Expanded bugs

  * Print Terminator of Form Feed doesn't seem to get sent even
    when it is enabled in the Set-Up screen. This is annoying
    because I wanted to use that to detect the end of the printout.
    (On the upside, the final line, including ST *are* sent.)

  * Weird bug: Rotated & Expanded prints of a region begin with 0A XX
    P, where XX is some random byte such as E3 or FC. It should begin
    with newline (0A) then the 7-bit DCS sequence (ESC P). This seems
    to be a bug. Changing those first two bytes to a single ESC makes
    the sixel file valid.

      ( echo -n $'\e'; tail -c+3 < rotated-expanded.six ) > foo.six

    [UPDATE: After resetting my VT340 this bug is not reproducing].



