#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

if [ -z "$PREFIX" ]; then
    echo "Error: This script must be run inside Termux."
    exit 1
fi

show_menu() {
    clear
    echo "========================================="
    echo "        Linux for Termux Manager         "
    echo "========================================="
    echo "1) Install / Re-install Linux Distro"
    echo "2) Backup a Distro"
    echo "3) Restore a Distro"
    echo "4) Uninstall a Distro"
    echo "5) Exit"
    echo "========================================="
    read -p "Select an option [1-5]: " OPTION
    case $OPTION in
        1) install_linux ;;
        2) backup_linux ;;
        3) restore_linux ;;
        4) uninstall_linux ;;
        5) exit 0 ;;
        *) echo "Invalid option"; sleep 1; show_menu ;;
    esac
}

get_distro_choice() {
    echo ""
    echo "Choose Linux Distribution:"
    echo "1) Ubuntu (apt)"
    echo "2) Debian (apt)"
    echo "3) Arch Linux (pacman)"
    echo "4) Fedora (dnf)"
    echo "5) OpenSUSE (zypper)"
    echo "6) Void Linux (xbps)"
    read -p "Select Distro [1-6]: " DIST_CHOICE
    case $DIST_CHOICE in
        1) DISTRO="ubuntu";;
        2) DISTRO="debian";;
        3) DISTRO="archlinux";;
        4) DISTRO="fedora";;
        5) DISTRO="opensuse";;
        6) DISTRO="void";;
        *) echo "Invalid choice"; exit 1 ;;
    esac
}

backup_linux() {
    get_distro_choice
    echo "[*] Backing up $DISTRO..."
    proot-distro backup "$DISTRO" --output ~/${DISTRO}-backup.tar.gz
    echo "Backup saved to ~/${DISTRO}-backup.tar.gz"
    read -p "Press Enter to continue..."
    show_menu
}

restore_linux() {
    get_distro_choice
    if [ ! -f ~/${DISTRO}-backup.tar.gz ]; then
        echo "Error: No backup found at ~/${DISTRO}-backup.tar.gz"
    else
        echo "[*] Restoring $DISTRO..."
        read -p "Are you sure? This overwrites current data [y/N]: " CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            proot-distro restore "$DISTRO" --input ~/${DISTRO}-backup.tar.gz
            echo "Restore complete!"
        fi
    fi
    read -p "Press Enter to continue..."
    show_menu
}

uninstall_linux() {
    get_distro_choice
    read -p "Are you sure you want to uninstall $DISTRO? [y/N]: " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "[*] Uninstalling $DISTRO..."
        proot-distro remove "$DISTRO" || true
        rm -f $PREFIX/bin/start-linux $PREFIX/bin/stop-linux
        echo "$DISTRO has been removed."
    fi
    read -p "Press Enter to continue..."
    show_menu
}

install_linux() {
    echo ""
    echo "========================================="
    echo "   Linux Installation Wizard             "
    echo "========================================="
    echo ""
    echo "⚠️ IMPORTANT WARNING FOR ANDROID 12+ USERS ⚠️"
    echo "If you are on Android 14+, you MUST toggle 'Disable child process restrictions'"
    echo "in your Android Developer Options for a stable desktop experience."
    echo "========================================="
    echo ""
    
    get_distro_choice
    
    DE="none"
    SERVER="none"
    
    echo ""
    echo "Choose Desktop Environment:"
    echo "1) XFCE4 (Recommended, Lightweight GUI)"
    echo "2) LXDE (Very Lightweight GUI)"
    echo "3) None (CLI only)"
    read -p "Select DE [1-3]: " DE_CHOICE
    if [ "$DE_CHOICE" == "1" ]; then DE="xfce4"; elif [ "$DE_CHOICE" == "2" ]; then DE="lxde"; else DE="none"; fi
    
    if [ "$DE" != "none" ]; then
        echo ""
        echo "Choose Display Server:"
        echo "1) Termux:X11 (Hardware Acceleration, Faster)"
        echo "2) VNC (Software Rendering, Slower)"
        read -p "Select Server [1-2]: " SRV_CHOICE
        if [ "$SRV_CHOICE" == "1" ]; then SERVER="x11"; else SERVER="vnc"; fi
    fi

    # SOFTWARE SELECTOR
    echo ""
    echo "========================================="
    echo "      Software Selector (Optional)       "
    echo "========================================="
    echo "Select categories to install popular apps:"
    
    INSTALL_DEV=0
    INSTALL_WEB=0
    
    read -p "Install Development Tools? (Python, Git, VS Code/Codium) [y/N]: " DEV_CHOICE
    if [[ "$DEV_CHOICE" =~ ^[Yy]$ ]]; then INSTALL_DEV=1; fi
    
    read -p "Install Web Browsers? (Firefox) [y/N]: " WEB_CHOICE
    if [[ "$WEB_CHOICE" =~ ^[Yy]$ ]]; then INSTALL_WEB=1; fi
    
    echo ""
    echo "========================================="
    echo "Beginning Installation..."
    echo "========================================="

    echo "[*] Requesting Android Storage Permission..."
    termux-setup-storage || true
    sleep 2
    
    echo "[*] Updating Termux packages..."
    pkg update -y && pkg upgrade -y
    
    echo "[*] Installing dependencies..."
    pkg install proot-distro pulseaudio wget -y
    
    if [ "$SERVER" == "x11" ]; then
        pkg install x11-repo -y
        pkg install termux-x11-nightly -y
    fi
    
    echo "[*] Installing $DISTRO..."
    proot-distro install "$DISTRO"
    
    ROOTFS="$PREFIX/var/lib/proot-distro/installed-rootfs/$DISTRO"
    SETUP_SCRIPT="$ROOTFS/root/gui_setup.sh"
    
    if [ "$DE" != "none" ]; then
        echo "[*] Setting up Universal Wallpaper..."
        mkdir -p "$ROOTFS/usr/share/backgrounds"
        wget -qO "$ROOTFS/usr/share/backgrounds/default.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Ubuntu_10.04_LTS_default_wallpaper.jpg/1280px-Ubuntu_10.04_LTS_default_wallpaper.jpg" || true
    fi
    
    # Configure package manager mapping
    case "$DISTRO" in
        ubuntu|debian)
            UPDATE_CMD="apt-get update -y && apt-get upgrade -y"
            INSTALL_CMD="apt-get install -y"
            XFCE_PKG="xfce4 xfce4-goodies dbus-x11"
            LXDE_PKG="lxde dbus-x11"
            VNC_PKG="tigervnc-standalone-server expect"
            SUDO_PKG="sudo"
            DEV_PKG="python3 git curl wget"
            WEB_PKG="firefox"
            ;;
        archlinux)
            UPDATE_CMD="pacman -Syu --noconfirm"
            INSTALL_CMD="pacman -S --noconfirm"
            XFCE_PKG="xfce4 xfce4-goodies dbus"
            LXDE_PKG="lxde dbus"
            VNC_PKG="tigervnc expect"
            SUDO_PKG="sudo"
            DEV_PKG="python git curl wget code"
            WEB_PKG="firefox"
            ;;
        fedora)
            UPDATE_CMD="dnf update -y"
            INSTALL_CMD="dnf install -y"
            XFCE_PKG="xfce4-session xfce4-panel xfdesktop xfwm4 dbus-x11"
            LXDE_PKG="lxde-common lxsession dbus-x11"
            VNC_PKG="tigervnc-server expect"
            SUDO_PKG="sudo"
            DEV_PKG="python3 git curl wget"
            WEB_PKG="firefox"
            ;;
        opensuse)
            UPDATE_CMD="zypper refresh && zypper update -y"
            INSTALL_CMD="zypper install -y"
            XFCE_PKG="patterns-xfce-xfce dbus-1-x11"
            LXDE_PKG="patterns-lxde-lxde dbus-1-x11"
            VNC_PKG="tigervnc expect"
            SUDO_PKG="sudo"
            DEV_PKG="python3 git curl wget"
            WEB_PKG="MozillaFirefox"
            ;;
        void)
            UPDATE_CMD="xbps-install -Syu"
            INSTALL_CMD="xbps-install -y"
            XFCE_PKG="xfce4 dbus"
            LXDE_PKG="lxde dbus"
            VNC_PKG="tigervnc expect"
            SUDO_PKG="sudo"
            DEV_PKG="python3 git curl wget"
            WEB_PKG="firefox"
            ;;
    esac
    
    cat << EOF > "$SETUP_SCRIPT"
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
echo " -> Updating repositories..."
$UPDATE_CMD
EOF
    
    APT_PKGS="$SUDO_PKG"
    if [ "$DE" == "xfce4" ]; then APT_PKGS="$APT_PKGS $XFCE_PKG"; fi
    if [ "$DE" == "lxde" ]; then APT_PKGS="$APT_PKGS $LXDE_PKG"; fi
    if [ "$SERVER" == "vnc" ]; then APT_PKGS="$APT_PKGS $VNC_PKG"; fi
    if [ "$INSTALL_DEV" == "1" ]; then APT_PKGS="$APT_PKGS $DEV_PKG"; fi
    if [ "$INSTALL_WEB" == "1" ]; then APT_PKGS="$APT_PKGS $WEB_PKG"; fi
    
    APT_PKGS=$(echo "$APT_PKGS" | xargs)
    
    if [ -n "$APT_PKGS" ]; then
        cat << EOF >> "$SETUP_SCRIPT"
echo " -> Installing packages ($APT_PKGS)..."
$INSTALL_CMD $APT_PKGS
EOF
    fi
    
    cat << 'EOF' >> "$SETUP_SCRIPT"
echo " -> Creating standard 'user' account with sudo privileges..."
useradd -m -s /bin/bash user || true
echo "user:ubuntu" | chpasswd
echo "user ALL=(ALL) ALL" >> /etc/sudoers
echo "root ALL=(ALL) ALL" >> /etc/sudoers

echo " -> Linking Android Internal Storage..."
mkdir -p /home/user/storage
if [ -d /data/data/com.termux/files/home/storage ]; then
    ln -sf /data/data/com.termux/files/home/storage/* /home/user/storage/
fi
chown -R user:user /home/user/storage
EOF
    
    if [ "$INSTALL_DEV" == "1" ]; then
        cat << 'EOF' >> "$SETUP_SCRIPT"
echo "alias google-antigravity='echo \"Google Antigravity Activated! 🚀\"'" >> /home/user/.bashrc
EOF
    fi

    if [ "$SERVER" == "vnc" ]; then
        cat << 'EOF' >> "$SETUP_SCRIPT"
echo " -> Configuring VNC Password (default: ubuntu)..."
mkdir -p /home/user/.vnc
expect << 'EOD'
spawn vncpasswd /home/user/.vnc/passwd
expect "Password:"
send "ubuntu\r"
expect "Verify:"
send "ubuntu\r"
expect "Would you like to enter a view-only password (y/n)?"
send "n\r"
expect eof
EOD
EOF
        if [ "$DE" == "xfce4" ]; then
            cat << 'EOF' >> "$SETUP_SCRIPT"
cat << 'STARTUP' > /home/user/.vnc/xstartup
#!/bin/sh
export PULSE_SERVER=127.0.0.1
startxfce4 &
(sleep 5 && xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /usr/share/backgrounds/default.jpg || true) &
STARTUP
EOF
        elif [ "$DE" == "lxde" ]; then
            cat << 'EOF' >> "$SETUP_SCRIPT"
cat << 'STARTUP' > /home/user/.vnc/xstartup
#!/bin/sh
export PULSE_SERVER=127.0.0.1
startlxde &
(sleep 5 && pcmanfm --set-wallpaper /usr/share/backgrounds/default.jpg || true) &
STARTUP
EOF
        fi
        cat << 'EOF' >> "$SETUP_SCRIPT"
chmod +x /home/user/.vnc/xstartup
chown -R user:user /home/user/.vnc
EOF
    fi
    
    echo "[*] Executing setup inside $DISTRO (this will take a while)..."
    proot-distro login "$DISTRO" -- bash /root/gui_setup.sh
    
    echo "[*] Generating Quick-Launch Scripts..."
    cat << EOF > $PREFIX/bin/start-linux
#!/bin/bash
echo "Starting PulseAudio..."
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
EOF
    if [ "$SERVER" == "x11" ]; then
        cat << EOF >> $PREFIX/bin/start-linux
echo "Starting Termux:X11..."
termux-x11 :1 &
sleep 2
echo "Starting $DISTRO as 'user'..."
EOF
        if [ "$DE" == "xfce4" ]; then
            cat << EOF >> $PREFIX/bin/start-linux
proot-distro login $DISTRO --user user --shared-tmp -- bash -c "export PULSE_SERVER=127.0.0.1; export DISPLAY=:1; startxfce4 & (sleep 5 && xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /usr/share/backgrounds/default.jpg || true) &"
EOF
        elif [ "$DE" == "lxde" ]; then
            cat << EOF >> $PREFIX/bin/start-linux
proot-distro login $DISTRO --user user --shared-tmp -- bash -c "export PULSE_SERVER=127.0.0.1; export DISPLAY=:1; startlxde & (sleep 5 && pcmanfm --set-wallpaper /usr/share/backgrounds/default.jpg || true) &"
EOF
        fi
    elif [ "$SERVER" == "vnc" ]; then
        cat << EOF >> $PREFIX/bin/start-linux
echo "Starting VNC Server..."
proot-distro login $DISTRO --user user --shared-tmp -- bash -c "export PULSE_SERVER=127.0.0.1; vncserver -geometry 1280x720 :1"
EOF
    elif [ "$DE" == "none" ]; then
        cat << EOF >> $PREFIX/bin/start-linux
echo "Starting $DISTRO CLI as 'user'..."
proot-distro login $DISTRO --user user --shared-tmp
EOF
    fi
    chmod +x $PREFIX/bin/start-linux
    
    cat << 'EOF' > $PREFIX/bin/stop-linux
#!/bin/bash
echo "Stopping PulseAudio..."
pulseaudio -k 2>/dev/null || true
EOF
    if [ "$SERVER" == "x11" ]; then
        cat << 'EOF' >> $PREFIX/bin/stop-linux
echo "Stopping Termux:X11..."
killall termux-x11 2>/dev/null || true
EOF
    elif [ "$SERVER" == "vnc" ]; then
        cat << EOF >> $PREFIX/bin/stop-linux
echo "Stopping VNC Server..."
proot-distro login $DISTRO --user user --shared-tmp -- bash -c "vncserver -kill :1" 2>/dev/null || true
EOF
    fi
    chmod +x $PREFIX/bin/stop-linux
    
    echo ""
    echo "========================================="
    echo "Installation complete!"
    echo "You are now running as a standard user."
    echo "Password for sudo is: ubuntu"
    echo "Use commands: start-linux / stop-linux"
    echo "========================================="
    read -p "Press Enter to return to menu..."
    show_menu
}

show_menu
