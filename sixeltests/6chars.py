#!/usr/bin/python3

# Make a quick sixel cheatsheat for the character encoding.
# Characters span from ? (0x3F) to ~ (0x7E).
# Subtract 0x3F to get a six-bit number. Least significant bit is top pixel.

global bucket
bucket= {}

tr=''.maketrans('01','.@')
for c in range(ord('?'), ord('~')+1):
    b=bin((c+1) & 0b00111111)[2:].zfill(6)
    bucket[c] = b.translate(tr)

for c in range(ord('?'), ord('~')+1):
    print(chr(c), end='')
print()
    
for x in range(5, -1, -1):
    for c in range(ord('?'), ord('~')+1):
        print(bucket[c][x], end='')
    print()

    

    
