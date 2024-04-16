# Source this -*- shell-script -*- to set up a VT340 for the modern age.

######################################################################
# Place this file in your PATH, for example /usr/local/bin/vt340,    #
# and source it from your login file. 				     #
######################################################################
# Example from hackerb9's .bash_profile:			     #
#								     #
# # If logging in from a serial console at a low speed, 	     #
# # presume it is my Digital Equipment Corporation VT340+.	     #
# if [[ $(tty) =~ /dev/tty(S|USB|ACM|E) ]]			     #
# then								     #
#     [[ $(stty) =~ speed(.*)baud ]]; BAUD=${BASH_REMATCH[1]}	     #
#     if [[ $BAUD -lt 38400 ]]; then				     #
# 	source vt340						     #
# 	eval `ssh-agent` && ssh-add				     #
#     fi       							     #
# fi								     #
######################################################################



# Set terminal type to for VT340 serial terminal
export TERM=vt340
# Output Latin-1, not UTF-8 chars
export LANG=$(locale -a 2>&- | egrep -s 8859.*15?$ | head -1)
[ "$LANG" ] || export LANG=C    # No Latin-1, so fallback to "C"

# Give a little warning if this system isn't configured yet.
if [ "$LANG" = "C" ]; then
    cat <<EOF

Note: Falling back to LANG=C as Latin-1 is not available on this system.
      Please uncomment en_US.iso88591 in /etc/locale.gen and run locale-gen.

EOF
fi


# Input characters are not UTF-8
stty -iutf8
# Turn on software flow control (^S/^Q)
stty ixon ixoff

# Turn on clocal if your cable does not provide DTR/Carrier Detect).
# You need it if open(2) on /dev/tty hangs. (E.g., mesg, less).
stty clocal

# Short prompt for MediaCopy screenshots
export PS1='\$ '

# Function to fix a common problem: unreadable text colors
resetpalette() {
    printf '\ePp
    S(
	M 0 	(H  0 L  0 S  0)
	M 1 	(H  0 L 49 S 59)
	M 2 	(H120 L 46 S 71)
	M 3 	(H240 L 49 S 59)
	M 4 	(H 60 L 49 S 59)
	M 5 	(H300 L 49 S 59)
	M 6 	(H180 L 49 S 59)
	M 7 	(H  0 L 46 S  0)
	M 8 	(H  0 L 26 S  0)
	M 9 	(H  0 L 46 S 28)
	M 10	(H120 L 42 S 38)
	M 11	(H240 L 46 S 28)
	M 12	(H 60 L 46 S 28)
	M 13	(H300 L 46 S 28)
	M 14	(H180 L 46 S 28)
	M 15	(H  0 L 79 S  0)
    )\e\\'
}

# Workarounds
export MANPAGER=more
export GCC_COLORS=""
alias nano="nano -Opx"
alias w3m="w3m -color=0"
alias git="git -c color.ui=never"
alias reset="reset; stty clocal"

if [ $SHLVL -gt 1 ]; then
  echo "Error, do not run this script."
  echo "It must be sourced, like so:"
  echo -ne "\n\t"
  if type $(basename $0)>/dev/null 2>&1
  then
    echo ". $(basename $0)"
  else
    echo "source $0"
  fi
  echo
  return 1
fi
