# Ubuntu for Android (Termux)

A fully automated, interactive bash script to install and configure Ubuntu on Android using Termux and `proot-distro`.

## Features
- **No Root Required:** Runs entirely in user space within Termux.
- **Interactive Wizard:** Choose between automatic presets or build a custom setup.
- **Graphical Desktop (GUI):** Automatically installs and configures XFCE4 or LXDE, TigerVNC, and the classic Ubuntu wallpaper.
- **Custom Packages:** Specify any extra Ubuntu packages you want installed right out of the box.

## Installation

1. Install [Termux](https://f-droid.org/en/packages/com.termux/) from F-Droid (do not use the Play Store version as it is outdated).
2. Download and run the script:
   ```bash
   pkg update -y && pkg install git -y
   git clone https://github.com/pdev-labs/ubuntu-for-android.git
   cd ubuntu-for-android
   chmod +x install_ubuntu.sh
   ./install_ubuntu.sh
   ```

## Usage

After installation, if you chose to install a GUI desktop:
1. Start the VNC server using the command provided at the end of the installation (e.g., `proot-distro login ubuntu -- vncserver -geometry 1280x720 :1`).
2. Open a VNC Viewer app on your Android device (like RealVNC or bVNC).
3. Connect to `127.0.0.1:5901` with the default password `ubuntu`.

To stop the desktop, run:
```bash
proot-distro login ubuntu -- vncserver -kill :1
```

If you installed the Minimal (CLI) version, simply run:
```bash
proot-distro login ubuntu
```

## License
MIT
