#!/usr/bin/env bash

if ! source ${HOME}/ArgonArch/install.conf; then
	echo "--------------------------------------------------------------"
	echo "        Set your password (example : password123)             "
	echo "--------------------------------------------------------------"
	read -p "Enter your password: " password
	echo "password=$password" >> install.conf
fi

keymap_long="${keyboard}"
keymap_short="${keymap_long:0:2}"

cd ~
mkdir -p ${HOME}/Documents/setup
cd ${HOME}/Documents/setup
git clone "https://aur.archlinux.org/yay.git"
cd ${HOME}/Documents/setup/yay
makepkg -si --noconfirm
cd ~

#echo $password | sudo -S localectl --no-ask-password set-keymap $keyboard_short
#echo $password | sudo -S localectl --no-ask-password set-x11-keymap $keymap_short
localectl --no-ask-password set-keymap $keyboard_short
localectl --no-ask-password set-x11-keymap $keyboard_short

touch "$HOME/.cache/zshhistory"
chsh -s $(which zsh)
mkdir -p ${HOME}/Documents/setup/zsh
cp ${HOME}/ArgonArch/zshrc ${HOME}/.zshrc
cp ${HOME}/ArgonArch/zalias ${HOME}/Documents/setup/zsh/zalias

sudo pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key FBA220DFC880C036
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm

sudo echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
PKGS=(
'autojump'
'dxvk-bin'
'plasma-pa'
'ocs-url'
'ttf-droid'
'ttf-hack'
'ttf-meslo'
'ttf-roboto'
)

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

export PATH=$PATH:~/.local/bin

exit
