$ 	SET NOVERIFY
$!
$!  1/20/89	SMD	Added landscape option
$!  MODIFIED ON 9/86 BY  -     J. STRICKLAND  MARTIN MARIETTA CORP.  
$!                                            KENNEDY SPACE CENTER, FLA.
$!
$! !! IMPORTANT !!  PLEASE READ DOCUMENTATION (.DOC) SUPPLIED FOR PROPER SETUP.
$!
$!	Command file to display pictures on VT125(maybe, we don't have any),
$!  VT240 and VT241 and vt330/340.  Then, run SIXEL.EXE which will retrieve a SIXEL 
$!  dump from the graphics terminal and put it in a file on the host 
$!  computer.This file may then be spooled off to a sixel graphics 
$!  printer (LN0_ SERIES ONLY).
$!  
$!	*******************************************************************
$!
$	SET NOON
$	ON CONTROL_Y THEN CONTINUE
$!
$!	--------------- Start things off. -------------------
$!
$	TEXTMODE[0,8]=27        !set to text mode
$	TEXTMODE[1,1]:="\"
$	GOFF := WRITE SYS$OUTPUT TEXTMODE
$!
$	GRAPHMODE[0,8]=27	!set to graphics mode
$	GRAPHMODE[1,3]:= "Plp"
$	GON := WRITE SYS$OUTPUT GRAPHMODE
$!
$	CLEAR_TEXT[0,8]=27
$	CLEAR_TEXT[1,3]:="[2J"
$!	
$	CLEAR_GRAPHICS:="''GRAPHMODE';S(E)[0,0]P[747,479]''TEXTMODE'"
$	CLEAR_SCREEN := WRITE SYS$OUTPUT CLEAR_TEXT,CLEAR_GRAPHICS
$! 
$   LOCK := "[2h"
$   UNLOCK := "[2l"
$!
$   LOCK_TERMINAL := WRITE SYS$OUTPUT LOCK
$   UNLOCK_TERMINAL := WRITE SYS$OUTPUT UNLOCK
$! ****************************************************************************
$   LOCK_TERMINAL
$	SET TERM/NOBROADCAST/NOECHO
$	IF P1 .NES. "" .AND. P1 .NES. "KEY" THEN $ASSIGN/NOLOG 'P1' FOR001
$	IF P1 .EQS. "KEY" .OR. P1 .EQS. "" THEN -
	$ ASSIGN/NOLOG TEMP.PIC FOR001
$!
$! Here is where the change needs to be made for the location of the executable.
$!
$ 	IF P2 .EQS. "LANDSCAPE" THEN GOTO Land
$	RUN mdraw:SIXEL.EXE
$ 	GOTO SETERM
$land:	RUN mdraw:SIXland.EXE
$!
$seterm:
$	SET TERM/ECHO/BROADCAST
$	CLEAR_SCREEN
$	GOFF
$   UNLOCK_TERMINAL
$	WRITE SYS$OUTPUT " **  Screen Dump Completed  **"
$	WRITE SYS$OUTPUT ""
$	DEASSIGN FOR001
$	IF P1 .EQS. "KEY" THEN GOTO ASK	
$	EXIT
$ASK:
$	INQUIRE/NOPUNC FILENAME "What would you like to call the screen file? " 
$	IF F$LOCATE(".",FILENAME) .EQ. F$LENGTH(FILENAME) THEN -
	$ RENAME TEMP.PIC  'FILENAME''.PIC
$	IF F$LOCATE(".",FILENAME) .NE. F$LENGTH(FILENAME) THEN -
	$ RENAME TEMP.PIC 'FILENAME'
$	EXIT
