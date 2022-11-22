Mode | VT340 Default | Description | Notes
-----|---------------|-------------|------
0 | <sub>not recognized</sub> |  | 
1 | reset| Application Cursor Keys (DECCKM), VT100. | 
2 | set| VT52 (ANSI) Mode (DECANM), VT520. | To leave VT52 mode, use Esc <.
3 | reset| 132 Column Mode (DECCOLM), VT100. | 
4 | reset| Smooth (Slow) Scroll (DECSCLM), VT100. | 
5 | reset| Reverse Video Screen (DECSCNM), VT100. | SET is light bg, RESET is dark bg.
6 | reset| Origin Mode (DECOM), VT100. | 
7 | reset| Auto-Wrap Mode (DECAWM), VT100. | 
8 | set| Auto-Repeat Keys (DECARM), VT100. | 
9 | <sub>not recognized</sub>| Send Mouse X & Y on button press, X10 XTerm. | VT100 used mode 9 for interlace, but dropped it in VT200+.
10 | reset| Edit Mode (DECEDM). | 
11 | reset| Line Transmit Mode (DECLTM). | 
12 | <sub>not recognized</sub>| Katakana Shift Mode (DECKANAM), VT382-J | 
13 | reset| Space compression field delimiter (DECSCFDM) | 
14 | set| Transmit execution (DECTEM). | 
15 | <sub>not recognized</sub>|  | 
16 | set| Edit key execution (DECEKEM). | 
17 | <sub>not recognized</sub>|  | 
18 | reset| Print Form Feed (DECPFF), VT220. | 
19 | set| Set printer extent to full screen (DECPEX), VT220. | 
20 | <sub>not recognized</sub>| Overstrike Mode (OS), VK100 | 
21 | <sub>not recognized</sub>| Local BASIC Mode (BA), VK100 | 
22 | <sub>not recognized</sub>| Host BASIC Mode (BA), VK100 | 
23 | <sub>not recognized</sub>| Programmed Keypad Mode (PK), VK100 | 
24 | <sub>not recognized</sub>| Auto Hardcopy Mode (AH), VK100 | 
25 | set| Text cursor enable (DECTCEM), VT220. | 
26 | <sub>not recognized</sub>|  | 
27 | <sub>not recognized</sub>|  | 
28 | <sub>not recognized</sub>|  | 
29 | <sub>not recognized</sub>|  | 
30 | <sub>not recognized</sub>| Show scrollbar, rxvt. | 
31 | <sub>not recognized</sub>|  | 
32 | <sub>not recognized</sub>|  | 
33 | <sub>not recognized</sub>|  | 
34 | <sub>not recognized</sub>| Cursor direction, right to left. | 
35 | <sub>not recognized</sub>| Hebrew keyboard mapping. | ek-vt3xx-tp is in error. DECTEK is actually 38.
36 | <sub>not recognized</sub>| Hebrew encoding mode. | 
37 | <sub>not recognized</sub>|  | 
38 | reset| Tektronix mode (DECTEK), VT240, xterm. | 
39 | <sub>not recognized</sub>|  | 
40 | <sub>not recognized</sub>| Allow 80/132 mode, xterm. | 
41 | <sub>not recognized</sub>| more(1) fix. | 
42 | permanently reset| National Replacement Character sets (DECNRCM), VT220. | 
43 | reset| Graphics Expanded Print Mode (DECGEPM). | 
44 | set| Graphics Print Color (DECGPCM) | 
45 | set| Graphics Print Color Syntax (DECGPCS). | 
46 | reset| Graphics Print Background (DECGPBM). | 
47 | reset| Graphics Rotated Print Mode (DECGRPM). | 
48 | <sub>not recognized</sub>|  | 
49 | <sub>not recognized</sub>| Thai Keyboard Input Mode (DECTHAIM), VT382-T | 
50 | <sub>not recognized</sub>| Thai Cursor Mode (DECTHAICM), VT382-T | SET is internal cursor, RESET is physical cursor
51 | <sub>not recognized</sub>|  | 
52 | <sub>not recognized</sub>|  | 
53 | set| VT131 transmit (DEC131TM). | 
54 | <sub>not recognized</sub>|  | 
55 | <sub>not recognized</sub>|  | 
56 | <sub>not recognized</sub>|  | 
57 | <sub>not recognized</sub>| North American / Greek keyboard mapping (DECNAKB) | 
58 | <sub>not recognized</sub>| IBM ProPrinter Emulation (DECIPEM) | Interpret subsequent data according to the IBM ProPrinter protocol syntax instead of the DEC protocol.
59 | <sub>not recognized</sub>| Kanji/Katakana Display Mode (DECKKDM), VT382-J | 
60 | reset| Horizontal cursor coupling (DECHCCM). | 
61 | set| Vertical cursor coupling (DECVCCM). | 
62 | <sub>not recognized</sub>|  | 
63 | <sub>not recognized</sub>|  | 
64 | set| Page cursor coupling (DECPCCM). | 
65 | <sub>not recognized</sub>|  | 
66 | reset| Application/Numeric keypad mode (DECNKM), VT320 | 
67 | reset| Backarrow key sends backspace (DECBKM), VT340, VT420, VT520. | By default (RESET) backarrow key sends delete.
68 | reset| Keyboard Usage: Data Processing or Typewriter Keys (DECKBUM). | Data Processing characters are printed on the right half of the keycaps. According to ek-520-rm, 'If you use the North American language, then DECKBUM should always be RESET (typewriter). For all other languages, you can use either mode.'
69 | <sub>not recognized</sub>| Vertical split screen / Left and right margin mode (DECVSSM/DECLRMM), VT420 and up. | 
70 | <sub>not recognized</sub>|  | 
71 | <sub>not recognized</sub>|  | 
72 | <sub>not recognized</sub>|  | 
73 | reset| Transmit rate limiting (DECXRLM). | 
74 | <sub>not recognized</sub>|  | 
75 | <sub>not recognized</sub>|  | 
76 | <sub>not recognized</sub>|  | 
77 | <sub>not recognized</sub>|  | 
78 | <sub>not recognized</sub>|  | 
79 | <sub>not recognized</sub>|  | 
80 | reset| Sixel Display Mode (DECSDM). | 
81 | <sub>not recognized</sub>| Keyboard sends key position reports instead of character codes (DECKPM). | 
82 | <sub>not recognized</sub>|  | 
83 | <sub>not recognized</sub>|  | 
84 | <sub>not recognized</sub>|  | 
85 | <sub>not recognized</sub>|  | 
86 | <sub>not recognized</sub>|  | 
87 | <sub>not recognized</sub>|  | 
88 | <sub>not recognized</sub>|  | 
89 | <sub>not recognized</sub>|  | 
90 | <sub>not recognized</sub>| Thai Space Compensating Mode (DECTHAISCM), VT382-T | 
91 | <sub>not recognized</sub>|  | 
92 | <sub>not recognized</sub>|  | 
93 | <sub>not recognized</sub>|  | 
94 | <sub>not recognized</sub>|  | 
95 | <sub>not recognized</sub>| Do not clear screen when DECCOLM is set/reset (DECNCSM), VT510 and up. | 
96 | <sub>not recognized</sub>| Perform a copy/paste from right-to-left (DECRLCM), VT520 | Only valid with Hebrew keyboard language, see DEC mode 35
97 | <sub>not recognized</sub>| CRT Save Mode (DECCRTSM), VT520 | 
98 | <sub>not recognized</sub>| Auto-resize the number of lines-per-page when the page arrangement changes (DECARSM), VT520 | 
99 | <sub>not recognized</sub>| Modem Control Mode: require DSR or CTS before communicating (DECMCM), VT520 | 
100 | <sub>not recognized</sub>| Send automatic answerback message 500ms after a communication line connection is made (DECAAM), VT520 | 
101 | <sub>not recognized</sub>| Conceal Answerback Message (DECCANSM), VT520 | 
102 | <sub>not recognized</sub>| Discard NUL characters upon receipt, or pass them on to the printer (DECNULM) | 
103 | <sub>not recognized</sub>| Half-Duplex Mode (DECHDPXM), VT520 | 
104 | <sub>not recognized</sub>| Enable Secondary Keyboard Language (DECESKM), VT520 | 
105 | <sub>not recognized</sub>|  | 
106 | <sub>not recognized</sub>| Overscan mode for monochrome VT520 terminal (DECOSCNM) | 
107 | <sub>not recognized</sub>|  | 
108 | <sub>not recognized</sub>| Num Lock Mode of keyboard (DECNUMLK) | 
109 | <sub>not recognized</sub>| Caps Lock Mode of keyboard (DECCAPSLK) | 
110 | <sub>not recognized</sub>| Keyboard LED's Host Indicator Mode (DECKLHIM) | 
111 | <sub>not recognized</sub>| Framed Windows with title bars, borders, and icons (DECFWM), VT520 | 
112 | <sub>not recognized</sub>| Allow user to Review Previous Lines that have scrolled off the top (DECRPL) | 
113 | <sub>not recognized</sub>| Host Wake-up Mode, CRT and Energy Saver (DECHWUM), VT520 | 
114 | <sub>not recognized</sub>| Use an alternate text color for underlined text (DECATCUM), VT520 | 
115 | <sub>not recognized</sub>| Use an alternate text color for blinking text (DECATCMB), VT520 | 
116 | <sub>not recognized</sub>| Bold and blink styles affect background as well as foreground (DECBSM), VT520 | 
117 | <sub>not recognized</sub>| Erase Color is screen background (VT) or text background (PC) (DECECM), VT520 | Background color used when text is erased or new text is scrolled on to the screen
118 | <sub>not recognized</sub>|  | 
119 | <sub>not recognized</sub>|  | 
120 | <sub>not recognized</sub>|  | 
121 | <sub>not recognized</sub>|  | 
122 | <sub>not recognized</sub>|  | 
123 | <sub>not recognized</sub>|  | 
124 | <sub>not recognized</sub>|  | 
125 | <sub>not recognized</sub>|  | 
126 | <sub>not recognized</sub>|  | 
127 | <sub>not recognized</sub>|  | 
... | ... |  | 
1022 | <sub>not recognized</sub>|  | 
1023 | <sub>not recognized</sub>|  | 
1024 | <sub>not recognized</sub>|  | 
