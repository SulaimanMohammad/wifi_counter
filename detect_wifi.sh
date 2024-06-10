#!/bin/bash

# Check if OUI_table.txt and Non_phones_macs.txt do not exist
if [ ! -f "OUI_table.txt" ] && [ ! -f "Non_phones_macs.txt" ]; then
    # Download the file and save it as OUI_table.txt
    wget "https://devtools360.com/en/macaddress/vendorMacs.xml?download=true" --output-document=OUI_table.txt > /dev/null 2>&1

    # Filter out specific manufacturers and extract MAC prefixes
    grep -vEi 'Motorola Mobility LLC, a Lenovo Company|GUANGDONG OPPO MOBILE TELECOMMUNICATIONS CORP.,LTD|Huawei Symantec Technologies Co.,Ltd.|Microsoft|HTC Corporation|Samsung Electronics Co.,Ltd|SAMSUNG ELECTRO-MECHANICS(THAILAND)|BlackBerry RTS|LG ELECTRONICS INC|Apple, Inc.|LG Electronics|OnePlus Tech (Shenzhen) Ltd|Xiaomi Communications Co Ltd|LG Electronics \(Mobile Communications\)' OUI_table.txt | sed -E 's/.*mac_prefix="([^"]*)".*/\1/' > Non_phones_macs.txt
fi

if ! command -v tshark &> /dev/null; then
    # Install tshark
    sudo apt-get update
    sudo apt-get install -y tshark

    # Configure tshark to run as non-root
    sudo dpkg-reconfigure wireshark-common
    sudo usermod -a -G wireshark ${USER:-root}
    newgrp wireshark
fi

# Check if wlan1 is in monitor mode
if ! iw wlan1 info | grep -q "type monitor"; then
    echo "Setting wlan1 to monitor mode..."
    sudo ifconfig wlan1 down
    sudo iw wlan1 set monitor none
    sudo ifconfig wlan1 up
fi

filename="data.txt"

# Check if the file exists
if [ -f "$filename" ]; then
    # File exists, delete it
    rm "$filename"
fi

# Create a new empty file
touch "$filename"

# Specify the channels to iterate over
channels=(1 6 11) # 1 ,6,11 are the ones used by smartphones 

# Loop through the channels
for channel in "${channels[@]}"; do
    echo "Switching to channel $channel..."
    #sudo iwconfig wlan1 channel $channel
    sudo iw dev wlan1 set channel $channel
    # Capture packets on the current channel and append to data.txt
    echo "Capturing packets on channel $channel..."
   tshark -i wlan1 -a duration:100 -T fields -e wlan.sa -e wlan.seq  >> data.txt
done

awk '{if (!seen[$1] || $2 > seen[$1]) seen[$1] = $2} END {for (mac in seen) print mac, seen[mac]}' data.txt > unique.txt
