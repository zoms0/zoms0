# zoms0

## Install Typora on D: (Windows)

Install Typora to **`D:\Program Files (x86)\Typora`**, mirroring the usual
`C:\Program Files (x86)\...` layout onto the D: drive.

### One-shot (elevated)

1. Make sure the **D:** drive exists.
2. Right-click `scripts\Install-TyporaToD.bat` → **Run as administrator**.

Or in an elevated PowerShell:

```powershell
cd path\to\zoms0
.\scripts\Install-TyporaToD.ps1
```

### What it does

| Default Windows path | This script |
| --- | --- |
| `C:\Program Files (x86)\Typora` | `D:\Program Files (x86)\Typora` |

- Downloads the official installer from `download.typora.io`
- Silent Inno Setup install with `/DIR="D:\Program Files (x86)\Typora"`
- Defaults to x64 + all-users (`/ALLUSERS`); override with parameters if needed

### Options

```powershell
# Custom folder under D:
.\scripts\Install-TyporaToD.ps1 -InstallDir 'D:\Program Files (x86)\Typora'

# 32-bit installer (native Program Files (x86) package)
.\scripts\Install-TyporaToD.ps1 -Architecture ia32

# Current user only (no admin)
.\scripts\Install-TyporaToD.ps1 -AllUsers:$false
```

### Notes

- Typora is paid software; you still need a license after install.
- This Cloud Agent host is Linux and cannot run the Windows installer itself — run the script on your Windows PC.
