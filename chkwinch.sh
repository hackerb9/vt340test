#!/bin/bash

# Double check that SIGWINCH gets sent when the terminal font changes size.
# (Changing the number of *pixels*, but not the number of rows or columns.)
#
# Note that the Linux kernel actually includes space in struct winsize
# for PIXELS as well as rows and columns, but they are labelled as "unused".
# However, that is not exactly true. The kernel skips sending SIGWINCH
# if the window has not changed size. But, "size" is not just the rows
# and columns. If the number of pixels change, SIGWINCH will be sent.

# Possible points of failure:
# * Some terminals may fail to send SIGWINCH when fontsize changes.
# * If connected to a remote host, telnet may eat the signal.
# * Telnetd and/or kernel may ignore TIOCSWINSZ if rows & cols did not change.

# Tested as working on:
#
#     XTerm X.Org 7.7.0(369)
#     XTerm X.Org 7.7.0(359)
#
# when XTerm is downloaded from
# https://invisible-island.net/datafiles/release/xterm.tar.gz
# and compiled without any configuration options.
#
# (Did not work in Debian's XTerm(366), but no clue why.)

# Test as working fine over ssh. 
#
# It does not work over telnet. (Because telnet does not send pixel size.)
# For more about telnet, please see the end of this file. 

timeout=.25

windowchange() {
    local IFS=";"		# temporarily split on semicolons

    # XTerm control sequence to query the sixel graphics geometry.
    if read -a REPLY -s -t ${timeout} -d "S" -p $'\e[?2;1;0S' >&2; then
	if [[ ${#REPLY[@]} -ge 4 && ${REPLY[2]} -gt 0 && ${REPLY[3]} -gt 0 ]]
	then
    	    w=${REPLY[2]}
    	    h=${REPLY[3]}
	else
    	    # dtterm WindowOps
	    if read -a REPLY -s -t ${timeout} -d "t" -p $'\e[14t' >&2;
	    then
		if [[ $? == 0  &&  ${#REPLY[@]} -ge 3 ]]; then
		    w=${REPLY[2]}
		    h=${REPLY[1]}
		fi
	    fi
	fi
    fi
    echo ${w} x ${h} pixels, $(tput lines) lines x $(tput cols) cols >&2
}

trap windowchange SIGWINCH

echo "Please change your font size now."
echo "If your terminal sends SIGWINCH, you'll see a report."
echo "Hit ^C to exit."
while :; do sleep .1; done


# Details on why Telnet is broken, but probably shouldn't be.
# 
# Telnet has a "NAWS" (Negotiate About Window Size) option which both
# the client and server must support for SIGWINCH to work.
#
# However, even when using netkit-telnet-ssl (which has NAWS support
# for both client and server), this script fails. The symptoms are
# odd. Turning on 'show option' shows that a new window size *is* sent
# every time the font size change. However, it is not getting turned
# into a WINCH signal. This is because the telnet protocol does not
# include the size of the window in pixels, so telnetd just uses a
# fake number when it calls the TIOCSWINSZ ioctl. Since the fake
# number is always the same, the Linux kernel thinks the terminal has
# not actually changed size and ignores the ioctl. 
#
# Note that the ssh protocol handles this correctly and sends both
# rows/columns and the pixel size.
#
# Future research: What would it take to get the telnet protocol to
# support pixels for the window size as is mentioned in ioctl_tty(2):

    # Get and set window size

    # Window sizes are kept in the kernel, but not used by the kernel (except
    # in the case of virtual consoles, where the kernel will update the  win‐
    # dow  size when the size of the virtual console changes, for example, by
    # loading a new font).

    # The following constants and structure are defined in <sys/ioctl.h>.

    # TIOCGWINSZ     struct winsize *argp
    #        Get window size.

    # TIOCSWINSZ     const struct winsize *argp
    #        Set window size.

    # The struct used by these ioctls is defined as

    #     struct winsize {
    #         unsigned short ws_row;
    #         unsigned short ws_col;
    #         unsigned short ws_xpixel;   /* unused */
    #         unsigned short ws_ypixel;   /* unused */
    #     };

    # When the window size changes, a SIGWINCH signal is sent  to  the  fore‐
    # ground process group.

# Telnet already has NAWS (Negotiate About Window Size) which sends
# the rows and columns. Ideally, we'd just tack on the extra pixel
# size to NAWS, and telnet daemons that can handle it would use the
# data and ones that cannot would (hopefully) ignore it.
#
# However, I suspect that will not be possible and it may be necessary
# to create a completely new option "GNAWS: Graphical Negotiate About
# Window Size" that would supercede NAWS.
#
# Whatever the solution is, it would need to send rows and columns and
# pixel size simultaneously so that the TIOCSWINSZ ioctl only gets
# called once.
