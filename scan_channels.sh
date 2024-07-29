#!/bin/bash

# Variables
INTERFACE="wlan1"
PRIMARY_CHANNELS=(1 6 11)
SECONDARY_CHANNELS=(2 3 4 5 7 8 9 10)
PRIMARY_SCAN_TIME=$1
SECONDARY_SCAN_TIME=$(( PRIMARY_SCAN_TIME / 4 ))
RSSI_THRESHOLD=$2
FLAG_FILE="/tmp/disable_wifi"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILENAME="$SCRIPT_DIR/data.txt"
FILENAME_UNIQUE="$SCRIPT_DIR/unique.txt"

# Bring up WiFi interface
ifconfig $INTERFACE up
touch $FLAG_FILE

# Set monitor mode if not already set
if ! iw $INTERFACE info | grep -q "type monitor"; then
    ifconfig $INTERFACE down
    iw $INTERFACE set monitor none
    ifconfig $INTERFACE up
fi

# Remove old data files if they exist
rm -f "$FILENAME" "$FILENAME_UNIQUE"

# Create new empty data files
touch "$FILENAME"

# Function to scan a given channel
scan_channel() {
    local channel=$1
    local duration=$2
    iw dev $INTERFACE set channel $channel
    tshark -i $INTERFACE -a duration:$duration -T fields -e wlan.sa -e wlan.seq -e radiotap.dbm_antsignal 2>/dev/null | \
    awk -v threshold="$RSSI_THRESHOLD" '{
        if ($3 ~ /,/) {
        split($3, a, ",");
        avg = (a[1] + a[2]) / 2;
        if (avg > threshold)
            print $1, $2
        }
    }' >> "$FILENAME"
}

# Scan primary channels
for channel in "${PRIMARY_CHANNELS[@]}"; do
    scan_channel $channel $PRIMARY_SCAN_TIME
done

# Scan secondary channels
for channel in "${SECONDARY_CHANNELS[@]}"; do
    scan_channel $channel $SECONDARY_SCAN_TIME
done

# Process captured data
awk '{if (!seen[$1] || $2 > seen[$1]) seen[$1] = $2} END {for (mac in seen) print mac, seen[mac]}' "$FILENAME" > "$FILENAME_UNIQUE"

# Bring down WiFi interface
ifconfig $INTERFACE down
rm -f $FLAG_FILE

