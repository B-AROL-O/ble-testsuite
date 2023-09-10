#!/bin/bash

set -xe

# Update OS
sudo apt-get update \
  && sudo apt-get -y dist-upgrade \
  && sudo apt-get -y autoremove --purge

# Install missing packages (if any)
which bluetoothctl || sudo apt-get -y install bluez
which curl         || sudo apt-get -y install curl
which expect       || sudo apt-get -y install expect
which lsb_release  || sudo apt-get -y install lsb-release
which lsof         || sudo apt-get -y install lsof
which lsusb        || sudo apt-get -y install usbutils
which tailscale    || (curl -fsSL https://tailscale.com/install.sh | sh)

# Check OS and kernel version
uname -a
lsb_release -a

# Check BlueZ installed version
dpkg -l bluez

# Check assigned IP addresses
hostname -i

# Check installed Bluetooth interfaces
hciconfig -a

# EOF