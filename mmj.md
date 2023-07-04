# DEC 423 (MMJ) Pinout

The VT340's second communication port and its printer port use a
DEC-423 connection, not the more typical DB-25. (The first comm port
offers both DEC-423 and DB-25).

## Hackerb9's Guess at DEC423 Wiring

Here's how hackerb9 wired up a 9-pin female to DEC-423 (colloquially
known as "MMJ", Modified Modular Jack) connector purchased from
PacificCable.com. Since both the VT340 and a typical PC serial port
are "DTE" equipment, they need to have a "null modem" in between to
crossover some of the wires.

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
standard DECconnect "BC16E" cable through such a connector. If you
purchase AD-9FT6-G1D from PacificCable.com, it comes with the pins
disconnected so you can choose how you wish to wire it.

## DE-9 Pinout (Female)

[Note: a "DE-9" port is what we used to call a "DB-9" port. Wikipedia
says we were all wrong.]

      ___________
      \5 4 3 2 1/	DE-9
       \9 8 7 6/ 	Female
        ------- 	Connector

## MMJ Pin 1 is furthest from "thumb" of MMJ latch

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

## BC16E DEC 423 Cable

| MMJ Plug 1 | Wire Color | DEC-423 | DEC-423 | Wire Color | MMJ Plug 2 |
|------------|------------|---------|---------|------------|------------|
| 1          | White      | Rdy Out | Rdy In  | Blue       | 6          |
| 2          | Black      | Tx+     | Rx+     | Yellow     | 5          |
| 3          | Red        | Tx-     | Rx-     | Green      | 4          |
| 4          | Green      | Rx-     | Tx-     | Red        | 3          |
| 5          | Yellow     | Rx+     | Tx+     | Black      | 2          |
| 6          | Blue       | Rdy In  | Rdy Out | White      | 1          |

----------------------------------------------------------------------

# Question H4 From the Digital Unix FAQ

## What are the pinouts of the MMJ jacks?

```ASCIIART
This describes the 6-pin modified modular jack (MMJ) used for serial ports
on various Digital hardware.

Digital carries four DB-to-MMJ adaptors.  They are internally wired as follows

                   Rdy Out  TX+  TX-  RX-  RX+  Rdy In      
 Adaptor   Gender     1      2    3    4    5     6       Use with:
--------------------------------------------------------------------------
 H8575-A     F      20      2    7    7    3    6&8     VTxxx terminal
 H8571-C     M       6      3    7    7    2     20     Digital printer
 H8571-D     M       6      3    7    7    2     20     Modem
 H8571-E     M      20      2    7    7    3    6&8     Female terminal
                                                        or LaserWriter
--------------------------------------------------------------------------

RS-232 using DB-25 connectors:
                                                DTE           DCE
                                             Terminal        Modem
                                            or computer
Pin Number Signal Name
    2          TD        Transmit Data                   -->
    3          RD        Receive Data                    <--
    7          GND       Ground                          ---
    6          DSR       Data Set Ready                  <--
    8          DCD       Data Carrier Detect             <--
   20          DTR       Data Terminal Ready             -->
```
