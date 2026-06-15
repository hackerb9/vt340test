# VT340 Locator Devices

The [Linux kernel][linux] describes the VT340's locator devices like so:

```C
/*
 *      DEC VSXXX-AA mouse (hockey-puck mouse, ball or two rollers)
 *		DEC VSXXX-GA mouse (rectangular mouse, with ball)
 *		DEC VSXXX-AB tablet (digitizer with hair cross or stylus)
 */
```

"Locator devices" is what DEC calls input devices that provide a
coordinate on the screen. The VT340 could be used with a circular
mouse (VSXXX-AA) or a tablet (VSXXX-AB). The tablet could use either a
mouse-like digitizer (with crosshairs and four buttons) or a stylus.

## Documentation

* [VT340 Programmer's Reference: Chapter 15 Using a Mouse or Tablet][ch15]
* [VT340 Programmer's Reference: Chapter 10 Report Command (in ReGIS)][ch10]
* [VT340 Programmer's Reference: Chapter 13 Tektronix 4014 Emulation][ch13]
* [VCB02 Video Subsystem Technical Manual][vcb02]

[ch15]: https://vt100.net/docs/vt3xx-gp/chapter15.html "Using a Mouse or Tablet"
[ch10]: https://vt100.net/docs/vt3xx-gp/chapter10.html "ReGIS Report Command"
[ch13]: https://vt100.net/docs/vt3xx-gp/chapter13.html "Tektronix 4014 Emulation"


## Testing

The VT340 manual describes two ways to read input from a locator
device: ReGIS and GIN. Various terminal emulators from DEC also
implemented a third method, [DEC Locator Mode], which the VT340 does
_not_ support. 

### ReGIS locator test

ReGIS mouse tracking can be configured to work in either _1-shot mode_
which request a single location or _multimode_ which keeps sending
mouse data until it is turned off. The following scripts test those
modes. One-shot is quite simple to use, even without a mouse.

* [locator1shot.sh][]

The primary advantage of multimode is that the terminal continues to
process input data. In one-shot mode, the terminal locks up while
waiting for the user to press a button; any data received is buffered
for later.

* [locatormulti.sh][]

By default the VT340 only sends events on "mouse down" (button
pressed), but it can be configured to also report "mouse up" (button
released) events. It can also be configured to send an arbitrary
string for each of the four mouse buttons. (Note: Only the tablet
actually has four buttons.) Use the following program to test that
functionality.

* [locatorprog.sh][]

<details><summary>Notes on ReGIS Locator Mode</summary><ul>

* According to a [DEC memo][decloc], “REGIS One-shot Graphics Input
  Mode is provided for backward compatibility with the VT240.”

* The documentation says that the terminal continues to process input
  normally in Multiple Mode. This only refers to ReGIS mode. Switching
  back to the standard VT340 escape sequences disables the Graphics
  Input and all mouse events are lost.

* The documentation says the Multiple Mode stays on until it is
  explicitly set back to "one shot mode" or the terminal is reset.
  Actually, exiting and reentering ReGIS mode switches to one shot
  mode.
  
* Exiting ReGIS mode is not a good idea with multimode as very rapid
  mouse movements and clicks will be lost, causing a poorly responding
  application. 
  
  However, that means text output must use ReGIS's text rendering
  which seems to be slow, mainly because the line it is on must first
  be cleared... Or does it? Is there a way to the make ReGIS's text
  background opaque? If not, is there a faster rectangle clear routine
  than "polyfill"? [XXX todo: investigate]

* ReGIS's DCS string can be opened in one of four modes, 0 through 3.
  Multiple Mode only seems to work with ReGIS modes 1 and 3. I'm not
  sure why yet. [XXX]

* Multiple mode always returns reports as escape sequences, never
  plain text.

* Unlike button clicks, moving the mouse is not an event sent by the
  VT340 spontaneously in multimode. The location must be polled by the
  application. This can be done by waiting for a button event with a
  select() timeout of about a tenth of a second, then sending a
  request for a position report. (See [locatormulti.sh][].)

* vttest has a "dec locator" test, but it only implements the DECTERM
  protocol, not the VT340 mouse.

</ul></details>

### Tektronix GIN mode test

* Enter Tek mode: Send Esc [ ? 3 8 h 

* Enter GIN mode: Send ESC SUB (^Z)

* Receive Report: Format? 

  Chapter 15 says, "See Chapter 13 for the format of the 4010/4014
  mode position report."
  
  Chapter 13 says, "Chapter 15 describes how to use a mouse or tablet
  in GIN mode."

* Exit Tek mode: Send Esc [ ? 3 8 l

#### Notes

* For some reason vttest's Tek mouse test does not work with the
  VT340. The GIN crosshairs do appear and pressing a key on the
  keyboard shows the keycode and correct location, but clicks always
  send roughly the same position repeatedly --- 27 (657, 882).



### DEC Locator test

As mentioned previously, these sequences do not work on the VT340.
They are merely mentioned as they are quite common in emulators.

Some of the [DEC Locator][decloc] sequences can be tested using Thomas
Dickey's `vttest` program under the menu: Non-VT100 Tests → XTERM
Special → Mouse → DEC Locator.

[decloc]: https://espterm.github.io/docs/Locator%20Input%20Model%20for%20ANSI%20Terminals%20(sixth%20revision).html

The following summary was borrowed from XTerm's
[ctlseqs](https://www.invisible-island.net/xterm/ctlseqs/ctlseqs.html)
file.

<details><summary>DECRQLP and DECLRP</summary><ul>

* **DECRQLP** Locator Position 

  |         |        |     |      |
  |:--------|:-------|:----|:-----|
  | **CSI** | **Ps** | '   | \|   |
  | 9/11    | 3/?    | 2/7 | 7/12 |

  Valid values for the parameter are:

  Ps = 0, 1 or omitted → transmit a single **DECLRP** locator report

If Locator Reporting has been enabled by a **DECELR**, xterm will respond
with a DECLRP Locator Report. This report is also generated on button
up and down events if they have been enabled with a **DECSLE**, or when
the locator is detected outside of a filter rectangle, if filter
rectangles have been enabled with a **DECEFR**.

* **DECLRP** Locator Report

  |         | event  |      | button |      | row     |      | column  |      | page    |     |     |
  |:-------:|:------:|:----:|:------:|:----:|:-------:|:----:|:-------:|:----:|:-------:|:---:|:---:|
  | **CSI** | **Pe** | ;    | **Pb** | ;    | **Pr**  | ;    | **Pc**  | ;    | **Pp**  | &   | w   |
  | 9/11    | 3/?    | 3/11 | 3/?    | 3/11 | 3/? ... | 3/11 | 3/? ... | 3/11 | 3/? ... | 2/6 | 7/7 |

  Valid values for the event:

  * Pe = 0 → locator unavailable - no other parameters sent
  * Pe = 1 → request - xterm received a DECRQLP
  * Pe = 2 → left button down
  * Pe = 3 → left button up
  * Pe = 4 → middle button down
  * Pe = 5 → middle button up
  * Pe = 6 → right button down
  * Pe = 7 → right button up
  * Pe = 8 → M4 button down
  * Pe = 9 → M4 button up
  * Pe = 1 0 → locator outside filter rectangle

  ‘‘button’’ parameter is a bitmask indicating which buttons are pressed:
  * Pb = 0 → no buttons down
  * Pb & 1 → right button down
  * Pb & 2 → middle button down
  * Pb & 4 → left button down
  * Pb & 8 → M4 button down

  ‘‘row’’ and ‘‘column’’ parameters are the coordinates of the locator
  position in the xterm window, encoded as ASCII decimal. The ‘‘page’’
  parameter is not used by xterm, and will be omitted.

</ul></details>


## Hardware Adapters

### From PS/2 mouse to VT340

Untested, but the idea to use an microcontroller and RS232 level
shifter seems sound:

https://hackaday.io/project/19576-dec-mouse-adapter

### From USB mouse to VT340

[...]

### From USB or PS/2 tablet to VT340

No projects exist yet to recreate the tablet digitizer with its
precision crosshairs or the stylus.

### From DEC mouse to PC serial port

The [Linux kernel][linux] has a builtin driver for the VT340's mouse
peripherals which includes in a comment how to build an adapter so it
can be plugged into a PC's standard RS-232 bus.

[linux]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/input/mouse/vsxxxaa.c

<details><summary>Linux kernel's comment from vsxxxaa.c</summary><ul>

```C
/*
 * Building an adaptor to DE9 / DB25 RS232
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *
 * DISCLAIMER: Use this description AT YOUR OWN RISK! I'll not pay for
 * anything if you break your mouse, your computer or whatever!
 *
 * In theory, this mouse is a simple RS232 device. In practice, it has got
 * a quite uncommon plug and the requirement to additionally get a power
 * supply at +5V and -12V.
 *
 * If you look at the socket/jack (_not_ at the plug), we use this pin
 * numbering:
 *    _______
 *   / 7 6 5 \
 *  | 4 --- 3 |
 *   \  2 1  /
 *    -------
 *
 *	DEC socket	DE9	DB25	Note
 *	1 (GND)		5	7	-
 *	2 (RxD)		2	3	-
 *	3 (TxD)		3	2	-
 *	4 (-12V)	-	-	Somewhere from the PSU. At ATX, it's
 *					the thin blue wire at pin 12 of the
 *					ATX power connector. Only required for
 *					VSXXX-AA/-GA mice.
 *	5 (+5V)		-	-	PSU (red wires of ATX power connector
 *					on pin 4, 6, 19 or 20) or HDD power
 *					connector (also red wire).
 *	6 (+12V)	-	-	HDD power connector, yellow wire. Only
 *					required for VSXXX-AB digitizer.
 *	7 (dev. avail.)	-	-	The mouse shorts this one to pin 1.
 *					This way, the host computer can detect
 *					the mouse. To use it with the adaptor,
 *					simply don't connect this pin.
 *
 * So to get a working adaptor, you need to connect the mouse with three
 * wires to a RS232 port and two or three additional wires for +5V, +12V and
 * -12V to the PSU.
 *
 * Flow specification for the link is 4800, 8o1.
 *
 * The mice and tablet are described in "VCB02 Video Subsystem - Technical
 * Manual", DEC EK-104AA-TM-001. You'll find it at MANX, a search engine
 * specific for DEC documentation. Try
 * http://www.vt100.net/manx/details?pn=EK-104AA-TM-001;id=21;cp=1
 */
```

</ul></details>


