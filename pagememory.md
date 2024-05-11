# Pages and Lines per page

The VT340 can store several "pages" of text in memory. 

* The VT340 has 144 lines of memory, divided by default into 6 pages
  of 24 lines. Each line can hold 132 characters.

* **DECSLPP** (`Esc` `[` _n_ `t`, lets one set the number of "lines
    per page". Values of _n_ can be `24`, `36`, `72`, or `144`. More
    lines per page means fewer pages available. Note that the "pages"
    are virtual: The actual number of lines shown on a VT340 screen is
    always 24.
	
* The same setting can be a controlled via <kbd>Set-Up</kbd> Display →
  Page Arrangement. 

* The VT340 keyboard has special keystrokes for navigating Page Memory.
  | Keys                                                                                                                     | Description                    |
  |--------------------------------------------------------------------------------------------------------------------------|--------------------------------|
  | <kbd>Ctrl</kbd><kbd>Next<br>Screen</kbd><br><br style="line-height: 0.5em" /><kbd>Ctrl</kbd><kbd>Prev<br>Screen</kbd>                                 | Change which page is displayed |
  | <kbd>Ctrl</kbd><kbd>↑</kbd><br><kbd>Ctrl</kbd><kbd>↓</kbd><br><kbd>Ctrl</kbd><kbd>←</kbd><br><kbd>Ctrl</kbd><kbd>→</kbd> | Pan the current virtual page   |

What is Page Memory good for? I am not yet sure.

## Pseudo scrollback buffer

Is "Page Memory" like the scrollback buffer we are familiar with on
modern terminal emulators? Not really...

To enable a sort of scrollback buffer, use the Set-Up menu to change
the Page Arrangement from 6 pages x 24 lines to anything else, e.g., 2
x 72. Now when data scrolls off the screen, it is kept in a virtual
screen of 72 lines.
  
  * The VT340's monitor shows only 24 lines as a "window" into the
    current page. To see text that has previously scrolled off, pan
    the window by pressing  <kbd>Ctrl</kbd><kbd>↑</kbd> . To reset the
    view back to the cursor location, just type any key.
	
  * Note: Programs that rely on cursor positioning techniques may
    break because **HOME** (`Esc [ H`), refers to the first line of
    the virtual page, not the first line visible on the screen.
    Programs that clear the screen also clear the scrollback buffer.

  * WARNING: The `resize` command, will detect a larger screen and
    full-screen programs will appear to go haywire, constantly
    scrolling the screen up and down as different lines are changed.
    To fix it, you can do
	
	```
	stty rows 24 columns 80
	```

## 132-columns with 80 column font.

The **DECSCPP** sequence can set the number of columns per page to 132
but keep using the 80 column font. When that has happened, one can pan
left and right using <kbd>Ctrl</kbd><kbd>←</kbd> and
<kbd>Ctrl</kbd><kbd>→</kbd>. This seems to be of limited utility, but
I was able to [fake sixel animation](sixeltests/animation.sh) with it.

## Multiple Pages

* To switch to a different page, press
  <kbd>Ctrl</kbd><kbd>Next<br>Screen</kbd>,
  <kbd>Ctrl</kbd><kbd>Prev<br>Screen</kbd>.

* There are sequences, **NP** (`Esc``[``U`) and **PP** (`Esc``[``V`),
  which can scroll forward and back in "pages". New data from the host
  is sent to the current page by default. Switching to a page that had
  been previously written on will show the data still there. 

* I do not yet know what the purpose of having multiple pages was as
  I've seen no mention of even intended application in the manual.
  Perhaps some sort of task switching which could restore a previous
  screen without having to resend all the data? But if so, why is the
  user able to switch pages using the keyboard? 
  
* Application don't get any signal when a user switches pages
  manually, but it is possible to query the current page. 


* Page Memory can be used like double-buffering, where text is written
  to the next page while the user is viewing the current one. (See
  [EK-VT3XX-TP.pdf#Ch10](docs/EK-VT3XX-TP-002_VT330_VT340_Text_Programming_May88.pdf#Ch10)
  for cursor coupling).

* The manual mentions that there are *two* sixel graphics pages (unless
  you are logged in to two sessions at once). It appears they are
  addressed the same way as standard page memory, but only the first
  two pages actually work. This means graphics double-buffering is
  possible!

## Future questions

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

