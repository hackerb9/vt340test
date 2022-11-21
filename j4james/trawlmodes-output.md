Mode | VT340 Default | Description | Notes
-----|---------------|-------------|------
0 | not recognized|  | 
1 | reset| Application Cursor Keys (DECCKM), VT100. | 
2 | set| VT52 (ANSI) Mode (DECANM), VT520. | To leave VT52 mode, use Esc <.
3 | reset| 132 Column Mode (DECCOLM), VT100. | 
4 | reset| Smooth (Slow) Scroll (DECSCLM), VT100. | 
5 | reset| Reverse Video Screen (DECSCNM), VT100. | SET is light bg, RESET is dark bg.
6 | reset| Origin Mode (DECOM), VT100. | 
7 | reset| Auto-Wrap Mode (DECAWM), VT100. | 
8 | set| Auto-Repeat Keys (DECARM), VT100. | 
9 | not recognized| Send Mouse X & Y on button press, X10 XTerm. | VT100 used mode 9 for interlace, but dropped it in VT200+.
10 | reset| Edit Mode (DECEDM). | 
11 | reset| Line Transmit Mode (DECLTM). | 
12 | not recognized| Katakana Shift Mode (DECKANAM), VT382-J | 
13 | reset| Space compression field delimiter (DECSCFDM) | 
14 | set| Transmit execution (DECTEM). | 
15 | not recognized|  | 
16 | set| Edit key execution (DECEKEM). | 
17 | not recognized|  | 
18 | reset| Print Form Feed (DECPFF), VT220. | 
19 | set| Set printer extent to full screen (DECPEX), VT220. | 
20 | not recognized| Overstrike Mode (OS), VK100 | 
21 | not recognized| Local BASIC Mode (BA), VK100 | 
22 | not recognized| Host BASIC Mode (BA), VK100 | 
23 | not recognized| Programmed Keypad Mode (PK), VK100 | 
24 | not recognized| Auto Hardcopy Mode (AH), VK100 | 
25 | set| Text cursor enable (DECTCEM), VT220. | 
26 | not recognized|  | 
27 | not recognized|  | 
28 | not recognized|  | 
29 | not recognized|  | 
30 | not recognized| Show scrollbar, rxvt. | 
31 | not recognized|  | 
32 | not recognized|  | 
33 | not recognized|  | 
34 | not recognized| Cursor direction, right to left. | 
35 | not recognized| Hebrew keyboard mapping. | ek-vt3xx-tp is in error. DECTEK is actually 38.
36 | not recognized| Hebrew encoding mode. | 
37 | not recognized|  | 
38 | reset| Tektronix mode (DECTEK), VT240, xterm. | 
39 | not recognized|  | 
40 | not recognized| Allow 80/132 mode, xterm. | 
41 | not recognized| more(1) fix. | 
42 | permanently reset| National Replacement Character sets (DECNRCM), VT220. | 
43 | reset| Graphics Expanded Print Mode (DECGEPM). | 
44 | set| Graphics Print Color (DECGPCM) | 
45 | set| Graphics Print Color Syntax (DECGPCS). | 
46 | reset| Graphics Print Background (DECGPBM). | 
47 | reset| Graphics Rotated Print Mode (DECGRPM). | 
48 | not recognized|  | 
49 | not recognized| Thai Keyboard Input Mode (DECTHAIM), VT382-T | 
50 | not recognized| Thai Cursor Mode (DECTHAICM), VT382-T | SET is internal cursor, RESET is physical cursor
51 | not recognized|  | 
52 | not recognized|  | 
53 | set| VT131 transmit (DEC131TM). | 
54 | not recognized|  | 
55 | not recognized|  | 
56 | not recognized|  | 
57 | not recognized| North American / Greek keyboard mapping (DECNAKB) | 
58 | not recognized| IBM ProPrinter Emulation (DECIPEM) | Interpret subsequent data according to the IBM ProPrinter protocol syntax instead of the DEC protocol.
59 | not recognized| Kanji/Katakana Display Mode (DECKKDM), VT382-J | 
60 | reset| Horizontal cursor coupling (DECHCCM). | 
61 | set| Vertical cursor coupling (DECVCCM). | 
62 | not recognized|  | 
63 | not recognized|  | 
64 | set| Page cursor coupling (DECPCCM). | 
65 | not recognized|  | 
66 | reset| Application/Numeric keypad mode (DECNKM), VT320 | 
67 | reset| Backarrow key sends backspace (DECBKM), VT340, VT420, VT520. | By default (RESET) backarrow key sends delete.
68 | reset| Keyboard Usage: Data Processing or Typewriter Keys (DECKBUM). | Data Processing characters are printed on the right half of the keycaps. According to ek-520-rm, 'If you use the North American language, then DECKBUM should always be RESET (typewriter). For all other languages, you can use either mode.'
69 | not recognized| Vertical split screen / Left and right margin mode (DECVSSM/DECLRMM), VT420 and up. | 
70 | not recognized|  | 
71 | not recognized|  | 
72 | not recognized|  | 
73 | reset| Transmit rate limiting (DECXRLM). | 
74 | not recognized|  | 
75 | not recognized|  | 
76 | not recognized|  | 
77 | not recognized|  | 
78 | not recognized|  | 
79 | not recognized|  | 
80 | reset| Sixel Display Mode (DECSDM). | 
81 | not recognized| Keyboard sends key position reports instead of character codes (DECKPM). | 
82 | not recognized|  | 
83 | not recognized|  | 
84 | not recognized|  | 
85 | not recognized|  | 
86 | not recognized|  | 
87 | not recognized|  | 
88 | not recognized|  | 
89 | not recognized|  | 
90 | not recognized| Thai Space Compensating Mode (DECTHAISCM), VT382-T | 
91 | not recognized|  | 
92 | not recognized|  | 
93 | not recognized|  | 
94 | not recognized|  | 
95 | not recognized| Do not clear screen when DECCOLM is set/reset (DECNCSM), VT510 and up. | 
96 | not recognized| Perform a copy/paste from right-to-left (DECRLCM), VT520 | Only valid with Hebrew keyboard language, see DEC mode 35
97 | not recognized| CRT Save Mode (DECCRTSM), VT520 | 
98 | not recognized| Auto-resize the number of lines-per-page when the page arrangement changes (DECARSM), VT520 | 
99 | not recognized| Modem Control Mode: require DSR or CTS before communicating (DECMCM), VT520 | 
100 | not recognized| Send automatic answerback message 500ms after a communication line connection is made (DECAAM), VT520 | 
101 | not recognized| Conceal Answerback Message (DECCANSM), VT520 | 
102 | not recognized| Discard NUL characters upon receipt, or pass them on to the printer (DECNULM) | 
103 | not recognized| Half-Duplex Mode (DECHDPXM), VT520 | 
104 | not recognized| Enable Secondary Keyboard Language (DECESKM), VT520 | 
105 | not recognized|  | 
106 | not recognized| Overscan mode for monochrome VT520 terminal (DECOSCNM) | 
107 | not recognized|  | 
108 | not recognized| Num Lock Mode of keyboard (DECNUMLK) | 
109 | not recognized| Caps Lock Mode of keyboard (DECCAPSLK) | 
110 | not recognized| Keyboard LED's Host Indicator Mode (DECKLHIM) | 
111 | not recognized| Framed Windows with title bars, borders, and icons (DECFWM), VT520 | 
112 | not recognized| Allow user to Review Previous Lines that have scrolled off the top (DECRPL) | 
113 | not recognized| Host Wake-up Mode, CRT and Energy Saver (DECHWUM), VT520 | 
114 | not recognized| Use an alternate text color for underlined text (DECATCUM), VT520 | 
115 | not recognized| Use an alternate text color for blinking text (DECATCMB), VT520 | 
116 | not recognized| Bold and blink styles affect background as well as foreground (DECBSM), VT520 | 
117 | not recognized| Erase Color is screen background (VT) or text background (PC) (DECECM), VT520 | Background color used when text is erased or new text is scrolled on to the screen
118 | not recognized|  | 
119 | not recognized|  | 
120 | not recognized|  | 
121 | not recognized|  | 
122 | not recognized|  | 
123 | not recognized|  | 
124 | not recognized|  | 
125 | not recognized|  | 
126 | not recognized|  | 
127 | not recognized|  | 
... | ... |  | 
1022 | not recognized|  | 
1023 | not recognized|  | 
1024 | not recognized|  | 
