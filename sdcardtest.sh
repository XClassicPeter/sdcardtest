#!/bin/bash

# Default Parameters
CHUNK_SIZE=${CHUNK_SIZE:-$((100*1024*1024))}  # 100MB in bytes
STEP_SIZE=${STEP_SIZE:-$((4*1024*1024*1024))}  # 4GB in bytes

# User Inputs
DEVICE=${1}
TEMP_FILE="/tmp/sdcard_test_data"
TEMP_OUTPUT="/tmp/cmp_output"

# Function to check if required parameters are provided
check_parameters() {
    if [[ -z "$DEVICE" ]]; then
        echo "Error: No device specified."
        echo "Usage: $0 <device>"
        echo "  <device>: Path to the device (e.g., /dev/sde1)"
        exit 1
    fi
}

# Function to handle Ctrl+C
ctrl_c() {
    echo "Test interrupted by user. Exiting..."
    rm -f "$TEMP_FILE" $TEMP_OUTPUT
    exit 2
}

# Set up the Ctrl+C trap and other exit traps
trap ctrl_c INT
trap 'rm -f "$TEMP_FILE" $TEMP_OUTPUT' EXIT

# Function to display card details
show_card_details() {
    echo "Card details for $DEVICE:"
    lsblk -o NAME,SIZE,VENDOR,MODEL | grep "$(basename $DEVICE)"
    blkid $DEVICE
    echo

    # Extract and display serial number and other unique identifiers
    SERIAL=$(udevadm info --query=all --name=$DEVICE | grep 'ID_SERIAL=' | cut -d '=' -f2)
    UUID=$(blkid -o value -s UUID $DEVICE)
    
    echo "Serial Number: $SERIAL"
    echo "UUID: $UUID"
    echo
}

confirm_overwrite() {
    echo "WARNING: This script will write to the device $DEVICE."
    echo "This operation may overwrite any existing data on the device."
    echo "Additionally, the script will create a temporary file named '$TEMP_FILE' and a log file '$TEMP_OUTPUT'."
    echo "If these files already exist, they will be overwritten. Please ensure you have backed up any important data before proceeding."
    echo "You can exit the script now and modify the paths for the test file and log file directly in the script if needed."
    read -p "Do you want to continue? (yes/no): " RESPONSE
    if [[ "$RESPONSE" != "yes" ]]; then
        echo "Operation cancelled by the user."
        exit 0
    fi
}

# Function to read reported capacity
get_reported_capacity() {
    echo $(lsblk -bno SIZE $DEVICE)
}

# Function to test the offset
test_offset() {
    local offset=$1
    echo "Testing at offset: $offset bytes ($(($offset / 1024 / 1024)) MB)"
    
    # Generate 100MB of random data
    dd if=/dev/urandom of="$TEMP_FILE" bs=1M count=100 iflag=fullblock 2>/dev/null

    # Write data to the device with progress reporting
    echo "Writing to device..."
    dd if="$TEMP_FILE" of=$DEVICE bs=1M seek=$(($offset / 1024 / 1024)) conv=notrunc oflag=direct status=progress 2>&1 || return 1
    
    # Synchronize to ensure data is written
    sync

    # Read back and compare with progress reporting
    echo "Reading back and comparing..."
    dd if=$DEVICE bs=1M count=100 skip=$(($offset / 1024 / 1024)) iflag=direct 2>/dev/null | \
    pv -s 100M | cmp -l "$TEMP_FILE" - > $TEMP_OUTPUT

    if [ -s $TEMP_OUTPUT ]; then
        echo "FAILED - Data mismatch detected"
        echo "First 5 mismatches:"
        head -n 5 $TEMP_OUTPUT | while read line; do
            byte_offset=$(echo $line | awk '{print $1}')
            expected=$(echo $line | awk '{print $2}')
            actual=$(echo $line | awk '{print $3}')
            echo "  Byte $byte_offset: Expected 0x${expected}, Got 0x${actual}"
        done
        return 1
    else
        echo "PASSED"
        return 0
    fi
}

# --- Main part ---

# Check parameters
check_parameters

# Check if the device exists
if [ ! -b "$DEVICE" ]; then
    echo "Error: Device $DEVICE does not exist or is not a block device."
    exit 1
fi

# Display card details
show_card_details

# Confirm overwrite
confirm_overwrite

# Get and display reported capacity
reported_capacity=$(get_reported_capacity)
echo "Reported capacity: $((reported_capacity / 1024 / 1024 / 1024)) GB"

# Test the SD card in steps
offset=0
while true; do
    if test_offset $offset; then
        offset=$((offset + STEP_SIZE))
    else
        echo "Last successful offset: $((offset - STEP_SIZE)) bytes ($((offset - STEP_SIZE)) / 1024 / 1024) MB"
        break
    fi
    if [ "$offset" -ge "$reported_capacity" ]; then
        echo "Reached the reported capacity of the device."
        break
    fi
done

echo "Estimated real size of the card: $offset bytes ($(($offset / 1024 / 1024)) MB)"
