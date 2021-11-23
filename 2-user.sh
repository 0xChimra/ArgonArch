#!/usr/bin/env bash
echo -e "\nINSTALLING AUR SOFTWARE\n"

echo "CLONING: YAY"
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
#cp -r $HOME/ArgonArch/dotfiles/* $HOME/.config/
#pip install konsave
#konsave -i $HOME/ArgonArch/kde.knsv
#sleep 1
#konsave -a kde

echo -e "\nDone!\n"
exit
