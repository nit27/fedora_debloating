#!/bin/bash

# configure dnf
printf "%s" "
fastestmirror=1
max_parallel_downloads=10
countme=false
" | sudo tee -a /etc/dnf/dnf.conf

# debloat
sudo dnf remove -y abrt* anaconda* libreoffice avahi baobab bluez-cups boost-date-time cheese fedora-bookmarks fedora-chromium-config geolite2* gnome-calculator gnome-calendar gnome-clocks gnome-online-accounts gnome-contacts gnome-logs gnome-maps gnome-remote-desktop gnome-system-monitor gnome-tour gnome-weather hyperv* kpartx mailcap mtr nano simple-scan sos firefox

# run updates
sudo dnf autoremove -y
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --fore
sudo fwupdmgr get-updates -y
sudo fwupdmgr update -y

# setup RPMFusion
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
sudo dnf groupupdate core -y

# add RPMs to dnf
	## Mullvad-vpn GUI
sudo dnf config-manager --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo
	## veracrypt GUI
wget https://launchpad.net/veracrypt/trunk/1.26.7/+download/veracrypt-1.26.7-CentOS-8-x86_64.rpm

# install apps
sudo dnf install -y mullvad-vpn
sudo dnf install -y veracrypt
sudo dnf install -y keepassxc
wget https://telegram.org/dl/desktop/linux

# make system fully-update
sudo dnf upgrade -y

# NTS instead of NTP
sudo curl https://raw.githubusercontent.com/GrapheneOS/infrastructure/main/chrony.conf -o /etc/chrony.conf

# randomize MAC address & disable static hostname
sudo bash -c 'cat > /etc/NetworkManager/conf.d/00-macrandomize.conf' <<-'EOF'
[main]
hostname-mode=none

[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
EOF

sudo systemctl restart NetworkManager
sudo hosnamectl hostname "localhost"

# finish progresses
echo "The configuration is now completed :)"
