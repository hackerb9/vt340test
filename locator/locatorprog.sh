#!/bin/bash -ue

# DECLBD*: Programming VT340 Locator Button Definitions to return
# custom strings. This also allows for detecting button-up, not just
# down. This makes click and drag possible.

# Any of the four locator buttons can send a report containing six
# bytes when pressed or released. See the end of this file for a
# summary of the escape sequences.

# * Note: "DECLBD" is the term used in the VT340 documentation. 
#   Other docs refer to it as "DECLKD" (Locator Key Definition).

main() {
    # Add escape sequences for both key press and release for all 4 buttons.
    declbd 1 "${CSI}241~"  "${CSI}242~" \
           2 "${CSI}243~"  "${CSI}244~" \
           3 "${CSI}245~"  "${CSI}246~" \
           4 "${CSI}247~"  "${CSI}248~" 

    # Testing goes here.

    # Reset mouse to VT340 power on defaults
    declbd -r
}



CSI=$'\e['                      # Control Sequence Introducer
DCS=$'\eP'                      # Device Control String
ST=$'\e\\'                      # String Terminator


declare -A defaultbuttons=(
      [null]="${CSI}240~"
    [b1down]="${CSI}241~"
      [b1up]=""
    [b2down]="${CSI}243~"
      [b2up]=""
    [b3down]="${CSI}245~"
      [b3up]=""
    [b4down]="${CSI}247~"
      [b4up]=""
)

declare -A button puck mouse stylus 
declare -g Pc=1                 # By default, only change buttons mentioned 

button=( 
      [null]="Null-button report"
    [b1down]="First button pressed"
      [b1up]="First button released"
    [b2down]="Second button pressed"
      [b2up]="Second button released"
    [b3down]="Third button pressed"
      [b3up]="Third button released"
    [b4down]="Fourth button pressed"
      [b4up]="Fourth button released"
)


puck=(
    # Digitizer's puck has four buttons in a diamond pattern
    [b1down]="North button pressed"
      [b1up]="North button released"
    [b2down]="West button pressed"
      [b2up]="West button released"
    [b3down]="East button pressed"
      [b3up]="East button released"
    [b4down]="South button pressed"
      [b4up]="South button released"
)

mouse=(
    # The usual three-button mouse
    [b1down]="Left pressed"
      [b1up]="Left released"
    [b2down]="Middle pressed"
      [b2up]="Middle released"
    [b3down]="Right pressed"
      [b3up]="Right released"
)

stylus=(
    # Tablet's stylus has a button on the side and on the tip.
    # Note: the default button (b1) is the side button, not the tip.
    [b1down]="Barrel pressed"
      [b1up]="Barrel released"
    [b2down]="Tip pressed"
      [b2up]="Tip released"
)

# DCS Pc $ w Ky₁/Std₁/Stu₁ ; ... ; Ky(n)/Std(n)/Stu(n) ST
declbd() {
    # Redefine locator button keys to send alternate strings.
    # Usage: declbd [ <Key> <StringDown> <StringUp> ] ...
    #    or: declbd -r          or: declbd -c
    # Where Key in {1..4}. StringDown/Up are strings of up to six chars.
    # Use -r to reset the locator buttons to the VT340 power on defaults. 
    # Use -c to clear all keys so no string is returned on a click.

    # Note 1: StringDown and StringUp are strings of 8-bit chars.
    #         (Unlike the VT340's Std and Stu parameters which are hex.)
    #
    # Note 2: Each key can be defined independently, but strings for
    #         both down and up must be specified.

    # Example 1: Set mouse down to type "b1down" and up, "b1up":
    #           declbd  1  "b1down"  "b1up"
    #
    # Example 2: Send nothing for mouse down and hit Enter for up:
    #           declbd  1  ""  $'\n'
    # 

    local name OPTIND=1
    while getopts  "rc" name; do
        case $name in
            c)                  # Clear all key bindings
               Pc=0
               sendlbd
               ;;
            r)                  # Reset key bindings to default
               local -n d=defaultbuttons
               sendstring 1 "${d[b1down]}" "${d[b1up]}" \
                          2 "${d[b2down]}" "${d[b2up]}" \
                          3 "${d[b3down]}" "${d[b3up]}" \
                          4 "${d[b4down]}" "${d[b4up]}"
               ;;
            *) echo "declbd(): ignoring argument $OPTIND '$name'"
               ;;
        esac
    done
    shift $(( OPTIND -1 ))
    sendstring "$@"
}

sendlbd() {
    # Given triplets of KYₙ, STUₙ, and STDₙ,
    # program key KY to emit ST for up and down.
    # Note that the ST strings must be in hexadecimal!

    printf "%s" ${DCS} ${Pc} '$' w
    if (( $# )); then
        printf "%d/%s/%s;" "$@"
    fi
    printf ${ST}
    return
}


sendstring() {
    # Same as sendlbd except the strings are characters, not hex.
    # Note: Use sendlbd directly if you need to send a NULL character.
    local args=() arg
    while (( $# )); do
        args+=( $1  "$(char2hex "$2")"  "$(char2hex "$3")" )
        shift 3
    done
    sendlbd "${args[@]}"
}


char2hex() {
    # 8-bit characters to hexadecimal. (BUG: Cannot handle '\0'.)
    echo -n "$1" | LANG=C xxd -c0 -p
}


cleanup() {
    echo ${ST}

    # Bash 5.0.3 has a bug where 'read -n1 -t .01' sometimes says,
    # "read: error setting terminal attributes: Interrupted system call".
    # Sleeping briefly before running flushstdin works around it.
    sleep .1
    flushstdin

    exit
}
trap cleanup EXIT

flushstdin() {
    # flush stdin as otherwise the coordinate report may get run as commands.
    local REPLY
    while read -s -n1 -t .001; do :; done
}

main "$@"

######################################################################
# DECLBD Device Control String

# You use the following device control string to define the function
# of locator buttons.
#
#       DCS Pc $ w Ky1/Std1/Stul ; ... ; Kyn/Stdn/Stun ST
#
# where
#
#       DCS (0x90) introduces device control strings. DCS is a C1
#           control character that you can also express as ESC P
#           (0x1B, 0x50) when coding for a 7-bit environment.
#
#       Pc  is the clear parameter. Pc determines how the locator
#           buttons are cleared.
#
#               Pc              Meaning
#               ----------      ------------------------------------
#               0 or none       Clear all button definitions before
#                               loading new values (default).
#               1               Clear one button at a time, before
#                               loading a new value.

#       $ w (0x24, 0x77) are the intermediate and final characters that
#           identify this device control string as a DECLBD string.

#       Ky/Std/Stu ; ... are the button definition strings.
# 
#           Ky is the number of the button you are defining.

#                Ky     Button  Device
#                --     ------  ------------------------------
#                 1     Left    Puck, mouse, or stylus barrel
#                 2     Middle  Puck, mouse, or stylus tip
#                 3     Right   Puck or mouse
#                 4     Fourth  Puck only

#            /  (0x2F) is the slash character. This character separates
#               the button selector number, up button value, and down
#               button value in each button definition.

#           Std is the down string value. This value represents the
#               code the selected locator button sends when pressed.
#               The value is a string of hex pairs, each representing
#               one 8-bit character.

#               You can use hex values with characters in the
#               following ranges 0 – 9, A – F, and a – f.

#               When you combine these hex values, you can represent
#               any 8-bit code. You can use up to 6 characters (6 hex
#               pairs) for each Std value.

#          Stu is the up string value. This value represents the code
#              the selected locator button sends when released. You
#              code this value the same as Std above.

#           ;  (0x3B) is a separator character. This character
#              separates each button definition string.

#       ST (0x9C) is the string terminator and indicates the end of
#          the DCS. ST is a C1 control character that you can also
#          express as ESC \ (0x1B, 0x5C) when coding for a 7-bit
#          environment.

# NOTE: You can only use 6 characters per button transition
# (pressed or released).

######################################################################
# Questions:

# 1. Can one redefine the null-button report code? 
#    By default R(P(I)) in multimode returns "Esc [ 240 ~".
#    To test: Perhaps using key number zero will do the trick? 

# 2. How does one query the current button definitions?

# 3. Does button remapping differ between one-shot and multimode?

# 4. Is there any way to use a locator when in VT340 (not ReGIS or Tek mode)?

# 5. The VCS02 document says each locator identifies to the VT340 what
#    its type is at power-on (stylus, puck, mouse). What is the API
#    for reporting that to a program?

