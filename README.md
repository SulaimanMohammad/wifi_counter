# WiFi-Based People Estimation
This repository implements a method to estimate the number of people in a given area by detecting nearby phones using their WiFi signals. This approach leverages Tshark and a wireless USB adapter in monitoring mode connected to a Raspberry Pi.

## Features
- **Detect WiFi Signals:** Identifies and counts the number of phones by their WiFi signals.
- **Automated Setup:** Configures the necessary environment and dependencies.
- **Data Collection:** Gathers and processes WiFi signal data to estimate the number of people.

## Requirements
- Raspberry Pi
- Wireless USB Adapter capable of monitoring mode
- Internet connection for initial setup

## Installation and Setup
1. Clone this repository to your Raspberry Pi.
   ```bash
   git clone https://github.com/SulaimanMohammad/wifi_counter.git
   cd wifi_counter
   ```
2. Run the detect_wifi bash script to set up and start the detection process.
   ```bash
   ./detect_wifi.sh
   ```

## detect_wifi Script
This script automates the setup and execution of the WiFi-based people estimation process. Here’s what it does:

1. **Download OUI Table**: Downloads the OUI table containing MAC addresses of various hardware manufacturers.
2. **Filter Non-Phone MACs**: Extracts and saves MAC addresses of non-phone devices to Non_phones_macs.
3. **Install Tshark**: Checks if Tshark is installed and installs it if necessary.
4. **Configure Wireless Adapter**: Sets the wireless adapter to monitoring mode.
5. **Launch Tshark**: Starts Tshark to scan for WiFi beacons and probes.

## Data Collection Process
- **Monitoring**: Tshark scans for WiFi <u> beacons and probes <u> from devices searching for or connected to WiFi networks.
- **Channel Hopping**: The script changes channels to ensure all devices are detected.
- **Data Storage**: All collected information is saved in data.txt (Contains raw data collected from Tshark).
- **Data Filtering**: The script filters the data to save only unique MAC addresses in unique.txt.

## Note:
- Ensure your wireless adapter supports monitoring mode.
- The script requires root privileges to set the adapter in monitoring mode and to run Tshark.
