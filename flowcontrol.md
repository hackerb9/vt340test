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
to as XON/XOFF). 

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
XOFF Point" to "Never". 

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


## USB Serial Ports are not all equal

When hackerb9 first got a VT340, it was a puzzle why it could only
connect at 9600 baud. At 19200, even with XON/XOFF flow control
enabled on the UNIX host (`stty ixon`), it was showing the backwards
question marks indicating that characters were getting dropped.

Hackerb9 spent a while trying to figure out what was going on.
Propagation delay? Termios buffer flushing? Many esoteric topics were
researched and W. Richard Stevens' weighty tome digested and disected.
Teeth were gnashed. Hair was pulled.

Turns out, some USB serial adapters simply _do not support xon/xoff
flow control_. Two different brands that had been lying around both
had failed the same way. After figuring out that it is up to the
hardware, hackerb9 tried a third and that _did_ work:

| Brand      | Model  | Kernel Driver | Works |
|------------|--------|---------------|-------|
| Belkin     | F5U109 | mct_u232      | no    |
| Targus     | ACP50  | mct_u232      | no    |
| Kensington | K33232 | pl2303        | YES   |

It is not recommended to buy the Kensington device hackerb9 used since
it is an extremely old and large port replicator. However, the chip
which is inside of it is Proflific Technology Inc's pl2303 (USB
Vendor=067b, Product=2303). You can search for 067b:2303 and see what
devices have that chip in it.

Some people have recommended online to buy FTDI products, such as the
UC232R-10, which are documented by them to support XON/XOFF. They seem
to be a very reputable company.


## Hardware flow control

Hardware flow control is apparently not possible with the VT340
firmware, although it does have the hardware lines necessary. Even on
the 6 wire DEC423 connectors, DTR/DSR are available and could
theoretically be wired to RTS/CTS on the host's serial port, presuming
the VT340 firmware was updated.

### Hackerb9's Guess at DEC423 Wiring

Here's how hackerb9 wired up a 9-pin female to DEC423 (AKA MMJ,
Modified Modular Jack) connector purchased from PacificCable.com.
Since both the VT340 and a typical PC serial port are "DTE" equipment,
they need to have "null modem" in between to crossover some of the
wires.

Putting both the DTR/DSR and null modem requirements together, one can
connect a VT340's MMJ port to a UNIX host's serial port like so:

| MMJ RS-232 name     | MMJ Pin | DE-9 pin | DE-9 RS-232 name |        |
|---------------------|---------|----------|------------------|--------|
| Data Terminal Ready | 1 →     | 8        | Clear To Send    | White  |
| Transmit Data       | 2 →     | 2        | Receive Data     | Black  |
| Ground              | 3 —     | 5        | Ground           | Red    |
| Ground              | 4       | — 5      | Ground           | Green  |
| Receive Data        | 5       | ← 3      | Transmit Data    | Yellow |
| Data Set Ready      | 6       | ← 7      | Request To Send  | Blue   |

Even though hardware flow control does not work, yet, this wiring
works for communication. The words you are reading are flowing over a
standard DECconnect "BC16E" cable and through such a connector. If you
purchase AD-9FT6-G1D from PacificCable.com, it comes with the pins
disconnected so you can choose how you wish to wire it.

### DE-9 Pinout (Female)

[Note: a "DE-9" port is what we used to call a "DB-9" port. Wikipedia
says we were all wrong.]

      ___________
      \5 4 3 2 1/	DE-9
       \9 8 7 6/ 	Female
        ------- 	Connector

### MMJ Pin 1 is furthest from "thumb" of MMJ latch

In the VT340, DEC assigns the 2nd and 3rd serial-port pins like this
(a 6-pin MMJ DEC-423 port, similar to EIA-423-D):

```
          _______________                 1 - DTR
          |             |                 2 - TXD+
          | 1 2 3 4 5 6 |                 3 - TXD-
          |________    _|                 4 - RXD-
                  |___|                   5 - RXD+
                                          6 - DSR
```

| MMJ Pin | DEC-423 name | Signal    | Wire Color at Jack | DB-25 |
|---------|--------------|-----------|--------------------|-------|
| 1       | Rdy Out      | DTR       | White              | 20    |
| 2       | Tx+          | TxD       | Black              | 2     |
| 3       | Tx-          | GND       | Red                | 7     |
| 4       | Rx-          | GND       | Green              | 7     |
| 5       | Rx+          | RxD       | Yellow             | 3     |
| 6       | Rdy In       | DSR & DCD | Blue               | 6 & 8 |

Note: wire color gets flipped on one plug since DEC 423 uses
crossover cables.

### BC16E DEC 423 Cable

| MMJ Plug 1 | Wire Color | DEC-423 | DEC-423 | Wire Color | MMJ Plug 2 |
|------------|------------|---------|---------|------------|------------|
| 1          | White      | Rdy Out | Rdy In  | Blue       | 6          |
| 2          | Black      | Tx+     | Rx+     | Yellow     | 5          |
| 3          | Red        | Tx-     | Rx-     | Green      | 4          |
| 4          | Green      | Rx-     | Tx-     | Red        | 3          |
| 5          | Yellow     | Rx+     | Tx+     | Black      | 2          |
| 6          | Blue       | Rdy In  | Rdy Out | White      | 1          |



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


