# VT340 Locator Devices

The [Linux kernel][linux] describes the VT340's locator devices like so:

```C
/*
 *      DEC VSXXX-AA mouse (hockey-puck mouse, ball or two rollers)
 *		DEC VSXXX-GA mouse (rectangular mouse, with ball)
 *		DEC VSXXX-AB tablet (digitizer with hair cross or stylus)
 */
```

## Documentation

* [VT340 Programmer's Reference: Chapter 10 Report Command (in ReGIS)][ch10]
* [VT340 Programmer's Reference: Chapter 15 Using a Mouse or Tablet][ch15]
* [VCB02 Video Subsystem Technical Manual][vcb02]
*


[ch15]: https://vt100.net/docs/vt3xx-gp/chapter15.html "Using a Mouse or Tablet"
[ch10]: https://vt100.net/docs/vt3xx-gp/chapter10.html "ReGIS Report Command"
[ch13]: https://vt100.net/docs/vt3xx-gp/chapter13.html "Tektronix 4014 Emulation"


## Testing

The VT340 manual describes two ways to read input from a locator
device: ReGIS and GIN. 


## Hardware Adapters

### From PS/2 mouse to VT340

Untested, but the idea to use an microcontroller and RS232 level
shifter seems sound:

https://hackaday.io/project/19576-dec-mouse-adapter

### From USB mouse to VT340



### From DEC mouse to PC serial port

The [Linux kernel][linux] has a builtin driver for the VT340's mouse
peripherals which includes as a comment how to build an adapter
Building an adaptor so it can be plugged into a standard RS-232 bus.

[linux]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/input/mouse/vsxxxaa.c

<details><summary>Linux kernel's comment from vsxxxaa.c</summary>

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

</details>



Hackerb9 only has a VSXXX-AA mouse so tests of VSXXX

"Locator devices" is what DEC calls input devices that provide a
coordinate on the screen. The VT340 could be used with a circular
mouse (VSXXX-AA) or a tablet (VSXXX-AB). The tablet could use either a

## Overview

* ReGIS "One-Shot" mode
  [locator1shot.sh](locator1shot.sh)

* ReGIS Multi mode.

* Tek GIN mode.

* Custom events for button up/down.


