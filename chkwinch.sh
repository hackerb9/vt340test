#!/bin/bash

# Double check that SIGWINCH gets sent when the terminal font changes size.

# NOTE: Some terminals fail to send SIGWINCH.

# Tested as working on:
#
#     XTerm X.Org 7.7.0(369)
#     XTerm X.Org 7.7.0(359)
#
# when XTerm is downloaded from
# https://invisible-island.net/datafiles/release/xterm.tar.gz
# and compiled without any configuration options.

# This is NOT true in Debian's XTerm(366). But why?

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
