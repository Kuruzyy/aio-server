#!/bin/bash

# Define variables
POOL_NAME="mypool"
MOUNT_POINT="/mnt/pool"
DISK_UUIDS_FILE="disk_uuids.txt"

# Check if the disk UUIDs file exists
if [[ ! -f "$DISK_UUIDS_FILE" ]]; then
    echo "Disk UUIDs file not found: $DISK_UUIDS_FILE. Skipping ZFS pool creation."
    exit 0  # Exit gracefully if the file does not exist
fi

# Read disk UUIDs from the file into an array
mapfile -t DISK_UUIDS < "$DISK_UUIDS_FILE"

# Initialize an array to hold valid UUIDs
VALID_DISK_UUIDS=()

# Check each UUID for existence on this machine
for UUID in "${DISK_UUIDS[@]}"; do
    if lsblk --noheadings --output UUID | grep -q "$UUID"; then
        VALID_DISK_UUIDS+=("$UUID")
    else
        echo "Disk UUID $UUID does not exist on this machine. Skipping."
    fi
done

# Check if we have any valid disk UUIDs to work with
if [[ ${#VALID_DISK_UUIDS[@]} -eq 0 ]]; then
    echo "No valid disk UUIDs found. Skipping ZFS pool creation."
    exit 0  # Exit gracefully if there are no valid UUIDs
fi

# Create the ZFS pool using the valid disk UUIDs
echo "Creating ZFS pool '$POOL_NAME' with disks: ${VALID_DISK_UUIDS[*]}"
sudo zpool create -m "$MOUNT_POINT" "$POOL_NAME" "${VALID_DISK_UUIDS[@]}"

# Check if the pool was created successfully
if [[ $? -eq 0 ]]; then
    echo "ZFS pool '$POOL_NAME' created successfully and mounted at '$MOUNT_POINT'."
else
    echo "Failed to create ZFS pool."
    exit 1
fi