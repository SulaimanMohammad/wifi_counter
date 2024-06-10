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
