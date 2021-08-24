## Hardware Glitches

This is the page where I'll record hardware/firmware bugs as I come
across them.

### Window up/down changes colors

j4james's bounce program, animation.sh, shows red turning black and
white turning yellow when the ball "moves" up and down. (Animation is
done by moving the screen up and down).

### Extra lines of scrolling in aspect ratios over 4:1

See Issue #11 in which @j4james has figured out at what aspect ratios
extra lines of scrolling are unnecessarily added. He has this to say:

> if you're about to write out a sixel line that isn't going to fit,
> you calculate the number of rows required using
> `(imageHeight/lineHeight)+1` rather than `ceil(imageHeight/lineHeight)`
> (which would have been more "correct"). This results in an extra row
> when the image height is a multiple of 20 (the line height).

> But note that this can only occur when the aspect ratio is 4:1 or
> above. At lower aspect ratios the sixel height is such that it would
> never be overflowing if it was also an exact multiple of the line
> height.

## Not a bug

Here is a place for me to stash odd behavior that I thought was a bug
but was actually by design.

### Text cursor ends up on last line of graphics, sometimes.

I had thought this was an annoying bug but @j4james set me straight. I
had expected the final graphics new line (DECGNL) in a sixel image
would ensure that my text cursor would start on the next available
line of text. It only does some of the time since DECGNL is six pixels
high and text is 20 pixels. A lot of the time, the next words printed
overlap with the bottom of the image. (What good could that possibly
be? Read on to find out!)

I had attempted to add a standard new line after the image, but that
simply shifted the problem so that occasionally there would be two
blank lines.

@j4james pointed out that the solution is to *not* send the final
DECGNL in the image. Since you are guaranteed to be on a line with
graphics, if you send a text new line afterward, it will be on the
next appropriate line, no extra blank line. Even better, @j4james
points out, if you decide to *not* send the text new line, you can
show a full screen image, all the way to the bottom right corner. If
the VT340 had implemented sixels the way I had expected, a full screen
image would have been impossible as it would have triggered scrolling.

