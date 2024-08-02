# Measure latency of Primary DA read.
# VT340+ is very slow printing attribute responses. A fifth of a second!
# Result: Use DSR5 instead which takes 0.02 seconds.

# Output from VT340+
#
# $ ./dalatency.sh 
# Measuring latency of ESC [ c
# Latency of    Device Attributes is  212,007,764 ns
#
# Measuring latency of ESC [ 6 n
# Latency of      Device Status 6 is   48,049,331 ns
#
# Measuring latency of ESC [ 5 n
# Latency of      Device Status 5 is   28,955,575 ns


echo "Measuring latency of ESC [ c"
declare -i latency=0
for i in {1..10}; do
    start=$(date +%s%N)
    # Send Device Attributes request and wait
    read -s -d "c" -p $'\e[c'
    end=$(date +%s%N)
    latency+=$((end-start))
done
latency=latency/10
printf "Latency of %20s is %'12d ns\n" "Device Attributes" $latency 

echo
echo "Measuring latency of ESC [ 6 n"
latency=0
for i in {1..10}; do
    start=$(date +%s%N)
    # Send Device Status Request 6 (cursor position) and wait
    read -s -d "R" -p $'\e[6n'
    end=$(date +%s%N)
    latency+=$((end-start))
done
latency=latency/10
printf "Latency of %20s is %'12d ns\n" "Device Status 6" $latency 

echo
echo "Measuring latency of ESC [ 5 n"
latency=0
for i in {1..10}; do
    start=$(date +%s%N)
    # Send Device Status Request 5 (howyadoin?) and wait
    read -s -d "n" -p $'\e[5n'
    end=$(date +%s%N)
    latency+=$((end-start))
done
latency=latency/10
printf "Latency of %20s is %'12d ns\n" "Device Status 5" $latency 
