# For text on the screen that already has the reversed attribute,
# changing the color map betwen 1 and 2 more than once can be
# confusing. The VT340 remembers that old text has the "previous"
# color map applied, but it only remembers one previous map.
#
# For example, the following shows several lines with colormap 2
# followed by one line of colormap 1:

for m in 1 2 1 2 1 2 1 2 1; do
  echo -n $'\e['${m}'){';
  echo -n $'\e[7m' Reverse $'\e[m'; 
  echo $'\e[7;1m' Bright Reverse $'\e[m'
done
