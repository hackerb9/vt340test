## Hardware Glitches

This is the page where I'll record hardware/firmware bugs as I come
across them.

### Window up/down changes colors

j4james's bounce program, animation.sh, shows red turning black and
white turning yellow when the ball "moves" up and down. (Animation is
done by panning the screen up and down using `CSI Pn S` and `CSI Pn T`).

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

### Text Cursor is left one row too high for certain sixel heights

@j4james may correct me on this, but I believe it is a glitch in the
VT340 hardware that for certain heights of sixel images the text
cursor is moved so that it overlaps not the final line of sixels but
the row above it.

Normally, one needs only a single text newline (`\n`) to go to the
next free line of text after sending a sixel image, but for those
particular heights, one would need two.

This bug occurs if (_h_-1)%6 > (_h_-1)%20, for a sixel image of height
_h._ Looking at all possible heights on the VT340 (from 1 to 480), the
entire list of buggy heights is:

<pre>
	 21  22  23  24  41  42          81  82  83  84
	101 102         141 142 143 144 161 162 
	201 202 203 204 221 222         261 262 263 264 281 282 
	321 322 323 324 341 342         381 382 383 384
	401 402         441 442 443 444 461 462
</pre>

#### Workaround

Other than checking each image's height to see if it is problematic,
what other solutions are there? As luck would have it, many
programmers may never run into this problem since scaling an image so
its height fits a certain number of text rows — which is useful thing
to do [anyway](https://github.com/hackerb9/vv) — means the bug would
never be triggered.

A text row is 20 pixels in height, but actually any image height which
is a multiple of ten (which is common) also works. In fact, although
less frequently seen, any multiple of 5 avoids the glitch.

#### Is it worth it to work around this bug?

The final digit in the table of buggy heights shows how many pixels
would be shaved off the bottom of the image if the glitch had occurred
and only a single newline was used before printing text. The maximum
is 4, but that occurs less often than one might expect. Counting the
possibilities, we get:

| Pixels shaved | Count | Probability (given glitch has occurred) |
|:-------------:|:-----:|:---------------------------------------:|
| 1             | 16    | ⅓                                       |
| 2             | 16    | ⅓                                       |
| 3             | 8     | ⅙                                       |
| 4             | 8     | ⅙                                       |

When the glitch occurs, two thirds of the time only 1 or 2 lines of
pixels would be overwritten by text. But, the glitch only occurs on 48
out of 480 possible image sizes. Adding the other 432 possibilities
into the table gives:

| Pixels shaved | Count | Probability |
|--------------:|------:|------------:|
|             0 |   432 |         90% |
|             1 |    16 |       3.33% |
|             2 |    16 |       3.33% |
|             3 |     8 |       1.66% |
|             4 |     8 |       1.66% |

So, the vast majority of the time, there will be no problem and when
there is a problem, it will likely be only 1 or 2 lines of pixels cut
off. Whether that matters or not depends on the application being
developed.

____

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
DECGNL in the image. Even better, @j4james points out, if you decide
to *not* send the text new line, you can show a full screen image, all
the way to the bottom right corner without scrolling.

~~Since you are guaranteed to be on a line with graphics, if you send a
text new line afterward, it will be on the next appropriate line, no
extra blank line.~~

[EDIT: I MISUNDERSTOOD AGAIN. THE PREVIOUS PARAGRAPH IS NOT TRUE].

Please see [sixeltests/textcursor.sh](sixeltests/textcursor.sh) which
shows how various methods overlap depending upon the height of the
sixel image sent. Sending a newline seems to overlap the least, but
does still have problems.

To do: @j4james said something CUR CUD (cursor down) is correct.



