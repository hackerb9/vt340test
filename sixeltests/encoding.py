#!/usr/bin/python

# Create a MarkDown table of the sixel data characters and what bits
# they represent.

# Characters span from ? (0x3F) to ~ (0x7E).
# Subtract 0x3F to get a six-bit number. Least significant bit is top pixel.


print ("| Character | Sixel                                | Binary |")
print ("|:---------:|:------------------------------------:|:------:|")

for x in range(ord('?'), ord('~')+1):
    b=bin((x+1) & 0b00111111)[2:].zfill(6)
    d=b
    d=d.replace('0', '\N{WHITE CIRCLE}')
    d=d.replace('1', '\N{BLACK CIRCLE}')
    d=reversed(d)
    special = '\\' if (chr(x) == '|' or chr(x) == '_'or chr(x) == '\\') else ''
    print("| **" + special + chr(x) + "**<br/><br/>(" + hex(x) + ")" + "  | " + ''.join([ c + "<br/>" for c in d ]) + ' | ' + ''.join(b) + ' |')

    
