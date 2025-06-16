#!/bin/bash

# Create identical partition layout on all 4 NVMe drives
# This creates empty partitions that the Debian installer can use

echo "Creating partition layout on all NVMe drives..."

for drive in nvme0n1 nvme1n1 nvme2n1 nvme3n1; do
    echo "Processing /dev/$drive..."
    
    # Clear any existing partition table
    sgdisk --zap-all /dev/$drive
    
    # Create GPT partition table
    sgdisk --clear /dev/$drive
    
    # Partition 1: 64MB EFI System
    sgdisk --new=1:0:+64M --typecode=1:EF00 --change-name=1:"EFI System" /dev/$drive
    
    # Partition 2: 1GB for /boot (Linux RAID)
    sgdisk --new=2:0:+1G --typecode=2:FD00 --change-name=2:"Linux RAID" /dev/$drive
    
    # Partition 3: 10GB for root filesystem (Linux RAID)
    sgdisk --new=3:0:+10G --typecode=3:FD00 --change-name=3:"Linux RAID" /dev/$drive
    
    # Partition 4: 17GB for swap (Linux RAID)
    sgdisk --new=4:0:+17G --typecode=4:FD00 --change-name=4:"Linux RAID" /dev/$drive
    
    # Leave partition 5 unallocated for future use (~900GB)
    
    # Set boot and esp flags on EFI partition
    sgdisk --attributes=1:set:2 /dev/$drive  # Set legacy BIOS bootable
    
    echo "Partition table created for /dev/$drive"
    sgdisk --print /dev/$drive
    echo "---"
done

echo "Partition creation complete!"
echo "You can now run the Debian installer and select 'Use existing partitions'"
echo "Configure as follows:"
echo "  - nvmeXn1p1: EFI System Partition"
echo "  - nvmeXn1p2: /boot (RAID1 across all drives)"
echo "  - nvmeXn1p3: Root filesystem (RAID1 + LUKS)"
echo "  - nvmeXn1p4: Swap (RAID1 + LUKS)"
