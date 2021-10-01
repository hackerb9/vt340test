# Flow control on the VT340

## XON/XOFF ALL THE TIME

Apparently there is no way to disable sending software flow control
XON/XOFF (aka ^S/^Q) from the VT340. The only option is to disable
whether to received XON/XOFF signal. 

This also has the consequence that it appears to be impossible to type
a ^S or ^Q (Ctrl+S or Ctrl+Q) from the keyboard as they simply toggle
the Hold Screen.

## Hardware flow control

Hardware flow control is apparently not possible with the VT340
firmware, although it does have the hardware lines necessary. Even on
the 6 wire DEC423 connectors, DTR/DSR are available and could
theoretically be wired to RTS/CTS on the host's serial port, presuming
the VT340 firmware was updated.

Here's how I wired up my 9-pin female to DEC423 (AKA MMJ) connectors
which I got from PacificCable.com. Since both the VT340 and a typical
PC serial port are "DTE" equipment, they need to have "null modem" in
between to crossover some of the wires. 

Putting both the DTR/DSR and null modem together, one can connect a
VT340's MMJ port to a UNIX host's serial port like so:

| MMJ RS-232 name     | MMJ Pin | DE-9 pin | DE-9 RS-232 name |        |
|---------------------|---------|----------|------------------|--------|
| Data Terminal Ready | 1 →     | 8        | Clear To Send    | White  |
| Transmit Data       | 2 →     | 2        | Receive Data     | Black  |
| Ground              | 3 —     | 5        | Ground           | Red    |
| Ground              | 4       | — 5      | Ground           | Green  |
| Receive Data        | 5       | ← 3      | Transmit Data    | Yellow |
| Data Set Ready      | 6       | ← 7      | Request To Send  | Blue   |

Even without hardware flow control, this wiring works for
communication. I'm using such a connector now with a standard
"BC16E" cable to type this. If you purchase AD-9FT6-G1D from
PacificCable.com, it comes with the pins disconnected so you can
choose how you wish to wire it.

### DE-9 Pinout (Female)

[Note: a "DE-9" port is what we used to call a "DB-9" port. Wikipedia
says we were all wrong.]

      ___________
      \5 4 3 2 1/    DE-9
       \9 8 7 6/ 	 Female
        -------      Connector

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


## USB Serial Ports are not all equal

When I first got my VT340, I could not figure out why I could only
connect at 9600 baud. At 19200, even with flow control turned on on
the UNIX host (`stty ixon`), I was getting the backwards question
marks showing that characters were getting dropped.

I spent a while trying to figure out what was going on. Propagation
delay? Termios buffer? Many esoteric topics were researched and W.
Richard Stevens' tome digested for any nuggets. Teeth were gnashed.
Hair was pulled.

Turns out, some USB serial adapters simply _do not support xon/xoff
flow control_.I had tried two different brands I had laying around and
both had failed the same way. Finally, after figuring out that it is
up to the hardware, I tried a third and that _did_ work:

| Brand      | Model  | Kernel Driver | Works |
|------------|--------|---------------|-------|
| Belkin     | F5U109 | mct_u232      | no    |
| Targus     | ACP50  | mct_u232      | no    |
| Kensington | K33232 | pl2303        | YES   |

I don't recommend buying the Kensington device I used since it is an
extremely old and large port replicator. However, the chip which is
inside of it is Proflific Technology Inc's pl2303 (USB Vendor=067b,
Product=2303). You can search for 067b:2303 and see what devices
have that chip in it.

I also found a recommendation online to buy FTDI products which are
documented by them to support XON/XOFF, such as the UC232R-10. They
seem to be a very reputable company.


