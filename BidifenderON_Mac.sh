#!/bin/bash

# Check if the script is run with sudo
if [ $EUID -ne 0 ]; then
   echo "This script must be run as root"
   exit 1
fi

# Define the URL for the Bitdefender installer
installerurl="https://cloudgz.gravityzone.bitdefender.com/Packages/MAC/0/p-ldrw/setup_downloader.dmg"

# Define the local path for the installer
installerpath="/tmp/Bitdefender.dmg"

# Download the installer
curl -o $installerpath $installerurl

#Mount the DMG file
hdiutil attach $installerpath

MOUNT_POINT=$(ls /Volumes | grep -i "Endpoint")
if [ -z "$MOUNT_POINT" ]; then
  echo "Error: Unable to find mounted location containing 'Endpoint'."
  exit 1
fi
#run installer
open "/Volumes/$MOUNT_POINT/SetupDownloader.app"

while pgrep -x "SetupDownloader" > /dev/null; do
  sleep 5
done

#unmount the DMG file
hdiutil  detach "/Volumes/$MOUNT_POINT"

# Clean up the installer file
rm -f "/tmp/Bidifender.dmg"