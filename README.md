# Linux for Android (Termux) Manager

A fully automated, interactive bash script to install, manage, backup, and configure **Ubuntu, Debian, Arch Linux, Fedora, OpenSUSE, or Void Linux** on Android using Termux and `proot-distro`.

## Advanced Features
- **Multi-Distribution Support:** Choose your favorite flavor of Linux! The script automatically handles the different package managers (apt, pacman, dnf, zypper, xbps).
- **No Root Required:** Runs entirely in user space within Termux.
- **Hardware Acceleration (Termux:X11):** Offers a choice between VNC (software rendering) and Termux:X11 for a much smoother, hardware-accelerated desktop experience.
- **Audio Support:** Automatically installs and configures PulseAudio so you can hear sound from your Linux environment.
- **Quick-Launch Commands:** Automatically generates `start-linux` and `stop-linux` commands. You can type them anywhere in Termux to boot up or shut down your desktop!
- **Backup & Restore:** Built-in menu options to backup your entire Linux system to your internal storage, and restore it later.
- **Uninstaller:** Easily delete the Linux environment to free up space with a single button.
- **SD Card Access:** Automatically links your phone's internal storage directly into `/root/storage` in Linux.

## Installation

1. Install [Termux](https://f-droid.org/en/packages/com.termux/) from F-Droid (do not use the Play Store version as it is outdated).
2. Download and run the script:
   ```bash
   pkg update -y && pkg install git -y
   git clone https://github.com/pdev-labs/Ubuntu-For-Android.git
   cd Ubuntu-For-Android
   chmod +x install_linux.sh
   ./install_linux.sh
   ```

## Usage

When you run `./install_linux.sh`, it will launch a Manager Menu where you can Install, Backup, Restore, or Uninstall any supported distribution.

After you have installed Linux through the manager, you never have to run the long startup commands manually again.

**To Start Linux:**
Just type this anywhere in Termux:
```bash
start-linux
```
*(Then, open your VNC Viewer or Termux:X11 app depending on what you chose during installation).*

**To Stop Linux:**
Just type this anywhere in Termux:
```bash
stop-linux
```

## ⚠️ Troubleshooting: Phantom Process Killer (Android 12+)

Starting in Android 12, the Android operating system aggressively limits the number of child processes an app can run in the background. Because a full Linux desktop environment requires many concurrent processes, Android may suddenly kill Termux while you are using Linux.

### How to check if you are affected
If you are affected by this issue, Termux will abruptly close while you are working in your GUI, and when you re-open Termux, you will see this error message in the terminal:
> `[Process completed (signal 9) - press Enter]`

### How to Fix (Android 14 and newer)
If you are on Android 14 or a recent Android 13 device, you can completely disable this restriction natively from the Developer Options.

**Step 1: Enable Developer Options**
1. Open your device **Settings**.
2. Scroll down and tap on **About phone**.
3. Find the **Build number** entry (on some devices, it's under 'Software information').
4. Tap the **Build number** quickly 7 times in a row.
5. Enter your lock screen PIN when prompted. You should see a toast message saying "You are now a developer!".

**Step 2: Disable Child Process Restrictions**
1. Go back to the main **Settings** menu.
2. Tap on **System** (or scroll to the very bottom) and open **Developer options**.
3. Scroll down the list until you find the toggle named **Disable child process restrictions**.
4. Turn this toggle **ON**.
5. Restart Termux. You will no longer experience signal 9 crashes!

*(Note: If you are on an older Android 12/12L/13 device that does not have this toggle, you will need to use ADB commands to disable the Phantom Process Killer. Search "Termux ADB disable phantom process" for guides specific to your device).*

## License
MIT
