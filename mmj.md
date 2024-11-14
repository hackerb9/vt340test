# DEC 423 (MMJ) Serial Port Pinout and Wiring

The VT340 has a standard RS-232 DB-25 connector only for its first
communication port. The second communication port and printer port
require a DEC-423 connection — colloquially known as "MMJ", Modified
Modular Jack. 

<!-- XXX TODO: Put image of back panel here with arrow to MMJ]. -->

(The first communication port can be used with either DB-25 or
DEC-423.)

## Why DEC 423 is nifty

* Simple "telephone" line cable
* Connect any two devices with that one cable (no more messing with
  null modems to convert DTE/DCE)
* Quick connect/disconnect
* Based on EIA-423-D, so cables can be much longer than RS-232
* Backwards compatible with RS-232 signals

## MMJ to DB9F Adapter

Since modern computers don't use MMJ, you'll need a female DE-9 RS-232
to MMJ socket adapter. According to [Lammert Bies][lammert] the DEC
model number for this adapter is **H8571-J**.

  [lammert]: https://www.lammertbies.nl/comm/cable/dec-mmj

<!-- XXX TODO: Insert picture of adapter here. -->

However, DEC's wiring requires an additional null modem to work
properly which is slightly annoying.

## Hackerb9's Suggestion for DE-9 to DEC423 Wiring

Here's how hackerb9 wired up a 9-pin female to DEC-423 connector so
that, like original DEC equipment, the PC can now be plugged into any
MMJ device using just a single cable. Since both the VT340 and a
typical PC serial port are "DTE", some of the wires need to crossover
as a null modem would do.

|     MMJ RS-232 name | MMJ Pin |   | DE-9 pin | DE-9 RS-232 name                 |               |
|--------------------:|--------:|:-:|:---------|----------------------------------|---------------|
| Data Terminal Ready |       1 | → | 8<br/>1  | Clear To Send<br/>Carrier Detect | White         |
|       Transmit Data |       2 | → | 2        | Receive Data                     | Black         |
|              Ground | 3<br/>4 | — | 5        | Ground                           | Red<br/>Green |
|        Receive Data |       5 | ← | 3        | Transmit Data                    | Yellow        |
|      Data Set Ready |       6 | ← | 7        | Request To Send                  | Blue          |

<sub><i>

Note: This connects pins 8 and 1 on the DE-9 so that the host computer
always sees the VT340 as present (carrier detect). Without this,
programs like `less` and `mesg` would hang forever on open of
/dev/tty. A software fix, if you have such a cable, is to run
`stty clocal`.

</i></sub>

Even without hardware flow control, this wiring works well for
communication. The words you are reading are flowing from a VT340
over a standard DECconnect "BC16E" cable, through this connector, to a
UNIX host's serial port. _Caveat: Some USB to RS232 serial adapters
lack "on-chip XON/XOFF" and will cause dropped characters. See below
for details._


### Purchasing Unassembled MMJ-DB9F Adapters

Most of the MMJ-DB9F adapters I've seen for sale online come with the
pins disconnected so you can choose how you wish to wire it.

I purchased mine from Pacific Cable (part no. AD-9FT6-G1D), but [their
website](https://pacificcable.com) is down. It looks like you can get
the same thing from other suppliers, but I cannot vouch for them.

* [L-Com Item # REC096FD][lcom].<br/>
  _($14 each + $10 shipping in the US as of 2024)._

  Surprisingly, L-Com also offers a free [3D CAD model][lcommodel] and
  [blueprint][lcomblueprint] if you want to make your own.

* [Stonewall Cable SKU: P-MMJ-DB9F][stonewall].<br/>
  _($15 each + $20 shipping in the US as of 2024)._

* [Connect Zone SKU MA-09FD][connectzone].<br/>
  _($5 each + $10 shipping in the US as of 2024)_
  
  I'm not sure Connect Zone still exists as their website is suffering
  badly from bitrot. 
  
  
  [lcom]: https://www.l-com.com/ethernet-modular-adapter-db9-female-mmj-6x6-jack-50%C2%B5-gold
  [lcommodel]: https://www.l-com.com/Download/CadDownloads?fileLocation=%2Fcontent%2FImages%2FDownloadables%2F3D%2FREC096FD_3D.STEP&fileName=REC096FD_3D.STEP
  [lcomblueprint]: https://www.l-com.com/Images/Downloadables/2D/REC096FD_2D.pdf
  [stonewall]: https://www.stonewallcable.com/more/accessories/modular-adapters/mmj-offset/unassembled-modular-adapter-mmj-db9f
  [connectzone]: https://www.connectzone.com/ma-09fd.html




## More pinouts

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

This is the standard MMJ connection cable. 

<!-- XXX TODO: Insert picture of BC16E cable. -->

| MMJ Plug 1 | Wire Color | DEC-423 | DEC-423 | Wire Color | MMJ Plug 2 |
|------------|------------|---------|---------|------------|------------|
| 1          | White      | Rdy Out | Rdy In  | Blue       | 6          |
| 2          | Black      | Tx+     | Rx+     | Yellow     | 5          |
| 3          | Red        | Tx-     | Rx-     | Green      | 4          |
| 4          | Green      | Rx-     | Tx-     | Red        | 3          |
| 5          | Yellow     | Rx+     | Tx+     | Black      | 2          |
| 6          | Blue       | Rdy In  | Rdy Out | White      | 1          |


Instead of using vintage cables which cost a premium, hackerb9
purchased an MMJ crimper and a bag of MMJ plugs to make BC16E cables
out of ordinary 6-wire telephone cable.

<!-- XXX TODO: Insert picture of crimper and MMJ plugs. -->


### DEC H8571-J adapter: PC RS232 serial port to MMJ, straight

While externally this looks the same as hackerb9's suggested dongle
above, this does not include the necessary "null modem" crossover for
connecting a terminal to a PC. 

| MMJ<br/>RS-232 name | MMJ<br/>Pin | DE-9<br/>pin       | DE-9<br/>RS-232 name                                |
|--------------------:|:-----------:|:------------------:|-----------------------------------------------------|
|                 DTR | 1           | 4                  | Data Terminal Ready                                 |
|                 Tx+ | 2           | 3                  | Transmit Data                                       |
|         Tx-</br>Rx- | 3<br/>4     | 5                  | Ground                                              |
|                 Rx+ | 5           | 3                  | Receive Data                                        |
|                 DSR | 6           | 1<br/>6<br/>8<br/> | Data Set Ready<br/>Clear To Send<br/>Carrier Detect |



----------------------------------------------------------------------

## Question H4 From the Digital Unix FAQ

<blockquote>

## What are the pinouts of the MMJ jacks?

This describes the 6-pin modified modular jack (MMJ) used for serial ports
on various Digital hardware.

Digital carries four DB-to-MMJ adaptors.  They are internally wired as follows

| Adaptor | Gender | 1      | 2   | 3   | 4   | 5   | 6     | Use with:       |
|---------|--------|--------|-----|-----|-----|-----|-------|-----------------|
|         |        | RdyOut | TX+ | TX- | RX- | RX+ | RdyIn |                 |
| H8575-A | F      | 20     | 2   | 7   | 7   | 3   | 6&8   | VTxxx terminal  |
| H8571-C | M      | 6      | 3   | 7   | 7   | 2   | 20    | Digital printer |
| H8571-D | M      | 6      | 3   | 7   | 7   | 2   | 20    | Modem           |
| H8571-E | M      | 20     | 2   | 7   | 7   | 3   | 6&8   | LaserWriter     |

</blockquote>


----------------------------------------------------------------------

## Pinout of 9-pin and 25-pin serial connectors

Adapted from the Linux Serial HOWTO chapter 19.

<blockquote>

The pin numbers are often engraved in the plastic of the connector but you may
need a magnifying glass to read them. Note DCD is sometimes labeled CD. The
numbering of the pins on a female connector is read from right to left,
starting with 1 in the upper right corner (instead of 1 in the upper left
corner for the male connector as shown below). --> direction is out of PC.

```
      ___________                    ________________________________________
      \1 2 3 4 5/  Looking at pins   \1  2  3  4  5  6  7  8  9  10 11 12 13/
       \6 7 8 9/  on male connector   \14 15 16 17 18 19 20 21 22 23 24 25/
        ------                         -----------------------------------
```

| DB-9 | DB-25 | Name | Full-Name           | Dir | What-it-May-Do/Mean     |
|------|-------|------|---------------------|-----|-------------------------|
| 1    | 8     | DCD  | Data Carrier Detect | <-- | Modem online            |
| 2    | 3     | RxD  | Receive Data        | <-- | Receives bytes on PC    |
| 3    | 2     | TxD  | Transmit Data       | --> | Transmits bytes from PC |
| 4    | 20    | DTR  | Data Terminal Ready | --> | PC says, "I'm here."    |
| 5    | 7     | SG   | Signal Ground       | --- |                         |
| 6    | 6     | DSR  | Data Set Ready      | <-- | Other side is connected |
| 7    | 4     | RTS  | Request To Send     | --> | "I'm ready to receive"  |
| 8    | 5     | CTS  | Clear To Send       | <-- | PC is clear to send     |
| 9    | 22    | RI   | Ring Indicator      | <-- | Telephone line ringing  |

Note that in modern usage, "Request to Send" is a misnomer from the
days of half-duplex. Since the 1980s, the RTS pin has been used for
full-duplex "RTS/CTS hardware handshaking". Some have suggested
renaming it "Ready To Receive".

</blockquote>
