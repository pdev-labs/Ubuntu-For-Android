#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

if [ -z "$PREFIX" ]; then
    echo "Error: This script must be run inside Termux."
    exit 1
fi

echo "========================================="
echo "   Ubuntu for Termux Installer Wizard    "
echo "========================================="
echo ""
echo "Please select installation mode:"
echo "1) Automatic Installation (Presets)"
echo "2) Manual Installation (Custom Choices)"
read -p "Enter choice [1 or 2]: " MODE

DE="none"
VNC="no"
EXTRA_PKGS=""

if [ "$MODE" == "1" ]; then
    echo ""
    echo "--- Automatic Installation Presets ---"
    echo "1) Minimal (CLI only, no GUI)"
    echo "2) Medium (XFCE4 GUI + VNC + Wallpapers)"
    echo "3) Full (Medium + git, python3, curl, wget, nano, firefox)"
    read -p "Select preset [1-3]: " PRESET
    
    if [ "$PRESET" == "1" ]; then
        DE="none"
        VNC="no"
    elif [ "$PRESET" == "2" ]; then
        DE="xfce4"
        VNC="yes"
    elif [ "$PRESET" == "3" ]; then
        DE="xfce4"
        VNC="yes"
        EXTRA_PKGS="git python3 curl wget nano firefox"
    else
        echo "Invalid preset. Defaulting to Minimal."
        DE="none"
        VNC="no"
    fi
elif [ "$MODE" == "2" ]; then
    echo ""
    echo "--- Manual Installation ---"
    echo "Choose Desktop Environment:"
    echo "1) XFCE4 (Recommended, Lightweight)"
    echo "2) LXDE (Very Lightweight)"
    echo "3) None (CLI only)"
    read -p "Select DE [1-3]: " DE_CHOICE
    if [ "$DE_CHOICE" == "1" ]; then 
        DE="xfce4"
    elif [ "$DE_CHOICE" == "2" ]; then 
        DE="lxde"
    else 
        DE="none"
    fi
    
    if [ "$DE" != "none" ]; then
        echo ""
        echo "Do you want to install TigerVNC Server to access the GUI remotely?"
        read -p "Install VNC? [y/N]: " VNC_CHOICE
        if [[ "$VNC_CHOICE" =~ ^[Yy]$ ]]; then VNC="yes"; else VNC="no"; fi
    fi
    
    echo ""
    echo "Enter any extra packages you want to install (space separated)."
    echo "Example: git python3 htop nodejs"
    read -p "Extra packages (leave blank for none): " EXTRA_PKGS
else
    echo "Invalid choice. Exiting."
    exit 1
fi

echo ""
echo "========================================="
echo "Beginning Installation..."
echo "========================================="

echo "[*] Updating Termux packages..."
pkg update -y && pkg upgrade -y

echo "[*] Installing proot-distro..."
pkg install proot-distro -y

echo "[*] Installing Ubuntu..."
proot-distro install ubuntu

# Generate setup script
UBUNTU_ROOTFS="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"
SETUP_SCRIPT="$UBUNTU_ROOTFS/root/gui_setup.sh"

cat << 'EOF' > "$SETUP_SCRIPT"
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
echo " -> Updating Ubuntu repositories..."
apt-get update -y && apt-get upgrade -y
EOF

# Build package list based on user choices
APT_PKGS=""
if [ "$DE" == "xfce4" ]; then
    APT_PKGS="xfce4 xfce4-goodies dbus-x11 ubuntu-wallpapers"
elif [ "$DE" == "lxde" ]; then
    APT_PKGS="lxde dbus-x11"
fi

if [ "$VNC" == "yes" ]; then
    APT_PKGS="$APT_PKGS tigervnc-standalone-server expect"
fi

if [ -n "$EXTRA_PKGS" ]; then
    APT_PKGS="$APT_PKGS $EXTRA_PKGS"
fi

# Trim leading spaces
APT_PKGS=$(echo "$APT_PKGS" | xargs)

if [ -n "$APT_PKGS" ]; then
    cat << EOF >> "$SETUP_SCRIPT"
echo " -> Installing selected packages..."
apt-get install -y $APT_PKGS
EOF
fi

if [ "$VNC" == "yes" ]; then
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
echo " -> Creating XFCE4 VNC startup script..."
cat << 'STARTUP' > ~/.vnc/xstartup
#!/bin/sh
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
echo " -> Creating LXDE VNC startup script..."
cat << 'STARTUP' > ~/.vnc/xstartup
#!/bin/sh
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

echo "[*] Executing setup inside Ubuntu (this may take a while)..."
proot-distro login ubuntu -- bash /root/gui_setup.sh

echo "========================================="
echo "Installation complete!"
echo ""
if [ "$VNC" == "yes" ]; then
    echo "To start your Ubuntu Desktop, run:"
    echo "    proot-distro login ubuntu -- vncserver -geometry 1280x720 :1"
    echo ""
    echo "Then, open your VNC Viewer app and connect to:"
    echo "    Address: 127.0.0.1:5901"
    echo "    Password: ubuntu"
    echo ""
    echo "To stop the desktop when you are done, run:"
    echo "    proot-distro login ubuntu -- vncserver -kill :1"
else
    echo "To access your Ubuntu terminal, run:"
    echo "    proot-distro login ubuntu"
fi
echo "========================================="
