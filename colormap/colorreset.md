# Resetting the VT340 color map

The VT340's palette of colors has strange entwinings between text,
Sixel graphics, and ReGIS graphics as discussed in the [colormap
page](colormap.md). It is easy for the VT340 to end up with unreadable
text and no obvious way to fix it.

## Simplest solution, using the keyboard

It is possible to reset colors from the VT340's builtin setup, but
tricky because the current color map is used for the setup screen's
text so you can't see what you're doing. To reset colors from the
keyboard (without needing to look) press this sequence of keys:

<ul>
<kbd>Set-Up</kbd> <kbd>Prev Screen</kbd> <kbd>Do</kbd> <kbd>Set-Up</kbd>
</ul>

That pulls up the palette editor and recalls the saved color map.

## Programmatic solutions

Of course, it would be better if there was a way to reset the VT340
colormap using an escape sequence. That is still being investigated,
but here is what we know so far.

### Current best solution: set colors in a script

While way too verbose to type blindly, one can create a script that
programs all 16 colors or only the ones which are used for text. There
are at least three ways to do that:

* ReGIS: one can create a [cattable file](../regis/resetpalette.regis)
  or a [shell function](../usage/vt340.setup.sh):

  ```bash
  # Function to fix a common problem: unreadable text colors
  resetpalette() {
	  printf '\ePp
	  S(
		  M 0     (H  0 L  0 S  0)
		  M 1     (H  0 L 49 S 59)
		  M 2     (H120 L 46 S 71)
		  M 3     (H240 L 49 S 59)
		  M 4     (H 60 L 49 S 59)
		  M 5     (H300 L 49 S 59)
		  M 6     (H180 L 49 S 59)
		  M 7     (H  0 L 46 S  0)
		  M 8     (H  0 L 26 S  0)
		  M 9     (H  0 L 46 S 28)
		  M 10    (H120 L 42 S 38)
		  M 11    (H240 L 46 S 28)
		  M 12    (H 60 L 46 S 28)
		  M 13    (H300 L 46 S 28)
		  M 14    (H180 L 46 S 28)
		  M 15    (H  0 L 79 S  0)
	  )\e\\'
  }
  ```

* [resetpalette.sh](resetpalette.sh): Uses **DECRSTS** (`\eP2$p`...)
  to send the actual Color Table Report returned by hackerb9's VT340+
  in response to **DECRQTSR** (Request Terminal State Report).

  Give the `-t` option to only reset the foreground and background
  text colors. Unlike ReGIS's Hue-Lightness-Saturation, colors are
  specified using the familiar RGB colorspace, with values ranging
  from 0 to 100%. Note that **DECRSTS** is explicitly documented as
  not portable to other terminals.

* [Sixel graphics](../sixeltests/resetpalette-sixel.sh) can
  technically change the color palette in a repeatable way, but it is
  needlessly grotesque. Unlike the situation in ReGIS, Sixel color
  index numbers do not correspond directly to the VT340's actual
  palette. Instead, they are mapped based on the order in which the
  colors are assigned.

  * The SIXTH color you assign will change the text foreground color,
  * The SEVENTH changes the bold + blinking foreground color,
  * The FIFTEENTH changes the bold text foreground color and
  * the SIXTEENTH changes the text background. 

  This confusing indirection has the benefit that four-color sixel
  images (as were common on the VT240) will not affect the background
  or text colors. The VT340 designers probably felt free to implement
  it this way because ReGIS provides direct access to the true
  colormap if necessary.

### What does NOT work

According to the [DEC Printer Programming Language 2 Reference][PPL2]
— although focused on printers, it is the best documentation yet
found for Sixel Level 2 — there are four ways in which the color
palette is reset. 

<blockquote><i>

Color numbers remain assigned even after leaving and reentering Sixel
Graphics mode. At power-up, Soft Terminal Reset (**DECSTR**), Select
Conformance Level (**DECSCL**), and Reset to Initial State (**RIS**), the
device assigns all color numbers to black.

Upon entering Sixel Graphics mode, the device selects color 0.

</i></blockquote>

[PPL2]:	../docs/EK-PPLV2-PM.B01_Level_2_Sixel_Programming_Reference.pdf

(For printers the initial palette is all black because the paper is
implicitly white, but of course that default doesn't make sense for a
video terminal which must define both foreground and background colors.)

#### **DECSTR**

Soft Terminal Reset does *not* reset the color palette on the VT340,
despite what the PPL2 says.

        CSI ! p
        printf '\e[!p'

Hackerb9 believes this is a misfeature in the VT340 and that emulators
should reset the palette upon receiving **DECSTR**.

#### "At power up"

Power cycling the VT340 technically works, but booting up requires a
lengthy self-test so it is not a practical solution.

#### **RIS**

Hard Terminal Reset (aka Reset to Initial State) does reset the
palette, but it takes a long time to execute as it goes through the
whole power-on self-test again.

    printf '\ec'

#### **DECSCL**

"Select Conformance Level" does not reset the palette on hackerb9's
VT340. [The VT340 manual][VT340TP] says **DECSCL** calls **DECSTR**
but does not otherwise mention resetting anything.

[VT340TP]: ../docs/EK-VT3XX-TP-002_VT330_VT340_Text_Programming_May88.pdf

The [DEC PPL2 documentation][PPL2] does explicitly state that
**DECSCL** will reset the color palette, the same as **DECSTR**.

    CSI Ps " p
    printf '\e["p'			# Default operating mode
    printf '\e[63;1"p'		# VT300 mode, 7-bit controls
    printf '\e[72"p'		# PPL Level 2

#### Tektronix mode

 Switching to Tektronix mode and back does not restore the palette.

    echo $'\e[?38h\e[?38l'		# Colors do not change

#### **DECSTGLT**

Technically using Set Text/Graphics Look-Up Table works, but it causes
graphical glitches on the screen where old text reappears in a
rectangle on the screen. Clearing the screen can erase the glitches,
but is less than ideal.

	#!/bin/bash
	# DECSTGLT - Set Text/Graphics Look-Up Table
	# Changing to colormap #0 then colormap #1 resets the color table to default.
	echo -n $'\e[0){\e[1){'

	# However, there are strange text glitches, so clear the screen.
	echo -n $'\e[2J'
