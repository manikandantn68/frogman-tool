```
  +--------------------------------------------------------------+
  |        WMI AUDIT  .  FROGMAN CYBER TOOL  .  600+ CMDS       |
  |           AUTHOR: MANIKANDAN  |  TEL: 9787091093             |
  +--------------------------------------------------------------+
        @..@
       ( -__- )
      (  >_____<  )
      ^^  ~~~~~~  ^^
   [ FROGMAN IS WATCHING YOU ]
```

# 🐸 WMI Frogman Cyber Tool v1

> **The ultimate Windows WMI-based security audit and threat detection framework.**  
> 600+ commands | 200+ MITRE ATT&CK TTPs | Remote WMI | Live Dashboard | Multi-format Export

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)
![Platform](https://img.shields.io/badge/Platform-Windows-blue?logo=windows)
![License](https://img.shields.io/badge/License-GPL%20v3-green)
![Author](https://img.shields.io/badge/Author-MANIKANDAN-red)
![Version](https://img.shields.io/badge/Version-v18-orange)

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Menu Reference](#-menu-reference)
- [Command Modules](#-command-modules)
- [Remote WMI Mode](#-remote-wmi-mode)
- [Live Dashboard](#-live-dashboard)
- [Export Formats](#-export-formats)
- [MITRE ATT&CK Mapping](#-mitre-attck-mapping)
- [Risk Scoring](#-risk-scoring)
- [Parameters](#-parameters)
- [Screenshots](#-screenshots)
- [Legal & Disclaimer](#-legal--disclaimer)
- [License](#-license)
- [Author](#-author)

---

## 🔍 Overview

**WMI Frogman** is a comprehensive PowerShell-based Windows security auditing framework that leverages Windows Management Instrumentation (WMI) and CIM (Common Information Model) to perform deep system reconnaissance, threat detection, and security assessment — both locally and remotely across a network.

Built for **security professionals, red/blue teamers, penetration testers, and system administrators**, Frogman provides an interactive terminal interface with 600+ audit commands, automatic MITRE ATT&CK mapping, risk scoring, and professional multi-format reporting.

---

## ✨ Features

| Feature | Details |
|---|---|
| 🔢 **600+ WMI/CIM Commands** | Organised across 19 audit modules |
| 🎯 **200+ MITRE ATT&CK TTPs** | Auto-mapped to findings |
| 🌐 **Remote WMI Support** | Audit remote hosts, subnet scan, host list |
| 📊 **Live Dashboard** | Real-time CPU/RAM/Disk/Threat monitoring |
| 📄 **Multi-format Export** | HTML, PDF, JSON, CSV, YAML |
| 🔴 **Risk Scoring** | Automated 0–100 risk score with severity levels |
| 🕵️ **Threat Detection** | WMI persistence, suspicious processes, backdoors |
| 🏢 **Active Directory Recon** | Full AD enumeration module |
| ☁️ **Cloud Detection** | AWS/Azure/GCP metadata detection |
| 🌐 **Browser Artifacts** | Chrome, Firefox, Edge artifact hunting |
| 🔒 **CVE / Patch Matching** | Missing patch and CVE correlation |
| 🎨 **Dynamic UI** | Random banners, color themes, matrix intro |
| ⏩ **Skip Support** | Press `S` before slow commands to skip |

---

## 📋 Requirements

| Requirement | Minimum | Recommended |
|---|---|---|
| **OS** | Windows 7 / Server 2008 R2 | Windows 10/11 / Server 2019+ |
| **PowerShell** | 5.1 | 7.x |
| **Privileges** | Standard user (limited) | **Administrator** (full audit) |
| **WMI Service** | Must be running | Must be running |
| **Remote WMI** | WMI service + firewall exception on target | Same + DCOM configured |

> ⚠️ **Run as Administrator** for complete results. Some WMI classes require elevated privileges.

---

## 🚀 Installation

### Option 1 — Direct Download

```powershell
# Clone or download frogman.ps1 to your machine
# No installation required — single script, no dependencies
```

### Option 2 — GitHub Clone

```bash
git clone https://github.com/YOUR_USERNAME/wmi-frogman.git
cd wmi-frogman
```

### Enable Script Execution (if needed)

```powershell
# Run once in elevated PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 💻 Usage

### Basic — Local Audit (Interactive)

```powershell
# Run as Administrator for best results
.\frogman.ps1
```

### With Save Location Pre-set

```powershell
.\frogman.ps1 -SaveLocation "C:\AuditReports"
```

### Remote Target

```powershell
.\frogman.ps1 -Target 192.168.1.50
.\frogman.ps1 -Target DC01 -TargetUser "DOMAIN\Administrator"
```

### Launch Directly to Live Dashboard

```powershell
.\frogman.ps1 -Dashboard
.\frogman.ps1 -Dashboard -RefreshSeconds 10
```

---

## 📋 Menu Reference

```
------------------------------------------------------------------
  SELECT AUDIT CATEGORY
  TARGET: LOCAL (DESKTOP-XXXXXXX)
------------------------------------------------------------------
  1   System Info              (Cmds 1-30)
  2   User and Group           (Cmds 31-60)
  3   Service and Driver       (Cmds 61-85)
  4   Process and Memory       (Cmds 86-110)
  5   Network and Shares       (Cmds 111-125)
  6   Privilege Access         (Cmds 126-200)
  7   WMI/CIM Advanced         (Cmds 201-300)
  8   Storage and Disk         (Cmds 301-340)
  9   Security and Firewall    (Cmds 341-380)
 10   Registry and Config      (Cmds 381-420)
 11   Hardware Peripherals     (Cmds 421-460)
 12   Software and Apps        (Cmds 461-500)
 13   Tasks, Logs and Audit    (Cmds 501-540)
 14   Certificates/Crypto      (Cmds 541-570)
 15   Persistence/Lateral      (Cmds 571-600)

 16   Active Directory Recon
 17   Cloud Metadata Detection
 18   Browser Artifacts
 19   CVE / Patch Matching

  B   RUN ALL 600 COMMANDS
  C   THREAT DETECTION
  D   EXPORT (HTML / PDF / JSON / CSV / YAML + Risk Score + MITRE)
  L   LIVE DASHBOARD MODE  [auto-refresh]
  R   SET REMOTE TARGET    [network scan / remote WMI]
  Q   EXIT
------------------------------------------------------------------
```

---

## 🗂️ Command Modules

### 1️⃣ System Info (Cmds 1–30)
OS version, BIOS, motherboard, UUID, physical memory, network adapters, environment PATH, logical disks, boot config, PCI/USB/PnP devices, video controller, sound devices, page file, and more.

### 2️⃣ User and Group (Cmds 31–60)
Local/domain user accounts, group memberships, logon sessions, account policies, password requirements, SID enumeration, account age, last logon times.

### 3️⃣ Service and Driver (Cmds 61–85)
Running services, auto-start services, stopped auto services, unquoted service paths, service permissions, driver enumeration, kernel drivers, signed/unsigned drivers.

### 4️⃣ Process and Memory (Cmds 86–110)
Running processes, process owners, process command lines, memory usage, parent-child process trees, process creation times, handles and threads.

### 5️⃣ Network and Shares (Cmds 111–125)
Active TCP/UDP connections, open shares, network adapters, DNS settings, WINS, ARP cache, routing tables, open ports.

### 6️⃣ Privilege Access (Cmds 126–200)
User rights, privilege assignments, UAC status, local security policy, account lockout, audit policies, firewall state, event logs config.

### 7️⃣ WMI/CIM Advanced (Cmds 201–300)
WMI event filters, event consumers, consumer bindings, WMI namespaces, CIM storage, CIM partitions, CIM firewall rules, CIM TCP connections, scheduled tasks, shadow copies, disk quotas.

### 8️⃣ Storage and Disk (Cmds 301–340)
Disk drives, partitions, volumes, BitLocker status, SMART data, iSCSI, RAID, removable media, disk quotas.

### 9️⃣ Security and Firewall (Cmds 341–380)
Firewall profiles (Domain/Private/Public), inbound/outbound rules, Windows Defender status, antivirus products, security event log analysis.

### 🔟 Registry and Config (Cmds 381–420)
Auto-run registry keys, RunOnce, RunServices, LSA settings, audit policy registry, UAC registry values, RDP config, WinRM config.

### 1️⃣1️⃣ Hardware Peripherals (Cmds 421–460)
Printers, pointing devices, sound cards, video adapters, USB history, Bluetooth devices, scanners, monitors.

### 1️⃣2️⃣ Software and Apps (Cmds 461–500)
Installed software, recent updates, Windows Store apps, MSI packages, software by publisher, program install dates.

### 1️⃣3️⃣ Tasks, Logs and Audit (Cmds 501–540)
Scheduled tasks, event log files, event log sizes, Windows logs, application/security/system event counts, task status.

### 1️⃣4️⃣ Certificates / Crypto (Cmds 541–570)
Certificate stores, expired certs, self-signed certs, code-signing certs, root CA, BitLocker recovery keys, EFS config.

### 1️⃣5️⃣ Persistence / Lateral Movement (Cmds 571–600)
WMI persistence subscriptions, startup folders, scheduled task persistence, registry run keys, DLL hijack paths, service hijack candidates.

### 🏢 Active Directory Recon (Module 16)
Domain info, domain controllers, AD users, AD groups, Group Policy Objects, FSMO roles, trust relationships, password policy, Kerberos policy.

### ☁️ Cloud Detection (Module 17)
AWS instance metadata (169.254.169.254), Azure IMDS, GCP metadata endpoints — detects cloud environment automatically.

### 🌐 Browser Artifacts (Module 18)
Chrome history/profile paths, Firefox profile detection, Edge artifacts — session data and profile enumeration.

### 🔒 CVE / Patch Matching (Module 19)
Installed hotfixes, missing patches, KB correlation, build number vs known CVE list matching.

---

## 🌐 Remote WMI Mode

Press `R` from the main menu to configure a remote target:

```
[1] Local machine (default)
[2] Enter remote IP / hostname
[3] Scan subnet  (e.g. 192.168.1.0/24)
[4] Scan from host list file
```

### Subnet Scan Example
```
Enter subnet: 192.168.1
→ Scans 192.168.1.1 - 192.168.1.254
→ Lists all live WMI-accessible Windows hosts
→ Select a host to target
```

### Host List File
```
# hosts.txt
192.168.1.10
192.168.1.20
SERVER01
DC01
```

### Remote Requirements on Target
```powershell
# Enable WMI through firewall on target
netsh advfirewall firewall set rule group="Windows Management Instrumentation (WMI)" new enable=yes

# Enable WinRM (optional, for CIM sessions)
Enable-PSRemoting -Force
```

---

## 📊 Live Dashboard

Press `L` or launch with `-Dashboard` flag for a real-time monitoring view:

```
+------------------------------------------------------------------+
  FROGMAN   LIVE DASHBOARD   Target: DESKTOP-B0SPC9T   14:32:55
+------------------------------------------------------------------+
  CPU Load  :  23%  [####----------------]
  RAM Used  :  67%  [#############-------]
  RAM       :   5.3GB / 7.9GB
  Disks     :
    C:   78% used  [################----]
  Network   :
    Intel(R) Ethernet  IP: 192.168.1.100
  Top 5 Procs (Memory):
    chrome.exe             312.4 MB
    explorer.exe            89.2 MB
  Services  :  142 running  |  0 auto not-running
  Threats   :  SuspPS=0  WMI_Subscriptions=0
------------------------------------------------------------------
  [Refreshing in 30s -- Press Q to exit dashboard]
```

**Press `Q` at any time to exit the dashboard.**

---

## 📤 Export Formats

Press `D` from the main menu to export. Available formats:

| Format | Contents |
|---|---|
| **HTML** | Full styled report with risk gauge, MITRE table, all findings |
| **PDF** | Auto-generated from HTML using Chrome/Edge headless |
| **JSON** | Structured machine-readable data — all audit results |
| **CSV** | Spreadsheet-compatible, one file per module |
| **YAML** | Human-readable structured format |
| **ALL** | Generates all 5 formats simultaneously |

### Export Includes:
- ✅ Full audit data from all collected commands
- ✅ Risk Score (0–100) with severity level
- ✅ MITRE ATT&CK technique mapping
- ✅ Timestamp and target hostname in filename

### Output Filename Format:
```
WMIFrogman_DESKTOP-B0SPC9T_20260303_022319.html
WMIFrogman_DESKTOP-B0SPC9T_20260303_022319.pdf
```

---

## 🎯 MITRE ATT&CK Mapping

Frogman automatically maps findings to **200+ MITRE ATT&CK techniques** including:

| Technique ID | Technique Name | Frogman Module |
|---|---|---|
| T1047 | Windows Management Instrumentation | Modules 7, 15 |
| T1543 | Create or Modify System Process | Module 3 |
| T1053 | Scheduled Task/Job | Module 13 |
| T1012 | Query Registry | Module 10 |
| T1057 | Process Discovery | Module 4 |
| T1049 | System Network Connections Discovery | Module 5 |
| T1087 | Account Discovery | Module 2 |
| T1082 | System Information Discovery | Module 1 |
| T1016 | System Network Configuration Discovery | Module 5 |
| T1021 | Remote Services | Modules 5, 16 |
| T1552 | Unsecured Credentials | Modules 6, 18 |
| T1546 | Event Triggered Execution (WMI) | Module 7 |

---

## 📈 Risk Scoring

Frogman computes an automated **Risk Score (0–100)** based on findings:

| Score Range | Level | Color |
|---|---|---|
| 75 – 100 | 🔴 **CRITICAL** | Red |
| 50 – 74 | 🟡 **HIGH** | Yellow |
| 0 – 49 | 🟢 **LOW / MEDIUM** | Green |

**Risk factors include:**
- WMI event subscriptions (persistence indicators)
- Suspicious process command lines (`-enc`, `-hidden`, `-bypass`)
- Firewall disabled
- Unquoted service paths
- Unsigned drivers
- Missing patches / CVEs
- Auto-start services not running
- Open shares
- Disabled local accounts (admin SID-500 status)

---

## ⚙️ Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `-SaveLocation` | String | `""` | Pre-set output directory path |
| `-Target` | String | `""` | Remote hostname or IP to audit |
| `-TargetUser` | String | `""` | Username for remote authentication |
| `-Dashboard` | Switch | `$false` | Launch directly to Live Dashboard |
| `-RefreshSeconds` | Int | `30` | Dashboard auto-refresh interval (seconds) |

### Examples

```powershell
# Local audit, save to Desktop
.\frogman.ps1 -SaveLocation "$env:USERPROFILE\Desktop"

# Remote audit with credentials
.\frogman.ps1 -Target "192.168.1.50" -TargetUser "CORP\Administrator"

# Live dashboard with 10s refresh
.\frogman.ps1 -Dashboard -RefreshSeconds 10

# Full remote audit to custom path
.\frogman.ps1 -Target "DC01" -SaveLocation "C:\Reports" -TargetUser "DOMAIN\user"
```

---

## 🛡️ Threat Detection (Press C)

The dedicated threat detection module checks for:

- 🔴 WMI event filter/consumer persistence (T1546.003)
- 🔴 Suspicious PowerShell flags (`-EncodedCommand`, `-WindowStyle Hidden`, `-Bypass`)
- 🔴 Unquoted service paths (privilege escalation)
- 🔴 Unsigned/untrusted kernel drivers
- 🟡 Firewall profile disabled (any profile)
- 🟡 AutoRun registry keys with external paths
- 🟡 Scheduled tasks pointing to temp/user directories
- 🟡 Services running from unusual locations
- 🟢 WMI namespace enumeration
- 🟢 Open administrative shares

---

## ⚡ Tips & Tricks

```
[S] Press S before a slow command starts to skip it
[Q] Press Q in Live Dashboard to exit
[B] Run ALL 600 commands in batch mode
[R] Switch between local and remote targets at any time
```

- Run as **Administrator** for complete WMI access
- For remote targets, ensure **WMI firewall exceptions** are enabled
- Use `-SaveLocation` parameter to skip the save prompt on startup
- The **HTML report** is the most visually rich format — open in Chrome/Edge
- PDF generation requires Chrome or Edge to be installed

---

## ⚖️ Legal & Disclaimer

> **This tool is intended for authorized security testing, auditing, and educational purposes ONLY.**

- ✅ Use on systems you **own** or have **explicit written permission** to test
- ✅ Use for **defensive security** — auditing your own infrastructure
- ✅ Use for **CTF challenges** and **security research**
- ❌ **Do NOT** use against systems without authorization
- ❌ **Do NOT** use for unauthorized access or malicious purposes

The author (MANIKANDAN) assumes **no liability** for misuse of this tool. Users are solely responsible for ensuring their activities comply with applicable laws and regulations.

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPL v3)**.

- ✅ Free to use, modify, and distribute
- ✅ Modifications must also be open source (GPL v3)
- ✅ **Attribution required** — original author credit must be retained in all copies and forks
- ❌ Cannot be relicensed as proprietary

See the [LICENSE](LICENSE) file for full details.  
Official GPL v3 text: https://www.gnu.org/licenses/gpl-3.0.txt

---

## 👤 Author

```
  +--------------------------------------------------+
  |  WMI sees all. Are you looking?                  |
  |  MANIKANDAN  |  Contact: 9787091093              |
  +--------------------------------------------------+
```

**MANIKANDAN**  
📞 Contact: 9787091093  
🐸 Tool: WMI Frogman Cyber Tool v18  
📅 Year: 2025  
🔒 License: GNU GPL v3  

---

## 🌟 Contributing

Contributions are welcome under GPL v3 terms:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-module`
3. Commit your changes: `git commit -m "Add: new detection module"`
4. Push to branch: `git push origin feature/new-module`
5. Open a Pull Request

**All contributions must retain original author attribution (MANIKANDAN).**

---

## 📊 Stats

```
Total Commands    : 600+
MITRE Techniques  : 200+
Audit Modules     : 19
Export Formats    : 5  (HTML, PDF, JSON, CSV, YAML)
Remote Modes      : 4  (Direct, Subnet Scan, Host List, Credential)
Exit Quotes       : 15 (random, Metasploit-style)
Entry Banners     : 10 (random ASCII frog art)
```

---

*Stay paranoid. Stay patched. Stay frog. 🐸*
