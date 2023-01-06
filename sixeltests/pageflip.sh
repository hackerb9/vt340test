#!/bin/bash

# VT340 has enough graphics RAM for two 800x480 sixel screens.
# They are addressable on first and second page. 

# While the protocol allows drawing sixels on the other pages,
# the VT340 simply ignore those requests.

# Switch cursor to next page, draw some sixels, set page cursor
# coupling mode on so that the page flips, set PCCM off,

CSI=$'\e['

clear
echo "This is page 1"
echo "Please wait."
tput home

# Displayed page won't flip when cursor goes to page
echo ${CSI}'?64l'		# Page Cursor Coupling Mode off
echo ${CSI}'2 P'		# Page Position Absolute goto page 2

# Draw an image on second page.
clear
echo "This is page 2"
cat cat.six

# Displayed page flips to where cursor is (page 2)
echo ${CSI}'?64h'		# Page Cursor Coupling Mode: on

tput home			# BUG: Why does page 1 scroll on sixel newlines

# Now, do the same trick to write to first page while second page is viewed.
# Displayed page won't flip when cursor goes to page
echo ${CSI}'?64l'		# Page Cursor Coupling Mode off
echo ${CSI}'1 P'		# Page Position Absolute goto page 1

cat cat.six
tput home

# Wait 5 seconds or until a key is hit
read -t5 -n1

# Show page 1 again
echo ${CSI}'?64h'		# Page Cursor Coupling Mode on


# Stop flipping page if cursor switches to another page.
#echo ${CSI}'?64l'		# Page Cursor Coupling Mode: off
