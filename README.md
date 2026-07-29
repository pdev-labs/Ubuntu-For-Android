<div align="center">
  <h1>🐧 Linux for Android Manager</h1>
  <p><b>The ultimate automated script to install, manage, and configure a full Linux desktop environment on Android via Termux.</b></p>
  <p>
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Termux-blue?style=for-the-badge&logo=android" alt="Platform">
    <img src="https://img.shields.io/badge/Language-Bash-green?style=for-the-badge&logo=gnu-bash" alt="Language">
    <img src="https://img.shields.io/badge/License-GPL%203.0-orange?style=for-the-badge&logo=gnu" alt="License">
  </p>
</div>

<hr>

## 📖 Table of Contents
- [About the Project](#-about-the-project)
- [Key Features](#-key-features)
- [Installation](#-installation)
- [Usage Guide](#-usage-guide)
- [Troubleshooting](#-troubleshooting-phantom-process-killer)
- [Contributing](#-contributing)
- [License](#-license)

## 🌟 About the Project

Turning your Android device into a full-fledged Linux workstation has never been easier. **Linux for Android Manager** is a fully automated, interactive bash script that wraps around `proot-distro` to install, manage, backup, share, update, and configure highly customized graphical Linux environments directly on your smartphone or tablet.

Currently supported distributions:
- **Ubuntu** (apt)
- **Debian** (apt)
- **Kali Linux** (apt)
- **Arch Linux** (pacman)
- **Fedora** (dnf)
- **OpenSUSE** (zypper)
- **Void Linux** (xbps)

## 🚀 Key Features

### The Ultimate Experience
- **True Linux Experience (Sudo):** Sets up a proper non-root user (`user`) with `sudo` privileges. Install packages just like on a real PC!
- **VirGL 3D Hardware Acceleration:** Automatically configures `virglrenderer-android`, passing 3D OpenGL rendering directly to your phone's physical GPU for incredibly smooth graphics.
- **Hardware Acceleration (Termux:X11):** Choose between traditional VNC (software rendering) or Termux:X11 for a much smoother, hardware-accelerated desktop experience.
- **Dynamic Display Settings:** Dynamically pick your screen resolution and UI scaling (Auto, 720p, 1080p, or Tablet size) to perfectly fit your device.

### Automation & Management
- **1-Click Universal Updater:** Never manually type update commands again! The Manager Menu automatically detects your distro and updates it in the background.
- **System Dashboard:** Instantly view your Android phone's RAM availability, Termux storage consumption, and CPU architecture right from the manager menu.
- **Advanced Audio Fixer:** A built-in debugger that dynamically restarts PulseAudio and forcefully binds it to TCP protocols to instantly resolve any audio crackling issues.
- **Instant SSH Server:** Start a native SSH server on port 8022 directly from the menu, allowing you to seamlessly remote into your phone from your PC.

### Portability & Convenience
- **Portable Export & Import (Share with Friends!):** Export your fully customized Linux OS as a `.tar.gz` file into your Android `Downloads` folder. Your friends can place the file in their `Downloads` folder and use the "Import" button to instantly clone your exact setup!
- **Home-Screen Widgets:** If you use the `Termux:Widget` app, the script automatically generates a shortcut so you can launch your Linux desktop with one tap straight from your Android home screen!

## ⚙️ Installation

### Prerequisites
1. Download and install [Termux](https://f-droid.org/en/packages/com.termux/) from **F-Droid**. 
   > ⚠️ **Warning:** Do NOT use the Google Play Store version of Termux, as it is outdated and severely broken.

### Quick Start
Copy and paste this snippet into your Termux terminal:

```bash
pkg update -y && pkg install git -y
git clone https://github.com/pdev-labs/Ubuntu-For-Android.git
cd Ubuntu-For-Android
chmod +x install_linux.sh
./install_linux.sh
```

## 💻 Usage Guide

When you run `./install_linux.sh`, it will launch the interactive Manager Menu where you can Install, Update, SSH, view the Dashboard, Export, Import, Backup, Restore, or Uninstall any supported distribution.

### Starting your Linux Desktop
Once installed, you never need to run the setup script again. Just type this anywhere in Termux:
```bash
start-linux
```
*(If you installed multiple OSs, it will automatically pop up a menu asking which one you want to boot!)*

### Default Credentials
- **Username:** `user`
- **Password (Sudo / VNC):** `ubuntu`

### Stopping your Linux Desktop
To safely kill the desktop, display servers, and audio systems, type:
```bash
stop-linux
```

## 🛠️ Troubleshooting (Phantom Process Killer)

Starting in Android 12, the Android OS aggressively limits the number of child processes an app can run in the background. Because a full Linux desktop environment requires many concurrent processes, Android may suddenly kill Termux while you are using Linux.

**Symptom:** Termux abruptly closes while you are working. When you reopen it, you see `[Process completed (signal 9) - press Enter]`.

### How to Fix (Android 14+ / recent 13)
1. Open your Android **Settings** > **About phone**.
2. Tap the **Build number** 7 times to enable Developer Options.
3. Go back to the main **Settings** menu > **System** > **Developer options**.
4. Scroll down and toggle **Disable child process restrictions** to **ON**.
5. Restart Termux.

*(Note: For older Android 12/12L devices without this toggle, you will need to run an ADB command from a PC to disable the Phantom Process Killer. Search for "Termux ADB disable phantom process" for guides specific to your device).*

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! 
If you want to improve this project, please fork the repository and submit a pull request.

## 📝 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**. 
Any derivatives, forks, or modifications of this project must also remain open-source and be distributed under the same license.
