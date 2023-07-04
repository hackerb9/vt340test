# Flow control on the VT340

Summary: VT340 can only do XON/XOFF flow control. Some USB serial
devices cannot do that.

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
known as "RTS/CTS") and software flowcontrol (more commonly referred
to as "XON/XOFF"). 

Hardware flow control uses physical hardware wires to signal whether a
machine is ready to receive data or not. Is better supported by modern
computers, is more reliable, faster, and unsupported by the VT340.

Software flow control is less reliable, uses up a couple of the keys
(Ctrl+S, Ctrl+Q), slower and is the only method the VT340 has to
prevent buffer overruns.

|                                                 | Hardware Flow Control<br/>(RTS/CTS) | Software Flow Control<br/>(XON/XOFF)  |
|-------------------------------------------------|-------------------------------------|---------------------------------------|
| VT340 support                                   | No                                  | Yes                                   |
| Modern computer hardware support                | Yes                                 | Not on some USB serial adapters       |
| Signal VT340 uses to ask host to stop sending   | Deasserts RTS pin                   | Sends XOFF character, aka DC3, aka ^S |
| Signal VT340 uses to ask host to resume sending | Asserts RTS pin                     | Sends XON character, aka DC1, aka ^Q  |
| Transparent to data?                            | Yes                                 | No, consumes ^S and ^Q                |
| Works over ssh                                  | Yes                                 | Not by default                        |
| Speed                                           | Fast                                | Slow                                  |

## XON/XOFF ALL THE TIME

Normally the VT340 is in XON/XOFF mode (software flow control) and it
is not possible to type ^S or ^Q (Ctrl+S or Ctrl+Q) from the keyboard
as they simply toggle the Hold Screen. However, XON/XOFF can be
disabled from the Communication Set-Up menu by changing the "Receive
XOFF Point" to "Never". However, since the VT340 appears to lack
hardware flow control, this will almost assuredly lead to garbled
screens.

Even with XON/XOFF enabled on the VT340, garbling can still occur if
the other end (the PC's serial port) does not support hardware
XON/XOFF or if the system takes longer than 50ms to respond to XOFF.

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


## Hardware for "Software" Flowcontrol

TL;DR: USB Serial Ports are not all equal.

When hackerb9 first got a VT340, it was a puzzle why it could only
connect at 9600 baud. At 19200, even with XON/XOFF flow control
enabled on the UNIX host (`stty ixon`), it was showing the backwards
question marks indicating that characters were getting dropped.

What was going on? Propagation delay? Termios buffer flushing? Many
esoteric topics were researched and W. Richard Stevens' weighty tome
digested and disected. Teeth were gnashed. Hair was pulled.

Turns out, some USB serial adapters _do not support xon/xoff flow
control_ in hardware (the UART chip). Hackerb9 tested four brands of
USB serial ports, two of which failed and two which worked:

| Brand      | Model  | Kernel Driver | Works |
|------------|--------|---------------|-------|
| Belkin     | F5U109 | mct\_u232     | no    |
| Targus     | ACP50  | mct\_u232     | no    |
| Kensington | K33232 | pl2303        | YES   |
| FTDI       | FT232R | ftdi_sio      | YES   |

Serial adapters which contain FTDI branded UARTs, such as the FT232R
and FT232BM, are more likely to work as they are advertised as
supporting "on chip" ("automatic") XON/XOFF. Prolific branded chips,
such as the PL2303, may or may not work. It is not recommended to buy
the exact Kensington device listed here since it is an extremely old
and large port replicator. However, the chip which is inside of it is
Prolific Technology Inc's pl2303 (USB Vendor=067b, Product=2303). You
can search for 067b:2303 and see what devices have that chip in it.

## Hardware flow control

Hardware flow control is apparently not possible with the VT340
firmware, although it does have the hardware lines necessary. Even on
the 6 wire DEC423 connectors, DTR/DSR are available and could
theoretically be wired to RTS/CTS on the host's serial port, presuming
the VT340 firmware was updated.

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


