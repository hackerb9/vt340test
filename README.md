## What is this?

In the decades since the DEC VT340 terminal was released, knowledge of
how it functioned has been lost. Mostly for archaeological purposes,
but also so that the [lsix](https://github.com/hackerb9/lsix) program
works correctly, [hackerb9](https://github.com/hackerb9) purchased a
VT340+ and is running tests, many of which were submitted by
[j4james](https://github.com/j4james), and documenting the results
here.


## Test files and output

* Please see the [j4james](j4james) directory for test files and their output.

* See [sixeltests](sixeltests) for a few sixel test images and scripts.

## Notes on Hardware VT340 

* DECSDM (Sixel Display Mode), when enabled, DISABLES Sixel Scrolling
  in the Graphics Set-up screen and vice versa.

* Showing images with 16 colors changes text foreground/background,
  sometimes making them illegible. There is no obvious way to reset
  the colors. See [Colormap Reset](colormap/colorreset.md) for
  details.
  
  * Unlike REGIS, sixel color numbering is different from VT340's
    setup screen numbering! No matter what number you assign a sixel
    color, it is only the order that you did the assignment that
    matters in terms of where it is put in the VT340 color map. Note
    that the first sixel color defined is mapped to VT color #1, not
    color #0. The sixth color assigned (color #7) becomes the
    foreground color. The sixteenth assigned color wraps around and
    modifies VT color #0, so to set the background color, one must set
    all the other colors first. This is probably intentional: a sixel
    file that doesn't make use of all 16 colors would not make
    annoying changes to the background.

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

  * OPEN QUESTION: How does one convert an image to sixteen colors,
    but with three of the colors (fg, bg, and bright) fixed and the
    others free?

  * Note: [lsix](https://github.com/hackerb9/lsix) splits the montage
    into rows to reduce waiting when there are more than 21 images to
    show. However, each montage has separate color map, which means
    the previous row's colors will get messed up. I'm not sure there's
    a good solution for this other than to force a fixed palette
    (would grayscale be a good idea?).

### VT340 Screen Resolution 

Graphics screen resolution is 800x480, but sometimes is quoted as
800x500, which includes the 25th line (the status line).

  * The status line is only addressable by sending a special escape
    sequence (DECSSDT, DECSASD):

        tput tsl; tput rev; echo; echo -n $(date); tput fsl)

    Even if one wanted to muck with that, the status line ignores
    sixel commands, so it is still not possible to use it for graphics.

### REGIS

* To enter REGIS: send from host `ESC P 3 p`
* To exit REGIS: send from host `ESC \`  or hit Control-L
* Example of using REGIS

        clear
        echo -n $'\eP3p'        # Enter interactive REGIS mode
        echo -n $'P[150,200]W(S1)C(W(I1))[+100]C[+66]C(W(I2))[+33]' # RAF roundels
        echo -n $'\e\\'     # Exit REGIS mode


### MEDIA COPY TO HOST ("screenshot"):

Media Copy tells the VT340 to transmit a sixel copy of the current
screen to the host.

See:

* [mediacopy/README.md](mediacopy/README.md): Investigations of how Media Copy works on VT340.
* [mediacopy/mediacopy.sh](mediacopy/mediacopy.sh): script that saves a screenshot in "print.six".

At the moment, it is required to use the VT340's Printer Set-Up to
manually change the Sixel Graphics Mode to "Level 2" before using
media copy. Without that, it sends Level 1 output with pixel aspect
ratio set to 2:1. 

~~The script isn't working quite right yet because occasionally the
VT340 pauses transmission in the middle and causes an 8-bit glitch in
the output data. (Could just be hackerb9's terminal or his serial port
connection?)~~ _[Bug was in hackerb9's script]_

### Keyboard

* The ESC key on the LK-201 keyboard only functions in VT100 mode. 
  Instead, you must use ^[ or ^3.

* Despite what the manual says, you cannot use "Return" to select
  elements in Setup. You must use the "Do" key.
  
* The LK-201's <kbd>Shift</kbd> does not affect `,` and `.`. Instead
  the `<` and `>` symbols are on their own key next to the left shift.
  This is not changeable from the VT340 Set-Up menu.

### Tek 4010/4014 mode

* Entering and exiting this mode leaves VT340 with autowrap mode
  turned off. This appears to be a firmware bug.
  - To test: echo $'\e[?38h\e[?38l'
  - To fix, set DECAWM after exiting Tek mode: echo $'\e[?7h'
* Sixel print to host appears buggy; last portion gets sent to screen
  instead of to the host. 

### 80/132 column mode

* Despite the
  [documentation](docs/EK-VT3XX-TP-002_VT330_VT340_Text_Programming_May88.pdf) 
  recommending DECSCPP (set columns per page) and deprecating DECCOLM
  (column mode) to switch between 80 and 132 column mode, they do not
  appear to be equivalent.

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

### Dual sessions

The VT340 allows two login sessions simultaneously. While it is
possible to do that over a single serial cable using DEC's proprietary
SSU protocol, it is easier to just use the VT340's two communication
ports. (See [MMJ](mmj.md) for how to build a DEC423 cable for
Comm2).

Press `F4` to switch which session is active. Use `Ctrl+F4` to split
the screen vertically or horizontally.

Sixel images persist on completely separate framebuffers. While each
session can have a separate color palette, the VT340 hardware can only
use one at a time. That means split screen images will only look
correct for the session that is currently active.

Note that when split horizontally, the VT340 attempts to scroll the
view up or down to where the cursor is. This works well most of the
time, but full-screen applications can have problems. For example, a
text editor that has the text cursor typing at the top of the screen,
but is also updating a status line at the bottom that shows the
current column and row would jitter up and down rapidly on each
keystroke.

### Printer port

The printer port is actually a third serial port, with the same DEC423
wiring as Comm1 and 2. As you'd expect, a print command, such as `Esc
[ i`, sends data to it. What is unusual is that any data received on
the printer port is typed into the active session as if it was from
the keyboard.

Although it defaults to 4800 baud, the same as the actual keyboard
port, it can be set to run at 19.2Kbps. 

This could be useful in the future for automating compatibility tests
by connecting the printer port to a host computer. [Hackerb9 currently
has Comm1 and 2 on /dev/ttyS0 and S1 and the printer on /dev/ttyUSB0.]

Note that DEC's printer port is necessarily bidirectional because the
VT340 needs to listen for XON/XOFF so it can pause when the printer is
being overrun with data.


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
  [EK-VT3XX-TP.pdf#Ch10](docs/EK-VT3XX-TP-002_VT330_VT340_Text_Programming_May88.pdf#Ch10)).

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

  
### XON/XOFF Flow Control is Required

It does not appear that the VT340 firmware can perform RTS/CTS
("hardware") flow control, although electrically it should be
possible. See [flowcontrol](flowcontrol.md) for more details. The most
important point about XON/XOFF is that the host's serial card must
handle XON/XOFF on the UART chip to prevent garbled data.

### Smooth scrolling is on by factory default

Instead of scrolling the page up as fast as possible ("Jump"
scrolling), the VT340 defaults to "Smooth-2" scrolling. Smooth-1,
Smooth-2, and Smooth-4 are the three possible smooth scrolling speeds
available in Set-Up -> Display -> Scrolling. 

On the VT340, this setting does not affect sixel images when _first_
being drawn. Graphics New Line ('-') at the end of the screen still
scrolls the entire screen as fast as possible. However, once on the
screen, sixel images do scroll smoothly along with the text upon
receiving a text New Line ('\n').

Documentation varied about how fast the different speeds were supposed
to be, so hackerb9 measured the speeds using the
[scrollspeed.sh](scrollspeed.sh) shell script.

Results:
|   Setting | Scanlines per second | Text lines per second |
|----------:|---------------------:|----------------------:|
|  Smooth-1 |                   60 |                     3 |
|  Smooth-2 |                  120 |                     6 |
|  Smooth-4 |                  240 |                    12 |
|      Jump |                 1192 |                    60 |
| No Scroll |                  N/A |                   N/A |

While the VT340 allows the scrolling speed to be changed in the Set-Up
menu, it does not appear to be programmatically changeable (as it is
on the VT5x0 using DECSSCLS, Set Smooth Scroll Speed). Instead, DEC
Private Mode #4, DECSCLM, Smooth Scroll Mode, is used as a binary
switch. When a program sets DECSCLM, Smooth-2 is selected (even if one
of the other Smooth speeds was already enabled). When DECSCLM is
RESET, Jump scroll is used. Querying the private mode via DECRQM
returns SET when any of the Smooth speeds are selected. If the user
selects "No scroll" in the Set-Up menu, then DECRQM returns NOT
RECOGNIZED.

Note that, although Smooth-2 is the factory default on the VT340, the
most popular terminfo file for the VT340 (as of 2023) disables Smooth
Scroll Mode when the "reset" sequence is sent, which is often done at
user login (e.g., `tset`). This makes having a user preference of
Smooth-1 or Smooth-4 overly onerous as they would require repeated
manual configuration in Set-Up.


### Character Sets

![Technical Character Set glyphs](charset/uplineload/char-tcs.gif)

It appears the easiest way to use a VT340 in modern times is to enable
the Latin1 character set in Set Up and and `export LANG=en_US.iso8859-1`. 
However, there may be ways to get more glyphs out of the VT340 without
even down-line loading a new font. Please see [the charset
subdirectory](charset/README.md).

Hackerb9 has also made a tool, [uplineloadfont](charset/uplineload/),
for automatically capturing a font from the screen. It works on the
VT340, but should work on any terminal that supports ReGIS's Media
Copy to Host. It creates separate images for each glyph, but can also
make a montage, like this:

![Technical Character Set montage](charset/uplineload/tcs-montage.png)

