#!/bin/bash
chmod +x *.sh
bash 0-preinstall.sh
arch-chroot /mnt /root/ArgonArch/1-setup.sh
source /mnt/root/ArgonArch/install.conf
arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/ArgonArch/2-user.sh
arch-chroot /mnt /root/ArgonArch/3-post-setup.sh