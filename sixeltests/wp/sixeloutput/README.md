# Typescripts from running WordPerfect

The purpose of this is to see what sort of output WordPerfect actually
created for the VT340 and other sixel terminal devices. 

Questions: What escape codes are sent before and after a print? How
are colors set? How many DCS strings are used to display an image?

## wp -t kermit 

MSKermit 3.0, a telecommunications program and terminal emulator from
Columbia University, included "VT340 sixel" support. However,
WordPerfect puts it into Tektronix graphics mode (`Esc [ ? 34 h`),
which is weird as that would not work on a genuine VT340. Kermit did
display sixels on an alternate screen, similar to how the VT340
displays Tek graphics, so was this a genuine requirement of Kermit?

* [kermit.typescript](kermit.typescript): Full typescript of running
  `wp -t kermit` and doing a print preview. Includes escape codes
  before and after the program.

* [kermit.print](kermit.print): Excerpt which contains just the sixel
  image from the print preview. The image is made up of multiple DCS
  strings. The image colormap is set in the first DCS string, which
  would work on the VT340, but not most terminal emulators. 
  
* [kermit.print.cleaned](kermit.print.cleaned): Modified excerpt which
  merges the image into a single DCS string which can be viewed on
  most terminal emulators.
  
  
