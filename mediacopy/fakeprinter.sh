#!/bin/bash

# Read from the host port the VT340's printer port is attached to and
# write all data out to files in the directory "spool".

trap 'exit' INT			# ^C to cancel script

# Remove empty files on exit
trap 'cd ..; find spool -size 0 -delete' EXIT

# First argument is serial port to use, or default to /dev/ttyUSB0
FAKEPRINTER=${1:-/dev/ttyUSB0}

stty -F $FAKEPRINTER 19200 \
     time 5 \
     hupcl \
     ignbrk \
     -brkint \
     -icrnl \
     -imaxbel \
     -opost \
     -onlcr \
     -isig \
     -icanon \
     -iexten \
     -echo \
     -echoe \
     -echok \
     -echoctl \
     -echoke

mkdir -p spool
cd spool

while sleep 0.1; do
    filename=$(date +%F_%T)
    # Use pipeview to show data as it flows in.
    # XXX bug: does not get EOF when printout finishes.
    pv --rate -A64  < $FAKEPRINTER  > $filename
    echo "Done with $filename..."
done
