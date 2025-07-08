# MDM Scripts Collection

This repository contains a collection of scripts aimed at managing and configuring devices through MDM (Mobile Device Management) on both macOS and Windows platforms. Each script serves a specific function, from creating admin users to managing Find My Mac settings and fetching user information. Below is a summary of each script's purpose and usage.

## Scripts

### 1. Add_printers.ps1
A PowerShell script designed for Windows systems to automate the addition of printers. This can be useful in enterprise environments where multiple printers need to be configured on various machines.

- **Compatibility**: Windows

### 2. BidifenderON_Mac.sh
This script is used to install Bitdefender on macOS systems.

- **Compatibility**: macOS

### 3. Create Admin user on Mac.sh
A shell script creates an administrative user on a macOS system. 

- **Usage**: Run the script on macOS with root or administrator privileges.
- **Compatibility**: macOS

### 4. DisableFindMyMac_and_notify.sh
A script that disables the "Find My Mac" feature on macOS

- **Compatibility**: macOS

### 5. UserInfoOnMac.sh
This script retrieves user information on macOS, such as user names, IDs, and other relevant account data and sends it to email

- **Usage**: Execute via terminal with necessary permissions.
- **Compatibility**: macOS

### 6. UserInfoWin.ps1
A PowerShell script for gathering user information on Windows systems and sends it to email

- **Usage**: Run via PowerShell on a Windows machine.
- **Compatibility**: Windows
