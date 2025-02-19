#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
HEIGHT=24
WIDTH=80
CHOICE_HEIGHT=4
BACKTITLE="Fedora Setup Util - By Osiris - https://lsass.co.uk"
TITLE="Please Make a selection"
MENU="Please Choose one of the following options:"

#Other variables
OH_MY_ZSH_URL="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
P10K_URL="https://github.com/romkatv/powerlevel10k.git"

#Check to see if Dialog is installed, if not install it - Thanks Kinkz_nl
if [ $(rpm -q dialog 2>/dev/null | grep -c "is not installed") -eq 1 ]; then
sudo dnf install -y dialog
fi

OPTIONS=(
    1 "Configure Gnome - Set clock format, window buttons, and centered windows"
    2 "Speed up DNF - This enables fastestmirror, max downloads and deltarpms"
    3 "Enable RPM Fusion - Enables the RPM Fusion repos for your specific version"
    4 "Install Plugins - Sound and Video Codecs (requires RPM Fusion)"
    5 "Install Software - Installs a bunch of my most used software"
    6 "Install Flathub - Enables the Flathub Flatpak repo and installs packages"
    7 "Install Oh-My-ZSH"
    8 "Install powerlevel10k (requires ZSH)"
    9 "Quit"
)

while [ "$CHOICE -ne 4" ]; do
    CHOICE=$(dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "$TITLE" \
        --nocancel \
        --menu "$MENU" \
        $HEIGHT $WIDTH $CHOICE_HEIGHT \
        "${OPTIONS[@]}" \
        2>&1 >/dev/tty)

    clear
    case $CHOICE in
        1)  echo "Configuring Gnome"
            gsettings set org.gnome.desktop.interface clock-format '12h'
            gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
            gsettings set org.gnome.mutter center-new-windows true
            notify-send "Gnome has been configured" --expire-time=10
            ;;
        2)  echo "Speeding Up DNF"
            echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf
            echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
            echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
            notify-send "Your DNF config has been amended" --expire-time=10
            ;;
        3)  echo "Enabling RPM Fusion"
            sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
            sudo dnf groupupdate -y core
            notify-send "RPM Fusion Enabled" --expire-time=10
            ;;
        4)  echo "Installing Plugins"
            sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
            sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
            sudo dnf install -y lame\* --exclude=lame-devel
            sudo dnf group upgrade -y --with-optional Multimedia
            notify-send "Plugins have been installed" --expire-time=10
            ;;
        5)  echo "Installing Software"
            sudo dnf install -y $(cat dnf-packages.txt)
            notify-send "Software has been installed" --expire-time=10
            ;;
        6)  echo "Installing Flathub"
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            flatpak update
            flatpak install -y $(cat flatpak-packages.txt)
            notify-send "Flatpak has now been enabled" --expire-time=10
            ;;
        7)  echo "Installing Oh-My-Zsh"
            sudo dnf -y install zsh util-linux-user
            sh -c "$(curl -fsSL $OH_MY_ZSH_URL)"
            echo "change shell to ZSH"
            chsh -s "$(which zsh)"
            notify-send "Oh-My-Zsh has been installed" --expire-time=10
            ;;
        8)  echo "Installing powerlevel10k"
            git clone --depth=1 $P10K_URL ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
            sed -i 's@^ZSH_THEME=.*@ZSH_THEME="powerlevel10k/powerlevel10k"@g' ~/.zshrc
            notify-send "powerlevel10k has been installed" --expire-time=10
            ;;
        9)  exit 0
            ;;
    esac
done
