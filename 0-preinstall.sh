#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true
#pacman -S --noconfirm pacman-contrib terminus-font
#setfont ter-v22b
sed -i 's/^#Para/Para/' /etc/pacman.conf
pacman -S --noconfirm reflector rsync grub
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo -e "-------------------------------------------------------------------------------------------"
echo -e '       d8888                                               d8888                 888'      
echo -e '      d88888                                              d88888                 888'      
echo -e '     d88P888                                             d88P888                 888'      
echo -e '    d88P 888 888d888 .d88b.   .d88b.  88888b.           d88P 888 888d888 .d8888b 88888b.'  
echo -e '   d88P  888 888P"  d88P"88b d88""88b 888 "88b         d88P  888 888P"  d88P"    888 "88b' 
echo -e '  d88P   888 888    888  888 888  888 888  888        d88P   888 888    888      888  888' 
echo -e ' d8888888888 888    Y88b 888 Y88..88P 888  888       d8888888888 888    Y88b.    888  888' 
echo -e 'd88P     888 888     "Y88888  "Y88P"  888  888      d88P     888 888     "Y8888P 888  888' 
echo -e '                         888'                                                              
echo -e '                    Y8b d88P'                                                              
echo -e '                     "Y88P"'                                                               
echo -e "-------------------------------------------------------------------------------------------"
echo -e "Setting up fast mirrors for your country: ' $iso ' !"
echo -e "-------------------------------------------------------------------------------------------"

reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
mkdir /mnt

# Set keymaps
echo "-------------------------------------------------"
echo "Enter keymap country-code  (example : de, us)"
echo "-------------------------------------------------"
read map

localectl --no-ask-password set-keymap $map


echo -e "\nInstalling prereqs...\n$HR"
pacman -S --noconfirm gptfdisk btrfs-progs

echo "-------------------------------------------------"
echo "-------Select Your Disk To Format----------------"
echo "-------------------------------------------------"
lsblk
echo "Please enter disk to work on: (example /dev/sda)"
read DISK
echo "THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK"
read -p "are you sure you want to continue (Y/N):" formatdisk
case $formatdisk in

y|Y|yes|Yes|YES)
echo "-------------------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "-------------------------------------------------"

# disk prep
sgdisk -Z ${DISK} # zap all on disk
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${DISK} # partition 1 (BIOS Boot Partition)
sgdisk -n 2::+100M --typecode=2:ef00 --change-name=2:'EFIBOOT' ${DISK} # partition 2 (UEFI Boot Partition)
sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' ${DISK} # partition 3 (Root), default start, remaining
if [[ ! -d "/sys/firmware/efi" ]]; then
    sgdisk -A 1:set:2 ${DISK}
fi

# make filesystems
echo -e "\nCreating Filesystems...\n$HR"
if [[ ${DISK} =~ "nvme" ]]; then
mkfs.vfat -F32 -n "EFIBOOT" "${DISK}p2"
mkfs.btrfs -L "ROOT" "${DISK}p3" -f
mount -t btrfs "${DISK}p3" /mnt
else
mkfs.vfat -F32 -n "EFIBOOT" "${DISK}2"
mkfs.btrfs -L "ROOT" "${DISK}3" -f
mount -t btrfs "${DISK}3" /mnt
fi
ls /mnt | xargs btrfs subvolume delete
btrfs subvolume create /mnt/@
umount /mnt
;;
*)
echo "-------------------------------------------------"
echo "Rebooting in 3 Seconds ..." && sleep 1
echo "Rebooting in 2 Seconds ..." && sleep 1
echo "Rebooting in 1 Second ..." && sleep 1
echo "-------------------------------------------------"
reboot now
;;
esac

# mount target
mount -t btrfs -o subvol=@ -L ROOT /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount -t vfat -L EFIBOOT /mnt/boot/

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted can not continue"
    echo "Rebooting in 3 Seconds ..." && sleep 1
    echo "Rebooting in 2 Seconds ..." && sleep 1
    echo "Rebooting in 1 Second ..." && sleep 1
    reboot now
fi

pacstrap /mnt base base-devel linux linux-firmware vim nano sudo archlinux-keyring wget libnewt --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
cp -R ${SCRIPT_DIR} /mnt/root/ArgonArch
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
if [[ ! -d "/sys/firmware/efi" ]]; then
    grub-install --boot-directory=/mnt/boot ${DISK}
fi
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -lt 8000000 ]]; then
    #Put swap into the actual system, not into RAM disk, otherwise there is no point in it, it'll cache RAM into RAM. So, /mnt/ everything.
    mkdir /mnt/opt/swap #make a dir that we can apply NOCOW to to make it btrfs-friendly.
    chattr +C /mnt/opt/swap #apply NOCOW, btrfs needs that.
    dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
    chmod 600 /mnt/opt/swap/swapfile #set permissions.
    chown root /mnt/opt/swap/swapfile
    mkswap /mnt/opt/swap/swapfile
    swapon /mnt/opt/swap/swapfile
    #The line below is written to /mnt/ but doesn't contain /mnt/, since it's just / for the sysytem itself.
    echo "/opt/swap/swapfile	none	swap	sw	0	0" >> /mnt/etc/fstab #Add swap to fstab, so it KEEPS working after installation.
fi

