# Ubuntu for Android (Termux) Manager

A fully automated, interactive bash script to install, manage, backup, and configure Ubuntu on Android using Termux and `proot-distro`.

## Advanced Features
- **No Root Required:** Runs entirely in user space within Termux.
- **Hardware Acceleration (Termux:X11):** Offers a choice between VNC (software rendering) and Termux:X11 for a much smoother, hardware-accelerated desktop experience.
- **Audio Support:** Automatically installs and configures PulseAudio so you can hear sound from your Ubuntu environment.
- **Quick-Launch Commands:** Automatically generates `start-ubuntu` and `stop-ubuntu` commands. You can type them anywhere in Termux to boot up or shut down your desktop!
- **Backup & Restore:** Built-in menu options to backup your entire Ubuntu system to your internal storage, and restore it later.
- **Uninstaller:** Easily delete the Ubuntu environment to free up space with a single button.
- **SD Card Access:** Automatically links your phone's internal storage directly into `/root/storage` in Ubuntu.

## Installation

1. Install [Termux](https://f-droid.org/en/packages/com.termux/) from F-Droid (do not use the Play Store version as it is outdated).
2. Download and run the script:
   ```bash
   pkg update -y && pkg install git -y
   git clone https://github.com/pdev-labs/Ubuntu-For-Android.git
   cd Ubuntu-For-Android
   chmod +x install_ubuntu.sh
   ./install_ubuntu.sh
   ```

## Usage

When you run `./install_ubuntu.sh`, it will launch a Manager Menu where you can Install, Backup, Restore, or Uninstall.

After you have installed Ubuntu through the manager, you never have to run the long startup commands manually again.

**To Start Ubuntu:**
Just type this anywhere in Termux:
```bash
start-ubuntu
```
*(Then, open your VNC Viewer or Termux:X11 app depending on what you chose during installation).*

**To Stop Ubuntu:**
Just type this anywhere in Termux:
```bash
stop-ubuntu
```

## License
MIT
