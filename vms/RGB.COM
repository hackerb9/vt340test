!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! From: https://community.hpe.com/t5/operating-system-openvms/colors-using-dcl/td-p/3780829  !
! John Travell Valued Contributor							     !
! ‎05-04-2006 10:07 AM									     !
! Re: Colors using DCL									     !
! 											     !
! The attached procedure is ancient, dating from the early 80's, but may be of some use.     !
! It sets each of the 4 colours that could be used on VT240/VT340's to any one of 64 values. !
! You may find some of the DCL and escape strings to be of some value, or maybe not...	     !
! 											     !
! 275812.txt ‏7 KB									     !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

$!            Simple colour setup for VT240 and VT340 text screens.
$!            ----------------------------------------------------
$!   P1 selects background, P2 foreground, P3 `bold' and P4 `blink' colours.
$!    either @RGB<cr> and answer questions, or (e.g.) @RGB BLU 20 42 RED<cr>
$! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$! remove or modify lines with " #$# " marker when VT340 FCO'd for blink colour
$ if f$mode() .nes. "INTERACTIVE" then exit
$ !
$ set control_y
$ on control_y then goto end
$ on error then goto end
$ !
$ esc[0,8] = 27
$ ws = "write sys$output"
$ colours = "BLACK!BLUE!RED!GREEN!MAGENTA!CYAN!YELLOW!WHITE"
$ term = f$getjpi("","terminal")
$ if .not. f$getdvi(term,"tt_regis") then goto nosup
$ if f$getdvi(term,"devtype") .eq. 110 then goto vt_240
$ if f$getdvi(term,"devtype") .eq. 112 then goto vt_340
$ goto nosup	!comment out for V4.5 or earlier
$vt_340:			!colour identity numbers for VT340 setup
$ back = 0
$ blnk = 1	!blink not used in VT340 yet, correct ID when FCO arrives #$# 
$ col4 = ""	!avoid err while no blink on VT340 #$# 
$ fore = 7
$ bold = 15
$ ttyp = 1			!flag VT340 for skip blink on VT340  #$# 
$ goto ask
$vt_240:			!colour identity numbers for VT240 setup
$ back = 0
$ blnk = 1
$ bold = 2
$ fore = 3
$ ttyp = 0			!flag VT240 for skip blink on VT340  #$# 
$ask:
$ col_chart = 0			!set to 1 when colour chart written out
$ C1  = "H260L65s60"		!HLS colour setup substrings
$ C2  = "H280L50s60"
$ C3  = "D"			!rgb set, black
$ C4  = "B"			!rgb set, blue
$ C5  = "H300L50s25"
$ C6  = "H0L35s25"
$ C7  = "H49L35s60"
$ C8  = "H300L80s25"
$ C9  = "H0L65s25"
$ C10 = "H0L50s60"
$ C11 = "H30L59s100"
$ C12 = "H0L25s25"
$ C13 = "H0L35s60"
$ C14 = "H320L50s60"
$ C15 = "H330L50s100"
$ C16 = "H320L35s60"
$ C17 = "H150L50s100"
$ C18 = "C"			!rgb set, cyan
$ C19 = "H120L35s60"
$ C20 = "H160L50s60"
$ C21 = "H180L65s60"
$ C22 = "H180L80s60"
$ C23 = "G"			!rgb set, green
$ C24 = "H240L25s25"
$ C25 = "H180L25s25"
$ C26 = "H200L35s60"
$ C27 = "H240L50s60"
$ C28 = "H240L35s60"
$ C29 = "H240L35s25"
$ C30 = "H210L50s100"
$ C31 = "H240L65s25"
$ C32 = "H280L35s60"
$ C33 = "H270L50s100"
$ C34 = "H220L65s60"
$ C35 = "H300L25s25"
$ C36 = "H0L33s0"
$ C37 = "H0L66s0"
$ C38 = "H180L50s25"
$ C39 = "M"			!rgb set, magenta
$ C40 = "H80L35s60"
$ C41 = "H120L50s60"
$ C42 = "H60L65s60"
$ C43 = "H40L50s60"
$ C44 = "H20L65s60"
$ C45 = "H120L65s25"
$ C46 = "H60L80s60"
$ C47 = "R"			!rgb set, red
$ C48 = "H120L25s25"
$ C49 = "H100L65s60"
$ C50 = "H90L50s100"
$ C51 = "H80L50s60"
$ C52 = "H120L35s25"
$ C53 = "H160L35s60"
$ C54 = "H140L65s60"
$ C55 = "H60L80s25"
$ C56 = "H300L80s60"
$ C57 = "H340L65s60"
$ C58 = "H300L65s60"
$ C59 = "H60L25s25"
$ C60 = "H60L50s25"
$ C61 = "H160L80s25"
$ C62 = "W"			!rgb set, white
$ C63 = "Y"			!rgb set, yellow
$ C64 = "H200L50s60"
$ !			--------------------
$ colid = back				!set up for background colour
$ col_req = " background:"
$ if p1 .eqs. "" then goto no_p1
$ col = p1				!put colour in 'col'
$ gosub validate			!validate colour choice
$ goto true_p1
$no_p1:
$ gosub get_col				!get input & validate colour choice
$true_p1:
$ col1 = scol				!save colour setup substring
$ !			--------------------
$ colid = fore				!set up for foreground colour
$ col_req = "''esc'[16C  text:"
$ if p2 .eqs. "" then goto no_p2
$ col = p2				!put colour in 'col'
$ gosub validate			!validate colour choice
$ goto true_p2
$no_p2:
$ gosub get_col				!get input & validate colour choice
$true_p2:
$ col2 = scol				!save colour setup substring
$ !			--------------------
$ colid = bold				!set up for bold colour
$ col_req = "''esc'[27C  bold:"
$ if p3 .eqs. "" then goto no_p3
$ col = p3				!put colour in 'col'
$ gosub validate			!validate colour choice
$ goto true_p3
$no_p3:
$ gosub get_col				!get input & validate colour choice
$true_p3:
$ col3 = scol				!save colour setup substring
$ !			--------------------
$ if ttyp .eq. 1 then goto do_it	!skip blink on VT340 #$# 
$ colid = blnk				!set up for blink colour
$ col_req = "''esc'[38C  blink:"
$ if p4 .eqs. "" then goto no_p4
$ col = p4				!put colour in 'col'
$ gosub validate			!validate colour choice
$ goto true_p4
$no_p4:
$ gosub get_col				!get input & validate colour choice
$true_p4:
$ col4 = scol				!save colour setup substring
$ !			--------------------
$do_it:					! #$# 
$ ws "''esc'[1B''esc'P0pS(M''col1'''col2'''col3'''col4')''esc'\" !set colours
$end:
$ exit
$nosup:
$ ws "    This procedure only supports VT240 or VT340 terminals"
$ exit
$ !------ subroutines --------
$get_col:
$ if col_chart .eq. 0 then gosub show_cols	!print map
$ read/prompt="  select colours:- ''col_req' " sys$command col
$ ws "''esc'[2A"					!back up 2 lines
$ if col .eqs. "" then goto no_col		!don't change this colour
$validate:
$ if col .eqs. " " then goto no_col
$ col = f$edit(col,"TRIM,UPCASE")
$ if f$length(col) .ge. 3 then if f$locate(col,colours) .ne. f$length(colours) -
	then goto rgb_col			!check for RGB codes
$ if f$integer(col) .lt. 1 .or. f$integer(col) .gt. 64 then goto bad_col
$ colnum = "c''f$integer(col)'"
$ colnam = 'colnum
$ scol = "''colid'(A''colnam')"			!make HLS substring
$ return
$bad_col:
$ col_chart = 0					!force colour map repaint
$ goto get_col
$rgb_col:
$ scol = "''colid'(A''f$extr(0,1,col)')"	!make RGB substring
$ if f$extr(0,3,col) .eqs. "BLA" then scol = "''colid'(AD)"  !fiddle for black
$ return
$no_col:
$ scol = ""				!no colour = null substring
$ return
$show_cols:
$ type sys$input
[2J[0;0H[0;24r				COLOR TABLE
( 1) Aquamarine     ( 2) Aquamarine,Med.( 3) Black (Dark)   ( 4) Blue           
( 5) Blue,Cadet     ( 6) Blue,Cornflower( 7) Blue,Dark Slate( 8) Blue,Light     
( 9) Blue,LightSteel(10) Blue,Medium    (11) Blue,Med.Slate (12) Blue,Midnight 
(13) Blue,Navy      (14) Blue,Sky       (15) Blue,Slate     (16) Blue,Steel     
(17) Coral          (18) Cyan           (19) Firebrick      (20) Gold           
(21) Goldenrod      (22) Goldenrod,Med. (23) Green          (24) Green,Dark     
(25) Green,Olive    (26) Green,Forest   (27) Green,Lime     (28) Green,Med.Fores
(29) Green,Med.Sea  (30) Green,Med.Sprin(31) Green,Pale     (32) Green,Sea      
(33) Green,Spring   (34) Green,Yellow   (35) Gray,Dark Slate(36) Gray,Dim       
(37) Gray,Light     (38) Khaki          (39) Magenta        (40) Maroon         
(41) Orange         (42) Orchid         (43) Orchid,Dark    (44) Orchid,Medium  
(45) Pink           (46) Plum           (47) Red            (48) Red,Indian     
(49) Red,Med.Violet (50) Red,Orange     (51) Red,Violet     (52) Salmon         
(53) Sienna         (54) Tan            (55) Thistle        (56) Turquoise      
(57) Turquoise,Dark (58) Turquoise,Med. (59) Violet         (60) Violet,Blue    
(61) Wheat          (62) White          (63) Yellow         (64) Yellow,Green   
or 3 chars from 1 of :- black, blue, red, green, magenta, cyan, yellow or white.
$ col_chart = 1
$ return
