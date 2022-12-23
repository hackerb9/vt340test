## Media Copy details & investigations

Media Copy is how one can take a screenshot from a VT340. It can be of
the entire screen or a region. Depending upon complexity of the
graphics, it can take a long time (~5m) to transmit. 

A script for making screenshots can be found in [mediacopy.sh](../mediacopy/mediacopy.sh).

The format of the output is discussed in [Sixel Printer Port](../mediacopy/sixel-printer-port.md).

### Sequence for sending

0. Set VT340 to Level 2 graphics in Printing Set-Up menu.
1. Set printing options (color, transparent background).
2. Send REGIS "HardCopy" command.
3. Receive sixel data from VT340.

### Details

To send the screen to the host as sixel data, you set the MediaCopy
output to "2", optionally change settings, and then send the ReGIS
"Hard Copy" command.

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

### Media Copy response from VT340

Here is what a typical Level 2 Graphics response from a VT340 might
look like:

```
[Esc] \ [Newline]
[Esc] [ 2 [Space] I
[Esc] P 0 ; 1 ; 6 q
" 1 ; 1 ; 800 ; 480
# 1 ; 2 ; 20 ; 20 
# 1 !255? !133? !8_ !9o !8_ $-
# 1 !255? !108? __oooowwww{{{{}}}} !39~ }}}}{{{{wwwwoooo__ $-
...
[ Esc ] \
```

#### Level 2 is required

The response varies depending upon what options you've chosen and
whether your VT340 is set up for Level 2 graphics. There appears to be
a bug in the Level 1 code where the final line of sixels, including
the ST (string terminator) are not sent to the host. Fortunately, you
don't want [Level 1](level1.md) anyway since it uses wacky rectangular
pixels.

#### read -p -d idiom

The typical `read` idiom in bash for getting a response from a
terminal does not work. Sending the inquiry in the prompt is fine, but
one cannot stop reading at the first `\` character because the VT340
sends ST (`Esc \`) at the beginning *and* the end of the data. Also
note that, while having ST at the beginning is valid, it confuses
ImageMagick and libsixel (as of October 2021).

#### Recommended reading method

Since the String Terminator can be at the start of the data, it is
recommended to look for the sixel header, `Esc P...q` — where "..." is
a string of digits and semicolons — before looking for the String
Terminator, `Esc \`.

While sixel images can theoretically be made up of multiple sixel
sequences — for example, setting palette colors in one and using them
in another — the VT340 never sends data like that during a Media Copy
command. After `Esc P...q`, the first backslash found will be the end
of the data.

A timeout is not reliable for guessing when the data is done. Due to
the 8-bit glitch mentioned below, the VT340 pauses for a long time in
the middle of transmission. 

# Scattered notes as I figure things out

* There are multiple options that affect the sixel data:

  1. __[Level 1]__/Level 2 graphics<br/>
     Only in Set-Up
  2. __[No Terminator]__/Send formfeed<br/>
     Only in Set-Up
  3. __[Compressed]__/Expanded<br/>
     DECGEPM, 43
  4. __[Mono]__/Color<br/>
     DECGPCM, 44
  5. __[HLS]__/RGB<br/>
     DECGPCS, 45
  6. __[No Background]__/Print Background<br/>
     DECGPBM, 46
  7. __[Compressed+Expanded]__/Rotated<br/>
     DECGRPM, 47

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

      REGIS_H="S(H(P[0,0])[$X1,$Y1][$X2,$Y2])"	# This works

      REGIS_H="S(H(P[0,0][$X1,$Y1][$X2,$Y2]))"	# This does not

* It takes several minutes to send a full screen of sixel data, so
  you'll want to print just a cropped part if you're debugging this.

* Before sending the sixel data, the VT340 sends ST (`Esc \`). 
  However, ImageMagick gets confused by sixel images that start with
  the String Terminator (it thinks they have only one pixel).
  [Todo: I should report this bug to ImageMagick.]

* VT340 defaults to printing in "mono". Must set to "color" using
  the DECGPCM (`Esc [?44h`) escape sequence.
  
* ImageMagick cannot handle HLS sixel graphics. Must set to RGB by
  using DECGPCS (`Esc [?45h`).

#### SSU - Select Size Unit

The purpose of the introductory sequence `Esc [ 2 Space I` before the
sixel data, is defined in
[ECMA-48](https://www.ecma-international.org/publications-and-standards/standards/ecma-48/)
as setting the unit of measurement for all numeric parameters to the
"Computer Decipoint" = 1/720th of an inch.

> **8.3.139 SSU - SELECT SIZE UNIT** <br/>
> Notation: (Ps) <br/>
> Representation: CSI Ps 02/00 04/09 <br/>
> Parameter default value: Ps = 0 <br/>
> <br/>
> SSU is used to establish the unit in which the numeric parameters of
> certain control functions are expressed. The established unit
> remains in effect until the next occurrence of SSU in the data
> stream.<br/>
> <br/>
> The parameter values are <br/>
> 0 CHARACTER  - The dimensions of this unit are device-dependent <br/>
> 1 MILLIMETRE     <br/>
> 2 COMPUTER DECIPOINT - 0,035 28 mm (1/720 of 25,4 mm)   <br/>
> 3 DECIDIDOT - 0,037 59 mm (10/266 mm)   <br/>
> 4 MIL - 0,025 4 mm (1/1 000 of 25,4 mm)   <br/>
> 5 BASIC MEASURING UNIT (BMU) - 0,021 17 mm (1/1 200 of 25,4 mm)   <br/>
> 6 MICROMETRE - 0,001 mm   <br/>
> 7 PIXEL - The smallest increment that can be specified in a device   <br/>
> 8 DECIPOINT - 0,035 14 mm (35/996 mm)  

The VT340 sends SSU to ensure that the "[horizontal
grid](../sixelmagic.md)" parameter in the sixel image is interpreted
correctly and the image is printed at the correct size. The VT340's
horizontal grid (space between pixels) on the screen is about .012
inches. For "rotated" printing, the VT340 sets the grid size in the
sixel output to 9/720 = 0.0125", which makes hardcopy almost exactly
the same size as the screen, 10" x 6". For "normal" printing, the
VT340 sets the grid to 6/720 ≈ .00833, which shrinks the image to 6.66" 
x 4" so the width will fit on the 8.5" width of US Letter sized
paper.

  * [ ] While the SSU data is currently thrown away by mediacopy.sh,
  the correct thing to do would be to embed the DPI information in the
  PNG output. (Since grid spacing is number of inches per dot, DPI is
  simply the inverse.)

  * *Side note:* Finding SSU was not easy. Reminder to self, when
  searching the control sequence standards look for "04/09" instead of
  simply the ASCII letter "I". ("04/09" == hexadecimal 0x49 == 'I'.
  Likewise, "02/00" == Space).


### Eight-bit glitch

For some reason, in the middle of transmission, the VT340 will send a
byte with the eighth bit high (which should never happen) and then
pause for several minutes. ^Q does not wake it up. If I let it sit, it
eventually finishes sending the entire image, but there will be a
small glitch in the picture for every time the 8-bit bug happened.

* The eighth-bit glitch is most apparent with large complex images,
  but that may simply because they take longer to send. 

* The glitch is not completely repeatable in that the exact value of
  the byte that gets mangled is not always the same.

#### Questions about 8-bit glitch:

* [x] Shabby serial line connection? Checked and seems okay.

* [x] Try second serial port. Checked and no different.

* [ ] Try using printer port.

* [ ] Are there certain pictures that trigger the glitch? It seems so
  as j4james's color_selection.sh was very difficult to get a media
  copy of until I switched the terminal to 132 column mode.

* [ ] Why did 132 column mode help? Or did it just move the glitch to
  an unnoticeable area?

* [ ] If it's a firmware bug, can I alter the ROM?

* [ ] Did this glitch happen with Level 1 printing? I don't recall
      noticing it.

### Level 1 printing does not work well and should be avoided

Design misfeatures and bugs make Level 1 Graphics not worth it for
print outs from the VT340. Just use Level 2.

For more info, read [level1.md](level1.md).

### What else doesn't work.

ReGIS is apparently required for sending graphics back to the host.

* There is no escape sequence to simply print graphics. The normal
  VT340 "Media Copy" command, `CSI i` is intended for text, not
  graphics.

* The Tektronix 4010/4014 hardcopy command, ESC ETB ($`\e\x17`), only
  works for Tek graphics and is, unless I'm mistaken, unusably buggy.
  As with ReGIS hardcopy, it does send data to the host, assuming I've
  sent `Esc [ ? 2 i` (media copy to host) before entering Tek mode.
  
  Unfortunately, the firmware has a serious glitch, cutting off the
  bottom of the image and sending it to the screen instead of to the
  host. (This seems a lot like the [Sixel Level 1](level1.md) errors I
  encountered before switching to Level 2).

  Even if it worked, it would be of limited use. Tektronix graphics
  are a completely separate system from ReGIS and the usual text
  modes. In Tek mode, the only command that works to send a hardcopy
  is the special Tek hardcopy command. And, the Tek hardcopy command
  only works in Tek mode. Additionally, there is no way to send only a
  small crop of the screen. And, finally, redirecting printer graphics
  to the host must be done before the Tek drawing commences as it is
  not possible on the VT340 (as far as I know) to exit Tektronix mode
  and re-enter it without clearing the screen.

