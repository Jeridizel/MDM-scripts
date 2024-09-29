# MDM Scripts Collection

This repository contains a collection of scripts aimed at managing and configuring devices through MDM (Mobile Device Management) on both macOS and Windows platforms. Each script serves a specific function, from creating admin users to managing Find My Mac settings and fetching user information. Below is a summary of each script's purpose and usage.

## Scripts

### 1. Add_printers.ps1
A PowerShell script designed for Windows systems to automate the addition of printers. This can be useful in enterprise environments where multiple printers need to be configured on various machines.

- **Usage**: Run via PowerShell with administrator privileges.
- **Compatibility**: Windows

### 2. BidifenderON_Mac.sh
This script is used to enable or configure Bitdefender on macOS systems. It might include commands to install or activate Bitdefender services.

- **Usage**: Run via terminal with necessary permissions.
- **Compatibility**: macOS

### 3. Create Admin user on Mac.sh
A shell script to create an administrative user on a macOS system. This can be useful for MDM workflows where admin access needs to be granted remotely.

- **Usage**: Run the script on macOS with root or administrator privileges.
- **Compatibility**: macOS

### 4. DisableFindMyMac_and_notify.sh
A script that disables the "Find My Mac" feature on macOS and potentially sends a notification. This could be used in scenarios where devices are repurposed or handed off to new users.

- **Usage**: Run via terminal with appropriate permissions.
- **Compatibility**: macOS

### 5. UserInfoOnMac.sh
This script retrieves user information on macOS, such as user names, IDs, and other relevant account data. It helps in monitoring and managing users on Mac systems.

- **Usage**: Execute via terminal with necessary permissions.
- **Compatibility**: macOS

### 6. UserInfoWin.ps1
A PowerShell script for gathering user information on Windows systems. It collects details such as usernames and user IDs, aiding in user management.

- **Usage**: Run via PowerShell on a Windows machine.
- **Compatibility**: Windows
