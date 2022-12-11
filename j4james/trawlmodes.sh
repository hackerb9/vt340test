
columnate() {
    # Neatly align ascii on pipe symbols, but only if writing to a file as
    # interactively we'll want to see output immediately.
    [ ! -t 1 ]  &&  column -t -s\| -o\|  ||  cat
}

../checkmode --trawl --output-markdown "$@"  |  columnate

