## What is this?

In the decades since the DEC VT340 terminal was released, knowledge of
how it functioned has been lost. Mostly for archaeological purposes,
but also so that the [lsix](https://github.com/hackerb9/lsix) program
works correctly, [hackerb9] purchased a VT340+ and is running tests,
many of which were submitted by [j4james](https://github.com/j4james),
and documenting the results here.


## Test files and output

* Please see the [j4james](j4james) directory for test files and their output.

* See [sixeltests](sixeltests) for a few sixel test images and scripts.

## Notes on Hardware VT340 

* DECSDM (Sixel Display Mode), when enabled, DISABLES Sixel Scrolling
  in the Graphics Set-up screen and vice versa.

* Showing images with 16 colors messes up text foreground/background. 

  * Soft Terminal Reset does *not* reset color palette.

        CSI ! p
        echo $'\x9b!p'

  * Hard Terminal Reset does reset palette, but it takes a long time to
    execute as it goes through the whole power-on self-test again.
    echo $'\ec'

  * It is hard to reset colors from the builtin setup because the
    current color map is used for the color setup screen.

  * To reset colors from keyboard (without needing to look):

        [Set-Up] [Prev Screen] [Do] [Set-Up]

    That pulls up the palette editor and recalls the saved color map.

  * Unlike REGIS, sixel color numbering is different from VT340's
    setup screen numbering! No matter what number you assign a sixel
    color, it is only the order that you did the assignment that
    matters in terms of where it is put in the VT340 color map.
    Strangely, the first sixel color defined is mapped to VT color #1,
    not color #0. The sixth color assigned (color #7) becomes the
    foreground color. The sixteenth assigned color wraps around and
    modifies VT color #0, so to set the background color, one must set
    all the other colors first. This is probably intentional: a sixel
    file that doesn't make use of all 16 colors would not make
    annoying changes to the background.

  * To reset the color palette programmatically, try hackerb9's
    [resetpalette.sh](colormap/resetpalette.sh) script which uses
    DECRSTS (Reset Terminal State) to set the color table directly
    instead of using sixel commands. It uses the actual Color Table
    Report returned by his VT340+ in response to DECRQTSR (Request
    Terminal State Report).

  * QUESTION: How do I convert an image to sixteen colors, but with
    three of the colors (fg, bg, and bright) fixed and the others free?

  * Note: lsix splits the montage into rows to reduce waiting when
    there are more than 21 images to show. However, each montage has
    separate color map, which means the previous row's colors will get
    messed up. I'm not sure there's a good solution for this other
    than to force a fixed palette (grayscale a good idea?).

### Number of colors on a genuine VT340

  * A genuine VT340 can show 16 colors from a 12-bit palette, which
    means there are 4096 (2^12) different colors available.
    ImageMagick calls this `-depth 4`, because there are 4-bits per
    color channel.

  * Red, Green, Blue vary from 0 to 100% intensity.

    RGB can specify 101×101×101 different colors (nearly 2^20).

  * Hue varies from 0 to 360 degrees, Lightness and Saturation vary
    from 0 to 100%. (Hue 0 and 360 are identical).

    HLS can specify 360×101×101 different colors (over 2^21).

  * Thus there are roughly 250 different RGB values and 1000 different
    HLS values for each possible color that can actually be shown.

  * When quantizing colors (reducing the color palette to 16) using
    ImageMagick, it may help to specify `-depth 4` so ImageMagick
    doesn't allocate two colors that are functionally identical.

### VT340 Screen Resolution 

Graphics screen resolution is 800x480, but sometimes is quoted as
800x500, which includes the 25th line (the status line).

  * The status line is only addressable by sending a special escape
    sequence

        tput tsl; tput rev; echo; echo -n $(date); tput fsl)

    Even if one wanted to muck with that, the status line ignores
    sixel commands, so it is still not possible to use it for graphics.

### REGIS

* To enter REGIS: send from host `ESC P 3 p`
* To exit REGIS: send from host `ESC \`  or hit Control-L
* Example of using REGIS

    clear
    echo -n $'\eP3p'		# Enter interactive REGIS mode
    echo -n $'P[150,200]W(S1)C(W(I1))[+100]C[+66]C(W(I2))[+33]' # RAF roundels
    echo -n $'\e\\'		# Exit REGIS mode


* MEDIA COPY TO HOST ("screenshot"): This isn't working quite right
  yet, but to send the screen to the host as sixel data, you can do
  something like this:

      CSI=$'\e['			# Control Sequence Introducer
      DCS=$'\eP'			# Device Control String
      ST=$'\e\\'			# String Terminator

      # MC: Media Copy ('2' meands send graphics to host, not printer)
      echo -n ${CSI}'?2i'		
      # DECGPCM: Print Graphics Color Mode
      #echo -n ${CSI}'?44l'		# Print in black and white
      echo -n ${CSI}'?46h'		# Print in Color
      # DECGPBM: Print Graphics Background Mode
      echo -n ${CSI}'?46l'		# Do not send background when printing
      #echo -n ${CSI}'?46h'		# Include background when printing

      echo -n ${DCS}'p'			# Enter REGIS mode
      echo -n $'S(H)'			# Screen hard copy
      echo -n ${ST}			# Exit REGIS mode

  I was able to capture a simple REGIS image using this method, but
  when trying to read the results after drawing on the screen with
  sixels, I'm having troubles. 

  The problem I have at the moment is attempting to read the results
  sent from the terminal. For some reason, the usual trick of putting
  the escape sequence in the prompt of bash's `read` fails and the
  last part of the sixel data gets splatted to the screen. It takes
  over three minutes to send a complex image, so maybe something is
  timing out. Or, it's possible I have flow control problem.

  Capturing the data with `script` worked slightly better, but the
  resulting output was strangely misaligned horizontally. (Could it be
  the sixel level (e.g., 1 or 2) I'm sending back is incorrect?)

### Keyboard

* The ESC key on the LK-201 keyboard only functions in VT100 mode. 
  Instead, you must use ^[ or ^3.

* Despite what the manual says, you cannot use "Return" to select
  elements in Setup. You must use the "Do" key.
  
