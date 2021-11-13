echo -e '\e[1){'                 # Select color map 1
echo -e '\e[7m COLOR 07 \e[m'    # This should use color 7 for the background
echo -e '\e[1;7m COLOR 15 \e[m'  # This should use color 15 for the background

sleep 1

echo -e '\e[2){'                 # Select color map 2
echo -e '\e[7m COLOR 08 \e[m'    # This should use color 8 for the background
echo -e '\e[1;7m COLOR 07 \e[m'  # This should use color 7 for the background

sleep 1

echo -e '\eP2$p7;2;100;0;0\e\\'  # Set color 7 to red
echo -e '\eP2$p8;2;0;100;0\e\\'  # Set color 8 to green
echo -e '\eP2$p15;2;0;0;100\e\\' # Set color 15 to blue
