#!/bin/bash

# Hosts: add your PC IPs / names here
HOSTS=("Yahne" "Marno")
HOST_NAMES=("192.168.178.6" "192.168.178.142")

# Menu loop
while true; do
    CHOICE=$(whiptail --title "Moonlight Client" --menu "Select an option" 15 50 6 \
    "1" "Stream a host" \
    "2" "Pair PS5 controller" \
    "3" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1)
            # Select which host
            HOST_CHOICE=$(whiptail --title "Select Host" --menu "Choose a host to stream" 15 50 6 \
            "0" "${HOST_NAMES[0]}" \
            "1" "${HOST_NAMES[1]}" 3>&1 1>&2 2>&3)

            if [ $? -eq 0 ]; then
                HOST_INDEX=$HOST_CHOICE
                HOST=${HOSTS[$HOST_INDEX]}
                echo "Starting stream from $HOST..."
                moonlight stream -app Desktop -1080 -60fps -bitrate 20000 -codec h264 $HOST
            fi
            ;;
        2)
            # Pair PS5 controller
            echo "Put your PS5 controller in pairing mode now..."
            whiptail --title "PS5 Pairing" --msgbox "Press and hold the PS button + Create button on the controller until the light blinks." 10 50
            # Scan for devices
            BT_ADDR=$(bluetoothctl scan on & sleep 5; bluetoothctl scan off; bluetoothctl devices | grep -i "Wireless Controller" | awk '{print $2}' | head -n 1)
            if [ -n "$BT_ADDR" ]; then
                bluetoothctl pair $BT_ADDR
                bluetoothctl trust $BT_ADDR
                bluetoothctl connect $BT_ADDR
                whiptail --title "PS5 Controller" --msgbox "Controller paired!" 8 40
            else
                whiptail --title "PS5 Controller" --msgbox "Controller not found. Try again." 8 40
            fi
            ;;
        3)
            clear
            exit 0
            ;;
    esac
done
