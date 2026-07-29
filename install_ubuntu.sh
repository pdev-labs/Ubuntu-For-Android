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
    echo "      Ubuntu for Termux Manager          "
    echo "========================================="
    echo "1) Install / Re-install Ubuntu"
    echo "2) Backup Ubuntu"
    echo "3) Restore Ubuntu"
    echo "4) Uninstall Ubuntu"
    echo "5) Exit"
    echo "========================================="
    read -p "Select an option [1-5]: " OPTION
    case $OPTION in
        1) install_ubuntu ;;
        2) backup_ubuntu ;;
        3) restore_ubuntu ;;
        4) uninstall_ubuntu ;;
        5) exit 0 ;;
        *) echo "Invalid option"; sleep 1; show_menu ;;
    esac
}

backup_ubuntu() {
    echo ""
    echo "[*] Backing up Ubuntu..."
    echo "This may take a few minutes depending on the size of your installation."
    proot-distro backup ubuntu --output ~/ubuntu-backup.tar.gz
    echo "Backup successfully saved to ~/ubuntu-backup.tar.gz"
    read -p "Press Enter to continue..."
    show_menu
}

restore_ubuntu() {
    echo ""
    if [ ! -f ~/ubuntu-backup.tar.gz ]; then
        echo "Error: No backup found at ~/ubuntu-backup.tar.gz"
    else
        echo "[*] Restoring Ubuntu..."
        echo "WARNING: This will overwrite your current Ubuntu installation."
        read -p "Are you sure? [y/N]: " CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            proot-distro restore ubuntu --input ~/ubuntu-backup.tar.gz
            echo "Restore complete!"
        else
            echo "Restore cancelled."
        fi
    fi
    read -p "Press Enter to continue..."
    show_menu
}

uninstall_ubuntu() {
    echo ""
    echo "WARNING: This will completely delete Ubuntu and all data inside it!"
    read -p "Are you sure you want to uninstall? [y/N]: " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "[*] Uninstalling Ubuntu..."
        proot-distro remove ubuntu || true
        rm -f $PREFIX/bin/start-ubuntu $PREFIX/bin/stop-ubuntu
        echo "Ubuntu has been removed."
    else
        echo "Uninstall cancelled."
    fi
    read -p "Press Enter to continue..."
    show_menu
}

install_ubuntu() {
    echo ""
    echo "========================================="
    echo "   Ubuntu Installation Wizard            "
    echo "========================================="
    
    DE="none"
    SERVER="none"
    EXTRA_PKGS=""
    
    echo "Choose Desktop Environment:"
    echo "1) XFCE4 (Recommended, Lightweight GUI)"
    echo "2) LXDE (Very Lightweight GUI)"
    echo "3) None (CLI only)"
    read -p "Select DE [1-3]: " DE_CHOICE
    if [ "$DE_CHOICE" == "1" ]; then DE="xfce4"; elif [ "$DE_CHOICE" == "2" ]; then DE="lxde"; else DE="none"; fi
    
    if [ "$DE" != "none" ]; then
        echo ""
        echo "Choose Display Server:"
        echo "1) Termux:X11 (Hardware Acceleration, Faster, Requires Termux:X11 App)"
        echo "2) VNC (Software Rendering, Slower, Requires VNC Viewer App)"
        read -p "Select Server [1-2]: " SRV_CHOICE
        if [ "$SRV_CHOICE" == "1" ]; then SERVER="x11"; else SERVER="vnc"; fi
    fi
    
    echo ""
    echo "Enter any extra packages you want to install (space separated)."
    echo "Example: git python3 htop nodejs"
    read -p "Extra packages (leave blank for none): " EXTRA_PKGS
    
    echo ""
    echo "========================================="
    echo "Beginning Installation..."
    echo "========================================="

    echo "[*] Requesting Android Storage Permission..."
    termux-setup-storage || true
    sleep 2
    
    echo "[*] Updating Termux packages..."
    pkg update -y && pkg upgrade -y
    
    echo "[*] Installing dependencies (proot-distro, pulseaudio)..."
    pkg install proot-distro pulseaudio -y
    
    if [ "$SERVER" == "x11" ]; then
        echo "[*] Installing Termux:X11 packages..."
        pkg install x11-repo -y
        pkg install termux-x11-nightly -y
    fi
    
    echo "[*] Installing Ubuntu (this will download the rootfs)..."
    proot-distro install ubuntu
    
    UBUNTU_ROOTFS="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"
    SETUP_SCRIPT="$UBUNTU_ROOTFS/root/gui_setup.sh"
    
    cat << 'EOF' > "$SETUP_SCRIPT"
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
echo " -> Updating Ubuntu repositories..."
apt-get update -y && apt-get upgrade -y
EOF
    
    APT_PKGS=""
    if [ "$DE" == "xfce4" ]; then
        APT_PKGS="xfce4 xfce4-goodies dbus-x11 ubuntu-wallpapers"
    elif [ "$DE" == "lxde" ]; then
        APT_PKGS="lxde dbus-x11"
    fi
    
    if [ "$SERVER" == "vnc" ]; then
        APT_PKGS="$APT_PKGS tigervnc-standalone-server expect"
    fi
    
    if [ -n "$EXTRA_PKGS" ]; then
        APT_PKGS="$APT_PKGS $EXTRA_PKGS"
    fi
    
    APT_PKGS=$(echo "$APT_PKGS" | xargs)
    
    if [ -n "$APT_PKGS" ]; then
        cat << EOF >> "$SETUP_SCRIPT"
echo " -> Installing selected packages inside Ubuntu..."
apt-get install -y $APT_PKGS
EOF
    fi
    
    # SD Card Symlink
    cat << 'EOF' >> "$SETUP_SCRIPT"
echo " -> Linking Android Internal Storage..."
mkdir -p /root/storage
# Attempt to link if Termux storage is available
if [ -d /data/data/com.termux/files/home/storage ]; then
    ln -sf /data/data/com.termux/files/home/storage/* /root/storage/
fi
EOF
    
    if [ "$SERVER" == "vnc" ]; then
        cat << 'EOF' >> "$SETUP_SCRIPT"
echo " -> Configuring VNC Password (default: ubuntu)..."
mkdir -p ~/.vnc
expect << 'EOD'
spawn vncpasswd
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
cat << 'STARTUP' > ~/.vnc/xstartup
#!/bin/sh
export PULSE_SERVER=127.0.0.1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
xrdb $HOME/.Xresources
startxfce4 &
(sleep 5 && xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /usr/share/backgrounds/warty-final-ubuntu.png) &
STARTUP
chmod +x ~/.vnc/xstartup
EOF
        elif [ "$DE" == "lxde" ]; then
            cat << 'EOF' >> "$SETUP_SCRIPT"
cat << 'STARTUP' > ~/.vnc/xstartup
#!/bin/sh
export PULSE_SERVER=127.0.0.1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
xrdb $HOME/.Xresources
startlxde &
STARTUP
chmod +x ~/.vnc/xstartup
EOF
        fi
    fi
    
    cat << 'EOF' >> "$SETUP_SCRIPT"
echo " -> Internal setup complete."
EOF
    
    echo "[*] Executing setup inside Ubuntu (this will take a while)..."
    proot-distro login ubuntu -- bash /root/gui_setup.sh
    
    echo "[*] Generating Quick-Launch Scripts..."
    cat << EOF > $PREFIX/bin/start-ubuntu
#!/bin/bash
echo "Starting PulseAudio..."
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
EOF
    if [ "$SERVER" == "x11" ]; then
        cat << EOF >> $PREFIX/bin/start-ubuntu
echo "Starting Termux:X11..."
termux-x11 :1 &
sleep 2
echo "Starting Ubuntu..."
proot-distro login ubuntu --shared-tmp -- bash -c "export PULSE_SERVER=127.0.0.1; export DISPLAY=:1; start${DE} &"
EOF
    elif [ "$SERVER" == "vnc" ]; then
        cat << 'EOF' >> $PREFIX/bin/start-ubuntu
echo "Starting VNC Server..."
proot-distro login ubuntu --shared-tmp -- bash -c "export PULSE_SERVER=127.0.0.1; vncserver -geometry 1280x720 :1"
EOF
    elif [ "$DE" == "none" ]; then
        cat << 'EOF' >> $PREFIX/bin/start-ubuntu
echo "Starting Ubuntu CLI..."
proot-distro login ubuntu --shared-tmp
EOF
    fi
    chmod +x $PREFIX/bin/start-ubuntu
    
    cat << 'EOF' > $PREFIX/bin/stop-ubuntu
#!/bin/bash
echo "Stopping PulseAudio..."
pulseaudio -k 2>/dev/null || true
EOF
    if [ "$SERVER" == "x11" ]; then
        cat << 'EOF' >> $PREFIX/bin/stop-ubuntu
echo "Stopping Termux:X11..."
killall termux-x11 2>/dev/null || true
EOF
    elif [ "$SERVER" == "vnc" ]; then
        cat << 'EOF' >> $PREFIX/bin/stop-ubuntu
echo "Stopping VNC Server..."
proot-distro login ubuntu --shared-tmp -- bash -c "vncserver -kill :1" 2>/dev/null || true
EOF
    fi
    chmod +x $PREFIX/bin/stop-ubuntu
    
    echo ""
    echo "========================================="
    echo "Installation complete!"
    echo "You can now use the following commands anywhere in Termux:"
    echo "  start-ubuntu  <- Starts the Desktop/CLI and Audio"
    echo "  stop-ubuntu   <- Stops the Desktop and Audio"
    echo "========================================="
    read -p "Press Enter to return to menu..."
    show_menu
}

# Start the script
show_menu
