# Pages and Lines per page

The VT340 can store several "pages" of text in memory, each of which
can be larger than the actual screen. 

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

What is Page Memory good for? 

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

* Applications don't get any signal when a user switches pages
  manually, but it is possible to query the current page. 

* Thanks to @j4james, I now have an inkling of what Pages were for. 

  <details>
  <summary>Click to see wisdom from j4james</summary

  I saw you were recently asking for input on what page memory is good for, so I thought I'd offer my thoughts based on what I've read, and also how I've been using pages myself.

## Data entry

Quoting the VT330/VT340 Programmer Reference Manual (Text Programming), in the section "What is page memory?", page 103:
> Page memory lets you store more text locally in the terminal.
> Page memory can provide a faster response time. While the terminal displays one page, the host can write to another.

They don't say this explicitly, but my guess is that this would typically have been used for data entry applications, likely combined with the block editing functionality.

For example, you may have terminals in offices around the country connected to a central database with customer data that you need to view and/or update remotely. If you've got a data entry form that spans multiple pages, you don't want to have to keep redrawing that every time you deal with a new customer.

So what you do is render the initial form design at startup (and this can cover multiple pages which are loaded in the background). Then looking up a new record just fills in the appropriate fields without having to redraw all of the surrounding content (and again, fields on the secondary pages can be loaded in the background).

If it's necessary to edit something, you'd typically use the block editing functionality to markup the editable areas of the page. And that way the user can enter the data locally, without a slow roundtrip connection to the central office for every keystroke. Once the form has been completely filled in, it can all be sent to the backend with a single write (possibly one write per page - I'm not overly familiar with the block editing functionality).

## Pop-up dialog and menus

This requires additional extensions that were only available on the later VT models, so I don't think it would work on the VT340, but quoting the VT420 Programmer Reference Manual, page 7:

> Page memory provides a storage space for pop-up menus and a means for instant screen updates.

Lets say you need to pop-up a dialog in an editor that's currently viewing a document. When you close that dialog, you ideally don't want to have to redraw the area of the screen that was temporarily covered. But if the terminal has rectangular area operations (specifically `DECCRA`), you can temporarily copy a portion of your active page to a secondary background page, and then copy that back again when the dialog is closed.

And with something like drop-down menus, which are likely to be frequently used, and where the content is known in advance, it can be advantageous to prerender them all to a background page. That way, opening a menu just involves a single copy operation, and flipping through menus can be almost instantaneous, even on a slow connection, and even when drawing over unknown content.

## Double buffering and compositing

I doubt this was one of the original goals for DEC terminals, considering the typical target market would likely have been business users, but if you want to develop a terminal game, there are some cool things you can do with pages.

In the simplest form, if you're needing to animate a bunch of sprites, and you have to erase them all before redrawing them in a new location (potentially in a different form), it's preferable to do this compositing on a background page, and then flip that page to the foreground when you're done. Otherwise you're liable to get flickering from the time between erasing and redrawing. 

And on later terminals that have `DECCRA` support, there is even more you can do with pages. For example, in a side-scrolling game, you can dedicate one page to the background, so it can easily be scrolled by itself every frame. You then copy that to another background page before you draw all the sprites on top of it. And finally you flip or copy that page to the foreground when you're done.

  </details>

I [j4james] recently made a version of the [Chrome dinosaur
game](https://github.com/j4james/vtrex) using this technique, and
although it's a bit sluggish, it was actually playable on a VT525.
  
* Page Memory can be used like double-buffering, where text is written
  to the next page while the user is viewing the current one. (See
  [EK-VT3XX-TP.pdf#Ch10](docs/EK-VT3XX-TP-002_VT330_VT340_Text_Programming_May88.pdf#Ch10)
  for cursor coupling).

* The manual mentions that there are *two* sixel graphics pages (unless
  you are logged in to two sessions at once). It appears they are
  addressed the same way as standard page memory, but only the first
  two pages actually work. This means graphics double-buffering is
  possible!

## Example of using Page Memory: j4james's vtrex!

j4james has a [nifty example of using
Pages](https://github.com/j4james/vtrex, an implementation of Google
Chrome's "Dinosaur" videogame for the VT525. (Does not work on the VT340.)


## Future questions

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

