# Linux for Android (Termux) Manager

A fully automated, interactive bash script to install, manage, backup, share, update, and configure **Ubuntu, Debian, Arch Linux, Fedora, OpenSUSE, or Void Linux** on Android using Termux and `proot-distro`.

## The Ultimate Features
- **Multi-Distribution Support:** Choose your favorite flavor of Linux! The script automatically handles the different package managers (apt, pacman, dnf, zypper, xbps).
- **True Linux Experience (Sudo):** Unlike standard Termux environments, this installer sets up a proper non-root user (`user`) with `sudo` privileges. You must use `sudo` to install packages, just like a real PC!
- **Portable Export & Import (Share with Friends!):** Easily export your fully customized Linux OS as a `.tar.gz` file into your Android `Downloads` folder to share with friends. They can place the file in their `Downloads` folder and use the new "Import" button to instantly copy your exact setup!
- **Dynamic Display Settings:** When installing with VNC, you can now dynamically pick your screen resolution and UI scaling (Auto, 720p, 1080p, or Tablet size) to perfectly fit your device.
- **VirGL Hardware Acceleration:** Automatically installs and starts `virglrenderer-android`, passing 3D OpenGL rendering directly to your phone's physical GPU for incredibly smooth graphics.
- **Home-Screen Widgets:** Automatically generates a `Start-Linux` shortcut. If you use the `Termux:Widget` Android app, you can launch your Linux desktop with one tap straight from your phone's home screen!
- **1-Click Universal Updater:** Never type `apt update` again! The Manager Menu includes an option to automatically detect your distro and update it in the background.
- **System Dashboard:** Instantly view your Android phone's RAM availability, Termux storage consumption, and CPU architecture right from the manager menu!
- **Advanced Audio Fixer:** A built-in debugger that dynamically restarts PulseAudio and forcefully binds it to TCP protocols to instantly resolve any audio crackling issues on problematic devices.
- **Instant SSH Server:** Start a native SSH server on port 8022 directly from the Manager Menu, allowing you to seamlessly remote into your phone from your PC.
- **Hardware Acceleration (Termux:X11):** Offers a choice between VNC (software rendering) and Termux:X11 for a much smoother, hardware-accelerated desktop experience.

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

When you run `./install_linux.sh`, it will launch a Manager Menu where you can Install, Update, SSH, view the Dashboard, Export, Import, Backup, Restore, or Uninstall any supported distribution.

**To Start Linux:**
Just type this anywhere in Termux:
```bash
start-linux
```
*(If you installed multiple OSs, it will automatically pop up a menu asking which one you want to boot!)*

**Default Credentials:**
- **Username:** `user`
- **Sudo / VNC Password:** `ubuntu`

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
