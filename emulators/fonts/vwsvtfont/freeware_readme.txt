X11, GRAPHICS, VWS VT200 fonts for DECterm
!
The fonts from the VWS VT200 emlulator are reformatted
as DECterm compatable fonts.  These fonts are size compatable
with the VT200, which helps ReGIS and text line up, as well
as being highly readable.

FOR ALPHA:

  To install:

    @SYS$UPDATE:VMSINSTAL DXFONT_AXP_VWSVT0_PCF010 freeware_cd:[VWSVT]

  After installation, to use, copy the file:

     DECW$SYSTEM_DEFAULTS:DECW$TERMINAL_DEFAULT.VWS_TEMPLATE

  to 

     DECW$USER_DEFAULTS:DECW$TERMINAL_DEFAULT.DAT

  You will need to restart DECwindows to load the fonts after the
  installation (@SYS$MANAGER:DECW$STARTUP RESTART) or simply reboot.

FOR VAX:

   The same steps are needed:  Use the saveset DXFONT-VWSVT0000.A
   Follow the directions provided during the installation.

