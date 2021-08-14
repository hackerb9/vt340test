## The basics of the VT340 Graphics

The following description is quoted from [EK-VT3XX-GP#About]. 

## Screen Display for Graphics

The terminal's monitor has a display area of 800 pixels horizontally × 480 pixels vertically. A pixel (picture element) is the smallest displayable unit on the screen. A pixel is also the smallest part of an image you can define.

### The Bitmap

Both the VT330 and VT340 use a bitmap to display graphics. The bitmap is that part of the terminal's RAM used to store graphic images.

The VT330 uses a two-plane bitmap for its monochrome monitor. This means each pixel is represented by a 2-bit code. A 2-bit code has four possible values, so the VT330 can display up to four shades of gray at a time. There are 64 shades of gray available to draw graphic images.

The VT340 uses a four-plane bitmap for its color monitor. This means each pixel is represented by a 4-bit code. A 4-bit code has 16 possible values, so the VT340 can display up to 16 different shades or colors at a time. There are 4096 colors available to draw graphic images.

### Graphics Pages

The terminal has two pages of bitmap memory for storing graphics. This manual [EK-VT3XX-GP] refers to those pages as graphics pages. Each graphics page is the same size as the monitor's display area – 800 × 480 pixels.

If the terminal is running a single session, applications can draw to both pages. If the terminal is running dual sessions, each session has one graphics page available. See Volume 1, [Chapter 14 of this manual](EK-VT3XX-GP#Ch14) for more details on session management.

Each graphics page is associated with the first 24 lines on each of the first 2 text pages in page memory. Therefore, there is no second graphics page when the page arrangement is set to 1 page of 144 lines.

## Three Graphics Protocols

You can use one of three graphics protocols to draw images on the terminal: ReGIS, Tektronix 4010/4014, and sixel. This manual [EK-VT3XX-GP] describes how to use each protocol.

**ReGIS**  ReGIS is a graphics instruction set from Digital. ReGIS provides a set of commands you can use to draw images on the screen. You can use ReGIS when the terminal is in VT100 or VT300 operating mode. ReGIS provides a full range of graphics capabilities and is compatible with Digital's VT125 and VT240 terminals.

**4010/4014**  The VT330 and VT340 have a special graphics mode that lets you run software designed for the Tektronix 4010 or 4014 terminal.

**Sixel**  A sixel is a vertical column of six pixels, representing part of a graphics image. Sixel graphics are often used for designing character fonts. Applications can send sixel data to the terminal by using the device control string described in Chapter 14. Volume 1, Chapter 5 describes how to downline-load soft character sets.

## Locator Device (Mouse or Graphics Tablet)

You can use Digital's VSXXX-AA mouse or VSXXX-AB graphics tablet with the VT330 and VT340. The terminals are designed to work with these particular locator devices. A locator device makes it easier to move the screen cursor and send data to graphics applications. You can order the mouse or tablet from Digital's Peripherals and Supplies Group. See Installing and Using the VT330/VT340 Video Terminal for ordering information.