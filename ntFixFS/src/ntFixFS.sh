#!/usr/bin/env bash
NTFS_DRIVES=$(lsblk --list -o FSTYPE,PATH | awk '$1 == "ntfs" {print $2}') 
NDISKS=$(echo $NTFS_DRIVES|wc -l)
echo $NTFS_DRIVES | parallel --max-args=1 --jobs=$NDISKS ntfsfix 1>dev/null && echo $NTFS_DRIVES | parallel --max-args=1 --jobs=$NDISKS ntfsfix -d 1>/dev/null
echo done
