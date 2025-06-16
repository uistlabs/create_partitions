#!/bin/bash

# Create identical partition layout using parted (for Debian installer)
# This creates empty partitions that the Debian installer can use

echo "Creating partition layout on all NVMe drives using parted..."

for drive in nvme0n1 nvme1n1 nvme2n1 nvme3n1; do
    echo "Processing /dev/$drive..."
    
    # Create GPT partition table (this wipes the drive)
    parted -s /dev/$drive mklabel gpt
    
    # Partition 1: 64MB EFI System
    parted -s /dev/$drive mkpart primary fat32 1MiB 65MiB
    parted -s /dev/$drive set 1 esp on
    parted -s /dev/$drive set 1 boot on
    
    # Partition 2: 1GB for /boot (Linux RAID)
    parted -s /dev/$drive mkpart primary ext4 65MiB 1089MiB
    parted -s /dev/$drive set 2 raid on
    
    # Partition 3: 10GB for root filesystem (Linux RAID) 
    parted -s /dev/$drive mkpart primary ext4 1089MiB 11337MiB
    parted -s /dev/$drive set 3 raid on
    
    # Partition 4: ~17.2GB for swap (Linux RAID)
    parted -s /dev/$drive mkpart primary linux-swap 11337MiB 28681MiB
    parted -s /dev/$drive set 4 raid on
    
    # Leave remaining space unpartitioned (~900GB)
    
    echo "Partition table created for /dev/$drive"
    parted /dev/$drive print
    echo "---"
done

echo "Partition creation complete!"
echo ""
echo "Refreshing partition tables..."
for drive in nvme0n1 nvme1n1 nvme2n1 nvme3n1; do
    partprobe /dev/$drive
done
echo "Partition tables refreshed."
echo ""
echo "You can now continue with the Debian installer and select 'Manual partitioning'"
echo "Configure as follows:"
echo "  - nvmeXn1p1: EFI System Partition (keep as fat32)"
echo "  - nvmeXn1p2: Create RAID1 for /boot (ext4)"
echo "  - nvmeXn1p3: Create RAID1 + LUKS for root filesystem (ext4)"
echo "  - nvmeXn1p4: Create RAID1 + LUKS for swap"
echo ""
echo "The installer will guide you through setting up RAID and LUKS on these partitions."
