#!/bin/bash
# Reset VT340 after screen has been messed up by soft fonts.

printf '\eP1;1;2{ @\e\\'	# Clear any soft font that might shadow ASCII.
# (This works because the VT340 can only hold one soft font)

printf '\e(B'			# Assign ASCII to G0
printf '\x0F'			# Assign G0 to Graphic Left (Locking Shift 0)

printf '\e-A'			# Assign Latin-1 to G1
printf '\e~'			# Assign G1 to Graphic Right (Locking Shift 1)

# 94 char: 	B: Ascii	0: VT100 Gfx	>: Dec Tech
# 96 char:	A: Latin-1	<: User Pref	


#DCS=$'\eP'			# Begin Device Control String
#ST=$'\e\\'			# DCS String Terminator
#printf ${DCS}'1!uA'${ST}	# Assign Latin-1 to User Preferred GR
#printf '\e-<'			# Assign User Preferred to G1
#printf '\e~'			# Assign G1 to Graphic Right (Locking Shift 1)


cat <<'EOF'
     <--C0--> <---------GL---------->  <--C1--> <---------GR---------->
       00  01  02  03  04  05  06  07    08  09  10  11  12  13  14  15
     +---+---+---+---+---+---+---+---+ +---+---+---+---+---+---+---+---+
  00 |NUL DLE| SP  0   @   P   `   p | |    DCS|     °   À   Ð   à   ð |
  01 |SOH DC1| !   1   A   Q   a   q | |    PU1| ¡   ±   Á   Ñ   á   ñ |
  02 |STX DC2| "   2   B   R   b   r | |    PU2| ¢   ²   Â   Ò   â   ò |
  03 |ETX DC3| #   3   C   S   c   s | |    STS| £   ³   Ã   Ó   ã   ó |
  04 |EOT DC4| $   4   D   T   d   t | |IND CCH| ¤   ´   Ä   Ô   ä   ô |
  05 |ENQ NAK| %   5   E   U   e   u | |NEL MW | ¥   µ   Å   Õ   å   õ |
  06 |ACK SYN| &   6   F   V   f   v | |SSA SPA| ¦   ¶   Æ   Ö   æ   ö |
  07 |BEL ETB| '   7   G   W   g   w | |ESA EPA| §   ·   Ç   ×   ç   ÷ |
  08 |BS  CAN| (   8   H   X   h   x | |HTS    | ¨   ¸   È   Ø   è   ø |
  09 |HT  EM | )   9   I   Y   i   y | |HTJ    | ©   ¹   É   Ù   é   ù |
  10 |LF  SUB| *   :   J   Z   j   z | |VTS    | ª   º   Ê   Ú   ê   ú |
  11 |VT  ESC| +   ;   K   [   k   { | |PLD CSI| «   »   Ë   Û   ë   û |
  12 |LF  FS | ,   <   L   \   l   | | |PLU ST | ¬   ¼   Ì   Ü   ì   ü |
  13 |CR  GS | -   =   M   ]   m   } | |RI  OSC| ­   ½   Í   Ý   í   ý |
  14 |SO  RS | .   >   N   ^   n   ~ | |SS2 PM | ®   ¾   Î   Þ   î   þ |
  15 |SI  US | /   ?   O   _   o  DEL| |SS3 APC| ¯   ¿   Ï   ß   ï   ÿ |
     +---+---+---+---+---+---+---+---+ +---+---+---+---+---+---+---+---+
     <--C0--> <---------GL---------->  <--C1--> <---------GR---------->
EOF
