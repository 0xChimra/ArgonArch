#!/usr/bin/env bash
echo -e "\nINSTALLING AUR SOFTWARE\n"

echo "CLONING: YAY"
cd ~
mkdir ${HOME}/Documents/setup
cd ${HOME}/Documents/setup
git clone "https://aur.archlinux.org/yay.git"
cd ${HOME}/Documents/setup/yay
makepkg -si --noconfirm
cd ~
touch "$HOME/.cache/zshhistory"
chsh -s $(which zsh)
#ZSH SETUP CONFIG STUFF
#
#
#

PKGS=(
'autojump'
'awesome-terminal-fonts'
'dxvk-bin' # DXVK DirectX to Vulcan
'github-desktop-bin' # Github Desktop sync
'lightly-git'
'lightlyshaders-git'
#'mangohud' # Gaming FPS Counter
#'mangohud-common'
'nerd-fonts-fira-code'
'nordic-darker-standard-buttons-theme'
'nordic-darker-theme'
'nordic-kde-git'
'nordic-theme'
'noto-fonts-emoji'
'papirus-icon-theme'
'plasma-pa'
'ocs-url' # install packages from websites
'sddm-nordic-theme-git'
'snapper-gui-git'
'ttf-droid'
'ttf-hack'
'ttf-meslo' # Nerdfont package
'ttf-roboto'
'zoom' # video conferences
'snap-pac'
)

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

export PATH=$PATH:~/.local/bin
cp -r $HOME/ArgonArch/dotfiles/* $HOME/.config/
pip install konsave
konsave -i $HOME/ArgonArch/kde.knsv
sleep 1
konsave -a kde

echo -e "\nDone!\n"
exit
