#!/bin/bash

# RPi backup script
#
# Backs up 2 important drives including partition tables:
# - /dev/mmcblk0: the SD card with /boot partition
# - /dev/sda: the USB stick with root partition
#
# The images are copied verbatim, including empty space.
# To save space, bup git repository is used to store the images.
#
# 1. images are copied to working dir, and commited
# 2. bup is used to backup the files
# 3. images are deleted from working dir
#
# Recommended to run once a week.
# Sample cron set to 2AM every Sunday:
# 0 2 * * 0 backup-pi.sh

# directories
export BUP_DIR="/media/My Book/Backup/bup"
ROOT_DIR="/media/My Book/Backup/pi"
WORKING_DIR="$ROOT_DIR/working"

SD_SOURCE="/dev/mmcblk0"
USB_SOURCE="/dev/sda"
SD_FILENAME="sd-card.image"
USB_FILENAME="usb-stick.image"

LOG_FILE="$ROOT_DIR/backup.log"

DATE=`date +%Y-%m-%d`
FULL_DATE=`date`

# redirect stdout and stderr, restore after script
exec 6>&1 # Link file descriptor #6 with stdout. Saves stdout
exec 7>&2 # Link file descriptor #7 with stderr. Saves stderr
exec >> "$LOG_FILE" 2>&1

# starting backup
echo "============================="
echo "backup for: $DATE"
echo "current time: $FULL_DATE"
echo;

# create target dir
TARGET_DIR="$WORKING_DIR/$DATE"
echo "target directory is: $TARGET_DIR"

# check if target dir exists
if [ -d "$TARGET_DIR" ]; then
	echo "target directory ($TARGET_DIR) already exists. exiting.."
	exit
fi

echo "creating target dir: $TARGET_DIR"
mkdir -p "$TARGET_DIR"

# first, copy the images
echo "copying sd-card image: $SD_SOURCE --> $TARGET_DIR/$SD_FILENAME"
sudo dd if="$SD_SOURCE" of="$TARGET_DIR/$SD_FILENAME"
echo "copying usb-stick image: $USB_SOURCE --> $TARGET_DIR/$USB_FILENAME"
sudo dd if="$USB_SOURCE" of="$TARGET_DIR/$USB_FILENAME"

# add images to repo and commit
echo "commiting new images.."
bup index "$TARGET_DIR"
bup save -n pi-backup "$TARGET_DIR"
bup fsck -g

# exit if error
if [ $# -eq 1 ]; then
	echo "bup save returned non-zero code. exiting.."
	exit
fi

# deleting images from working
echo "deleting pushed images..$TARGET_DIR"
rm -rf "$TARGET_DIR"

# success!
echo "backup done successfuly! see u tomorrow."

# restore streams
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6
exec 2>&7 7>&-      # Restore stderr and close file descriptor #7
