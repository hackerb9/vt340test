### Level 1 printing does not work well and should be avoided

Design misfeatures and bugs make Level 1 Graphics not worth it for
print outs from the VT340. Just use [Level 2](README.md).

* Level 1 Compressed prints lose vertical resolution as they use the
  printer's 2:1 pixel aspect ratio, giving an effective resolution of
  800x240.

* Level 1 Expanded prints have the proper vertical resolution, but
  they double the horizontal resolution (1600x480) in an attempt to
  make printouts look right on DEC printers' 2:1 pixel aspect ratio.

* Rotating level 1 prints does not help as they still suffer the pixel
  aspect ratio problems depending on compressed or expanded setting.
  (400x480 or 800x960)

* Level 1 Compressed Print Mode (the default) has a few problems

  * Fonts look grotty (due to lower resolution)

  * String Terminator (ESC \) at end of file gets shown on screen
    instead of sent to the host which makes it hard (impossible?) to
    tell when the the VT340 has finished.

  * There is some other garbage shown on the screen after the ST,
    looks like the first 80 characters of the printout.
  
  * ImageMagick and XTerm get the geometry wrong because they do not
    understand a pixel aspect ratio of 2:1. They show the image as
    800x240 instead of 800x480.

* Level 1 Expanded Print Mode is better than Compressed in that no
  resolution is lost, but it still has a few problems:

  * ImageMagick can't read it if the starting ST isn't removed.
    (Treats the images as a single pixel)

  * ImageMagick and XTerm get the geometry wrong. They show expanded
    prints as 1600x480 instead of 1600x960.

  * Image is too large to fit on screen when catted to VT340. Repair
    with `convert -sample 50%x100% print.six print.png`.

### Level 1 Compressed Bugs

* When sending level 1 compressed prints, I can't seem to read the
  VT340 String Terminator sequence that marks the end of the print.
  Weirdly, it *does* display on the screen as "^[\". It shows even
  with 'stty -echo' set, which should have prevented anything from
  showing. It must be some bizzaro vt340 firmware fluke.
  Fortunately, it's unlikely anybody wants a compressed print.
  Unfortunately, that is the default setting for the VT340.

  Here is the kludge I used before I found out about Level 2:

      # The final line is not received in "compressed" mode.
      # Kludge: Don't leave terminal in sixel mode after catting file.
      echo -n ${ST} >> print.six

* Since I couldn't read the end of print message (ST), I tried using
  a repeated 1 second time out. However, that doesn't always work.
  In particular, the VT340 takes a long pause in the middle of
  sending an image when, perhps, Print Graphics Background Mode is turned
  off. There may be other circumstances... Oops, spoke too soon, now
  the delay is happening even when the Background Mode is turned on.
  Moral: Timeouts cannot be relied on with using Media Copy to host.

* Since I can't rely on getting the String Terminator with level 1
  compressed graphics, nor can I use a timeout if no data has been
  received for a while, one solution is to wait for a Form Feed (^L)
  at the end. However, that only gets sent if you enable it manually
  in the VT340 Set-up. I do not see a way to enable the Print
  Terminator via escape sequences. Also, it only seems to work in
  Compressed graphics mode, not Expanded.

  Again: this is probably not worth fixing as people can just use
  level 2 or expanded prints.

* Level 1 aspect ratio is displayed incorrectly in ImageMagick and
  xterm. Width seem fine, height is squashed by half. I believe
  these programs simply ignore sixel's ability to change the pixel
  aspect ratio to 2:1.

### Level 1 Expanded bugs

  * Print Terminator of Form Feed doesn't seem to get sent even
    when it is enabled in the Set-Up screen. This is annoying
    because I wanted to use that to detect the end of the printout.
    (On the upside, the final line, including ST *are* sent.)

  * Weird bug: Rotated & Expanded prints of a region begin with 0A XX
    P, where XX is some random byte such as E3 or FC. It should begin
    with newline (0A) then the 7-bit DCS sequence (ESC P). This seems
    to be a bug. Changing those first two bytes to a single ESC makes
    the sixel file valid.

      ( echo -n $'\e'; tail -c+3 < rotated-expanded.six ) > foo.six

    [UPDATE: After resetting my VT340 this bug is not reproducing].



