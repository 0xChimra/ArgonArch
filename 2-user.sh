#!/usr/bin/env bash
cd ~
mkdir -p ${HOME}/Documents/setup
cd ${HOME}/Documents/setup
git clone "https://aur.archlinux.org/yay.git"
cd ${HOME}/Documents/setup/yay
makepkg -si --noconfirm
cd ~
touch "$HOME/.cache/zshhistory"
chsh -s $(which zsh)

mkdir -p ${HOME}/Documents/setup/zsh
cp ${HOME}/ArgonArch/zshrc ${HOME}/.zshrc
cp ${HOME}/ArgonArch/zalias ${HOME}/Documents/setup/zsh/zalias


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
