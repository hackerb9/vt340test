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
  
### 80/132 column mode

* Despite the [documentation](EK-VT3XX-TP.pdf) recommending DECSCPP
  (set columns per page) and deprecating DECCOLM (column mode) to
  switch between 80 and 132 column mode, they do not appear to be equivalent. 

  * DECSCPP: `Esc` `[` `8``0` `$` `|`   or  `Esc` `[` `1``3``2` `$` `|`

    Terminal now thinks it has that many columns, but the screen font
    doesn't actually change. Has the benefit of not clearing data in
    page memory or changing number of lines per page. If you switch to
    132 columns, but are using an 80 column font, then text that is
    off the screen simply isn't shown. It is unclear how this is
    beneficial.
 
  * DECCOLM: `Esc` `[` `?` `3` `l`  or  `Esc` `[` `?` `3` `h`
      
    Terminal switch to 80- or 132-column mode, the same as if it had
    been changed in the Set-Up -> Display screen. Both the logical
    width and the actual font size change. Resets page memory.

### Pages and Lines per page

The VT340 can store several "pages" of text in memory. Is "Page
Memory" like the scrollback buffer we are familiar with on modern
terminal emulators? It does not seem so.

Pages appears to be intended for application use, perhaps for some
sort of task switching where you'd want to get back to a previous
screen without having to resend all the data.

* There are sequences, NP (`Esc``[``U`) and PP (`Esc``[``V`), which
  can scroll forward and back in "pages", but it appears the pages are
  only written to when an application specifically addresses them.
  When data scrolls off the top, it doesn't get put into a page.

* Page Memory can be used like double-buffering, where text is written
  to the next page while the user is viewing the current one. (See
  [EK-VT3XX-TP.pdf#Ch10]).

* Manual mentions that there are *two* sixel graphics pages (unless
  you are logged in to two sessions at once). It appears they are
  addressed the same way as standard page memory, but only the first
  two pages actually work. This means graphics double-buffering is
  possible!

* Future questions

  * Did/do any programs actually use Page Memory?

  * Is there an example of using the graphics pages for double buffering?
    (For example, for decoding animated GIF images.)

  * Is there a quick way to have the VT340 copy one graphics page in
    memory to another? For example, in an animated GIF, only the first
    frame should have to be sent, after that the differences for
    subsequent frames take up much less bandwidth. Without a quick way
    to copy pages, double-buffering would mean the first two frames
    would have to be sent and deltas would have to be applied twice.

  * If the VT340 had more RAM, could it have held sixel bitmaps
    associated with each of the text pages? If so, how hard would it
    be nowadays to upgrade the hardware/firmware to do this?

  * DECSLPP lets one set the VT340 to have more "lines per page" and
    concomittantly fewer "pages", or vice versa, but what good is that
    if the pages are too big to display on the screen? Is it fast to pan pages?

  