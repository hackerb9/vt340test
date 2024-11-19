# MMJ (DEC 423) Serial Port Pinout and Wiring

The VT340 has three MMJ ("Modified Modular Jack") ports: the first and
second communication port and the printer port. Officially it is
called "DEC-423" or "DECconnect", but colloquially and most commonly
it is MMJ.

<!-- XXX TODO: Put image of back panel here with arrow to MMJ and -->
<!-- showing synonyms: MMJ, DEC-423, DECconnect. -->

Note that MMJ is not required as the VT340 also has a standard RS-232
DB-25 connector which can be configured in the VT340 Setup menu to map
to the first communication port. However, to get the most of your
VT340, including dual sessions and printing graphics, you'll need MMJ
cables.

## Why MMJ is nifty

* Simple "telephone" line cable
* Connect any two devices with that one cable (no more messing with
  null modems to convert DTE/DCE)
* Quick connect/disconnect
* Based on EIA-423-D, so cables can be much longer than RS-232
* Backwards compatible with RS-232 signals

## MMJ to DE-9F Adapter

Since modern computers don't use MMJ, you'll need a female DE-9 RS-232
to MMJ socket adapter. According to [Lammert Bies][lammert] the DEC
model number for this adapter is **H8571-J**.

  [lammert]: https://www.lammertbies.nl/comm/cable/dec-mmj

<!-- XXX TODO: Insert picture of adapter here. -->

However, that adapter's wiring (see below) requires an additional null
modem to work properly, losing one of the advantages of using MMJ.

## Hackerb9's Suggestion for DE-9 to MMJ Wiring

Here's how hackerb9 wired up a 9-pin female to MMJ connector so that,
like original DEC equipment, a PC can be plugged into any MMJ device
using just a single cable. Since both the VT340 and a typical PC
serial port are "DTE", some wires crossover as with a null modem.

|     MMJ RS-232 name | MMJ Pin |   | DE-9 pin | DE-9 RS-232 name                 |               |
|--------------------:|--------:|:-:|:---------|----------------------------------|---------------|
| Data Terminal Ready |       1 | → | 1<br/>6<br/>8  | Carrier Detect</br/>Data Set Ready<br/>Clear To Send | White         |
|       Transmit Data |       2 | → | 2        | Receive Data                     | Black         |
|              Ground | 3<br/>4 | — | 5        | Ground                           | Red<br/>Green |
|        Receive Data |       5 | ← | 3        | Transmit Data                    | Yellow        |
|      Data Set Ready |       6 | ← | 7        | Request To Send                  | Blue          |

<sub><i> j Note: On the DE-9 end of the adapter there is a small
problem since unassembled kits come with only six DSub female pins.
That means only two of pins 1, 6, and 8 can be connected. Perhaps the
most important of those is pin 1 (Carrier Detect) as without it,
programs like `less` and `mesg` would hang forever on open of
/dev/tty. A software fix, if you have such a cable, is to run `stty
clocal`. 

Pin 8 (Clear To Send) is also useful as it is common for modern
systems to presume hardware flow control (even though the VT340 does
not have it). Pin 6 (Data Set Ready) is least important as [UNIX
systems have ignored it for eons][UWR870] in favor of Carrier Detect
(Pin 1). For more considerations, see the [Linux Text Terminal
Howto][TLDPTTH].

</i></sub>

  UWR870: https://www.washington.edu/R870/TerminalsModems.html
  TLDPTTH: https://tldp.org/HOWTO/Text-Terminal-HOWTO-12.html

Despite the VT340 lacking hardware flow control, this wiring works
well for communication. The words you are reading are flowing from a
VT340, over a standard "DEC-423 BC16E" cable, through this homemade
MMJ to DE-9 adapter, to a UNIX host's serial port. _Caveat: Some USB
to RS232 serial adapters lack "on-chip XON/XOFF" and will cause
dropped characters. See [flowcontrol.md](flowcontrol.md) for details._


### Purchasing Unassembled MMJ-DB9F Adapters

Most of the MMJ-DB9F adapters sale online come with the pins
disconnected so you can choose how you wish to wire it.

Hackerb9 ordered from Pacific Cable (part no. AD-9FT6-G1D), but [their
website](https://pacificcable.com) is down. It looks like you can get
the same thing from other suppliers, but no promises.

* [L-Com Item # REC096FD][lcom].<br/>
  _($14 each + $10 shipping in the US as of 2024)._

  Surprisingly, L-Com also offers a free [3D CAD model][lcommodel] and
  [blueprint][lcomblueprint] if you want to make your own.

* [Stonewall Cable SKU: P-MMJ-DB9F][stonewall].<br/>
  _($15 each + $20 shipping in the US as of 2024)._

* [Connect Zone SKU MA-09FD][connectzone].<br/>
  _($5 each + $10 shipping in the US as of 2024)_
  
  <sub>
  
  Connect Zone may no longer be in business as their website is
  suffering badly from bitrot.
  
  </sub>
  
  
  [lcom]: https://www.l-com.com/ethernet-modular-adapter-db9-female-mmj-6x6-jack-50%C2%B5-gold
  [lcommodel]: https://www.l-com.com/Download/CadDownloads?fileLocation=%2Fcontent%2FImages%2FDownloadables%2F3D%2FREC096FD_3D.STEP&fileName=REC096FD_3D.STEP
  [lcomblueprint]: https://www.l-com.com/Images/Downloadables/2D/REC096FD_2D.pdf
  [stonewall]: https://www.stonewallcable.com/more/accessories/modular-adapters/mmj-offset/unassembled-modular-adapter-mmj-db9f
  [connectzone]: https://www.connectzone.com/ma-09fd.html


<!-- Note that when assembling, if you follow hackerb9's schematic, you'll
need to cut and splice one of the female D-Sub pins. See the [assembly
instructions](mmj-db9f-assembly.md) for details. -->


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

Note: wire color gets flipped on one plug since DEC-423 always uses
crossover cables.

### BC16E DEC-423 Cable

This is DEC's official MMJ cable. 

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

----------------------------------------------------------------------


### Mark Gleaves MMJ to 9-pin serial with fake RTS/CTS flow control

The Linux Documentation Project has a pinout very similar to the one
hackerb9 suggests above. It additionally loops back the Request to
Send (RTS) signal from the PC back into the Carrier Detect (CD) and
Data Terminal Ready (DTR) pins. This seems like a mistake as RTS and
DTR are both _outputs_ pins and one could fry the serial port if they
disagree about what voltage to set the line.

His schematic is:

      DEC MMJ                            Linux PC DB9
    Pin  Signal                           Signal  Pin
    ===  ======                           ======  ===
     1    DTR -----------------------|---> DSR     6
                                     |---> CTS     8
     2    TxD ---------------------------> RxD     2
     3    SG (TxD)--------------------|--- SG      5
     4    SG (RxD)--------------------|
     5    RxD <--------------------------- TxD     3
     6    DSR <-----------------------|--- RTS     7
                                      |--> DTR !?  4
                                      |--> CD      1
                           (no connection) RI      9

Hackerb9 does NOT RECOMMENDED this cable due to the possibility of
hardware damage.


### DEC H8571-J adapter: PC RS232 serial port to MMJ, straight

DEC's official MMJ to DE-9 adapter. While physically this looks the
same as hackerb9's suggested dongle above, the wiring does not include
the necessary "null modem" crossover for connecting a VT340 to a PC.

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
