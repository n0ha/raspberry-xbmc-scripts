#!/bin/bash

# RPi backup script
#
# Backs up 2 important drives including partition tables:
# - /dev/mmcblk0: the SD card with /boot partition
# - /dev/sda: the USB stick with root partition
#
# The images are copied verbatim, including empty space.
# To save space, bare git repository is used to store the images.
#
# Commiting to git repo works like this
# working repo --> cloned from bare repo
#
# 1. images are copied to working repo, and commited
# 2. push origin master from working to bare
# 3. images are deleted from working
#
# Recommended to run every night.
# Sample cron set to 3AM:
# 0 3 * * * sudo /home/pi/s/backup-pi.sh

# directories
ROOT_DIR="/media/My Book/Backup/pi"

BARE_GIT_REPO="$ROOT_DIR/bare"
WORKING_GIT_REPO="$ROOT_DIR/working"

SD_SOURCE="/dev/mmcblk0"
USB_SOURCE="/dev/sda"
SD_FILENAME="sd-card.image"
USB_FILENAME="usb-stick.image"

LOG_FILE="$ROOT_DIR/backup.log"
touch "$LOG_FILE"

DATE=`date +%Y-%m-%d`
FULL_DATE=`date`

# redirect stdout and stderr, restore after script
exec 6>&1 # Link file descriptor #6 with stdout. Saves stdout
exec 7>&2 # Link file descriptor #7 with stderr. Saves stderr
exec > "$LOG_FILE" 2>&1

# starting backup
echo "============================="
echo "backup for: $DATE"
echo "current time: $FULL_DATE"
echo;

# create target dir
# TODO check if exists and exit
# TODO check if repo is clean and exit
TARGET_DIR="$WORKING_GIT_REPO/$DATE"
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
#sudo dd if="$SD_SOURCE" of="$TARGET_DIR/$SD_FILENAME"
echo "copying usb-stick image: $USB_SOURCE --> $TARGET_DIR/$USB_FILENAME"
#sudo dd if="$USB_SOURCE" of="$TARGET_DIR/$USB_FILENAME"

touch "$TARGET_DIR/$SD_FILENAME"
touch "$TARGET_DIR/$USB_FILENAME"

# add images to repo and commit
echo "commiting new images.."
cd "$WORKING_GIT_REPO"
git add "$DATE"
git commit -m "backup of SD-card and USB-stick images for $DATE"

# exit if error
if [ $# -eq 1 ]; then
	echo "git commit returned non-zero code. exiting.."
	exit
fi

# push commit to bare
echo "pushing to bare repo.."
git push origin master

# exit if error
if [ $# -eq 1 ]; then
	echo "git push returned non-zero code. exiting.."
	exit
fi

# deleting images from working
echo "deleting pushed images.."
rm -rf "$DATE"

# success!
echo "backup done successfuly! see u tomorrow."

# restore streams
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6
exec 2>&7 7>&-      # Restore stderr and close file descriptor #7