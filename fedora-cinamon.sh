#!/bin/bash

# configure dnf
fastestmirror=1
print "%s" "
maxparalell_downloads=10
countme=false
" | sudo tee -a /etc/dnf/dnf.conf

# setup RPMFusion
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
sudo dnf groupupdate core -y

# make system fully-update
sudo dnf upgrade -y

# debloat
fedora_cinamon_debloat () {
	log "fedora_cinamon_debloat"
	local -a fedora_cinamon_debloat_stuff
	fedora_cinamon_debloat_stuff=(
	"abrt*"
	"anaconda*"
	"avahi"
	"baobab"
	"bluez-cups"
	"boost-date-time"
	"cheese"
	"fedora-bookmarks"
	"fedora-chromium-config"
	"geolite2*"
	"gnome-calculator"
	"gnome-calendar"
	"gnome-clocks"
	"gnome-contacts"
	"gnome-logs"
	"gnome-maps"
	"gnome-remote-desktop"
	"gnome-system-monitor"
	"gnome-tour"
	"gnome-weather"
	"hyperv*"
	"kpartx"
	"mailcap"
	"mtr"
	"nano"
	"simple-scan"
	"sos"
	)
sudo dnf -y rm ${fedora_cinamon_debloat_stuff[*]}
}
fedora_cinamon_debloat

# run update
sudo dnf autoremove -y
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --fore
sudo fwupdmgr get-updates -y
sudo fwupdmgr update -y

# install RPMs
sudo dnf install -y torbrowser-launcher mullvad-vpn --best --allowerasing keepassxc

# NTS instead of NTP
sudo sudo curl https://raw.githubusercontent.com/GrapheneOS/infrastructure/main/chrony.conf -o /etc/chrony.conf

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

echo "The configuration is now complete :)"

