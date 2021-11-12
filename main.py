import os
import sys
import subprocess
import time

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

#Get mirrors
result = subprocess.run(["curl", "-4", "ifconfig.co/country-iso"], stdout=subprocess.PIPE)

COUNTRY_CODE = result.stdout.decode("utf-8")

def install_package(package):
    if isinstance(package, list):
        for pack in package:
            os.system(pack)
    else:
        os.system(package)

def execute_command(command):
    os.system(command)
#Set Time
subprocess.run(["timedatectl", "set-ntp", "true"])

######
execute_command("pacman -S --noconfirm reflector rsync grub")
#Backing Up the mirrorlist
execute_command("cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup")
####################
execute_command("reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist")
execute_command("mkdir /mnt")
execute_command("pacman -S --noconfirm gptfdisk btrfs-progs")
######
#Select Disk
print("Select the disk you want to install ArchLinux on")
print("Format Example: '/dev/sda'")
execute_command("lsblk")
DISK = input("Enter the disk: ")
print("All Data on", DISK, "deleted and the disk will be formatted")
CONFIRM = input("Are you sure? (y/n) ")
if CONFIRM == "Y" or CONFIRM == "y":
    pass
else:
    DISK = input("Enter the new disk: ")
execute_command(("sgdisk -Z " + DISK))
execute_command(("sgdisk -a 2048 -o " + DISK))
######
#Create Partitions
execute_command(("sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' " + DISK)) # partition 1 (BIOS Boot Partition)
execute_command(("sgdisk -n 2::+100M --typecode=2:ef00 --change-name=2:'EFIBOOT' " + DISK)) # partition 2 (UEFI Boot Partition)
execute_command(("sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' " + DISK)) # partition 3 (Root Partition)
if not os.path.exists("/sys/firmware/efi"):
    execute_command(("sgdisk -A 1:set:2 " + DISK))
######
#Create Filesystems
#NVME
if "nvme" in DISK:
    execute_command(('mkfs.vfat -F32 -n "EFIBOOT" ' + DISK + "p2"))
    execute_command(('mkfs.btrfs -L "ROOT" ' + DISK + "p3 -f"))
    execute_command(('mount -t btrfs ' + DISK + "p3 /mnt"))


#SATA
else:
    execute_command(('mkfs.vfat -F32 -n "EFIBOOT" ' + DISK + "2"))
    execute_command(('mkfs.btrfs -L "ROOT" ' + DISK + "3 -f"))
    execute_command(('mount -t btrfs ' + DISK + "3 /mnt"))

execute_command("ls /mnt | xargs btrfs subvolume delete")
execute_command("btrfs subvolume create /mnt/@")
execute_command("umount /mnt")
execute_command(";;")
execute_command("*)")
#Reboot
print("Rebooting in 3 seconds")
time.sleep(3)
execute_command("reboot now")
execute_command(";;")

execute_command("mount -t btrfs -o subvol=@ -L ROOT /mnt")
execute_command("mkdir /mnt/boot")
execute_command("mkdir /mnt/boot/efi")
execute_command("mount -t vfat -L EFIBOOT /mnt/boot/")

print("INSTALLING")
input("Waiting")
