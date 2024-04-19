#!/usr/bin/python3

# Convert from VT340 style HLS to RGB.

# Hue is an angle from 0 to 360, where 0 is blue.
# Lightness and saturation are 0 to 100

# Note that standard hls2rgb algorithm almost worked for the VT340
# once the starting angle of the hue was offset by -120 degrees.
# Typically, 0 degrees is typically RED, but on the VT340 it is BLUE!

# The standard algorithm is not quite right as there are certain
# values which are slightly off. For example, from the [default color
# map](colormap.md):
#
# 	HLS(0, 49, 59) maps to RGB(20, 20, 79) on the VT340,
#	but by this algorithm: RGB(20, 20, 78)
#	
# 	HLS(240, 49, 59) on VT340: RGB(20, 79, 20)
#                  this algorithm: RGB(20, 78, 20)
#
# 	HLS(60, 49, 59) on VT340: RGB(79, 20, 79)
#                 this algorithm: RGB(78, 20, 78)
#
# 	HLS(300, 49, 59) on VT340: RGB(20, 79, 79)
#                  this algorithm: RGB(20, 78, 78)
#
# 	HLS(180, 49, 59) on VT340: RGB(79, 79, 20)
#                  this algorithm: RGB(78, 78, 20)
#
# 	HLS(120, 42, 38) on VT340: RGB(59, 26, 26)
#                  this algorithm: RGB(58, 26, 26)
#

# DEC's color code (https://github.com/hackerb9/vms/color-conversion)
# agrees with this tool. The VT340 may have used a shortcut.

import argparse

# Some floating point constants

ONE_THIRD = 1.0/3.0
ONE_SIXTH = 1.0/6.0
TWO_THIRD = 2.0/3.0


def hls2rgb_vt340(h, l, s):
    """Given a VT340 HLS color return a VT340 RGB color.

    Hue ranges from 0 to 360 degrees, 0 degrees is blue.
    Lightness and Saturation range from 0 to 100 percent.

    R, G, B output is in the range from 0 to 100 percent.
    """

    # Normalize to 0.0 to 1.0
    (r,g,b) = hls2rgb_normalized(h/360, l/100, s/100)

    # Scale to 0 to 100% R, G, B
    return [ round(x*100) for x in (r,g,b) ]

def hls2rgb_8bit(h,l,s):
    """Given a VT340 HLS color return an RGB color with the 
    8-bit colordepth more typically seen in modern systems.

    Hue ranges from 0 to 360 degrees, 0 degrees is blue.
    Lightness and Saturation range from 0 to 100 percent.

    R, G, B output is in the range from 0x00 to 0xFF.

    """
    # Normalize to 0.0 to 1.0
    (r,g,b) = hls2rgb_normalized(h/360, l/100, s/100)

    # Scale to 0x00 to 0xFF
    return [ round(x*0xFF) for x in (r,g,b) ]

def hls2rgb_normalized(h, l, s):
    """Given a normalized HLS color return a normalized RGB color.

    Hue ranges from 0.0 to 1.0 degrees, 0 degrees is blue.
    Lightness and Saturation range from 0.0 to 1.0.

    R, G, B output is in the range from 0 to 1.0.

    This routine was borrowed from Python's color library.
    """
    if s == 0.0:
        return l, l, l
    if l <= 0.5:
        m2 = l * (1.0+s)
    else:
        m2 = l+s-(l*s)
    m1 = 2.0*l - m2
    r = _v(m1, m2, h)
    g = _v(m1, m2, h-ONE_THIRD)
    b = _v(m1, m2, h+ONE_THIRD)
    return (r,g,b)

def _v(m1, m2, hue):
    hue = hue % 1.0
    if hue < ONE_SIXTH:
        return m1 + (m2-m1)*hue*6.0
    if hue < 0.5:
        return m2
    if hue < TWO_THIRD:
        return m1 + (m2-m1)*(TWO_THIRD-hue)*6.0
    return m1


def main():
    parser = argparse.ArgumentParser(
        description='Given VT340 HLS color, return RGB as percent.')
    parser.add_argument('hue', type=int, help='hue angle from 0 to 360')
    parser.add_argument('lightness', type=int, help='lightness from 0 to 100')
    parser.add_argument('saturation', type=int, help='saturation from 0 to 100')


    group = parser.add_mutually_exclusive_group()

    group.add_argument('-v', '--vt340', action="store_true",
                        help='Output RGB as percent from 0 to 100, VT340 style (DEFAULT)')
    group.add_argument('-x', '--hex-output', action="store_true",
                        help='Output RGB as three hexadecimal bytes')
    
    args = parser.parse_args()

    if args.hex_output:
        (r,g,b) = hls2rgb_8bit(args.hue, args.lightness, args.saturation)
        print( "%2X%2X%2X" % (r,g,b) )
    else:
        (r,g,b) = hls2rgb_vt340(args.hue, args.lightness, args.saturation)
        print( "%d %d %d" % (r,g,b) )

if __name__ == "__main__":
    main()

