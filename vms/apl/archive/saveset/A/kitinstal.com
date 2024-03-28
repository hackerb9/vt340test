$ !                       K I T I N S T A L . C O M
$ !
$ !                           COPYRIGHT © 1990 BY
$ !                    DIGITAL EQUIPMENT CORPORATION, MAYNARD
$ !                     MASSACHUSETTS.  ALL RIGHTS RESERVED.
$ !
$ !  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND COPIED
$ !  ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE AND WITH THE INCLUSION
$ !  OF THE ABOVE COPYRIGHT NOTICE.  THIS SOFTWARE OR ANY OTHER COPIES
$ !  THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY OTHER
$ !  PERSON.  NO TITLE TO AND OWNERSHIP OF THE SOFTWARE IS HEREBY TRANSFERRED.
$ !
$ !  THE INFORMATION IN THIS SOFTWARE IS SUBJECT TO CHANGE WITHOUT NOTICE AND
$ !  SHOULD NOT BE CONSTRUED AS A COMMITMENT BY DIGITAL EQUIPMENT CORPORATION.
$ !
$ !  DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE OR RELIABILITY OF ITS
$ !  SOFTWARE ON EQUIPMENT THAT IS NOT SUPPLIED BY DIGITAL.
$ !
$ !***************************************************************************
$ !
$ !     This procedure installs VAX APL V3.2-834 on VMS using VMSINSTAL
$ !
$ VAXAPL$VERSION = %X00328341
$
$ !	NB:  The IVP looks for the )VERSION in the above line ("3.2-") within
$ !	     the first 40 lines of a copy of KITINSTAL.COM called
$ !	     APL$IVPKIT.COM.  If not found or if the version number of APL is
$ !	     less than the one on this line, the IVP fails.  The IVP signals
$ !	     SUCCESS by signaling the hex number in VAXAPL$VERSION so it must
$ !	     be changed too:  its format is <version number><minor version>
$ !	     <edit number><1>.
$ !
$ !	Save Set Distribution of files:
$ !
$ !		Save Set A
$ !		----------
$ !		KITINSTAL.COM
$ !		APL032.RELEASE_NOTES
$ !
$ !		Save Set B
$ !		----------
$ !		APLEXE.TLB reduced library containing:
$ !			APL.EXE
$ !			QAPL.EXE
$ !			APLMSG.EXE
$ !			APLTAP.EXE
$ !
$ !		APLTXT.TLB reduced library containing:
$ !			APL.CLD
$ !			APL.HLP_1		(copied as APL.HLP)
$ !			APL$VT220_FONT.FNT	(copied as APL$VT240_FONT.FNT)
$ !			APL$VT240_FONT_132.FNT
$ !			APL$VT320_FONT.FNT
$ !			APL$VT320_FONT_132.FNT
$ !			APL$VT330_FONT.FNT	(copied as APL$VT340_FONT.FNT)
$ !			APL$VT330_FONT_132.FNT	(copied as APL$VT340_FONT_132.FNT)
$ !			APLEXE.FDL
$ !			APLIMAGES.DAT
$ !			APLFILES.DAT
$ !			APL$STARTUP.COM		(to install APLSHR)
$ !			APLSYS.OBJ		(for building APLSHR)
$ !			APLDISP.OBJ		(for building APLSHR)
$ !			PCDRIVER.OBJ		(for building a v5.0 version)
$ !			PCLOADER.COM
$ !			REMOVE_VTA.AAS		(removes lost PCDRIVER terms)
$ !			SMG.AAS			(SMG$ map statements)
$ !			GKS.AAS			(GKS$ map statements)
$ !			UIS$LOAD_FONT_APL.COM 	(latent VAXstation support)
$ !			VAXAPL.HLP
$ !
$ !		APL$IVP.APL
$ !		DVWSVT0I03WK00GG001TKZZZZ02A000.VWS$FONT      (VS   80-col font)
$ !		DVWSVT0G03CK00GG001TKZZZZ02A000.VWS$FONT      (VS  132-col font)
$ !		DVWSVT0I03WK00GG001TKZZZZ02A000.VWS$VAFONT    (GPX  80-col font)
$ !		DVWSVT0G03CK00GG001TKZZZZ02A000.VWS$VAFONT    (GPX 132-col font)
$ !
$ !		Save Set C
$ !		----------
$ !		APLAUX.TLB reduced library containing:
$ !			METAFNC.AAS
$ !			QWDFMT.AAS
$ !			WSINCOM.AAS
$ !			WSOUTCOM.AAS
$ !
$ !		WSIN.APL
$ !		WSOUT.APL
$ !
$ !		Save Set D
$ !		----------
$ !			! DECwindows 75dpi fonts for DECterm
$ !		APL_TERMINAL14.DECW$FONT
$ !		APL_TERMINAL18.DECW$FONT
$ !		APL_TERMINAL28.DECW$FONT
$ !		APL_TERMINAL36.DECW$FONT
$ !		APL_TERMINAL_BOLD14.DECW$FONT
$ !		APL_TERMINAL_BOLD18.DECW$FONT
$ !		APL_TERMINAL_BOLD28.DECW$FONT
$ !		APL_TERMINAL_BOLD36.DECW$FONT
$ !		APL_TERMINAL_BOLD_DBLWIDE14.DECW$FONT
$ !		APL_TERMINAL_BOLD_DBLWIDE18.DECW$FONT
$ !		APL_TERMINAL_BOLD_NARROW14.DECW$FONT
$ !		APL_TERMINAL_BOLD_NARROW18.DECW$FONT
$ !		APL_TERMINAL_BOLD_NARROW28.DECW$FONT
$ !		APL_TERMINAL_BOLD_NARROW36.DECW$FONT
$ !		APL_TERMINAL_BOLD_WIDE14.DECW$FONT
$ !		APL_TERMINAL_BOLD_WIDE18.DECW$FONT
$ !		APL_TERMINAL_DBLWIDE14.DECW$FONT
$ !		APL_TERMINAL_DBLWIDE18.DECW$FONT
$ !		APL_TERMINAL_NARROW14.DECW$FONT
$ !		APL_TERMINAL_NARROW18.DECW$FONT
$ !		APL_TERMINAL_NARROW28.DECW$FONT
$ !		APL_TERMINAL_NARROW36.DECW$FONT
$ !		APL_TERMINAL_WIDE14.DECW$FONT
$ !		APL_TERMINAL_WIDE18.DECW$FONT
$ !		FONTFILES75.DAT
$ !
$ !		Save Set E
$ !		----------
$ !			! DECwindows 100dpi fonts for DECterm
$ !		APL_TERMINAL10.DECW$FONT
$ !		APL_TERMINAL14.DECW$FONT
$ !		APL_TERMINAL20.DECW$FONT
$ !		APL_TERMINAL28.DECW$FONT
$ !		APL_TERMINAL_BOLD10.DECW$FONT
$ !		APL_TERMINAL_BOLD14.DECW$FONT
$ !		APL_TERMINAL_BOLD20.DECW$FONT
$ !		APL_TERMINAL_BOLD28.DECW$FONT
$ !		APL_TERMINAL_BOLD_DBLWIDE10.DECW$FONT
$ !		APL_TERMINAL_BOLD_DBLWIDE14.DECW$FONT
$ !		APL_TERMINAL_BOLD_NARROW10.DECW$FONT
$ !		APL_TERMINAL_BOLD_NARROW14.DECW$FONT
$ !		APL_TERMINAL_BOLD_NARROW20.DECW$FONT
$ !		APL_TERMINAL_BOLD_NARROW28.DECW$FONT
$ !		APL_TERMINAL_BOLD_WIDE10.DECW$FONT
$ !		APL_TERMINAL_BOLD_WIDE14.DECW$FONT
$ !		APL_TERMINAL_DBLWIDE10.DECW$FONT
$ !		APL_TERMINAL_DBLWIDE14.DECW$FONT
$ !		APL_TERMINAL_NARROW10.DECW$FONT
$ !		APL_TERMINAL_NARROW14.DECW$FONT
$ !		APL_TERMINAL_NARROW20.DECW$FONT
$ !		APL_TERMINAL_NARROW28.DECW$FONT
$ !		APL_TERMINAL_WIDE10.DECW$FONT
$ !		APL_TERMINAL_WIDE14.DECW$FONT
$ !		FONTFILES100.DAT
$ !
$ !----------------------------------------------------------------------------
$ !
$ !     Setup error handling
$ !
$ ON CONTROL_Y THEN VMI$CALLBACK CONTROL_Y
$ ON WARNING THEN GOTO ERR_EXIT
$ !
$ !----------------------------------------------------------------------------
$ !
$ !     Handle INSTALL, IVP and unsupported parameters passed by VMSINSTAL
$ !
$ APL$VERIFY = F$VERIFY (P2)
$ IF P1 .EQS. "VMI$_INSTALL" THEN GOTO INSTALL
$ IF P1 .EQS. "VMI$_IVP"     THEN GOTO IVP
$ APL$VERIFY = F$VERIFY (APL$VERIFY)
$ EXIT VMI$_UNSUPPORTED
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Do installation of VAX APL
$ !
$ INSTALL:
$ !
$ !----------------------------------------------------------------------------
$ !
$ !     Check for valid VMS version
$ !
$ APL$VMSVER52 == 0
$ VMI$VERSION52 = "5.2"
$ VMI$CALLBACK CHECK_VMS_VERSION APL$VMSVER52 'VMI$VERSION52'
$ IF .NOT. APL$VMSVER52 THEN VMI$CALLBACK MESSAGE E BADVMS -
	"This kit requires Version 5.2 or a subsequent version of VMS"
$ IF .NOT. APL$VMSVER52 THEN EXIT VMI$_FAILURE
$ !
$ !----------------------------------------------------------------------------
$ !
$ ! 	Ask the user if the license is installed.
$ !
$ APL$LL == 0
$ VMI$CALLBACK CONFIRM_LICENSE APL$LL APL DEC 3.2 15-JAN-1990
$ IF .NOT. APL$LL THEN VMI$CALLBACK MESSAGE E NOAPLREG -
	"You must install the license before performing this installation"
$ IF .NOT. APL$LL THEN EXIT VMI$_FAILURE
$ !
$ !-----------------------------------------------------------------------------
$ !
$ !     Check for enough free blocks on system disk.
$ !     Need a minimum of 7000.
$ !
$ VMI$CALLBACK CHECK_NET_UTILIZATION APL$BLKS  7000
$ IF .NOT. APL$BLKS THEN VMI$CALLBACK MESSAGE E NOSPACE -
        "System disk does not contain enough free blocks to install APL"
$ IF .NOT. APL$BLKS THEN EXIT VMI$_FAILURE
$ !
$ !----------------------------------------------------------------------------
$ !
$ !     See if the user wants IVP executed after installation
$ !
$ TYPE SYS$INPUT

	This kit contains an Installation Verification Procedure (IVP)
	to verify the correct installation of the VAX APL interpreter.
	It can be run prior to the conclusion of this procedure by
	answering "YES" to the IVP prompt or invoked after the installation
	as follows:

	APL/TERM=TTY/SILENT SYS$COMMON:[SYSTEST.APL]APL$IVP

$ VMI$CALLBACK SET IVP ASK
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Here's where we ask what options the user wants.
$ !
$ !	As of VMS v4.4, VMSINSTAL will ask if you want to display and/or
$ !	print the Release Notes if invoked with OPTIONS N.  The Release
$ !	Notes are in saveset A as APL032.RELEASE_NOTES.
$ !
$ !
$ !----------------------------------------------------------------------------
$ !
$ ! Do check of Workstation Software
$ !
$ APL$VWS == "NO"
$ IF F$GETSYI("WINDOW_SYSTEM") .EQ. 2 THEN APL$VWS == "YES"
$ VMI$CALLBACK ASK APL$VWS "Do you want VMS Workstation Software (VWS) fonts"-
	'APL$VWS' B
$ IF .NOT. APL$VWS THEN GOTO END_VWS
$ VWS_CHECK:
$ VMI$CALLBACK CHECK_PRODUCT_VERSION APL$VWSVER -
	VMI$ROOT:[SYSEXE]UIS$VT200_PME.EXE V4.1 VWS
$ IF .NOT. APL$VWSVER THEN VMI$CALLBACK MESSAGE W BADVWS -
	"VAX APL requires VWS version 4.1 for VWS use."
$ IF APL$VWSVER THEN GOTO END_VWS
$ NO_VWS_CHECK:
$ TYPE SYS$INPUT

	For proper operation in VWS terminal emulators, VAX APL requires
	VWS version 4.1.  If VAX APL is used with earlier versions of VWS,
	you may experience anomalous behavior of the terminal emulator,
	POSSIBLY INCLUDING SYSTEM CRASHES.

$ END_VWS:
$ APL$DECW == "NO"
$ ! VMI$VERSION53 = "5.3"
$ ! VMI$CALLBACK CHECK_VMS_VERSION APL$VMSVER53 'VMI$VERSION53'
$ ! IF .NOT. APL$VMSVER53 THEN GOTO END_DECW
$ IF F$GETSYI("WINDOW_SYSTEM") .EQ. 1 THEN APL$DECW == "YES"
$ TYPE SYS$INPUT

	Under version 2.0 of DECwindows, this version of VAX APL can display
	the APL characters in the DECwindows terminal.  To do this, the APL
	fonts must be installed on the DECwindows server.

$ VMI$CALLBACK ASK APL$DECW "Do you want DECwindows fonts" 'APL$DECW' B
$ IF .NOT. APL$DECW THEN GOTO END_DECW
$ TYPE SYS$INPUT

	Along with the 75 dpi fonts, you can optionally install the 100 dpi
	fonts. 

$ VMI$CALLBACK ASK APL$DECW100 "Do you want 100 dpi video fonts installed" NO B
$ END_DECW:
$ TYPE SYS$INPUT

	This kit contains tools which read and write APL 
	workspaces in WSIS (Workspace Interchange Standard)
	format to allow the transportation of workspaces between
	VAX APL and other APL implementations. It is your option
	to place WSIS in your [SYSLIB] area.

$ VMI$CALLBACK ASK APL$WSIS "Do you want WSIS" YES B
$ TYPE SYS$INPUT

	This kit contains the annotated versions of the tools 
	which read and write APL workspaces in WSIS 
	(Workspace Interchange Standard) format.  It is your 
	option to place WSINCOM and WSOUTCOM in your [SYSLIB] 
	area.

$ VMI$CALLBACK ASK APL$WSCOM "Do you want WSINCOM and WSOUTCOM" NO B
$ TYPE SYS$INPUT

	This kit contains the APL meta-functions
	(Appendix C in the "VAX APL Language Reference Manual").  
	It is your option to place METAFNC in your [SYSLIB] area.

$ VMI$CALLBACK ASK APL$META "Do you want the APL meta-functions" NO B
$ !
$ !----------------------------------------------------------------------------
$ !
$ ! Let the user choose if old versions get purged
$ !
$ VMI$CALLBACK SET PURGE ASK
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Get the required files to unpack and restore in saveset B
$ !
$ VMI$CALLBACK RESTORE_SAVESET B
$ !
$ !	Unpack the text files in APLTXT.TLB
$ !
$ LIBRARIAN/TEXT/EXTRACT=APLCLD			/OUT=VMI$KWD:APL.CLD			VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLHLP1		/OUT=VMI$KWD:APL.HLP_1			VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLVT220080FNT		/OUT=VMI$KWD:APL$VT220_FONT.FNT		VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLVT240132FNT		/OUT=VMI$KWD:APL$VT240_FONT_132.FNT	VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLVT320080FNT		/OUT=VMI$KWD:APL$VT320_FONT.FNT		VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLVT320132FNT		/OUT=VMI$KWD:APL$VT320_FONT_132.FNT	VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLVT330080FNT		/OUT=VMI$KWD:APL$VT330_FONT.FNT		VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLVT330132FNT		/OUT=VMI$KWD:APL$VT330_FONT_132.FNT	VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLEXEFDL		/OUT=VMI$KWD:APLEXE.FDL			VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLIMAGESDAT		/OUT=VMI$KWD:APLIMAGES.DAT		VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLFILESDAT		/OUT=VMI$KWD:APLFILES.DAT		VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLSTARTUPCOM		/OUT=VMI$KWD:APL$STARTUP.COM		VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLSYSOBJ		/OUT=VMI$KWD:APLSYS.OBJ			VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=APLDISPOBJ		/OUT=VMI$KWD:APLDISP.OBJ		VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=PCDRIVEROBJ		/OUT=VMI$KWD:PCDRIVER.OBJ		VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=PCLOADERCOM		/OUT=VMI$KWD:PCLOADER.COM		VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=REMOVEVTAAAS		/OUT=VMI$KWD:REMOVE_VTA.AAS		VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=SMGAAS			/OUT=VMI$KWD:SMG.AAS			VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=GKSAAS			/OUT=VMI$KWD:GKS.AAS			VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=UISLOADFONTAPLCOM	/OUT=VMI$KWD:UIS$LOAD_FONT_APL.COM	VMI$KWD:APLTXT.TLB
$ LIBRARIAN/TEXT/EXTRACT=VAXAPLHLP		/OUT=VMI$KWD:VAXAPL.HLP			VMI$KWD:APLTXT.TLB
$ !
$ DELETE VMI$KWD:APLTXT.TLB;*
$ !
$ !	Unpack and reformat the .EXE files in APLEXE.TLB
$ !
$ LIBRARIAN/TEXT/EXTRACT=APLEXE			/OUT=VMI$KWD:APL.EXE			VMI$KWD:APLEXE.TLB
$ CONVERT/FDL=VMI$KWD:APLEXE.FDL	VMI$KWD:APL.EXE		VMI$KWD:APL.EXE
$ PURGE VMI$KWD:APL.EXE
$ !
$ LIBRARIAN/TEXT/EXTRACT=QAPLEXE		/OUT=VMI$KWD:QAPL.EXE			VMI$KWD:APLEXE.TLB
$ CONVERT/FDL=VMI$KWD:APLEXE.FDL	VMI$KWD:QAPL.EXE	VMI$KWD:QAPL.EXE
$ PURGE VMI$KWD:QAPL.EXE
$ !
$ LIBRARIAN/TEXT/EXTRACT=APLMSGEXE		/OUT=VMI$KWD:APLMSG.EXE			VMI$KWD:APLEXE.TLB
$ CONVERT/FDL=VMI$KWD:APLEXE.FDL	VMI$KWD:APLMSG.EXE	VMI$KWD:APLMSG.EXE
$ PURGE VMI$KWD:APLMSG.EXE
$ !
$ LIBRARIAN/TEXT/EXTRACT=APLTAPEXE		/OUT=VMI$KWD:APLTAP.EXE			VMI$KWD:APLEXE.TLB
$ CONVERT/FDL=VMI$KWD:APLEXE.FDL	VMI$KWD:APLTAP.EXE	VMI$KWD:APLTAP.EXE
$ PURGE VMI$KWD:APLTAP.EXE
$ !
$ DELETE VMI$KWD:APLEXE.TLB;*
$ !
$ !----------------------------------------------------------------------------
$ !
$ !     Add APL and qualifiers to DCL
$ !
$ VMI$CALLBACK PROVIDE_DCL_COMMAND APL.CLD
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Build the VAXAPL )HELP file
$ !
$ LIBRARY/HELP/CREATE=(KEYSIZE=48) VMI$KWD:VAXAPL.HLB VMI$KWD:VAXAPL.HLP
$ !
$ !	Create the DCL .HLP file by merging the command line syntax with
$ !	the release notes
$ !
$ RENAME VMI$KWD:APL.HLP_1 VMI$KWD:APL.HLP
$ ! APPEND VMI$KWD:APL032.RELEASE_NOTES VMI$KWD:APL.HLP
$ !
$ !     Now update the system help library
$ !
$ TYPE SYS$INPUT

	The APL help file will now be installed in the help library.
	If any user attempts to access online help during this time, the
	installation may fail.  If the procedure fails, you must restart
	the installation procedure.  You may want to notify any users not
	to access online help until this step of the procedure is completed.

$ HELP_AGAIN:
$ VMI$CALLBACK ASK APL$CNT "Type Y when you are ready to continue" "" B
$ IF .NOT. APL$CNT THEN GOTO HELP_AGAIN
$ !
$ VMI$CALLBACK PROVIDE_DCL_HELP APL.HLP
$ !
$ TYPE SYS$INPUT

	The APL help file has been successfully installed in the help
	library.  Users can now access online help without endangering this
	installation procedure.

$ !
$ !----------------------------------------------------------------------------
$ !
$ ! Tell the user to rest
$ !
$ TYPE SYS$INPUT

	No further questions will be asked.

$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Setup IVP files to move to the correct place
$ !
$ VMI$CALLBACK FIND_FILE APL$STATUS VMI$ROOT:[SYSTEST]APL.DIR "" S APL$IVPOK
$ IF APL$IVPOK .NES. "S" THEN $ VMI$CALLBACK CREATE_DIRECTORY SYSTEM SYSTEST.APL
$ COPY VMI$KWD:KITINSTAL.COM VMI$KWD:APL$IVPKIT.COM
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Terminal support files
$ !	
$ !	We have to link a new APLSHR.
$ !
$ LINK/PROTECT/NOSYSSHR/NODEBUG/NOMAP/NOTRACEBACK/SHARE=VMI$KWD:APLSHR.EXE -
	VMI$KWD:APLSYS.OBJ,SYS$INPUT/OPTIONS
   SYS$SYSTEM:SYS.STB/SELECTIVE
   CLUSTER=TRANSFER_VECTOR,,,VMI$KWD:APLDISP.OBJ
   GSMATCH=LEQUAL,1,1
$ !
$ !	We only copy in PCDRIVER if the image does not exist in
$ !	SYS$LOADABLE_IMAGES.  This is so we don't override any new
$ !	versions that may have been installed by DTM.  We will give them
$ !	PCLOADER.COM that initializes the terminal driver on system start-up.
$ !
$ VMI$CALLBACK FIND_FILE APL$PC VMI$ROOT:[SYS$LDR]PCDRIVER.EXE "" S APL$PCOK
$ IF APL$PCOK .EQS. "S" THEN GOTO END_PCDRIVER
$ !
$ !	Put PCDRIVER_V5.EXE in SYS$LOADABLE_IMAGES.
$ !
$ !	We need to link PCDRIVER.
$ !
$    TYPE SYS$INPUT

	Linking PCDRIVER.EXE -- Please ignore "no transfer vector" warning

$ !
$    ON WARNING THEN CONTINUE
$    LINK/NODEBUG/NOMAP/NOTRACEBACK/EXE=VMI$KWD:PCDRIVER.EXE -
	VMI$KWD:PCDRIVER.OBJ,SYS$INPUT/OPTIONS,SYS$SYSTEM:SYS.STB
      BASE=0
      IDENT="APL V3.2"
$    ON WARNING THEN GOTO ERR_EXIT
$    VMI$CALLBACK PROVIDE_IMAGE APL$STATUS PCDRIVER.EXE  VMI$ROOT:[SYS$LDR]
$ !
$ END_PCDRIVER:
$ !
$ !	The VT240 80 column font file is the same as the VT220
$ !
$ COPY VMI$KWD:APL$VT220_FONT.FNT VMI$KWD:APL$VT240_FONT.FNT
$ !
$ !	The VT340 fonts are the same as the VT330
$ !
$ COPY VMI$KWD:APL$VT330_FONT.FNT VMI$KWD:APL$VT340_FONT.FNT
$ COPY VMI$KWD:APL$VT330_FONT_132.FNT VMI$KWD:APL$VT340_FONT_132.FNT
$ !
$ !----------------------------------------------------------------------------
$ !
$ !     Now put everything in its place
$ !
$ !OPEN/WRITE APL$IMAGES VMI$KWD:APLIMAGES.DAT
$ !WRITE APL$IMAGES "    APL$STATUS APL.EXE                 VMI$ROOT:[SYSEXE]"
$ !WRITE APL$IMAGES "    APL$STATUS APLMSG.EXE              VMI$ROOT:[SYSMSG]"
$ !WRITE APL$IMAGES "    APL$STATUS QAPL.EXE                VMI$ROOT:[SYSEXE]"
$ !WRITE APL$IMAGES "    APL$STATUS APLSHR.EXE              VMI$ROOT:[SYSLIB]"
$ !CLOSE APL$IMAGES
$ !
$ VMI$CALLBACK PROVIDE_IMAGE "" APLIMAGES.DAT "" T
$ !
$ !OPEN/WRITE APL$FILES VMI$KWD:APLFILES.DAT
$ !WRITE APL$FILES "    APL$STATUS VAXAPL.HLB              VMI$ROOT:[SYSHLP]"
$ !WRITE APL$FILES "    APL$STATUS VAXAPL.HLP              VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL.CLD                 VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL.HLP                 VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL$IVP.APL             VMI$ROOT:[SYSTEST.APL]"
$ !WRITE APL$FILES "    APL$STATUS APL$IVPKIT.COM          VMI$ROOT:[SYSTEST.APL]"
$ !WRITE APL$FILES "    APL$STATUS SMG.AAS                 VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS GKS.AAS                 VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APLSYS.OBJ              VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APLDISP.OBJ             VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS PCDRIVER_V4.EXE         VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS PCDRIVER.OBJ            VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS PCLOADER.COM            VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS REMOVE_VTA.AAS          VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL$VT220_FONT.FNT      VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL$VT240_FONT.FNT      VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL$VT240_FONT_132.FNT  VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL$VT320_FONT.FNT      VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL$VT320_FONT_132.FNT  VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL$VT330_FONT.FNT      VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL$VT330_FONT_132.FNT  VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL$VT340_FONT.FNT      VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL$VT340_FONT_132.FNT  VMI$ROOT:[SYSLIB]"
$ !WRITE APL$FILES "    APL$STATUS APL$STARTUP.COM         VMI$ROOT:[SYS$STARTUP]"
$ !CLOSE APL$FILES
$ !
$ VMI$CALLBACK PROVIDE_FILE  "" APLFILES.DAT "" T
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	VWS VAXstation support
$ !
$ IF .NOT. APL$VWS THEN GOTO NO_VWS
$ VMI$CALLBACK FIND_FILE APL$SYSFONT VMI$ROOT:[000000]SYSFONT.DIR "" S APL$VWS_SF
$ APL$FONT_DST = "VMI$ROOT:[SYSLIB]"
$ IF APL$VWS_SF .EQS. "S" THEN APL$FONT_DST = "VMI$ROOT:[SYSFONT]"
$ VMI$CALLBACK PROVIDE_FILE APL$STATUS UIS$LOAD_FONT_APL.COM                      'APL$FONT_DST'
$ VMI$CALLBACK PROVIDE_FILE APL$STATUS DVWSVT0I03WK00GG001TKZZZZ02A000.VWS$FONT   'APL$FONT_DST'
$ VMI$CALLBACK PROVIDE_FILE APL$STATUS DVWSVT0G03CK00GG001TKZZZZ02A000.VWS$FONT   'APL$FONT_DST'
$ VMI$CALLBACK PROVIDE_FILE APL$STATUS DVWSVT0I03WK00GG001TKZZZZ02A000.VWS$VAFONT 'APL$FONT_DST'
$ VMI$CALLBACK PROVIDE_FILE APL$STATUS DVWSVT0G03CK00GG001TKZZZZ02A000.VWS$VAFONT 'APL$FONT_DST'
$ NO_VWS:
$ !
$ !	WSIS support (optional)
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Restore the rest of the savesets as we need them.
$ !
$ IF .NOT. (APL$WSIS .OR. APL$WSCOM .OR. APL$META) THEN GOTO 10D
$
$ VMI$CALLBACK RESTORE_SAVESET C
$
$ IF .NOT. APL$WSIS THEN GOTO 10B
$ VMI$CALLBACK PROVIDE_IMAGE APL$STATUS APLTAP.EXE VMI$ROOT:[SYSLIB]
$ VMI$CALLBACK PROVIDE_FILE  APL$STATUS WSIN.APL   VMI$ROOT:[SYSLIB]
$ VMI$CALLBACK PROVIDE_FILE  APL$STATUS WSOUT.APL  VMI$ROOT:[SYSLIB]
$10B:
$ !
$ IF .NOT. APL$WSCOM THEN GOTO 10C
$ !
$ !	Unpack the auxilliary files in APLAUX.TLB
$ !
$ LIBRARIAN/TEXT/EXTRACT=WSINCOMAAS  /OUT=VMI$KWD:WSINCOM.AAS  VMI$KWD:APLAUX.TLB
$ LIBRARIAN/TEXT/EXTRACT=WSOUTCOMAAS /OUT=VMI$KWD:WSOUTCOM.AAS VMI$KWD:APLAUX.TLB
$ VMI$CALLBACK PROVIDE_FILE  APL$STATUS WSOUTCOM.AAS VMI$ROOT:[SYSLIB]
$ VMI$CALLBACK PROVIDE_FILE  APL$STATUS WSINCOM.AAS  VMI$ROOT:[SYSLIB]
$ 
$10C:
$ !
$ !	METAFNC and QWDFMT files (optional)
$ !
$ IF .NOT. APL$META THEN GOTO 10D
$ !
$ !	Unpack the auxilliary files in APLAUX.TLB
$ !
$ LIBRARIAN/TEXT/EXTRACT=METAFNCAAS  /OUT=VMI$KWD:METAFNC.AAS  VMI$KWD:APLAUX.TLB
$ LIBRARIAN/TEXT/EXTRACT=QWDFMTAAS   /OUT=VMI$KWD:QWDFMT.AAS   VMI$KWD:APLAUX.TLB
$ VMI$CALLBACK PROVIDE_FILE  APL$STATUS METAFNC.AAS VMI$ROOT:[SYSLIB]
$ VMI$CALLBACK PROVIDE_FILE  APL$STATUS QWDFMT.AAS  VMI$ROOT:[SYSLIB]
$
$ DELETE VMI$KWD:APLAUX.TLB;*
$
$10D:
$ IF .NOT. APL$DECW THEN GOTO NO_DECW
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Restore the 75 dpi font saveset.
$ !
$ VMI$CALLBACK RESTORE_SAVESET D
$ SET COMMAND VMI$KWD:APL
$ VMI$CALLBACK MESSAGE I DWFUNP75 -
	"The 75 dpi DECwindows fonts will now be unpacked."
$ TYPE SYS$INPUT


$ DEFINE/USER APL VMI$KWD:APL.EXE
$ APL/NOHI/SILENT=ALL/TERMINAL=TTY VMI$KWD:DWFONTUNPK
'VMI$KWD:DWFONT75' FONTUNPACK 'VMI$KWD:'
0.RO.XQ')OFF'
$ DELETE VMI$KWD:DWFONT75.AIS;
$ VMI$CALLBACK PROVIDE_FILE  "" FONTFILES75.DAT "" T
$
$ IF .NOT. APL$DECW100 THEN GOTO NO_DECW
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Restore the 100 dpi font saveset.
$ !
$ VMI$CALLBACK RESTORE_SAVESET E
$ VMI$CALLBACK MESSAGE I DWFUNP100 -
	"The 100 dpi DECwindows fonts will now be unpacked."
$ TYPE SYS$INPUT


$ DEFINE/USER APL VMI$KWD:APL.EXE
$ APL/NOHI/SILENT=ALL/TERMINAL=TTY VMI$KWD:DWFONTUNPK
'VMI$KWD:DWFONT100' FONTUNPACK 'VMI$KWD:'
0.RO.XQ')OFF'
$ DELETE VMI$KWD:DWFONT100.AIS;
$ VMI$CALLBACK PROVIDE_FILE  "" FONTFILES100.DAT "" T
$
$ NO_DECW:
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Tell the user what will be left on disk
$ !
$ TYPE SYS$INPUT

    The following files will be left on disk:

	SYS$SYSTEM:APL.EXE			[new]
	SYS$MESSAGE:APLMSG.EXE			[new]
	SYS$HELP:HELPLIB.HLB			[modified]
	SYS$LIBRARY:DCLTABLES.EXE		[modified]
	SYS$SYSTEM:QAPL.EXE			[new]
	SYS$HELP:VAXAPL.HLB			[new]
	SYS$LIBRARY:VAXAPL.HLP			[new]
	SYS$LIBRARY:APL.CLD			[new]
	SYS$LIBRARY:APL.HLP			[new]
	SYS$HELP:APL032.RELEASE_NOTES		[new]
	SYS$LIBRARY:APL$VT220_FONT.FNT  	[new]
	SYS$LIBRARY:APL$VT240_FONT.FNT  	[new]
	SYS$LIBRARY:APL$VT240_FONT_132.FNT	[new]
	SYS$LIBRARY:APL$VT320_FONT.FNT  	[new]
	SYS$LIBRARY:APL$VT320_FONT_132.FNT	[new]
	SYS$LIBRARY:APL$VT330_FONT.FNT  	[new]
	SYS$LIBRARY:APL$VT330_FONT_132.FNT	[new]
	SYS$LIBRARY:APL$VT340_FONT.FNT  	[new]
	SYS$LIBRARY:APL$VT340_FONT_132.FNT	[new]
$ IF .NOT. APL$VWS THEN GOTO 11B
$ IF APL$VWS_SF .NES. "S" THEN GOTO 11A
$ TYPE SYS$INPUT
	SYS$FONT:UIS$LOAD_FONT_APL.COM          [new]
	SYS$FONT:DVWS*.VWS$*FONT		[new]
$       GOTO 11B
$ 11A:
$ TYPE SYS$INPUT
	SYS$LIBRARY:UIS$LOAD_FONT_APL.COM	[new]
	SYS$LIBRARY:DVWS*.VWS$*FONT		[new]
$ 11B:
$ IF .NOT. APL$DECW THEN GOTO 11C
$ TYPE SYS$INPUT
	SYS$COMMON:[SYSFONT.DECW.USER_75DPI]APL_TERMINAL*.DECW$FONT	[new]
$ IF .NOT. APL$DECW100 THEN GOTO 11C
$ TYPE SYS$INPUT
	SYS$COMMON:[SYSFONT.DECW.USER_100DPI]APL_TERMINAL*.DECW$FONT	[new]
$ 11C:
$ TYPE SYS$INPUT
	SYS$LIBRARY:APLSHR.EXE 			[new]
	SYS$LIBRARY:APLSYS.OBJ			[new]
	SYS$LIBRARY:APLDISP.OBJ	 		[new]
	SYS$LOADABLE_IMAGES:PCDRIVER.EXE	[copied if no previous version]
	SYS$LIBRARY:PCDRIVER.OBJ		[new]
	SYS$LIBRARY:PCLOADER.COM		[new]
	SYS$LIBRARY:SMG.AAS			[new]
	SYS$LIBRARY:GKS.AAS			[new]
	SYS$COMMON:[SYSTEST.APL]APL$IVP.APL	[new]
	SYS$COMMON:[SYSTEST.APL]APL$IVPKIT.COM	[new]
	SYS$STARTUP:APL$STARTUP.COM		[new]
$ IF .NOT. APL$WSIS THEN GOTO 11D
$ TYPE SYS$INPUT
	SYS$LIBRARY:APLTAP.EXE		    	[optional WSIS]
	SYS$LIBRARY:WSIN.APL		    	[optional WSIS]
	SYS$LIBRARY:WSOUT.APL		    	[optional WSIS]
$11D:
$ IF .NOT. APL$WSCOM THEN GOTO 11E
$ TYPE SYS$INPUT
	SYS$LIBRARY:WSINCOM.AAS		    	[optional annotated WSIS]
	SYS$LIBRARY:WSOUTCOM.AAS	    	[optional annotated WSIS]
$11E:
$ IF .NOT. APL$META THEN GOTO 11F
$ TYPE SYS$INPUT
	SYS$LIBRARY:METAFNC.AAS		    	[optional meta-functions]
	SYS$LIBRARY:QWDFMT.AAS		    	[optional meta-functions]
$11F:
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Set things up so the IVP will run correctly
$ !
$ VMI$CALLBACK SET STARTUP APL$STARTUP.COM
$ !
$ TYPE SYS$INPUT

*******************************************************************************

	If this installation is being done on a cluster, you must
	do @SYS$STARTUP:APL$STARTUP.COM on all other nodes.  In
	addition, be sure to have your system manager add
	@SYS$STARTUP:APL$STARTUP.COM to your system startup file.

	If you intend to use DECterm or the VT200, VT300, or HDS200
	series of terminals, you should also insure that 
	@SYS$LIBRARY:PCLOADER.COM is in your system startup file,

*******************************************************************************

$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Successful installation completed
$ !
$ APL$VERIFY = F$VERIFY (APL$VERIFY)
$ EXIT VMI$_SUCCESS
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Error Exit
$ !
$ ERR_EXIT:
$ !
$ S = $STATUS
$ !
$ TYPE SYS$INPUT

	VAX APL V3.2 Installation Procedure failed.

$ !
$ APL$VERIFY = F$VERIFY (APL$VERIFY)
$ EXIT S
$ !
$ !                 End of VAXAPL installation
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Run IVP procedure
$ !
$ IVP:
$ !
$ !  Set up error handling
$ !
$ ON CONTROL_Y THEN EXIT VMI$_FAILURE
$ ON WARNING THEN GOTO IVP_ERR_EXIT
$ APL$VERIFY = F$VERIFY (P2)
$ !
$ TYPE SYS$INPUT

	Beginning the VAX APL V3.2 Installation Verification Procedure.

$ !
$ !	NB:  PROVIDE_DCL_COMMAND added the APL command to this process's
$ !	     command tables so APL/TERM=TT/SILENT works.
$ !
$ APL/TERM=TT/SILENT VMI$ROOT:[SYSTEST.APL]APL$IVP
$ APL$STATUS = $STATUS
$ IF APL$STATUS .NE. VAXAPL$VERSION THEN GOTO IVP_ERR_EXIT
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	Successful IVP test
$ !
$ TYPE SYS$INPUT

	VAX APL V3.2 Installation Verification Procedure completed successfully.

$ !
$ APL$VERIFY = F$VERIFY (APL$VERIFY)
$ EXIT VMI$_SUCCESS
$ !
$ !----------------------------------------------------------------------------
$ !
$ !	IVP test failed
$ !
$ IVP_ERR_EXIT:
$ !
$ TYPE SYS$INPUT

	VAX APL V3.2 Installation Verification Procedure failed.

$ !
$ APL$VERIFY = F$VERIFY (APL$VERIFY)
$ EXIT APL$STATUS
$ !
$ !     End of VAXAPL IVP
$ !
$ !
$ !     End of VAX APL KITINSTAL.COM
$ !
