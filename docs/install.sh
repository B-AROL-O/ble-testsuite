#!/bin/bash

set -e
set +x

if ! command -v sudo > /dev/null 2>&1; then
    echo "ERROR: sudo is not installed on this system." >&2
    exit 1
fi

# Update OS
sudo apt-get update \
  && sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade \
  && sudo DEBIAN_FRONTEND=noninteractive apt-get -y autoremove --purge

# Install missing packages (if any)
which bluetoothctl || sudo apt-get -y install bluez
which expect       || sudo apt-get -y install expect
which lsb_release  || sudo apt-get -y install lsb-release
which lsof         || sudo apt-get -y install lsof
which lsusb        || sudo apt-get -y install usbutils

# Check OS and kernel version
uname -a
lsb_release -a

# Check BlueZ installed version
dpkg -l bluez

# Check installed Bluetooth interfaces
hciconfig -a

# EOF
