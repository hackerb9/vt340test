Mode | VT340 Response | Description | Notes
-----|----------------|-------------|------
1 | reset| Application Cursor Keys (DECCKM), VT100. | 
2 | set| VT52 (ANSI) Mode (DECANM), VT520. | To leave VT52 mode, use Esc <.
3 | reset| 132 Column Mode (DECCOLM), VT100. | 
4 | set| Smooth (Slow) Scroll (DECSCLM), VT100. | 
5 | reset| Reverse Video Screen (DECSCNM), VT100. | SET is light bg, RESET is dark bg.
6 | reset| Origin Mode (DECOM), VT100. | 
7 | reset| Auto-Wrap Mode (DECAWM), VT100. | 
8 | set| Auto-Repeat Keys (DECARM), VT100. | 
10 | reset| Edit Mode (DECEDM). | 
11 | reset| Line Transmit Mode (DECLTM). | 
13 | reset| Space compression field delimiter (DECSCFDM) | 
14 | set| Transmit execution (DECTEM). | 
16 | set| Edit key execution (DECEKEM). | 
18 | reset| Print Form Feed (DECPFF), VT220. | 
19 | set| Set printer extent to full screen (DECPEX), VT220. | 
25 | set| Text cursor enable (DECTCEM), VT220. | 
38 | reset| Tektronix mode (DECTEK), VT240, xterm. | 
42 | permanently reset| National Replacement Character sets (DECNRCM), VT220. | On the VT340 and perhaps other terminals, DECNRCM is PERMANENTLY RESET when the Keyboard Dialect selected in the Set Up menu is 'North American'.
43 | reset| Graphics Expanded Print Mode (DECGEPM). | 
44 | reset| Graphics Print Color (DECGPCM) | 
45 | reset| Graphics Print Color Syntax (DECGPCS). | 
46 | set| Graphics Print Background (DECGPBM). | 
47 | reset| Graphics Rotated Print Mode (DECGRPM). | 
53 | reset| VT131 transmit (DEC131TM). | 
60 | reset| Horizontal cursor coupling (DECHCCM). | 
61 | set| Vertical cursor coupling (DECVCCM). | 
64 | set| Page cursor coupling (DECPCCM). | 
66 | reset| Application/Numeric keypad mode (DECNKM), VT320 | 
67 | reset| Backarrow key sends backspace (DECBKM), VT340, VT420, VT520. | When RESET (the default), backarrow key sends delete.
68 | reset| Keyboard Usage: Data Processing or Typewriter Keys (DECKBUM). | Data Processing characters are printed on the right half of the keycaps. According to ek-520-rm, 'If you use the North American language, then DECKBUM should always be RESET (typewriter). For all other languages, you can use either mode.'
73 | set| Transmit rate limiting (DECXRLM). | 
80 | reset| Sixel Display Mode (DECSDM). | 
