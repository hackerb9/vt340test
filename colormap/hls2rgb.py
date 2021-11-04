#!/usr/bin/python3

# The standard hls2rgb algorithm worked for the VT340 once the
# starting angle of the hue was offset by -120 degrees.
# 0 degrees is typically RED, but on the VT340 appears to be BLUE!

import colorsys, argparse

def hls2rgb(h,l,s):
     (r,g,b) = colorsys.hls_to_rgb((h-120)/360, l/100, s/100)
     return [ int(x*100+.5) for x in (r,g,b) ]

def main():
    parser = argparse.ArgumentParser(
        description='Given VT340 HLS color, return RGB as percent.')
    parser.add_argument('hue', type=int, help='hue angle from 0 to 360')
    parser.add_argument('lightness', type=int, help='lightness from 0 to 100')
    parser.add_argument('saturation', type=int, help='saturation from 0 to 100')

    args = parser.parse_args()

    print( hls2rgb(args.hue, args.lightness, args.saturation) )


if __name__ == "__main__":
    main()

