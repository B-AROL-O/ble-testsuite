#!/bin/bash
#
# Usage: try-connect.sh [options]
#
# Environment:
# - TARGET_BDADDR: Address of the BLE peripheral to connect to

set -e

# NiclaSenseME with TestBattery.ino
[ -z "$TARGET_BDADDR" ] && TARGET_BDADDR=A9:81:60:4C:7C:9B
# CHARACTERISTIC to test
[ -z "$TARGET_CHARACTERISTIC" ] && TARGET_CHARACTERISTIC=6e400002-b5a3-f393-e0a9-e50e24dcca9e

fail() {
  echo "ERROR: $*"
  exit 1
}

# Sanity checks
which bluetoothctl >/dev/null || fail "Please install bluez"
which expect       >/dev/null || fail "Please install expect"
which lsb_release  >/dev/null || fail "Please install lsb-release"

echo "=== TEST_CONFIG_BEGIN ==="
echo "{"
echo "  hostname: \"$(hostname)\","
echo "  date: \"$(date)\","
echo "  in_container: \"$([ -e /.dockerenv ] && echo true || echo false)\","
echo "  uname_r: \"$(uname -r)\","
echo "  uname_m: \"$(uname -m)\","
echo "  lsb_release_is: \"$(lsb_release -is)\","
echo "  lsb_release_rs: \"$(lsb_release -rs)\","
echo "  bluez_version: \"$(dpkg -l bluez | awk '/bluez/ {print $3}')\","
hciconfig hci0 version
echo "  TARGET_BDADDR: \"$TARGET_BDADDR\""
echo "}"
echo "=== TEST_CONFIG_END ==="
echo ""

# set -x

# Check installed Bluetooth interfaces
hciconfig -a

echo ""
echo "DEBUG: Try connecting to $TARGET_BDADDR"
echo "DEBUG: Try to read characteristic $TARGET_CHARACTERISTIC"
echo ""

# bluetoothctl -- devices

tmpfile=/tmp/expect$$
cat <<END >$tmpfile
#!/usr/bin/expect -f
set device "$TARGET_BDADDR"
set characteristic "$TARGET_CHARACTERISTIC"
# set controller "F0:2F:74:63:3A:12"
set timeout 5
set ret 0

spawn bluetoothctl

if {\$ret == 0} {
  expect {
    "Agent registered" {
        send_user "\nDEBUG: Agent registered\n" 
    }
    "#" {
        # send_user "\nDEBUG: Got first prompt\n" 
    }
    timeout {
        send_user "\nERROR: TIMEOUT (first prompt)\n"
        set ret 15
    }
  }
}

# Flush input
# See https://stackoverflow.com/questions/1877015/how-can-i-flush-the-input-buffer-in-an-expect-script
expect -re $


expect -re $
if {\$ret == 0} {
  send -- "list\r"
  expect {
    "#" {
        # send_user "\nDEBUG: Got prompt (list)\n" 
    }
    timeout {
        send_user "\nERROR: TIMEOUT (list)\n"
        set ret 19
    }
  }
}

# send -- "select \$controller\r"

# send -- "remove \$device\r"
# expect "Device \$device"

expect -re $
if {\$ret == 0} {
  send -- "scan on\r"
  expect {
    "Discovery started" {
        # send_user "\nDEBUG: Discovery started\n"
        exp_continue
    }
    "Device \$device" {
        send_user "\nDEBUG: Found device: \$device\n"
    }
    "#" {
        # send_user "\nDEBUG: Got prompt (scan on)\n"
        exp_continue
    }
    timeout {
        send_user "\nERROR: TIMEOUT (scan on)\n"
        set ret 29
    }
  }
}

# send -- "pair \$device\r"
# expect "Pairing successful"

expect -re $
if {\$ret == 0} {
  send -- "connect \$device\r"
  expect {
    "Connection successful" {
        send_user "\nINFO: CONNECTION SUCCESSFUL\n"
    }
    "Device \$device not available" {
        send_user "\nERROR: DEVICE NOT AVAILABLE\n"
        set ret 42
    }
    "Failed to connect" {
        send_user "\nERROR: FAILED TO CONNECT\n"
        set ret 43
    }
    # "#" {
    #    send_user "\nDEBUG: Got prompt (connect)\n"
    #    exp_continue
    # }
    timeout {
        send_user "\nERROR: TIMEOUT WAITING FOR CONNECTION\n"
        set ret 44
    }
  }
  # send_user "\nDEBUG: After connect device: ret=\$ret\n"
}

expect -re $
if {\$ret == 0} {
  send -- "scan off\r"
  expect {
    "Discovery stopped" {
        # send_user "\nDEBUG: Discovery stopped\n"
    }
    "#" {
        # send_user "\nDEBUG: Got prompt (scan off)\n" 
        exp_continue
    }
    timeout {
        send_user "\nERROR: TIMEOUT (scan off)\n"
        set ret 29
    }
  }
}

expect -re $
if {\$ret == 0} {
  send -- "trust \$device\r"
  expect "trust succeeded"
  send -- "info \$device\r"
  # send_user "\nDEBUG: After info device: ret=\$ret\n" 
}

expect -re $
if {\$ret == 0} {
  send -- "menu gatt\r"
  expect "Menu gatt:"

  expect -re $
  send -- "list-attributes \$device\r"
  expect -re $

  # send_user "\nDEBUG: After list-attributes device: ret=\$ret\n" 
}

expect -re $
if {\$ret == 0} {

  send -- "select-attribute \$characteristic\r"
  expect -re $
  send_user "\nDEBUG: Attribute selected\n"
  send -- "notify on\r"
  expect {
    "Notify started" {
        send_user "\nDEBUG: Notify started\n"
    }
    timeout {
        send_user "\nERROR: TIMEOUT (notify on)\n"
        set ret 55
    }
  }
  expect -re $
  set timeout 20
  expect {
    "Connected: no" {
        send_user "\nERROR: DEVICE DISCONNECTED WHILE NOTIFYING\n"
        set ret 56
    }
    timeout {
        send_user "\nDEBUG: NOTIFY RUNNING WITHOUT ERROR (notify on)\n"
    }
  }
  set timeout 5
  
}

if {\$ret == 0} { 
    send -- "notify off\r"
    expect -re $

    send -- "back\r"
    expect {
        "Menu main:"
    }
}

if {\$ret == 0} {
  expect -re $
  send -- "info \$device\r"
  expect {
    "Connected: yes" {
        send_user "\nINFO: Still connected\n"
    }
    "Connected: no" {
        send_user "\nERROR: DEVICE DISCONNECTED\n"
        set ret 52
    }
    timeout {
        send_user "\nERROR: TIMEOUT\n"
        set ret 54
    }
  }
}

# TODO

# send_user "\nDEBUG: STOPPING HERE FOR NOW\n"
# set ret 99

send -- "disconnect \$device\r"

send -- "exit\r"
expect eof
exit \$ret
END

# set -x

set +e  # expect may fail
expect -f $tmpfile
retval=$?
if [ $retval -eq 0 ]; then
    printf "\n=== TEST: OK"
else
    printf "\n=== TEST: FAIL (error $retval)"
fi
exit $retval

# EOF