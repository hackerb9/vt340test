#!/bin/bash

# Read from the host port the VT340's printer port is attached to and
# write all data out to files in the directory "spool".

trap 'exit' INT			# ^C to cancel script

FAKEPRINTER=/dev/ttyUSB0

mkdir -p spool
cd spool

while sleep 0.1; do
    filename=$(date +%F_%T)
    # Use pipeview to show data as it flows in.
    # XXX bug: does not get EOF when printout finishes.
    pv --rate -A64  < $FAKEPRINTER  > $filename
    echo "Done with $filename..."
done
