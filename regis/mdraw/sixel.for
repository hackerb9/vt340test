C	
C	1/20/89	SMD	Modified ln03 (the escape commands) command at 
C			beginning of file save to work with MDRAW 
C	
C	REWRITE  MADE 9/26/86 BY JEFF STRICKLAND MARTIN MARIETTA CORP. 
C                                                KENNEDY SPACE CENTER, FLA.
C
C	VAX/VMS Fortran 77 is required to compile this program.
C	
C	This program will read a VT125(MAYBE) or VT240/VT241's graphic screen
C	and dump the information back to the computer into a file name
C	specified by the user.  The file will be in a SIXEL format 
C       that can then be spooled of to a LN03. There should not be a printer
C	hooked up, or the redirection may not work.
C	
C	Note :   After the startup of this program the keyboard is locked until
C             it is finished, due to the fact that any keyboard activity 
C             during the dump would corrupt the file.  It will take anywhere 
C             from 1 to 3 minutes depending on the load on your system.

	Implicit Integer *4 (A-Z)

	Include '($IODEF)'
	Include '($TTDEF)'

	Character*2     GOFF,GON,BUF
	Character*3     Device,move,prompt_erase
	Character*4     To_Computer,To_Printer,Hard_Copy
	Character*40    File_Name
	Character*5     portrait
        Character*4     escape
	Character*8     enlarge
	Integer*4       Terminal_Mode(2)
	Integer*2       CHANNEL,IOSB(4)

	Byte     Done(2),SIXEL(50000),WCHAR
	Byte     Carriage_Return,File_Byte(40),Delete
	
	DATA Device /'TT:'/
	DATA Done   /27,92/
	DATA GON    /'Pp'/
	DATA GOFF   /'\'/
	DATA ESC    /27/
	DATA Delete /127/
	DATA To_Computer /'[?2i'/
	DATA To_Printer  /'[?0i'/
	DATA Hard_Copy   /'S(H)'/
	DATA up		/'[1A'/
	DATA move	/'[2C'/
	DATA prompt_erase /'[1K'/

	Index = 0
	Carriage_Return = 13

C	************************************************************************

C	Get the terminal's channel number for the QIO.


	Call Sys$Assign (Device,Channel,,)

C	Re-direct I/O from printer port to the communications port.

	Write (*,100) ESC,To_Computer
100	Format ('+',A1,A4,$)
	
C	Enter ReGIS graphic mode on the terminal.

	Write (*,101) ESC,GON
101	Format ('+',A1,A2,$)

C	Get the terminal's current mode of operation.

	status = Sys$QIOW (,%VAL(Channel),  %VAL(IO$_SENSEMODE),
	1                 %REF(IOSB),,,%REF(Terminal_Mode(1)),%VAL(8),,,,)
	If (.not. status) Call SYS$EXIT(%VAL(status))

C	Set the Host Sync flag in the terminal Characteristics word.

	Terminal_Mode(2) = IOR (Terminal_Mode(2),TT$M_HOSTSYNC)

C	Temporarily set the terminal to host sync mode to eliminate
C	any overrun which may occur because of the lack of XON-XOFF.

	status = Sys$QIOW (,%VAL(Channel),%VAL(IO$_SETMODE),%REF(IOSB),,,
	1             %REF(Terminal_Mode(1)),%VAL(8),,,,)
	If (.not.status) Call SYS$EXIT(%VAL(status))

C       **********************************************************************
C       This is for erasing the dollar prompt which shows up after such 
C        operations as a directory. This can easily be adjusted by changing
C        the UP,MOVE,and the PROMPT_ERASE "$"  under the Data statements.
C	Do not use this if you DUMP within an application program.
C	Can also be used in conjunction with FMS to print the screen.

C       MOVE UP (1) AND OVER LEFT(2) AND ...
                  
C	Write (*,103) ESC,up,ESC,move
C 103	format ('+',A1,A3,A1,A3,$)

C       ...ERASE THE DOLLAR PROMPT.

C 	Write (*,7) ESC,PROMPT_ERASE
C 7	Format ('+',A1,A3,$)

C       ************************************************************************
C  >>>  There is no need to change the code from >>> to <<<.

C	Enter ReGIS graphic mode on the terminal.

111	Write (*,8) ESC,GON
 8	Format ('+',A1,A2,$)

C	Issue the SIXEL dump command to the terminal for hardcopy.

	Write (*,200) Hard_Copy
200	Format ('+',A4,$)


C	Get the initial data sent, synchronize on the first <ESC> \

	Do While (.NOT. (SIXEL(1).EQ.Done(1) .and. SIXEL(2).EQ.Done(2)))
	status = Sys$QIOW (,%VAL(Channel),%VAL(IO$_READVBLK+IO$M_NOECHO),
	1	           IOSB,  ,  ,  %REF(WChar),  %VAL(1), , , , )
	       If(.not. status) Call SYS$EXIT(%VAL(status))
	    SIXEL(1) = SIXEL(2)
	    SIXEL(2) = WChar
	End Do

C	Now get some real data (SIXEL bit map data and terminate on <ESC> \

	Index = 2

300	Status = Sys$QIOW (,%VAL(Channel),%VAL(IO$_READVBLK+IO$M_NOECHO),
	1                  IOSB,  ,  ,  %REF(WChar),  %VAL(1), , , , )
	       If(.not. status) Call SYS$EXIT(%VAL(status))
	  Index = Index + 1
	  SIXEL(Index) = WChar
	If (SIXEL(Index-1).EQ.Done(1) .and. SIXEL(Index).EQ.Done(2)) Goto 400
	Goto 300

C	Exit ReGIS graphics mode on the terminal.

400	Write (*,401) ESC,GOFF
401	Format ('+',A1,A2,$)

C	Reset hardcopy to the printer port.

	Write (*,402) ESC,To_Printer
402	Format ('+',A1,A4,$)

C  <<<  ***********************************************************************

C	Check if file name is a null and if so exit the program.

	If (Index.LE.1) Goto 900

C       Open the file for001.dat.The filename will be changed
C        by the accompaning comfile which calls this program.

	Open (Unit=1, Status='NEW', Access='Direct',
	1     Recordsize=20, FORM='Unformatted')

C      ************************************************************************
C      Write out the SIXEL data to the file.  Use a random access file.
C      Here is where I put the escape sequences to place the sixel
C      dump in portrait mode and enlarge it to fill the page. 
C      !! IMPORTANT !!    you must have extra RAM cartridge for the ln03.
C      If you do not, comment out the portrait and enlarge statements below.
C      Your print will then come out smaller than the actual size on the screen.

C	    File_Rec = 1
C        portrait = char(27)//char(91)//char(48)//char(32)//char(74)
C        Write (1'File_Rec) portrait

C	   File_Rec = File_Rec + 1
C       enlarge = char(155)//char(48)//char(59)//char(50)
C     + //char(59)//char(50)//char(113)//char(50)
C       Write (1'File_Rec) enlarge


C        Do loop for writing out the file.  I found the first 8 characters of 
C       the file are not necessary if the previous sequences are used. If they 
C	are NOT used, I suggest you then use the next statement to put the ln03
C       into the graphics mode. Do not change the DO statement.


        File_Rec = 1
        escape = char(27)//char(80)//char(49)//char(113)
        Write (1'File_Rec) escape
	   File_Rec = File_Rec + 1
       enlarge = char(144)//char(48)//char(59)//char(50)
     + //char(59)//char(50)//char(113)//char(50)
       Write (1'File_Rec) enlarge

C	Sixel(16) = char(50)

	Do 600 J = 17,index+3,80
	File_Rec=File_Rec+1
	IF (J .GE. INDEX+1) GOTO 900
600	Write (1'File_Rec) (SIXEL(I),I=J,J+79)


900	Call Exit                                            
	END
