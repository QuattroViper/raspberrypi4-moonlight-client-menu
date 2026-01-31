#!/bin/bash
# Controller-native Moonlight menu for Pi OS Lite (no last host memory)
# Uses /dev/input/js0

# Hosts to select
HOSTS=("192.168.178.6" "192.168.178.142")
HOST_NAMES=("Yahne" "Marno")

# Map buttons (PS5 DualSense)
BTN_CROSS=1      # usually button 1
BTN_CIRCLE=2     # usually button 2

# Initialize selection
CURRENT_SELECTION=0

# Function to draw menu
draw_menu() {
    clear
    echo "=== Moonlight Menu ==="
    echo ""
    for i in "${!HOST_NAMES[@]}"; do
        if [ "$i" -eq "$CURRENT_SELECTION" ]; then
            echo " > ${HOST_NAMES[$i]}"
        else
            echo "   ${HOST_NAMES[$i]}"
        fi
    done
    echo ""
    echo "Press CROSS to select host"
    echo "Press CIRCLE to pair controller"
}

# Function to pair PS5 controller
pair_controller() {
    echo "Put your PS5 controller in pairing mode (PS + Create button)..."
    sleep 1
    BT_ADDR=$(bluetoothctl scan on & sleep 5; bluetoothctl scan off; bluetoothctl devices | grep -i "Wireless Controller" | awk '{print $2}' | head -n 1)
    if [ -n "$BT_ADDR" ]; then
        bluetoothctl pair $BT_ADDR
        bluetoothctl trust $BT_ADDR
        bluetoothctl connect $BT_ADDR
        echo "Controller paired! Press any key to continue..."
        read -n 1
    else
        echo "Controller not found. Try again. Press any key..."
        read -n 1
    fi
}

# Event loop
while true; do
    draw_menu
    echo ""
    echo "Waiting for controller input..."

    # Read js0 events
    while read -r -d '' ev; do
        BTN=$(od -An -N1 -tu1 <<<"$ev")
        if [ "$BTN" -eq "$BTN_CROSS" ]; then
            HOST=${HOSTS[$CURRENT_SELECTION]}
            echo "Streaming from $HOST..."
            moonlight stream -app Desktop -1080 -60fps -bitrate 20000 -codec h264 $HOST
            break  # return to menu after stream
        elif [ "$BTN" -eq "$BTN_CIRCLE" ]; then
            pair_controller
            break
        fi
    done < /dev/input/js0
done
