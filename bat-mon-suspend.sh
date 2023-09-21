#!/bin/bash

# Looks for changes in device battery status and suspends the system when
# the battery reaches a preconfigured treshold while discharging

# Author: 	Dmitriy Safiullin

# Configuration

# The battery treshold in percent
BATTERY_TRESHOLD=5
# The battery device
BATTERY_DEVICE="/org/freedesktop/UPower/devices/battery_BAT1"
# The command to suspend the system
SUSPEND_COMMAND="systemctl suspend"
# Suspend grace timer in seconds
SUSPEND_GRACE_PERIOD=60
# Notification icon
NOTIFICATION_ICON="/usr/share/icons/Adwaita/symbolic/status/battery-caution-symbolic.svg"

# Script

# State to check if the battery is still discharging
# and below treshold so the script can know if the
# suspend process has already finished running once
already_suspended=0

# Send notification and start the suspend timer unless suspend
# process has already started
function trigger_suspend {
    # Check if the machine has already been suspend due to low battery
    # and has been woken up. If so, do not suspend again.
    if [ $already_suspended -eq 0 ]; then
        notify-send -u critical -e -i $NOTIFICATION_ICON "Battery low" "Suspending in ${SUSPEND_GRACE_PERIOD} seconds"
        sleep $SUSPEND_GRACE_PERIOD
        # Check if the battery is still discharging
        battery_status=$(upower -i $BATTERY_DEVICE | grep -E "state|percentage")
        if [[ $battery_status == *"discharging"* ]]; then
            # Check if the battery percentage is still below the treshold
            battery_percentage=$(echo $battery_status | grep -Eo "[0-9]+%" | grep -Eo "[0-9]+")
            if [ $battery_percentage -le $BATTERY_TRESHOLD ]; then
                already_suspended=1
                $SUSPEND_COMMAND
            fi
        fi
    fi
}

# Monitor upower for changes in battery status
upower -m | while read -r line; do
    # Check if the device that has changed is the battery by checking if
    # the line contains the battery device name
    if [[ $line == *${BATTERY_DEVICE}* ]]; then
        # Get the current battery status
        battery_status=$(upower -i $BATTERY_DEVICE | grep -E "state|percentage")

        # Check if the battery is discharging
        if [[ $battery_status == *"discharging"* ]]; then
            # Get the battery percentage
            battery_percentage=$(echo $battery_status | grep -Eo "[0-9]+%" | grep -Eo "[0-9]+")
            # Check if the battery percentage is below the treshold
            if [ $battery_percentage -le $BATTERY_TRESHOLD ]; then
                # Trigger suspend procedure
                trigger_suspend
            fi
        else
            # Reset the suspend flag
            already_suspended=0
        fi
    fi
done
