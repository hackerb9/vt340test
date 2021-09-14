#!/bin/bash

# VT340 has enough graphics RAM for two 800x480 sixel screens.
# They are addressable on first and second page. 

# While the protocol allows drawing sixels on the other pages,
# the VT340 simply ignore those requests.

# Switch cursor to next page, draw some sixels, set page cursor
# coupling mode on so that the page flips, set PCCM off,

CSI=$'\e['

echo "Please wait."

# Displayed page won't flip when cursor goes to page
#echo ${CSI}'?64l'		# Page Cursor Coupling Mode off
echo ${CSI}'2 P'		# Page Position Absolute goto page 2

# Draw an image on second page.
cat cat.six

# Displayed page flips to where cursor is
echo ${CSI}'?64h'		# Page Cursor Coupling Mode: on

# Wait 5 seconds or until a key is hit
read -t5 -n1

echo ${CSI}'1 P'		# Page Position Absolute. Goto page 1

# Stop flipping page if cursor switches to another page.
#echo ${CSI}'?64l'		# Page Cursor Coupling Mode: off
