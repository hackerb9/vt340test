#!/bin/bash

# Allows the user to pick four colors from the palette of 64 colors
# available on the VT241 to use for text display. This also works on
# the VT340, but does not take advantage of its hardware (16 colors
# from a palette of 4096).

# Based on an ancient VMS DCL procedure from the early 1980s.
# Rewritten by hackerb9 in 2023.
# See end of file for original script.

###############################################################################
#            Simple colour setup for VT240 and VT340 text screens.	      #
#            ----------------------------------------------------	      #
#   P1 selects background, P2 foreground, P3 `bold' and P4 `blink' colours.   #
#    either @RGB<cr> and answer questions, or (e.g.) @RGB BLU 20 42 RED<cr>   #
###############################################################################

# Todo:
#
# * Rewrite from scratch to get rid of crazy GOSUB/GOT control flow.
#
# * What was the "blink color" FCO (Field Change Order) for the VT340?
#   (Hackerb9's vt340 does blink+bold using color index number 8)
#
# * Write up how this differs from "ANSI color" and the pros and cons. 
#
# * Proper VT340 support:
#   IDEAS
#   * Use extra color map entries to preview what settings look like.
#   * Allow picking from 4096 color palette.
#     * Maybe sliders, like VT340's firmware, but HLS instead of RGB.
#     * Maybe allow refining colour with a second choice from 64.
#     * Maybe have user pick three bits at a time, most significant first.
#       * Can pick four times to refine. 4x3 = 12 bits per color.
#       * Show a central square with example text and eight squares around it.
#              (0xxx,0xxx,0xxx), (0xxx,0xxx,1xxx), (0xxx,1xxx,0xxx),
#              (1xxx,1xxx,1xxx),                   (0xxx,1xxx,1xxx),
#              (1xxx,1xxx,0xxx), (1xxx,0xxx,1xxx), (1xxx,0xxx,0xxx), 
#         Let xxx be 100 and xx be 10 to get a medium tone when refining.
#       * Squares can be picked by number or by arrow keys. 9 finishes.
#       Problem: ReGIS specifies colors in HLS, not RGB!

vt_340() {			#colour identity numbers for VT340 setup
    back=0
    blnk=8			# blink bold text fg
    fore=7
    bold=15
    ask
    exit
}
vt_240() {			#colour identity numbers for VT240 setup
    back=0
    blnk=1
    bold=2
    fore=3
    ask
    exit
}

interrupt() {
    echo
    echo
    exit
}

end() {
    tput sgr0
    echo -n "This is normal text	"
    tput bold
    echo "This is bold text"
    tput sgr0
    tput blink
    echo -n "This is blinking text	"
    tput bold
    echo "This is boldly blinking text"
    tput sgr0
    exit 0
}
ws() {
    echo -n "$@"
}

nosup() {
    ws "    This procedure only supports VT240 or VT340 terminals"
    exit
#    echo "xxx for debugging, trying to run anyway" >&2
#    OperatingLevel=63
}    

ask() {
    col_chart=0			#set to 1 when colour chart written out
    C[ 1]="H260L65S60"		#HLS colour setup substrings
    C[ 2]="H280L50S60"
    C[ 3]="D"			#rgb set, black
    C[ 4]="B"			#rgb set, blue
    C[ 5]="H300L50S25"
    C[ 6]="H0L35S25"
    C[ 7]="H49L35S60"
    C[ 8]="H300L80S25"
    C[ 9]="H0L65S25"
    C[10]="H0L50S60"
    C[11]="H30L59S100"
    C[12]="H0L25S25"
    C[13]="H0L35S60"
    C[14]="H320L50S60"
    C[15]="H330L50S100"
    C[16]="H320L35S60"
    C[17]="H150L50S100"
    C[18]="C["			#rgb set, cyan
    C[19]="H120L35S60"
    C[20]="H160L50S60"
    C[21]="H180L65S60"
    C[22]="H180L80S60"
    C[23]="G"			#rgb set, green
    C[24]="H240L25S25"
    C[25]="H180L25S25"
    C[26]="H200L35S60"
    C[27]="H240L50S60"
    C[28]="H240L35S60"
    C[29]="H240L35S25"
    C[30]="H210L50S100"
    C[31]="H240L65S25"
    C[32]="H280L35S60"
    C[33]="H270L50S100"
    C[34]="H220L65S60"
    C[35]="H300L25S25"
    C[36]="H0L33S0"
    C[37]="H0L66S0"
    C[38]="H180L50S25"
    C[39]="M"			#rgb set, magenta
    C[40]="H80L35S60"
    C[41]="H120L50S60"
    C[42]="H60L65S60"
    C[43]="H40L50S60"
    C[44]="H20L65S60"
    C[45]="H120L65S25"
    C[46]="H60L80S60"
    C[47]="R"			#rgb set, red
    C[48]="H120L25S25"
    C[49]="H100L65S60"
    C[50]="H90L50S100"
    C[51]="H80L50S60"
    C[52]="H120L35S25"
    C[53]="H160L35S60"
    C[54]="H140L65S60"
    C[55]="H60L80S25"
    C[56]="H300L80S60"
    C[57]="H340L65S60"
    C[58]="H300L65S60"
    C[59]="H60L25S25"
    C[60]="H60L50S25"
    C[61]="H160L80S25"
    C[62]="W"			#rgb set, white
    C[63]="Y"			#rgb set, yellow
    C[64]="H200L50S60"
    #			--------------------
    colid=$back				#set up for background colour
    col_req=" background:"
    [[ "$p1" ]] || no_p1		# check user supplied args
    col=$p1				#put colour in 'col'
    validate				#validate colour choice
    true_p1
    exit
}

no_p1() {
    get_col				#get input & validate colour choice
    true_p1
    exit
}
true_p1() {
    col1=$scol				#save colour setup substring
    #			--------------------
    colid=$fore				#set up for foreground colour
    col_req="$esc[16C  text:"
    [[ "$p2" ]] || no_p2
    col=$p2				#put colour in 'col'
    validate			#validate colour choice
    true_p2
    exit
}
no_p2() {
    get_col				#get input & validate colour choice
    true_p2
    exit
}
true_p2() {
    col2=$scol				#save colour setup substring
    #			--------------------
    colid=$bold				#set up for bold colour
    col_req="$esc[27C  bold:"
    [[ "$p3" ]] || no_p3
    col=$p3				#put colour in 'col'
    validate			#validate colour choice
    true_p3
    exit
}
no_p3() {
    get_col				#get input & validate colour choice
    true_p3
    exit
}
true_p3() {
    col3=$scol				#save colour setup substring
    colid=$blnk				#set up for blink colour
    col_req="$esc[38C  blink:"
    [[ "$p4" ]] || no_p4
    col=$p4			#put colour in 'col'
    validate			#validate colour choice
    true_p4
    exit
}
no_p4() {
    get_col				#get input & validate colour choice
    true_p4
    exit
}
true_p4() {
    col4=$scol				#save colour setup substring
    do_it
    exit
}

# !			--------------------
do_it() {
    #set colours
    ws "${esc}[1B${esc}P0pS(M${col1}${col2}${col3}${col4})${esc}\\" 
    exit
}


getprimaryda() {
    # Request the Primary Device Attributes report from the terminal.
    # Set global variable OperatingLevel (61=VT100, 62=VT2x0, 63=VT3x0)
    # Set global associative array Extensions[key], with key for every reported extension.
    local key
    declare -g OperatingLevel
    declare -gA Extensions
    IFS=";" read -a DA -s -t 1 -d "c" -p $'\e[c' >&2

    OperatingLevel=${DA[0]}
    OperatingLevel=${OperatingLevel:3}

    for key in ${!DA[@]}; do
	value=${DA[$key]}
	Extensions[${value:0:3}]=Yup
    done
}

getjpi() {
    echo "$TERM"
}

getdvi() {
    # Get Device Information
    # Not sure how VMS did this, but probably had a fixed database.
    # We'll dynamically inquire from the terminal using Device Attributes.
    # Only the two functions needed by the script are implemented.

    local term=$1  inq=$2  i

    # Make sure getprimaryda is run to set OperatingLevel and Extensions[]
    [[ "$OperatingLevel" ]] || 	getprimaryda

    case $inq in
	tt_regis)
	    [[ ${Extensions[3]} ]]
	    return
	    ;;
	devtype)
	    echo $OperatingLevel 	# Not the same as VMS's devtype, but good enough.
	    return
	    ;;
	*)
	    echo "Unknown inquiry '$inq'" >&2
	    return 1
    esac
}    
	    


# !------ subroutines --------
get_col() {
    if [[ $col_chart == 0 ]]; then show_cols; fi	#print map
    read -p "  select colours:- $col_req " col
    ws "$esc[2A"					#back up 2 lines
    [[ "$col" ]] || no_col		#don't change this colour
    validate
}

validate() {
    [[ "$col" ]] || no_col
    col=$(echo ${col})	# Trim whitespace on outside.

    if [[ "${#col}" -ge 3 ]]; then
	if [[ $colours == *$col* ]]; then 
	    #check for RGB codes (rgb_col)
	    scol="${colid}(A${col:0:1})"	#make RGB substring
	    if [[ ${col:0:3} == "BLA" ]]; then
		scol="${colid}(AD)"  #fiddle for black
	    fi
	    return
	fi
    fi
    if [[ $col < 1 || $col -gt 64 ]]; then bad_col; exit; fi
    colnam=${C[$col]}
    scol="${colid}(A${colnam})"			#make HLS substring
    return
}
bad_col() {
 col_chart=0					#force colour map repaint
 get_col
 exit
}
no_col() {
 scol=""				#no colour = null substring
 exit
}
show_cols() {
  cat <<EOF
${esc}[2J${esc}[0;0H${esc}[0;24r				COLOR TABLE
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
EOF
  col_chart=1
  return
}


# Main

# set p1..4 similar to VMS DCL
declare -g p1="$1" p2="$2" p3="$3" p4="$4"

# col variable is always uppercase
declare -u col

if ! tty -s; then echo "Not a tty">&2; exit; fi

trap end exit
trap interrupt int

esc=$'\e'
ws() { echo "$@"; }
colours="BLACK BLUE RED GREEN MAGENTA CYAN YELLOW WHITE"
term=`getjpi termimal`
if ! getdvi $term tt_regis; then nosup; fi
OperatingLevel=63
case $(getdvi $term devtype) in
    62) vt_240
	;;
    63) vt_340
	;;
    *) echo "Device supports ReGIS, but is not a VT240 or VT340" >&2
       exit
       ;;
esac

nosup				# no support; comment out for V4.5 or earlier
exit


Original DCL script (COLORS.COM) for VAX/VMS
--------8<---------CUT HERE--------8<---------CUT HERE--------8<---------
From: 
https://community.hpe.com/t5/operating-system-openvms/colors-using-dcl/td-p/3780829

John Travell
John Travell Valued Contributor

‎05-04-2006 10:07 AM
Re: Colors using DCL
The attached procedure is ancient, dating from the early 80's, but may be of some use. It sets each of the 4 colours that could be used on VT240's and VT340's to any one of 64 values.
You may find some of the DCL and escape strings to be of some value, or maybe not...
275812.txt ‏7 KB



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


