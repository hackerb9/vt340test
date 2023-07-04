#!/bin/bash

# This is in reference to https://github.com/hackerb9/vt340test/issues/32
# Multiple DSR Requests at the same time?

# @j4james notes that two can be performed in one request on the VT240.
# Is the same true for the VT340?

CSI=$'\e['

query() {
  if IFS="\e" read -a REPLY -t 2 -s -p "$1" -r -d "$2"
  then
    printf "%q" ${REPLY[0]}$2
  else
    printf "%q" ${REPLY[0]}
  fi
}

dsr() {
  query ${CSI}$1'n' $2
}

cls() {
  echo -n ${CSI}'H'${CSI}'J'
}


cls
echo "Please wait..."


# Testing individual reports
echo -n ${CSI}'11;22H'
os=$(dsr 5 'n')
cpr=$(dsr 6 'R')
xcpr=$(dsr '?6' 'R')
pp=$(dsr '?15' 'n')
udk=$(dsr '?25' 'n')
kbd=$(dsr '?26' 'n')
locstat=$(dsr '?55' 'n')
loctype=$(dsr '?56' 'n')

# Testing multiple reports at the same time
ansi_separate=$(query ${CSI}'5n'${CSI}'6n')
ansi_combined=$(query ${CSI}'5;6n')
ansi_repeats=$(query ${CSI}'5;5;5;5;5;5n')
dec_separate=$(query ${CSI}'?6n'${CSI}'?15n'${CSI}'?25n'${CSI}'?26n'${CSI}'?55n'${CSI}'?56n')
dec_combined=$(query ${CSI}'?6;15;25;26;55;56n')
dec_repeats=$(query ${CSI}'?15;15;15;15;15;15n')


cls
echo -e "Device Status Reports\n"
echo "DSR-OS:        $os"
echo "DSR-CPR:       $cpr"
echo "DSR-XCPR:      $xcpr"
echo "DSR-PP:        $pp"
echo "DSR-UDK:       $udk"
echo "DSR-KBD:       $kbd"
echo "DSR-LOCSTAT:   $locstat"
echo "DSR-LOCTYPE:   $loctype"

echo -e "\nMultiple Reports Together\n"
echo "ANSI Separate: $ansi_separate"
echo "ANSI Combined: $ansi_combined"
echo "ANSI Repeats:  $ansi_repeats"
echo "DEC Separate:  $dec_separate"
echo "DEC Combined:  $dec_combined"
echo "DEC Repeats:   $dec_repeats"

echo ""
