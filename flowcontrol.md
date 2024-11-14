# Flow control on the VT340

Summary: VT340 can only do XON/XOFF flow control. Some USB serial
devices cannot do that. Purchasing an FTDI UART is recommended.

## Flow control overview

The VT340 has a 1024 byte receive buffer. If data is coming in faster
than the VT340 can process it, the buffer will overflow. This happens
easily if complex graphics are sent to the terminal, but can happen
even when just processing typical text data. According to the Text
Programming manual (EK-VT3XX-TP-002, page 265),

> Character processing in the VT300 occurs at about **9400** bits per
> second.

That means, even at the default rate of 9600 baud, some form of flow
control would be necessary if there is a sustained burst of text data
for over 40 seconds. 

    time_to_overflow = ( buffer_size_in_bits ) / ( input_baudrate - processing_speed )
	
    t = ( 1024 * 8 ) / ( baud - 9400 )
	
	t = 8192 / (9600-9400) ≈ 40 seconds
	
At the VT340's top speed of 19,200 baud, the buffer would overflow
from a burst of only 0.84 seconds!

<details><summary>Sidenote about the VT340<b>+</b></summary>

* Hackerb9's VT340<b>+</b> is able to handle 9600 baud without flow
  control.
* Is this because the "plus" version has slightly faster hardware than
  the original VT340? 
* At 19,200 baud the VT340+ required flowcontrol after receiving about
  3200 bytes.
* That puts the text processing speed of the VT340+ at 13,000 bps,
  which is 33% faster than the VT340.

</details>

### The two flavors: hardware and software flow control

There are two kinds of flow control. Hardware flow control (sometimes
known as "RTS/CTS") and software flow control (more commonly referred
to as "XON/XOFF").

* **Hardware flow control** uses physical hardware wires to signal
  whether a machine is ready to receive data or not. It is better
  supported by modern computers, more reliable, faster, and
  unfortunately unsupported by the VT340.

* **Software flow control** is generally less reliable, runs slower,
  and uses up a couple of the keys (Ctrl+S, Ctrl+Q). It is the only
  method the VT340 has to prevent buffer overruns. Fortunately (?) the
  VT340's maximum speed is 19,200 bits per second, which is slow
  enough that software flow control will work, presuming the host
  computer's serial port has the right hardware. (See below.)

|                                                    | Hardware Flow Control<br/>(RTS/CTS) | Software Flow Control<br/>(XON/XOFF)  |
|----------------------------------------------------|-------------------------------------|---------------------------------------|
| VT340 terminal support                             | No                                  | Yes                                   |
| Modern computer hardware support                   | Yes                                 | Requires "on chip" XON/XOFF in UART   |
| Signal terminal uses to ask host to stop sending   | Deasserts RTS pin                   | Sends XOFF character, aka DC3, aka ^S |
| Signal terminal uses to ask host to resume sending | Asserts RTS pin                     | Sends XON character, aka DC1, aka ^Q  |
| Transparent to data?                               | Yes                                 | No, consumes ^S and ^Q                |
| Works over ssh                                     | Yes                                 | Not by default                        |
| Speed                                              | Fast                                | Slow, but fast enough for the VT340   |

## XON/XOFF ALL THE TIME

Normally the VT340 is in XON/XOFF mode (software flow control) and it
is not possible to type ^S or ^Q (Ctrl+S or Ctrl+Q) from the keyboard
as they simply toggle the Hold Screen. However, XON/XOFF can be
disabled from the Communication Set-Up menu by changing the "Receive
XOFF Point" to "Never". However, since the VT340 lacks hardware flow
control, this is not a good idea and will almost assuredly lead to
garbled screens.

Even with XON/XOFF enabled on the VT340, garbling can still occur if
the other end (your PC's serial port) does not support hardware
XON/XOFF or if the system takes longer than 50ms to respond to XOFF
(unlikely with modern computers).

<details><summary>Sidenote about propagation delay</summary>

* By default the threshold for sending XOFF is 64 bytes, which may seem
surprisingly low for a buffer of 1024 bytes. 
* This is likely chosen to accomodate "propagation delay" .
* If ^S/^Q are being sent literally across a network (as happens with
  ssh), it could take a relatively long time for the command to
  propagate and for the flow of incoming data to stop.
* 1024-64 == 960 bytes remaining in the buffer.
* At 9600 baud, the buffer would fill in 100 milliseconds.
* At 19,200 baud, it would be full in 50 ms.
</details>


## Hardware XON/XOFF for "Software" Flowcontrol

TL;DR: USB Serial Ports are not all equal. FTDI usually works.

When hackerb9 first got a VT340, it was a puzzle why it could only
connect at 9600 baud. At 19200, even with XON/XOFF flow control
enabled on the UNIX host (`stty ixon`), it was showing the backwards
question marks indicating that characters were getting dropped.

What was going on? Propagation delay? Termios buffer flushing? Many
esoteric topics were researched and W. Richard Stevens' weighty tome
disected and digested. Teeth were gnashed, hair pulled, kernels
recompiled.

Turns out, some USB serial adapters _do not support xon/xoff flow
control_ in hardware (the UART chip). Hackerb9 tested five brands
of USB serial ports, three of which failed and two which worked:

| Brand      | Model  | Kernel Driver | Works at 19200 |
|------------|--------|---------------|----------------|
| Belkin     | F5U109 | mct\_u232     | no             |
| Targus     | ACP50  | mct\_u232     | no             |
| Kensington | K33232 | pl2303        | YES            |
| Generic    | None   | pl2303?       | no             |
| FTDI       | FT232R | ftdi_sio      | YES            |

Serial adapters which contain FTDI branded UARTs, such as the
**FT232R** and **FT232BM**, are more likely to work as they are
advertised as supporting "on chip" ("automatic") XON/XOFF.

Prolific branded chips may or may not work but tend to be cheaper. The
chip which is inside the Kensington device is Prolific Technology
Inc's **pl2303** (USB Vendor=067b, Product=2303). The generic USB
serial cable also claims to have a pl2303 ("067b:2303"), but is likely
a knock-off as it locks up when `stty ixon` is run.

## Hardware flow control

Hardware flow control is possible with the VT340's firmware, although
the schematic shows it does have the hardware lines necessary. Even on
the DEC423 connectors, with only 6 wires, DTR/DSR are available and
could theoretically be wired to RTS/CTS on the host's serial port,
presuming the VT340 firmware was updated.

See also: [DEC423 Wiring](mmj.md).

## V.25 bis Hardware Handshaking?

What about the statement in the Text Programming manual
[EK-VT3XX-TP-002, page 276]() that 

> "The VT300 only supports the hardware handshaking of the V.25 bis
> protocol"

?

Does that not imply hardware handshaking works to some extent? Yes and
no. When "Modem Control Mode" is set to "Mode 2" in the Communication
Set-Up menu, the VT340 is _compliant_ with V.25 bis CTS/RTS hardware
handshaking. That is, while the terminal is on, it asserts RTS ("I'm
read to receive").

However, it does not appear to actually function in terms of
protecting the receive buffer. It seems to always assert RTS
regardless of how full the buffer is. [XXX Todo: Check this on an
oscilloscope].

Although not as important, it is not even clear that it pays any
attention to CTS, or if it just transmits bytes willy-nilly.


## See also

The VT340's DEC423 MMJ connector pinout and cable wiring is discussed
more fully at [mmj.md](mmj.md).
