#!/bin/bash

# Heathkit H19 enters graphics mode upon Esc F, and exits on Esc G. 
# In graphics mode, the alphabet is transliterated to box drawing characters.

export LANG=en_US.UTF-8 

sed 'y/^-`abcdefghijklmnopqrstuvwxyz{|}~/●◥│─┼┐┘└┌±→▒▚↓▗▖▘▝▀▐◤┬┤┴├╳╱╲▔▁▏▕¶/'

