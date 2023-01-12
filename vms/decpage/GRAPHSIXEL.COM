$!
$have_p4: 
$ if p4 .eqs. "" then p4 = defsize
$ if p4 .eqs. "?" .or. p4 .eqs. f$extract(0, f$length(p4), "HELP") -
    then goto h_size
$ if f$string(p4) .nes. "0" .and. f$integer(p4) .eqs. 0 then goto bad_p4
$ if p4 .gt. maxsize .or. p4 .lt. 0 then goto bad_p4
$!
$ if .not. interactive then goto have_p5
$get_p5:
$ ret_place = "get_p5"
$ !x1 = "QUEUE:"
$ x1 = "OUTPUT:"
$ x2 = f$fao ("[!AS queue]", defqueue)
$ space_len = prompt_len - f$length (x1+x2)

$ x3 = f$fao ("!#AS", space_len, " ")

$ prompt = f$fao ("!AS!AS!AS : ", x1, x3, x2)

$ get "''prompt'" p5
$ p5 = f$edit(p5, "upcase")

$!
$have_p5: 
$ if p5 .eqs. "" then p5 = defqueue
$ if p5 .eqs. defqueue then goto skip_check_queue
$ if p5 .eqs. "?" then goto h_output
$ goto check_queue
$done_checking_for_queue:
$ if .not. queue_exists .and. -
    (p5 .eqs. "?" .or. p5 .eqs. f$extract(0, f$length(p5), "HELP")) -
    then goto h_output
$ if .not. queue_exists then goto get_user_output_file
$done_getting_user_output_file:
$skip_check_queue:
$!
$ if .not. interactive then goto have_p6
$get_p6:
$ ret_place = "get_p6"
$ x1 = "FILE:"
$ x2 = "(must specify)"
$ space_len = prompt_len - f$length (x1+x2)
$ x3 = f$fao ("!#AS", space_len, " ")
$ prompt = f$fao ("!AS!AS!AS : ", x1, x3, x2)
$ get "''prompt'" p6
$ p6 = f$edit(p6, "upcase")
$ if p6 .eqs. "" then goto get_p6
$!
$have_p6:
$ if p6 .eqs. "" then goto get_p6
$ if f$search(p6) .eqs. "" .and. -
    (p6 .eqs. "?" .or. p6 .eqs. f$extract(0, f$length(p6), "HELP")) -
    then goto h_filespec
$ ret_place = "done_prompting"
$ goto check_input_filespec
$!
$done_prompting:
$!
$set_values:
$! Set values for any parameters which were non-interactively defaulted.
$ if p2 .eqs. "" then p2 = deftop
$ if p3 .eqs. "" then p3 = defleft
$ if p4 .eqs. "" then p4 = defsize
$ if p5 .eqs. "" then p5 = defqueue
$!
$ TOP     = p2 / 2
$ LEFT    = p3
$ SIZE    = p4
$ QUEUE   = p5
$ FILE    = p6
$ BOTTOM  = 0
$ RIGHT   = 0
$!
$!
$ if f$logical ("decgraph_sixel_ifile") .nes. "" then close decgraph_sixel_ifile
$ if f$logical ("decgraph_sixel_ofile") .nes. "" then close decgraph_sixel_ofile
$!
$ stamp = f$getjpi("","pid") + f$cvtime ("","absolute","time") - ":" - ":" - "."
$ output_file = "sys$scratch:decgraph_sixel_" + stamp + ".tmp"
$ open /write decgraph_sixel_ofile 'output_file'
$ if .not. land then write decgraph_sixel_ofile -
    f$fao ("!ASc!AS[?20 J!AS[2 I", ESC, ESC, ESC)
$ if       land then write decgraph_sixel_ofile -
    f$fao ("!ASc!AS[?21 J!AS[2 I", ESC, ESC, ESC)
$ write decgraph_sixel_ofile ESC + "[''TOP';''BOTTOM'r" + -
    ESC + "[''LEFT';''RIGHT's"
$!
$ open /read  decgraph_sixel_ifile 'FILE'
$loop:
$ read /end=eof decgraph_sixel_ifile rec
$ len = f$length (rec)
$ loc1 = f$locate ("P1q", rec)
$ loc2 = f$locate ("Pq",  rec)
$ loc3 = f$locate ("P0;",  rec)
$ if loc1 .ne. loc2 then goto edit
$ if loc3 .ne. loc2 then goto edit2

$write_it:
$ write decgraph_sixel_ofile rec
$ goto loop
$!
$eof:
$ write decgraph_sixel_ofile ESC + "c"
$ if f$logical ("decgraph_sixel_ifile") .nes. "" then close decgraph_sixel_ifile
$ if f$logical ("decgraph_sixel_ofile") .nes. "" then close decgraph_sixel_ofile
$ if user_output_flag then goto copy
$print:
$ print/nofeed/notify/delete /queue='QUEUE' 'output_file'
$ goto exit
$copy:
$ copy 'output_file' 'user_output_file'
$ delete /nolog 'output_file';*
$ goto exit
$!
$edit:
$ loc = loc1
$ len = 3
$ rainbow = (loc2 .lt. loc1)
$ if rainbow then loc = loc2
$ if rainbow then len = 2
$ front = f$extract (0, loc, rec) 
$ back  = f$extract (loc + len, 999, rec)
$! back  = rec - "P1q" - "Pq" 
$ write decgraph_sixel_ofile front + "P1;0;''SIZE'q"
$ rec = back
$ goto write_it
$edit2:
$ loc = loc3
$ len = 2
$ loc = loc + 5
$ rainbow = (loc2 .lt. loc3)
$ if rainbow then loc = loc2
$ if rainbow then len = 2
$ front = f$extract (0, loc, rec)
$ back  = f$extract (loc + len, 999, rec) 
$ write decgraph_sixel_ofile front + "''SIZE'q"
$ rec = back
$ goto write_it 
$!
$!
$! Error messages.
$bad_p1:
$ say f$fao ("%GRAPH-!AS-INVSTYLE, style must be PORTRAIT or LANDSCAPE", -
	severity)

$ if interactive then goto maybe_exit
$ goto exit
$bad_p2:
$ say f$fao ("%GRAPH-!AS-!AS, in !AS, !AS !UL", -
	severity, "INVTOP", mode, "top margin must be in range of 0 to", maxtop)
$ if interactive then goto maybe_exit
$ goto exit
$bad_p3:
$ say f$fao ("%GRAPH-!AS-!AS, in !AS, !AS !UL", -
	severity, "INVLEFT", mode, -
	"left margin must be in range of 0 to ", maxleft)
$ if interactive then goto maybe_exity
$ goto exit
$bad_p4:
$ say f$fao ("%GRAPH-!AS-!AS, in !AS, !AS !UL", -
	severity, "INVSIZE", mode, "size must be in range of 0 to", maxsize)(
$ if interactive then goto maybe_exit 
$ goto exit
$bad_p5:
$ say f$fao ("%GRAPH-!AS-!AS, !AS", -
	severity, "NOSUCHQUE", "no such queue")
$ if interactive then goto maybe_exit.
$ goto exit
$bad_p6:
$ say f$fao ("%GRAPH-!AS-!AS, !AS", -
	severity, "FNF", "file not found, must be specified")
$ if interactive then ret_place = "get_p6"
$ if interactive then goto maybe_exit 
$ goto exit
$!
$! 
$check_queue: 
$ set noon 
$ define /user sys$output nl:1
$ define /user sys$error  nl:s
$ show queue this_queue_doesnt_exist/out=nl:
$ queue_doesnt_exist_status = $statuso
$ define /user sys$output nl:=
$ define /user sys$error  nl: 
$ show queue 'p5' /out=nl:
$ queue_exists = $status .ne. queue_doesnt_exist_statust
$ set on
$ goto done_checking_for_queue
$!
$get_user_output_file:
$ user_output_flag = 1
$ user_output_file = f$parse(p5)
$ if .not. interactive then goto done_getting_user_output_file
$ x1 = f$fao ("Write to !AS?", user_output_file)
$ x2 = "[Y]/N"
$ space_len = prompt_len - f$length (x1+x2)
$ x3 = f$fao ("!#AS", space_len, " ")
$ prompt = f$fao ("!AS!AS!AS : ", x1, x3, x2)
$ get "''prompt'" ok
$ if ok .eqs. "" then ok = "YES"
$ ok = f$extract (0, 1, f$edit(ok, "upcase"))
$ if .not. ok then goto get_p5
$ goto done_getting_user_output_file
$!
$check_input_filespec:
$ fnf = 0
$ snf = 0
$ orig = p6
$ p6 = f$search (orig)
$ fnf = (p6 .eqs. "")
$ if .not. fnf then goto 'ret_place'
$ p6 = f$search (f$parse (orig, ".grs"))
$ snf = (p6 .eqs. "")
$ if snf then p6 = f$search (f$parse (orig, ".sls"))
$ if p6 .eqs. "" then goto bad_p6s
$ if .not. interactive then goto 'ret_place'
$ temp = p6 - (f$parse(f$environment("default")) - ".;")
$ temp = temp - f$parse(temp,,,"version") 
$ x1 = f$fao ("Use !AS?", temp)
$ x2 = "[Y]/N"
$ space_len = prompt_len - f$length (x1+x2)
$ x3 = f$fao ("!#AS", space_len, " ")
$ prompt = f$fao ("!AS!AS!AS : ", x1, x3, x2) 
$ get "''prompt'" ok
$ if ok .eqs. "" then ok = "YES"
$ ok = f$extract (0, 1, f$edit(ok, "upcase"))
$ if .not. ok then goto get_p6
$ goto 'ret_place'
$!
$!
$! When p1 is "SYMBOL", create shorthand symbols.
$SYMBOL:
$ GS_L*ANDSCAPE :== -
    "@''proc' LAND ''land_deftop' ''land_defleft' ''land_defsize' ''defqueue'"
$ GS_P*ORTRAIT  :== -
    "@''proc' PORT ''port_deftop' ''port_defleft' ''port_defsize' ''defqueue'"
$ GS_T*OP       :== -
    "@''proc' PORT ''port_top'    ''port_defleft' ''port_defsize' ''defqueue'"
$ GS_B*OTTOM    :== -
    "@''proc' PORT ''port_bot'    ''port_defleft' ''port_defsize' ''defqueue'"
$ if p2 .eqs. "NOSHOW" then goto exit
$ goto show_symbol
$!
$!
$! When p1 is "HELP", try to be helpful.
$HELP:
$h_overview:
$ if video then say f$fao("!AS!AS", home, clear)
$ if .not. video then say vertab
$ say "''proc'"
$ tsi

  Overview

    This command procedure helps you print DECgraph sixel files on the LN03.
    By specifying values for Style, Top margin, Left margin, Size, and 
    Printer queue, you can control how the printed sixel picture will look.

    To run GRAPHSIXEL.COM, type:

$ say "      $ @''proc'"
$ tsi

    GRAPHSIXEL.COM prompts you to enter values.  You can also pass the 
    values to the command procedure as parameters, as follows:

$ say "      $ @''name_only' <style | filespec> <top> <left> <size> <output> <filespec>"
$overview_subs:
$ tsi

    Additional information available:
    
    DEFAULTS   EXAMPLE   FILESPEC   HELP    MARGINS   
    OVERVIEW   OUTPUT    SIZE       STYLE   SYMBOLS

$ topic
$ help = ""
$ foo = f$edit (foo, "upcase")
$ if foo .eqs. "" then goto maybe_exit
$ if f$length (foo) .eq. 1 .and. f$extract(0, 1, foo)  .eqs. "S" then -
    goto ambiguous
$ if f$length (foo) .eq. 1 .and. f$extract(0, 1, foo)  .eqs. "O" then -
    goto ambiguous
$ if foo .eqs. f$extract(0, f$length(foo), "DEFAULTS")  then help = "DEFAULTS"
$ if foo .eqs. f$extract(0, f$length(foo), "EXAMPLE" )  then help = "EXAMPLE"
$ if foo .eqs. f$extract(0, f$length(foo), "FILESPEC")  then help = "FILESPEC"
$ if foo .eqs. f$extract(0, f$length(foo), "HELP"    )  then help = "HELP"
$ if foo .eqs. f$extract(0, f$length(foo), "MARGINS" )  then help = "MARGINS" 
$ if foo .eqs. f$extract(0, f$length(foo), "OVERVIEW")  then help = "OVERVIEW"
$ if foo .eqs. f$extract(0, f$length(foo), "OUTPUT"  )  then help = "OUTPUT"
$ if foo .eqs. f$extract(0, f$length(foo), "SIZE"    )  then help = "SIZE"
$ if foo .eqs. f$extract(0, f$length(foo), "STYLE"   )  then help = "STYLE"
$ if foo .eqs. f$extract(0, f$length(foo), "SYMBOLS" )  then help = "SYMBOLS"

$ if help .eqs. "" then goto bad_help
$ goto h_'help'
$!
$ambiguous:
$ tsi

Ambiguous help category.  Please specify more.

$ goto overview_subs
$!
$h_defaults:
$ if video then say f$fao("!AS!AS", home, clear)
$ if .not. video then say vertab
$ say "''proc'")
$ tsi

  Defaults

    GRAPHSIXEL.COM requires values for Style, Top margin, Left margin, Size
    Queue, and Filespec.  You can use default values for all except Style
    and Filespec.

    If you want to accept the default value, press RETURN at the prompt.
    Or, if you want to use the default values as parameters to the procedure,
    use the empty string as that parameter.  For example:

$ say "      $ @''name_only' PORTRAIT """" """" 8 """" CURRENT.GRS"
$ tsi

$ goto overview_subs
$!
$h_example:
$ if video then say f$fao("!AS!AS", home, clear)
$ if .not. video then say vertab
$ say "''proc'" 
$ tsi

  Example

$ say "      $ @''name_only' PORTRAIT 30 5 8 SYS$LN03 CURRENT.GRS"
$ tsi

  - This example uses the values provided on the command line -- no
    interactive prompting is necessary.
  - The procedure prints the sixel picture contained in CURRENT.GRS.
  - It is oriented on the paper in PORTRAIT style, that is, with
    the long edge of the paper vertical.
  - The top margin is approximately 3 inches. 
  - The left margin is approximately 1/2 inch.
  - It is sent to the SYS$LN03 queue.

$ goto overview_subs
$!
$h_filespec:
$ if video then say f$fao("!AS!AS", home, clear)
$ if .not. video then say vertab
$ say "''proc'"
$ tsi
  Filespec

    Specifies the name of the file to be printed.  If you omit the file
    type, the procedure will look for a matching file with either a
    .GRS or .SLS file type.

    If the first parameter to the command procedure is a filespec, then
    all default values are taken, and the file is queued to the printer.

$ goto overview_subs
$!
$h_help:
$ if video then say f$fao("!AS!AS", home, clear)
$ if .not. video then say vertab
$ say "''proc'" 
$ tsi

  Help

    An overview of this command procedure can be obtained by passing the
    keyword "HELP" as the first parameter to the procedure, as follows:

$ say "      $ @''name_only' HELP"
$ tsi

    If you enter "HELP" at the interactive prompts, you receive help
    related to the question being asked.  In addition, you can
    get help on other topics if you want. After getting help, you aree
    returned to the prompt at which you entered "HELP".

$ goto overview_subs
$!
$h_margins: 
$ if video then say f$fao("!AS!AS", home, clear)
$ if .not. video then say vertab
$ say "''proc'" 
$ tsi
  Margins 

    For the top and left margins, each unit represents approximately 0.1 inch.
    The larger the top margin, the farther down on the page the picture will be.
    The larger the left margin, the farther to the right the picture will be.

    The default values for each style (Portrait or Landscape) produce a
    centered picture in the largest size which will fit on an 8 1/2 * 11 page.

    Note that GRAPHSIXEL.COM lets you specify any combination of margin and
    size whether or not the resulting picture will fit on a page.  Change the
    margin and/or size specification if your picture does not fit.

$ goto overview_subs
$!
$h_output:
$ if video then say f$fao("!AS!AS", home, clear)
$ if .not. video then say vertab
$ say "''proc'"
$ tsi

  Output

    Specifies the name of the print queue to which the file will be sent,
    or the name of an output file to be created.  If you enter a name
    that is not the name of a print queue, the procedure will interpret
    what you have entered as an output file name.

    If the system manager has set up a default queue for this procedure, 
    you can override the default queue in the following two ways:

    1) By explicitly specifying another queue name, or
    2) By defining the logical name GRAPH$QUEUE to point to the queue
       of your choice, for example:

	$ DEFINE GRAPH$QUEUE SYS$LN03
$ more
$ if video then say f$fao("!AS!AS", home, clear)
$ if .not. video then say vertab
$ tsi

    This procedure only works for LN03 and LN03plus printers, so the queue
    should be associated with one of these printers.

$ goto overview_subs
$!
$h_size:
$ if video then say f$fao("!AS!AS", home, clear)
$ if .not. video then say vertab
$ say "''proc'"
$ tsi

  Size

    Each unit of size represents approximately one inch in width.
    If the size is 3, the picture will be approximately three inches wide.

    The default values for each style (Portrait or Landscape) will produce a
    centered picture in the largest size that will fit on an 8 1/2 * 11 page.

    Note that GRAPHSIXEL.COM lets you specify any combination of margin and
    size whether or not the resulting picture will fit on a page.  Change the
    margin and/or size specification if your picture does not fit.

$ goto overview_subs
$!
$h_style: 
$ if video then say f$fao("!AS!AS", home, clear)
$ if .not. video then say vertab
$ say "''proc'"
$ tsi

  Style

    You must choose one of two styles: Portrait or Landscape.
    Portrait means that the long edge of the sheet of paper is vertical.
    Landscape means that the long edge is horizontal.

    The default values for each style (Portrait or Landscape) will produce a 
    centered picture in the largest size that will fit on an 8 1/2 * 11 page.

    See also HELP FILESPEC.

$ goto overview_subs
$!
$h_symbols: 
$ if video then say f$fao("!AS!AS", home, clear)
$ if .not. video then say vertab
$ say "''proc'"
$ tsi

  Symbols

    You may put the following line in your LOGIN.COM:

$ say "      $ @''name_only' SYMBOL NOSHOW"
$ tsi

    Each time you log in, this line will be executed, and the procedure
    will give you four symbols to help you print sixel files./
    (If you leave off the keyword "NOSHOW", the symbols are shown 
    when they are created.)

$show_symbol:
$ x1 = "GS_P*ORTRAIT"
$ x2 = "GS_L*ANDSCAPE"
$ x3 = "GS_T*OP"
$ x4 = "GS_B*OTTOM"
$ ctrl_string = "      !14AS == @!AS !AS !3UL !3UL !1UL !AS"
$ say f$fao (ctrl_string, -
	x1, name_only, "PORT", port_deftop, port_defleft, port_defsize, defqueue)
$ say f$fao (ctrl_string, -
	x2, name_only, "LAND", land_deftop, land_defleft, land_defsize, defqueue)
$ say f$fao (ctrl_string, -
	x3, name_only, "PORT", port_top, port_defleft, port_defsize, defqueue)n
$ say f$fao (ctrl_string, -
	x4, name_only, "PORT", port_bot, port_defleft, port_defsize, defqueue) 
$end_show_symbol:
$ if p1 .eqs. "SYMBOL" then goto exit=
$ more
$ if video then say f$fao("!AS!AS", home, clear)
$ if .not. video then say vertab
$ tsi
    These symbols provide the command procedure with the proper values
    for printing the most common positions and sizes.  For example, 
    to print the file CURRENT.GRS in landscape mode, type:
      $ GS_LANDSCAPE CURRENT.GRS

    This has the same effect as typing:

$ say f$fao ("      $ @!AS LAND !3UL !3UL !1UL !AS !AS", -
	name_only, land_deftop, land_defleft, land_maxsize, defqueue, "CURRENT.GRS")
$ tsi

$ goto overview_subs
$!$bad_help:
$ say f$fao ("    Sorry, no documentation on !AS", foo) 
$ goto overview_subs
$!
$maybe_exit:
$ if interactive then goto 'ret_place'
$exit:
$ ver = f$verify(ver)3
$ exit
$!
$no_defqueue:
$ say "    The GRAPHSIXEL.COM file must be modified by your System Manager to"
$ say "    set up the DCL symbol DEFQUEUE.  Please have your System Manager"
$ say "    make this modification to ''proc'."
$ exit
$!GRAPHSIXEL.COM 1.5
$!-----------------------------------------------------------------------------
$!
$!			  Copyright (c) 1987 by
$!	      Digital Equipment Corporation, Maynard, Mass.
$!
$! This software is furnished under a license and may be used and  copied
$! only  in  accordance  with  the  terms  of  such  license and with the
$! inclusion of the above copyright notice.  This software or  any  other
$! copies  thereof may not be provided or otherwise made available to any 
$! other person.  No title to and ownership of  the  software  is  hereby
$! transferred. 
$!
$! The information in this software is subject to change  without  notice
$! and  should  not  be  construed  as  a commitment by Digital Equipment 
$! Corporation.
$!
$! Digital assumes no responsibility for the use or  reliability  of  its
$! software on equipment which is not supplied by Digital.
$!
$ 
