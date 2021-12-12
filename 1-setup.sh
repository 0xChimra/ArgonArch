#!/usr/bin/env bash

#"--------------------------------------"
#"--          Network Setup           --"
#"--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
#"-------------------------------------------------"
#"Setting up mirrors for optimal download          "
#"-------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
pacman -S --noconfirm reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(grep -c ^processor /proc/cpuinfo)
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
fi

#https://wiki.archlinux.org/title/Locale
if ! source /root/ArgonArch/install.conf; then
    echo "--------------------------------------------------------------"
	echo "           Set your locale (example : en_US.UTF-8 )           "
	echo "--------------------------------------------------------------"
	read -p "Enter your locale: " locale
	echo "locale=$locale" >> /root/ArgonArch/install.conf
fi
if ! source /root/ArgonArch/install.conf; then
    echo "--------------------------------------------------------------"
	echo "        Set your Timezone (example : Europe/Berlin)           "
	echo "--------------------------------------------------------------"
	read -p "Enter your timezone: " timezone
	echo "timezone=$timezone" >> /root/ArgonArch/install.conf
fi
if ! source /root/ArgonArch/install.conf; then
	echo "--------------------------------------------------------------"
	echo "        Set your keyboard layout (example : de-latin1)               "
	echo "--------------------------------------------------------------"
	read -p "Enter your keyboard layout: " keyboard
	echo "keyboard=$keyboard" >> /root/ArgonArch/install.conf
fi
if ! source /root/ArgonArch/install.conf; then
	echo "--------------------------------------------------------------"
	echo "        Set your username (example : argonuser)               "
	echo "--------------------------------------------------------------"
	read -p "Enter your username: " username
	echo "username=$username" >> /root/ArgonArch/install.conf
fi
if ! source /root/ArgonArch/install.conf; then
	echo "--------------------------------------------------------------"
	echo "        Set your hostname (example : ArgonBox)                "
	echo "--------------------------------------------------------------"
	read -p "Enter your hostname: " hostname
	echo "hostname=$hostname" >> /root/ArgonArch/install.conf
fi
if ! source /root/ArgonArch/install.conf; then
	echo "--------------------------------------------------------------"
	echo "        Set your password (example : password123)                "
	echo "--------------------------------------------------------------"
	read -p "Enter your password: " password
	echo "password=$password" >> install.conf
fi

#Change the locale
sed -i 's/^#${locale} UTF-8/${locale} UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone $timezone
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG=$locale LC_TIME=$locale

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

#Add parallel downloading
sed -i 's/^#Para/Para/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

PKGS=(
'mesa'
'xorg'
'xorg-server'
'xorg-apps'
'xorg-drivers'
'xorg-xkill'
'xorg-xinit'
'xterm'
'plasma-desktop'
'alsa-plugins'
'alsa-utils'
'ark'
'autoconf'
'automake'
'base'
'bash-completion'
'bind'
'binutils'
'bison'
'bluedevil'
'bluez'
'bluez-libs'
'bluez-utils'
'breeze'
'breeze-gtk'
'bridge-utils'
'btrfs-progs'
'cronie'
'cups'
'dialog'
'discover'
'dolphin'
'dosfstools'
'dtc'
'efibootmgr'
'egl-wayland'
'exfat-utils'
'extra-cmake-modules'
'filelight'
'flex'
'fuse2'
'fuse3'
'fuseiso'
'gcc'
'git'
'gptfdisk'
'grub'
'grub-customizer'
'gst-libav'
'gst-plugins-good'
'gst-plugins-ugly'
'gwenview'
'haveged'
'kate'
'kcodecs'
'kcoreaddons'
'kdeplasma-addons'
'kde-gtk-config'
'kinfocenter'
'kscreen'
'kwallet-pam'
'konsole'
'kwayland-integration'
'kgamma5'
'khotkeys'
'kwrited'
'layer-shell-qt'
'libdvdcss'
'libnewt'
'libtool'
'linux'
'linux-firmware'
'linux-headers'
'lsof'
'lzop'
'm4'
'make'
'milou'
'nano'
'neofetch'
'networkmanager'
'ntfs-3g'
'ntp'
'openbsd-netcat'
'openssh'
'os-prober'
'p7zip'
'pacman-contrib'
'patch'
'picom'
'pkgconf'
'drkonqi'
'plasma-disks'
'plasma-nm'
'plasma-pa'
'plasma-systemmonitor'
'plasma-thunderbolt'
'plasma-firewall'
'plasma-sdk'
'plasma-vault'
'powerdevil'
'powerline-fonts'
'print-manager'
'pulseaudio'
'pulseaudio-alsa'
'pulseaudio-bluetooth'
'python-notify2'
'python-psutil'
'python-pyqt5'
'python-pip'
'rsync'
'sddm'
'sddm-kcm'
'sudo'
'systemsettings'
'terminus-font'
'ufw'
'unrar'
'unzip'
'usbutils'
'vim'
'wget'
'which'
'wine-gecko'
'wine-mono'
'winetricks'
'xdg-desktop-portal-kde'
'xdg-user-dirs'
'zeroconf-ioslave'
'zip'
'zsh'
'zsh-syntax-highlighting'
'zsh-autosuggestions'
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

#
# determine processor type and install microcode
# 
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	

# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
    pacman -S nvidia --noconfirm --needed
	nvidia-xconfig
elif lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

if [ $(whoami) = "root"  ];
then
    useradd -m -G wheel -s /bin/bash $username
	echo -e "$password\n$password" | passwd $username
	cp -R /root/ArgonArch /home/$username/
    chown -R $username: /home/$username/ArgonArch
	echo $hostname > /etc/hostname
else
	echo "You are already a user proceed with aur installs"
fi


