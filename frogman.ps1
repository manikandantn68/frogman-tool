# ============================================================
# WMI AUDIT - FROGMAN CYBER TOOL v18
# AUTHOR  : MANIKANDAN
# CONTACT : 9787091093
# 600+ COMMANDS | 200+ MITRE ATT&CK TTPs | REMOTE WMI
# AD RECON | CLOUD DETECT | BROWSER ARTIFACTS | CVE MATCH
# LIVE DASHBOARD | DARK/LIGHT THEME | YAML/JSON/CSV/HTML
# ============================================================
param(
    [string]$SaveLocation  = "",
    [string]$Target        = "",
    [string]$TargetUser    = "",
    [switch]$Dashboard,
    [int]$RefreshSeconds   = 30
)
$script:RemoteTarget = if ($Target) { $Target } else { $env:COMPUTERNAME }
$script:RemoteCred   = $null
$script:IsRemote     = ($Target -ne "" -and $Target -ne $env:COMPUTERNAME)

Clear-Host
$colors = @("Green","Cyan","Yellow","Magenta","White")
$script:FrogColor = Get-Random $colors
$script:SkipCurrent = $false

# Beep intro
[console]::beep(500,80); Start-Sleep -Milliseconds 60
[console]::beep(700,80); Start-Sleep -Milliseconds 60
[console]::beep(900,80); Start-Sleep -Milliseconds 60
[console]::beep(1100,80); Start-Sleep -Milliseconds 60
[console]::beep(1400,200)

$ColorScheme = @{
    FrogMain="Green"; Header="Cyan"; MenuNumber="Yellow"; MenuText="White"
    Title="Magenta"; Data="DarkCyan"; Alert="Red"; Success="Green"
    Warning="Yellow"; InfoLow="Gray"
}

# 10 random entry banners
$script:bannerLines = @(
    @("      (o   o)","     (   =^=   )","     (           )","      (           )","        (         )","          (_________)","   [ WMI AUDIT - FROGMAN v15 ]"),
    @("        @..@","       ( -__- )","      (  >_____<  )","      ^^  ~~~~~~  ^^","   [ FROGMAN IS WATCHING YOU ]"),
    @("    _(I)(I)_","   (  _  .. _  )","    ``..--..``","   /  |  ||  |  \","  (   |  ||  |   )","   [ WMI RECON COMPLETE ]"),
    @("         o  o   o  o","         |\/^\^/\/|","         |,-------|","       ,-.(|)   (|),-.","       \_*._  _.*_/","   [ THREAT MATRIX LOADED ]"),
    @("           .--._.--","          ( O     O )","          /   . .   \","         .-._______-.","        /(           )\","   [ FROGMAN AUDIT SYSTEM ]"),
    @("        _  _","       (.)(.)"," ,-.(.____.),-."," ( \ \ '--' / / )"," ( | '----' | )","   [ FROGMAN FORTRESS ONLINE ]"),
    @("   __/^^^\__","  ( 0  )( 0 )"," (  \  ===  /  )","  (  ``-----''  )","   [ FROG SHELL ACTIVE ]"),
    @("  *    .  *     .","      (o)(o)","   .  (  =vv=  )  .","     (  RIBBIT  )","   .   ``-------''","   [ STEALTHY FROGMAN MODE ]"),
    @("   >°))))彡  >°))))彡","       (  O  O  )","      (   =vv=   )","     (  WMI AUD  )","      (  IT NOW  )","   [ DEEP PACKET FROG ]"),
    @("    |===========|","    | (.) . (.) |","    |   ( ^ )   |","    |  ``-----''  |","    |  F R O G  |","    |===========|","   [ WMI FROGMAN  ]")
)

# 15 EXIT banners (like Metasploit) - random each exit
$script:exitBanners = @(
    @("","  +-----------------------------------------+","  |  Bugs are features with documentation.  |","  |              -- MANIKANDAN               |","  +-----------------------------------------+",""),
    @("","  +------------------------------------------+","  |  The only secure system is powered off.  |","  |              -- MANIKANDAN                |","  +------------------------------------------+",""),
    @("","  +--------------------------------------------------+","  |  In God we trust. All others, we audit.        |","  |                        -- MANIKANDAN  9787091093|","  +--------------------------------------------------+",""),
    @("","  +------------------------------------------+","  |  Audit everything. Trust nothing.         |","  |                -- MANIKANDAN            |","  +------------------------------------------+",""),
    @("","  +------------------------------------------+","  |  Knowing your enemy begins with WMI.     |","  |                -- MANIKANDAN            |","  +------------------------------------------+",""),
    @("","  +------------------------------------------+","  |  The hacker saw what admins ignored.     |","  |                -- MANIKANDAN            |","  +------------------------------------------+",""),
    @("","  +----------------------------------------------+","  |  Security is a process, not a product.    |","  |  Phone: 9787091093  |  MANIKANDAN          |","  +----------------------------------------------+",""),
    @("","  +------------------------------------------+","  |  Complexity is the enemy of security.   |","  |                -- MANIKANDAN            |","  +------------------------------------------+",""),
    @("","  +------------------------------------------+","  |  Patch today. Or explain it tomorrow.   |","  |                -- MANIKANDAN            |","  +------------------------------------------+",""),
    @("","  +-------------------------------------------+","  |  Every unquoted path is an invitation.  |","  |               -- MANIKANDAN             |","  +-------------------------------------------+",""),
    @("","  +--------------------------------------------------+","  |  WMI sees all. Are you looking?               |","  |  MANIKANDAN  |  Contact: 9787091093          |","  +--------------------------------------------------+",""),
    @("","  +------------------------------------------+","  |  Unsigned driver today, rootkit tomorrow.|","  |                -- MANIKANDAN            |","  +------------------------------------------+",""),
    @("","  +------------------------------------------+","  |  Firewall OFF = Welcome mat for hackers. |","  |                -- MANIKANDAN            |","  +------------------------------------------+",""),
    @("","  +------------------------------------------+","  |  Your logs have the answers. Read them.  |","  |                -- MANIKANDAN            |","  +------------------------------------------+",""),
    @("","  +------------------------------------------+","  |  Stay paranoid. Stay patched. Stay frog. |","  |                -- MANIKANDAN            |","  +------------------------------------------+","")
)

function Start-MatrixRain {
    param([int]$Lines = 16)
    $width = [math]::Min([console]::WindowWidth, 120)
    $chars = "01ABCDEFabcdef@#$%^&*"
    for ($i = 0; $i -lt $Lines; $i++) {
        $line = ""
        for ($j = 0; $j -lt $width; $j++) {
            if ((Get-Random -Maximum 10) -lt 2) { $line += $chars[(Get-Random -Maximum $chars.Length)] }
            else { $line += " " }
        }
        Write-Host $line -ForegroundColor @("DarkGreen","Green")[(Get-Random -Maximum 2)]
        Start-Sleep -Milliseconds 18
    }
}

function Start-FrogBlink {
    $eyeSets = @(@("(o   o)","(O   O)"),@("(^   ^)","(-   -)"),@("(>   <)","(o   o)"))
    $pick = $eyeSets[(Get-Random -Maximum $eyeSets.Count)]
    for ($i = 0; $i -lt 3; $i++) {
        Clear-Host
        $e = $pick[($i % 2)]
        Write-Host "      $e" -ForegroundColor $script:FrogColor
        Write-Host "     (   =^=   )" -ForegroundColor $script:FrogColor
        Write-Host "     (           )" -ForegroundColor $script:FrogColor
        Write-Host "      (           )" -ForegroundColor $script:FrogColor
        Write-Host "        (          )" -ForegroundColor $script:FrogColor
        Write-Host "          (_________)" -ForegroundColor $script:FrogColor
        Write-Host ""
        Write-Host "   [ WMI AUDIT - FROGMAN  LOADING... ]" -ForegroundColor $ColorScheme.Header
        Write-Host "   [ AUTHOR: MANIKANDAN | 9787091093    ]" -ForegroundColor $ColorScheme.InfoLow
        Start-Sleep -Milliseconds (220 + (Get-Random -Maximum 180))
    }
}

function Show-Header {
    Clear-Host
    $hc = @("Cyan","Green","Magenta","Yellow")[(Get-Random -Maximum 4)]
    Write-Host "+--------------------------------------------------------------+" -ForegroundColor $hc
    Write-Host "|        WMI AUDIT  .  FROGMAN CYBER TOOL  .  600+ CMDS       |" -ForegroundColor $ColorScheme.Title
    Write-Host "|           AUTHOR: MANIKANDAN  |  TEL: 9787091093             |" -ForegroundColor $ColorScheme.InfoLow
    Write-Host "+--------------------------------------------------------------+" -ForegroundColor $hc
    Write-Host ""
    $idx = Get-Random -Minimum 0 -Maximum $script:bannerLines.Count
    foreach ($line in $script:bannerLines[$idx]) {
        Write-Host $line -ForegroundColor $script:FrogColor
    }
}

function Show-ExitBanner {
    $idx = Get-Random -Minimum 0 -Maximum $script:exitBanners.Count
    foreach ($line in $script:exitBanners[$idx]) {
        Write-Host $line -ForegroundColor $ColorScheme.Success
    }
}

function Show-Menu {
    Write-Host ""
    Write-Host ("-" * 66) -ForegroundColor $ColorScheme.Header
    Write-Host "  SELECT AUDIT CATEGORY" -ForegroundColor $ColorScheme.Title
    $tgt = if ($script:IsRemote) { "  TARGET: $($script:RemoteTarget)" } else { "  TARGET: LOCAL ($env:COMPUTERNAME)" }
    Write-Host $tgt -ForegroundColor $(if ($script:IsRemote) {"Yellow"} else {"Green"})
    Write-Host ("-" * 66) -ForegroundColor $ColorScheme.Header
    Write-Host "  1  System Info           (Cmds 1-30)" -ForegroundColor $ColorScheme.MenuText
    Write-Host "  2  User and Group        (Cmds 31-60)" -ForegroundColor $ColorScheme.MenuText
    Write-Host "  3  Service and Driver    (Cmds 61-85)" -ForegroundColor $ColorScheme.MenuText
    Write-Host "  4  Process and Memory    (Cmds 86-110)" -ForegroundColor $ColorScheme.MenuText
    Write-Host "  5  Network and Shares    (Cmds 111-125)" -ForegroundColor $ColorScheme.MenuText
    Write-Host "  6  Privilege Access      (Cmds 126-200)" -ForegroundColor $ColorScheme.MenuText
    Write-Host "  7  WMI/CIM Advanced      (Cmds 201-300)" -ForegroundColor $ColorScheme.MenuText
    Write-Host "  8  Storage and Disk      (Cmds 301-340)" -ForegroundColor $ColorScheme.MenuText
    Write-Host "  9  Security and Firewall (Cmds 341-380)" -ForegroundColor $ColorScheme.MenuText
    Write-Host " 10  Registry and Config   (Cmds 381-420)" -ForegroundColor $ColorScheme.MenuText
    Write-Host " 11  Hardware Peripherals  (Cmds 421-460)" -ForegroundColor $ColorScheme.MenuText
    Write-Host " 12  Software and Apps     (Cmds 461-500)" -ForegroundColor $ColorScheme.MenuText
    Write-Host " 13  Tasks, Logs and Audit (Cmds 501-540)" -ForegroundColor $ColorScheme.MenuText
    Write-Host " 14  Certificates/Crypto   (Cmds 541-570)" -ForegroundColor $ColorScheme.MenuText
    Write-Host " 15  Persistence/Lateral   (Cmds 571-600)" -ForegroundColor $ColorScheme.MenuText
    Write-Host ""
    Write-Host " 16  Active Directory Recon     " -ForegroundColor $ColorScheme.Warning
    Write-Host " 17  Cloud Metadata Detection   " -ForegroundColor $ColorScheme.Warning
    Write-Host " 18  Browser Artifacts          " -ForegroundColor $ColorScheme.Warning
    Write-Host " 19  CVE / Patch Matching      " -ForegroundColor $ColorScheme.Warning
    Write-Host ""
    Write-Host "  B  RUN ALL 600 COMMANDS" -ForegroundColor $ColorScheme.Alert
    Write-Host "  C  THREAT DETECTION" -ForegroundColor $ColorScheme.Alert
    Write-Host "  D  EXPORT  (HTML / PDF / JSON / CSV / YAML + Risk Score + MITRE)" -ForegroundColor $ColorScheme.Alert
    Write-Host "  L  LIVE DASHBOARD MODE  [auto-refresh]" -ForegroundColor $ColorScheme.Alert
    Write-Host "  R  SET REMOTE TARGET    [network scan / remote WMI]" -ForegroundColor $ColorScheme.Warning
    Write-Host ""
    Write-Host "  TIP: Press [S] before a slow command starts to skip it" -ForegroundColor $ColorScheme.InfoLow
    Write-Host "  Q  EXIT" -ForegroundColor $ColorScheme.MenuText
    Write-Host ("-" * 66) -ForegroundColor $ColorScheme.Header
    return Read-Host "Enter option"
}

$OutputPath = ""
function Initialize-SaveLocation {
    if ($SaveLocation -and (Test-Path $SaveLocation)) { $script:OutputPath = $SaveLocation; return }
    Write-Host "`nSave location: 1=Desktop  2=Documents  3=Home  4=Custom" -ForegroundColor $ColorScheme.MenuNumber
    $ch = Read-Host "Select 1-4"
    switch ($ch) {
        "1" { $script:OutputPath = if (Test-Path "$env:USERPROFILE\Desktop")   { "$env:USERPROFILE\Desktop"   } else { $env:USERPROFILE } }
        "2" { $script:OutputPath = if (Test-Path "$env:USERPROFILE\Documents") { "$env:USERPROFILE\Documents" } else { $env:USERPROFILE } }
        "3" { $script:OutputPath = $env:USERPROFILE }
        "4" { $c = Read-Host "Enter path"; $script:OutputPath = if (Test-Path $c) { $c } else { $env:USERPROFILE } }
        default { $script:OutputPath = $env:USERPROFILE }
    }
    Write-Host "Location set: $script:OutputPath" -ForegroundColor $ColorScheme.Success
}

# ========================================================
# Wmi-Q : wrapper that injects -ComputerName + -Credential
# ========================================================
function Wmi-Q {
    param([string]$Class, [string]$Namespace = "root\cimv2", [string]$Filter = "", [hashtable]$Extra = @{})
    $p = @{ Class = $Class; Namespace = $Namespace; ErrorAction = "SilentlyContinue" }
    if ($Filter)                     { $p["Filter"]       = $Filter }
    if ($script:IsRemote)            { $p["ComputerName"] = $script:RemoteTarget }
    if ($script:RemoteCred)          { $p["Credential"]   = $script:RemoteCred }
    foreach ($k in $Extra.Keys)      { $p[$k]             = $Extra[$k] }
    Get-WmiObject @p
}
function Cim-Q {
    param([string]$Class, [string]$Namespace = "root\cimv2", [string]$Filter = "")
    $p = @{ ClassName = $Class; Namespace = $Namespace; ErrorAction = "SilentlyContinue" }
    if ($Filter)           { $p["Filter"]       = $Filter }
    if ($script:IsRemote)  { $p["ComputerName"] = $script:RemoteTarget }
    if ($script:RemoteCred){ $p["Credential"]   = $script:RemoteCred }
    Get-CimInstance @p
}

# ==== REMOTE TARGET SETUP ====
function Set-RemoteTarget {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "REMOTE WMI TARGET SETUP" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Write-Host "  Current target: " -NoNewline -ForegroundColor $ColorScheme.InfoLow
    Write-Host $script:RemoteTarget -ForegroundColor $(if ($script:IsRemote) {"Yellow"} else {"Green"})
    Write-Host ""
    Write-Host "  [1] Local machine (default)" -ForegroundColor $ColorScheme.MenuText
    Write-Host "  [2] Enter remote IP / hostname" -ForegroundColor $ColorScheme.MenuText
    Write-Host "  [3] Scan subnet  (e.g. 192.168.1.0/24)" -ForegroundColor $ColorScheme.MenuText
    Write-Host "  [4] Scan from host list file" -ForegroundColor $ColorScheme.MenuText
    Write-Host "  [B] Back" -ForegroundColor $ColorScheme.InfoLow
    $ch = Read-Host "Select"
    switch ($ch.ToUpper()) {
        "1" {
            $script:RemoteTarget = $env:COMPUTERNAME
            $script:IsRemote     = $false
            $script:RemoteCred   = $null
            Write-Host "  [OK] Switched to LOCAL" -ForegroundColor $ColorScheme.Success
        }
        "2" {
            $t = Read-Host "  Enter IP or hostname"
            if ($t) {
                $script:RemoteTarget = $t.Trim()
                $script:IsRemote     = $true
                $useCred = Read-Host "  Use alternate credentials? (Y/N)"
                if ($useCred -eq "Y" -or $useCred -eq "y") {
                    $user = Read-Host "  Username (DOMAIN\user or user)"
                    $script:RemoteCred = Get-Credential -UserName $user -Message "Enter password for $user"
                }
                Write-Host "  [OK] Target set to: $($script:RemoteTarget)" -ForegroundColor $ColorScheme.Success
                # Quick connectivity test
                Write-Host "  Testing WMI connectivity..." -ForegroundColor $ColorScheme.InfoLow
                try {
                    $test = Wmi-Q -Class Win32_OperatingSystem
                    Write-Host "  [OK] Connected! OS: $($test.Caption)" -ForegroundColor $ColorScheme.Success
                } catch {
                    Write-Host "  [WARN] Could not connect: $_" -ForegroundColor $ColorScheme.Warning
                }
            }
        }
        "3" {
            $subnet = Read-Host "  Enter subnet (e.g. 192.168.1)"
            Write-Host "  Scanning $subnet.1 - $subnet.254 for live WMI hosts..." -ForegroundColor $ColorScheme.Warning
            $live = @()
            1..254 | ForEach-Object {
                $ip = "$subnet.$_"
                if (Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue) {
                    try {
                        $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ip -ErrorAction SilentlyContinue -TimeoutMs 2000
                        if ($os) { $live += [PSCustomObject]@{IP=$ip; OS=$os.Caption; Build=$os.BuildNumber}; Write-Host "  [+] $ip -- $($os.Caption)" -ForegroundColor $ColorScheme.Success }
                    } catch {}
                }
            }
            if ($live.Count -gt 0) {
                Write-Host "`n  Found $($live.Count) live WMI host(s):" -ForegroundColor $ColorScheme.Success
                $live | Format-Table -AutoSize
                $pick = Read-Host "  Enter IP to target (blank to cancel)"
                if ($pick) { $script:RemoteTarget = $pick.Trim(); $script:IsRemote = $true }
            } else {
                Write-Host "  [INFO] No live WMI hosts found on $subnet.x" -ForegroundColor $ColorScheme.Warning
            }
        }
        "4" {
            $file = Read-Host "  Enter path to host list file (one IP/host per line)"
            if (Test-Path $file) {
                $hosts = Get-Content $file | Where-Object { $_.Trim() }
                Write-Host "  Loaded $($hosts.Count) hosts. Testing connectivity..." -ForegroundColor $ColorScheme.InfoLow
                $live = @()
                foreach ($h in $hosts) {
                    try {
                        $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $h.Trim() -ErrorAction SilentlyContinue
                        if ($os) { $live += [PSCustomObject]@{Host=$h.Trim();OS=$os.Caption}; Write-Host "  [+] $h -- $($os.Caption)" -ForegroundColor $ColorScheme.Success }
                    } catch {}
                }
                if ($live.Count -gt 0) {
                    $live | Format-Table -AutoSize
                    $pick = Read-Host "  Enter hostname to target (blank to cancel)"
                    if ($pick) { $script:RemoteTarget = $pick.Trim(); $script:IsRemote = $true }
                }
            } else { Write-Host "  [ERR] File not found" -ForegroundColor $ColorScheme.Alert }
        }
    }
}

# ==== LIVE DASHBOARD ====
function Start-LiveDashboard {
    param([int]$Interval = 30)
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "LIVE DASHBOARD MODE  --  Refresh every ${Interval}s  --  Press Q to exit" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    $run = $true
    while ($run) {
        $ts = Get-Date -Format "HH:mm:ss"
        Clear-Host
        Write-Host "+------------------------------------------------------------------+" -ForegroundColor $ColorScheme.Header
        Write-Host "  FROGMAN   LIVE DASHBOARD   Target: $($script:RemoteTarget)   $ts" -ForegroundColor $ColorScheme.Title
        Write-Host "+------------------------------------------------------------------+" -ForegroundColor $ColorScheme.Header

        # CPU
        try {
            $cpu = Wmi-Q -Class Win32_Processor | Measure-Object -Property LoadPercentage -Average
            $cpuVal = [math]::Round($cpu.Average, 0)
            $cpuColor = if ($cpuVal -gt 80) {"Red"} elseif ($cpuVal -gt 60) {"Yellow"} else {"Green"}
            Write-Host ("  CPU Load  : {0,3}%  " -f $cpuVal) -NoNewline -ForegroundColor $cpuColor
            $bar = "[" + ("#" * [math]::Floor($cpuVal/5)) + ("-" * (20 - [math]::Floor($cpuVal/5))) + "]"
            Write-Host $bar -ForegroundColor $cpuColor
        } catch { Write-Host "  CPU Load  : N/A" -ForegroundColor $ColorScheme.InfoLow }

        # Memory
        try {
            $os  = Wmi-Q -Class Win32_OperatingSystem
            $memTotal = [math]::Round($os.TotalVisibleMemorySize/1MB, 2)
            $memFree  = [math]::Round($os.FreePhysicalMemory/1MB, 2)
            $memUsed  = [math]::Round($memTotal - $memFree, 2)
            $memPct   = [math]::Round(($memUsed / $memTotal) * 100, 0)
            $memColor = if ($memPct -gt 85) {"Red"} elseif ($memPct -gt 65) {"Yellow"} else {"Green"}
            $bar = "[" + ("#" * [math]::Floor($memPct/5)) + ("-" * (20 - [math]::Floor($memPct/5))) + "]"
            Write-Host ("  RAM Used  : {0,3}%  " -f $memPct) -NoNewline -ForegroundColor $memColor
            Write-Host $bar -ForegroundColor $memColor
            Write-Host ("  RAM       :  {0}GB / {1}GB" -f $memUsed, $memTotal) -ForegroundColor $ColorScheme.InfoLow
        } catch { Write-Host "  RAM       : N/A" -ForegroundColor $ColorScheme.InfoLow }

        # Disk
        try {
            Write-Host "  Disks     :" -ForegroundColor $ColorScheme.InfoLow
            Wmi-Q -Class Win32_LogicalDisk | Where-Object { $_.Size -gt 0 } | ForEach-Object {
                $pct = [math]::Round(($_.Size - $_.FreeSpace) / $_.Size * 100, 0)
                $dc  = if ($pct -gt 90) {"Red"} elseif ($pct -gt 75) {"Yellow"} else {"Green"}
                $bar = "[" + ("#" * [math]::Floor($pct/5)) + ("-" * (20 - [math]::Floor($pct/5))) + "]"
                Write-Host ("    {0}  {1,3}% used  " -f $_.DeviceID, $pct) -NoNewline -ForegroundColor $dc
                Write-Host $bar -ForegroundColor $dc
            }
        } catch {}

        # Network
        try {
            $net = Wmi-Q -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }
            Write-Host "  Network   :" -ForegroundColor $ColorScheme.InfoLow
            $net | Select-Object -First 3 | ForEach-Object {
                Write-Host ("    {0}  IP: {1}" -f ($_.Description -replace '.{1,30}$','$0'), ($_.IPAddress -join ", ")) -ForegroundColor $ColorScheme.Data
            }
        } catch {}

        # Top Processes
        try {
            Write-Host "  Top 5 Procs (Memory):" -ForegroundColor $ColorScheme.InfoLow
            Wmi-Q -Class Win32_Process | Sort-Object WorkingSetSize -Descending | Select-Object -First 5 | ForEach-Object {
                Write-Host ("    {0,-22} {1,6} MB" -f ($_.Name -replace '(.{20}).*','$1'), [math]::Round($_.WorkingSetSize/1MB,1)) -ForegroundColor $ColorScheme.Data
            }
        } catch {}

        # Running Services Count
        try {
            $svcRun = @(Wmi-Q -Class Win32_Service | Where-Object { $_.State -eq "Running" }).Count
            $svcAuto= @(Wmi-Q -Class Win32_Service | Where-Object { $_.StartMode -eq "Auto" -and $_.State -ne "Running" }).Count
            Write-Host ("  Services  :  {0} running  |  {1} auto not-running" -f $svcRun, $svcAuto) -ForegroundColor $(if ($svcAuto -gt 0) {"Yellow"} else {"Green"})
        } catch {}

        # Quick threat check
        try {
            $suspPS = @(Wmi-Q -Class Win32_Process | Where-Object { $_.CommandLine -match "-enc|-hidden|-bypass" }).Count
            $wmiSub = @(Get-WmiObject -Namespace root\subscription -Class __EventFilter -ErrorAction SilentlyContinue).Count
            $threatColor = if ($suspPS -gt 0 -or $wmiSub -gt 0) {"Red"} else {"Green"}
            Write-Host ("  Threats   :  SuspPS={0}  WMI_Subscriptions={1}" -f $suspPS, $wmiSub) -ForegroundColor $threatColor
        } catch {}

        Write-Host ""
        Write-Host "  [Refreshing in ${Interval}s -- Press Q to exit dashboard]" -ForegroundColor $ColorScheme.InfoLow

        # Wait with Q-check
        $elapsed = 0
        while ($elapsed -lt $Interval) {
            if ([Console]::KeyAvailable) {
                $k = [Console]::ReadKey($true)
                if ($k.Key -eq [ConsoleKey]::Q) { $run = $false; break }
            }
            Start-Sleep -Milliseconds 500
            $elapsed += 0.5
        }
    }
    Write-Host "`n[DASHBOARD] Exited." -ForegroundColor $ColorScheme.Success
}

# ====================================================
# Run-Cmd with SKIP support (press S before cmd runs)
# ====================================================
function Run-Cmd {
    param([string]$Num, [string]$Title, [scriptblock]$Cmd, [switch]$Slow)
    # Drain any pending 'S' keypress to skip
    if ([Console]::KeyAvailable) {
        $ki = [Console]::ReadKey($true)
        if ($ki.Key -eq [ConsoleKey]::S -or ($ki.Key -eq [ConsoleKey]::S -and ($ki.Modifiers -band [ConsoleModifiers]::Control))) {
            Write-Host "  [$Num] $Title -- SKIPPED (S pressed)" -ForegroundColor $ColorScheme.InfoLow
            return
        }
    }
    if ($Slow) {
        Write-Host "  [$Num] $Title  " -NoNewline -ForegroundColor $ColorScheme.Title
        Write-Host "[SLOW -- press S now to skip]" -ForegroundColor $ColorScheme.Warning
        Start-Sleep -Milliseconds 400
        if ([Console]::KeyAvailable) {
            $ki = [Console]::ReadKey($true)
            if ($ki.Key -eq [ConsoleKey]::S) {
                Write-Host "  --> SKIPPED" -ForegroundColor $ColorScheme.InfoLow
                return
            }
        }
    } else {
        Write-Host "[$Num] $Title" -ForegroundColor $ColorScheme.Title
    }
    try {
        $r = & $Cmd
        if ($r) { $r | Format-Table -AutoSize -ErrorAction SilentlyContinue | Out-String | Write-Host -ForegroundColor $ColorScheme.Data }
        else { Write-Host "    [INFO] No data" -ForegroundColor $ColorScheme.InfoLow }
    } catch { Write-Host "    [SKIP] $_" -ForegroundColor $ColorScheme.InfoLow }
}

# ==== COMMANDS 1-30 ====
function Invoke-SystemInfo {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "SYSTEM INFO (1-30)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "1"  "OS Version"              { Get-WmiObject Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,OSArchitecture }
    Run-Cmd "2"  "Computer System"         { Get-WmiObject Win32_ComputerSystem  | Select-Object Name,Model,Manufacturer,Domain }
    Run-Cmd "3"  "Processor Info"          { Get-WmiObject Win32_Processor       | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed }
    Run-Cmd "4"  "BIOS Information"        { Get-WmiObject Win32_BIOS            | Select-Object Manufacturer,Name,SerialNumber,Version,ReleaseDate }
    Run-Cmd "5"  "Motherboard"             { Get-WmiObject Win32_BaseBoard       | Select-Object Manufacturer,Product,SerialNumber,Version }
    Run-Cmd "6"  "System UUID"             { Get-WmiObject Win32_ComputerSystemProduct | Select-Object Name,UUID,IdentifyingNumber }
    Run-Cmd "7"  "System Enclosure"        { Get-WmiObject Win32_SystemEnclosure | Select-Object Manufacturer,Type,SerialNumber,PartNumber }
    Run-Cmd "8"  "Physical Memory"         { Get-WmiObject Win32_PhysicalMemory  | Select-Object BankLabel,Capacity,Speed,Manufacturer }
    Run-Cmd "9"  "Network Adapters IP"     { Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } | Select-Object Description,IPAddress,DNSHostName }
    Run-Cmd "10" "Timezone"                { Get-WmiObject Win32_TimeZone        | Select-Object Caption,StandardName }
    Run-Cmd "11" "Startup Commands"        { Get-WmiObject Win32_StartupCommand  | Select-Object Name,Command,Location,User }
    Run-Cmd "12" "Environment PATH"        { Get-WmiObject Win32_Environment     | Where-Object { $_.Name -eq "PATH" } | Select-Object VariableValue }
    Run-Cmd "13" "Logical Disks"           { Get-WmiObject Win32_LogicalDisk     | Select-Object DeviceID,DriveType,Size,FreeSpace }
    Run-Cmd "14" "Volume Information"      { Get-WmiObject Win32_Volume          | Select-Object Name,Capacity,FreeSpace,Label }
    Run-Cmd "15" "Boot Configuration"      { Get-WmiObject Win32_BootConfiguration | Select-Object BootDirectory,SystemDirectory }
    Run-Cmd "16" "Onboard Devices"         { Get-WmiObject Win32_OnBoardDevice   | Select-Object Name,DeviceType,Status }
    Run-Cmd "17" "PCI Devices"             { Get-WmiObject Win32_PnPDevice       | Select-Object Name,Status,DeviceID | Select-Object -First 20 }
    Run-Cmd "18" "System Drivers"          { Get-WmiObject Win32_SystemDriver    | Select-Object Name,State,StartMode,PathName | Select-Object -First 20 }
    Run-Cmd "19" "BIOS Release Date"       { Get-WmiObject Win32_BIOS            | Select-Object ReleaseDate,Manufacturer,SMBIOSVersion }
    Run-Cmd "20" "OS Paths"                { Get-WmiObject Win32_OperatingSystem | Select-Object SystemDrive,WindowsDirectory,Locale }
    Run-Cmd "21" "Boot History"            { Get-WmiObject Win32_OperatingSystem | Select-Object LastBootUpTime,InstallDate }
    Run-Cmd "22" "Total Memory Usage"      { (Get-WmiObject Win32_Process | Measure-Object -Property WorkingSetSize -Sum).Sum }
    Run-Cmd "23" "Processor Details"       { Get-WmiObject Win32_Processor       | Select-Object ProcessorId,Stepping,Family,Revision }
    Run-Cmd "24" "Page File Config"        { Get-WmiObject Win32_PageFile        | Select-Object Name,FileSize,InitialSize,MaximumSize }
    Run-Cmd "25" "Monitor Config"          { Get-WmiObject Win32_DesktopMonitor  | Select-Object Name,ScreenHeight,ScreenWidth }
    Run-Cmd "26" "Video Controller"        { Get-WmiObject Win32_VideoController | Select-Object Name,DriverVersion,VideoMemory }
    Run-Cmd "27" "Keyboard Layout"         { Get-WmiObject Win32_Keyboard        | Select-Object Name,Layout }
    Run-Cmd "28" "CD/DVD Drives"           { Get-WmiObject Win32_CDROMDrive      | Select-Object Name,Drive,MediaType }
    Run-Cmd "29" "Sound Device"            { Get-WmiObject Win32_SoundDevice     | Select-Object Name,Manufacturer | Select-Object -First 5 }
    Run-Cmd "30" "USB Devices"             { Get-WmiObject Win32_PnPEntity       | Where-Object { $_.DeviceID -like "USB*" } | Select-Object Name,DeviceID | Select-Object -First 15 }
}

# ==== COMMANDS 31-60 ====
function Invoke-UserGroupEnum {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "USER AND GROUP (31-60)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "31" "Local User Accounts"     { Get-WmiObject Win32_UserAccount | Where-Object { $_.LocalAccount }       | Select-Object Name,SID,Disabled,Description }
    Run-Cmd "32" "Domain User Accounts"    { Get-WmiObject Win32_UserAccount | Where-Object { -not $_.LocalAccount }  | Select-Object Name,Domain,SID }
    Run-Cmd "33" "User Account Details"    { Get-WmiObject Win32_UserAccount  | Select-Object Name,FullName,PasswordRequired,PasswordExpires }
    Run-Cmd "34" "Local Groups"            { Get-WmiObject Win32_Group        | Where-Object { $_.LocalAccount }      | Select-Object Name,SID,Description }
    Run-Cmd "35" "All Groups"              { Get-WmiObject Win32_Group        | Select-Object Name,SID,Domain,Description }
    Run-Cmd "36" "Group Memberships"       { Get-WmiObject Win32_GroupUser    | Select-Object GroupComponent,PartComponent | Select-Object -First 30 } -Slow
    Run-Cmd "37" "Domain Users"            { Get-WmiObject Win32_UserAccount  | Where-Object { -not $_.LocalAccount } | Select-Object Name,Domain }
    Run-Cmd "38" "Logon Sessions"          { Get-WmiObject Win32_LogonSession | Select-Object LogonId,AuthenticationPackage,LogonType }
    Run-Cmd "39" "Logged On Users"         { Get-WmiObject Win32_LoggedOnUser | Select-Object Antecedent,Dependent }
    Run-Cmd "40" "User Profiles"           { Get-WmiObject Win32_UserProfile  | Select-Object LocalPath,LastUseTime,Loaded }
    Run-Cmd "41" "Profile Status"          { Get-WmiObject Win32_UserProfile  | Select-Object SID,Status,RefCount }
    Run-Cmd "42" "Groups Count"            { (Get-WmiObject Win32_Group | Measure-Object).Count }
    Run-Cmd "43" "Administrator SID-500"   { Get-WmiObject Win32_UserAccount  | Where-Object { $_.SID -like "*-500" } | Select-Object Name,SID,Disabled }
    Run-Cmd "44" "Guest Account SID-501"   { Get-WmiObject Win32_UserAccount  | Where-Object { $_.SID -like "*-501" } | Select-Object Name,Disabled }
    Run-Cmd "45" "Service Accounts"        { Get-WmiObject Win32_Service      | Select-Object StartName -Unique | Where-Object { $_.StartName -ne "LocalSystem" } | Select-Object -First 30 }
    Run-Cmd "46" "Password Settings"       { Get-WmiObject Win32_UserAccount  | Select-Object Name,PasswordRequired,PasswordExpires,PasswordChangeable }
    Run-Cmd "47" "Disabled Accounts"       { Get-WmiObject Win32_UserAccount  | Where-Object { $_.Disabled }         | Select-Object Name,SID,FullName }
    Run-Cmd "48" "No Password Required"    { Get-WmiObject Win32_UserAccount  | Where-Object { $_.PasswordRequired -eq $false } | Select-Object Name }
    Run-Cmd "49" "Enabled Accounts"        { Get-WmiObject Win32_UserAccount  | Where-Object { -not $_.Disabled }    | Select-Object Name,Domain }
    Run-Cmd "50" "Account Lockout Status"  { Get-WmiObject Win32_UserAccount  | Select-Object Name,Lockout,LockoutTime }
    Run-Cmd "51" "Domain Information"      { Get-WmiObject Win32_ComputerSystem | Select-Object Domain,DomainRole,PartOfDomain }
    Run-Cmd "52" "Computer Role"           { Get-WmiObject Win32_ComputerSystem | Select-Object Name,DomainRole }
    Run-Cmd "53" "Admin Level Accounts"    { Get-WmiObject Win32_UserAccount  | Where-Object { $_.SID -like "*-500" } | Select-Object Name,SID }
    Run-Cmd "54" "Logon Type Summary"      { Get-WmiObject Win32_LogonSession | Select-Object LogonType,LogonId | Select-Object -First 20 }
    Run-Cmd "55" "Total User Count"        { (Get-WmiObject Win32_UserAccount | Measure-Object).Count }
    Run-Cmd "56" "Network Login Profile"   { Get-WmiObject Win32_NetworkLoginProfile -ErrorAction SilentlyContinue | Select-Object UserName,LastLogon }
    Run-Cmd "57" "Trustee Info"            { Get-WmiObject Win32_Trustee -ErrorAction SilentlyContinue | Select-Object TrusteeSID | Select-Object -First 30 }
    Run-Cmd "58" "Account SID Mapping"     { Get-WmiObject Win32_AccountSID  -ErrorAction SilentlyContinue | Select-Object AccountName,DomainName,SID }
    Run-Cmd "59" "Session Information"     { Get-WmiObject Win32_Session     -ErrorAction SilentlyContinue | Select-Object ComputerName,UserName,StartTime }
    Run-Cmd "60" "User Profile Count"      { (Get-WmiObject Win32_UserProfile | Measure-Object).Count }
}

# ==== COMMANDS 61-85 ====
function Invoke-ServiceEnum {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "SERVICE AND DRIVER (61-85)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "61" "All Services"            { Get-WmiObject Win32_Service | Select-Object Name,State,StartMode,PathName | Select-Object -First 50 }
    Run-Cmd "62" "Running Services"        { Get-WmiObject Win32_Service | Where-Object { $_.State -eq "Running" }    | Select-Object Name,PathName,StartName }
    Run-Cmd "63" "Auto-Start Services"     { Get-WmiObject Win32_Service | Where-Object { $_.StartMode -eq "Auto" }   | Select-Object Name,State }
    Run-Cmd "64" "Manual Services"         { Get-WmiObject Win32_Service | Where-Object { $_.StartMode -eq "Manual" } | Select-Object Name,State }
    Run-Cmd "65" "Disabled Services"       { Get-WmiObject Win32_Service | Where-Object { $_.StartMode -eq "Disabled" } | Select-Object Name,State }
    Run-Cmd "66" "Stopped Services"        { Get-WmiObject Win32_Service | Where-Object { $_.State -eq "Stopped" }    | Select-Object Name,StartMode }
    Run-Cmd "67" "Service Paths"           { Get-WmiObject Win32_Service | Select-Object Name,PathName | Select-Object -First 20 }
    Run-Cmd "68" "Service Dependencies"    { Get-WmiObject Win32_Service | Where-Object { $_.Dependencies }           | Select-Object Name,Dependencies | Select-Object -First 10 }
    Run-Cmd "69" "Custom Start Names"      { Get-WmiObject Win32_Service | Where-Object { $_.StartName -notlike "*SYSTEM*" } | Select-Object Name,StartName,State | Select-Object -First 20 }
    Run-Cmd "70" "SYSTEM Services"         { Get-WmiObject Win32_Service | Where-Object { $_.StartName -like "*SYSTEM*" }   | Select-Object Name,PathName | Select-Object -First 20 }
    Run-Cmd "71" "SVCHOST Services"        { Get-WmiObject Win32_Service | Where-Object { $_.PathName -like "*svchost*" }   | Select-Object Name,ProcessId,State }
    Run-Cmd "72" "Start Mode Distribution" { Get-WmiObject Win32_Service | Group-Object StartMode | Select-Object Name,Count }
    Run-Cmd "73" "State Distribution"      { Get-WmiObject Win32_Service | Group-Object State     | Select-Object Name,Count }
    Run-Cmd "74" "Total Service Count"     { (Get-WmiObject Win32_Service | Measure-Object).Count }
    Run-Cmd "75" "Non-Windows Services"    { Get-WmiObject Win32_Service | Where-Object { $_.PathName -notmatch "Windows" } | Select-Object Name | Select-Object -First 20 }
    Run-Cmd "76" "System Drivers"          { Get-WmiObject Win32_SystemDriver | Select-Object Name,State,StartMode,PathName | Select-Object -First 20 }
    Run-Cmd "77" "Boot Drivers"            { Get-WmiObject Win32_SystemDriver | Where-Object { $_.StartMode -eq "Boot" }    | Select-Object Name,PathName }
    Run-Cmd "78" "Device Drivers"          { Get-WmiObject Win32_PnPSignedDriver | Select-Object Name,DriverVersion,Manufacturer | Select-Object -First 30 }
    Run-Cmd "79" "Faulty Drivers"          { Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.Status -ne "OK" }      | Select-Object Name,Status }
    Run-Cmd "80" "Unsigned Drivers"        { Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.Signed -eq $false }    | Select-Object Name,DriverVersion }
    Run-Cmd "81" "Driver Count"            { (Get-WmiObject Win32_PnPSignedDriver | Measure-Object).Count }
    Run-Cmd "82" "Windows Drivers"         { Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.Filename -like "*windows*" } | Select-Object Name | Select-Object -First 20 }
    Run-Cmd "83" "Service Status Overview" { Get-WmiObject Win32_Service | Group-Object State | Select-Object Name,Count }
    Run-Cmd "84" "Core Windows Services"   { Get-WmiObject Win32_Service | Where-Object { $_.PathName -match "System32" }   | Select-Object Name | Select-Object -First 30 }
    Run-Cmd "85" "Third-Party Services"    { Get-WmiObject Win32_Service | Where-Object { $_.DisplayName -notmatch "Windows" } | Select-Object Name | Select-Object -First 20 }
}

# ==== COMMANDS 86-110 ====
function Invoke-ProcessTasks {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "PROCESS AND MEMORY (86-110)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "86"  "All Running Processes"  { Get-WmiObject Win32_Process | Select-Object ProcessId,Name,SessionId | Select-Object -First 30 }
    Run-Cmd "87"  "Process Exe Paths"      { Get-WmiObject Win32_Process | Where-Object { $_.ExecutablePath }    | Select-Object ProcessId,Name,ExecutablePath | Select-Object -First 20 }
    Run-Cmd "88"  "Process Command Lines"  { Get-WmiObject Win32_Process | Where-Object { $_.CommandLine }       | Select-Object ProcessId,Name,CommandLine | Select-Object -First 20 }
    Run-Cmd "89"  "Process Tree"           { Get-WmiObject Win32_Process | Select-Object ProcessId,Name,ParentProcessId | Select-Object -First 30 }
    Run-Cmd "90"  "Thread Counts"          { Get-WmiObject Win32_Process | Select-Object ProcessId,Name,ThreadCount,SessionId | Select-Object -First 30 }
    Run-Cmd "91"  "PID 0 Children"         { Get-WmiObject Win32_Process | Where-Object { $_.ParentProcessId -eq 0 } | Select-Object ProcessId,Name }
    Run-Cmd "92"  "User Session Processes" { Get-WmiObject Win32_Process | Where-Object { $_.SessionId -gt 0 }    | Select-Object ProcessId,Name,SessionId | Select-Object -First 20 }
    Run-Cmd "93"  "PowerShell Instances"   { Get-WmiObject Win32_Process | Where-Object { $_.Name -like "*powershell*" } | Select-Object ProcessId,CommandLine,ParentProcessId }
    Run-Cmd "94"  "CMD Instances"          { Get-WmiObject Win32_Process | Where-Object { $_.Name -like "*cmd*" } | Select-Object ProcessId,CommandLine,SessionId }
    Run-Cmd "95"  "Total Process Count"    { (Get-WmiObject Win32_Process | Measure-Object).Count }
    Run-Cmd "96"  "Memory Top 10"          { Get-WmiObject Win32_Process | Sort-Object WorkingSetSize -Descending | Select-Object ProcessId,Name,WorkingSetSize | Select-Object -First 10 }
    Run-Cmd "97"  "High Memory >100MB"     { Get-WmiObject Win32_Process | Where-Object { $_.WorkingSetSize -gt 104857600 } | Select-Object ProcessId,Name,WorkingSetSize }
    Run-Cmd "98"  "Process Priority"       { Get-WmiObject Win32_Process | Where-Object { $_.Priority -gt 0 }    | Select-Object ProcessId,Name,Priority | Select-Object -First 30 }
    Run-Cmd "99"  "High Priority"          { Get-WmiObject Win32_Process | Where-Object { $_.Priority -gt 10 }   | Select-Object ProcessId,Name,Priority }
    Run-Cmd "100" "Handle Count Analysis"  { Get-WmiObject Win32_Process | Sort-Object HandleCount -Descending   | Select-Object Name,HandleCount | Select-Object -First 15 }
    Run-Cmd "101" "High Handle >1000"      { Get-WmiObject Win32_Process | Where-Object { $_.HandleCount -gt 1000 } | Select-Object ProcessId,Name,HandleCount }
    Run-Cmd "102" "Process Creation Times" { Get-WmiObject Win32_Process | Where-Object { $_.CreationDate }      | Select-Object ProcessId,Name,CreationDate | Select-Object -First 20 }
    Run-Cmd "103" "Recent Processes <1hr"  { Get-WmiObject Win32_Process | Where-Object { $_.CreationDate -gt (Get-Date).AddHours(-1) } | Select-Object ProcessId,Name,CreationDate }
    Run-Cmd "104" "Exe Distribution"       { Get-WmiObject Win32_Process | Where-Object { $_.ExecutablePath }    | Group-Object ExecutablePath | Sort-Object Count -Descending | Select-Object Count,Name | Select-Object -First 15 }
    Run-Cmd "105" "Page File Usage"        { Get-WmiObject Win32_Process | Sort-Object PageFileUsage -Descending  | Select-Object ProcessId,Name,PageFileUsage | Select-Object -First 20 }
    Run-Cmd "106" "Virtual Memory Usage"   { Get-WmiObject Win32_Process | Sort-Object VirtualSize -Descending    | Select-Object ProcessId,Name,VirtualSize | Select-Object -First 20 }
    Run-Cmd "107" "Total Memory Handles"   { (Get-WmiObject Win32_Process | Measure-Object -Property HandleCount -Sum).Sum }
    Run-Cmd "108" "Process By Session"     { Get-WmiObject Win32_Process | Group-Object SessionId | Select-Object Name,Count }
    Run-Cmd "109" "Non-System Processes"   { Get-WmiObject Win32_Process | Where-Object { $_.ExecutablePath -notmatch "Windows" } | Select-Object ProcessId,Name | Select-Object -First 30 }
    Run-Cmd "110" "Process Summary"        { @{ TotalProcesses=(Get-WmiObject Win32_Process | Measure-Object).Count; AvgMemMB=([math]::Round((Get-WmiObject Win32_Process | Measure-Object -Property WorkingSetSize -Average).Average/1MB,2)) } }
}

# ==== COMMANDS 111-125 ====
function Invoke-NetworkShares {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "NETWORK AND SHARES (111-125)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "111" "Network Adapters"       { Get-WmiObject Win32_NetworkAdapter | Select-Object Name,NetConnectionStatus,Speed,MACAddress }
    Run-Cmd "112" "Enabled Adapters"       { Get-WmiObject Win32_NetworkAdapter | Where-Object { $_.NetEnabled }  | Select-Object Name,Speed,AdapterType }
    Run-Cmd "113" "Network Config"         { Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } | Select-Object Description,IPAddress,SubnetMask }
    Run-Cmd "114" "DHCP Config"            { Get-WmiObject Win32_NetworkAdapterConfiguration | Select-Object Description,DHCPEnabled,DHCPServer,DHCPLeaseObtained }
    Run-Cmd "115" "DNS Config"             { Get-WmiObject Win32_NetworkAdapterConfiguration | Select-Object Description,DNSServerSearchOrder,DNSHostName }
    Run-Cmd "116" "Network Shares"         { Get-WmiObject Win32_Share | Select-Object Name,Path,Type,Description }
    Run-Cmd "117" "Network Connections"    { Get-WmiObject Win32_NetworkConnection -ErrorAction SilentlyContinue | Select-Object LocalName,RemoteName,ConnectionState }
    Run-Cmd "118" "Mapped Logical Disks"   { Get-WmiObject Win32_MappedLogicalDisk -ErrorAction SilentlyContinue | Select-Object DeviceID,ProviderName,Size }
    Run-Cmd "119" "IPv4 Routing Table"     { Get-WmiObject Win32_IP4RouteTable | Select-Object Destination,NextHop,Metric | Select-Object -First 30 }
    Run-Cmd "120" "Active Routes"          { Get-WmiObject Win32_ActiveRoute -ErrorAction SilentlyContinue | Select-Object Destination,NextHop,Metric | Select-Object -First 30 }
    Run-Cmd "121" "Network Protocols"      { Get-WmiObject Win32_NetworkProtocol | Select-Object Name,Description,Status }
    Run-Cmd "122" "Session Connections"    { Get-WmiObject Win32_Session -ErrorAction SilentlyContinue | Select-Object ComputerName,UserName,Status }
    Run-Cmd "123" "RDP Sessions"           { Get-WmiObject Win32_TerminalServiceSetting -ErrorAction SilentlyContinue | Select-Object TerminalServerMode,AllowLogoff }
    Run-Cmd "124" "Network Performance"    { Get-WmiObject Win32_PerfRawData_Tcpip_NetworkInterface -ErrorAction SilentlyContinue | Select-Object Name | Select-Object -First 10 }
    Run-Cmd "125" "Total Routes Count"     { (Get-WmiObject Win32_IP4RouteTable | Measure-Object).Count }
}

# ==== COMMANDS 126-200 ====
function Invoke-PrivilegePolicy {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "PRIVILEGE AND SECURITY (126-200)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "126" "Administrator Accounts"  { Get-WmiObject Win32_UserAccount | Where-Object { $_.SID -like "*-500" } | Select-Object Name,SID,Disabled }
    Run-Cmd "127" "Admins Group Members"    { Get-WmiObject Win32_GroupUser | Where-Object { $_.GroupComponent -like "*Administrators*" } | Select-Object UserComponent | Select-Object -First 20 }
    Run-Cmd "128" "Power Users Group"       { Get-WmiObject Win32_Group | Where-Object { $_.Name -like "*PowerUsers*" }   | Select-Object Name,SID }
    Run-Cmd "129" "Backup Operators"        { Get-WmiObject Win32_Group | Where-Object { $_.Name -like "*Backup*" }       | Select-Object Name,SID }
    Run-Cmd "130" "Remote Desktop Users"    { Get-WmiObject Win32_Group | Where-Object { $_.Name -like "*Remote*" }       | Select-Object Name,SID }
    Run-Cmd "131" "Domain Membership"       { Get-WmiObject Win32_ComputerSystem | Select-Object Domain,PartOfDomain }
    Run-Cmd "132" "Domain Role"             { Get-WmiObject Win32_ComputerSystem | Select-Object DomainRole,Name }
    Run-Cmd "133" "Encryption Status"       { Get-WmiObject -Namespace "root\cimv2\security\microsoftvolumeencryption" -Class Win32_EncryptableVolume -ErrorAction SilentlyContinue | Select-Object DriveLetter,ProtectionStatus }
    Run-Cmd "134" "Firewall Status"         { Get-WmiObject -Namespace "root\standardcimv2" -Class MSFT_NetFirewallProfile -ErrorAction SilentlyContinue | Select-Object Name,Enabled }
    Run-Cmd "135" "Hotfixes Installed"      { Get-WmiObject Win32_QuickFixEngineering | Measure-Object | Select-Object Count }
    Run-Cmd "136" "Latest Hotfix"           { Get-WmiObject Win32_QuickFixEngineering | Sort-Object InstalledOn -Descending | Select-Object HotFixID,InstalledOn | Select-Object -First 5 }
    Run-Cmd "137" "Empty Password Accounts" { Get-WmiObject Win32_UserAccount | Where-Object { $_.PasswordRequired -eq $false } | Select-Object Name }
    Run-Cmd "138" "Event Log Count"         { Get-WmiObject Win32_NTEventlogFile | Measure-Object | Select-Object Count }
    Run-Cmd "139" "Software Inventory"      { Get-WmiObject Win32_Product | Select-Object Name,Version | Select-Object -First 30 } -Slow
    Run-Cmd "140" "Software Count"          { (Get-WmiObject Win32_Product | Measure-Object).Count } -Slow
    Run-Cmd "141" "Antivirus Status"        { Get-WmiObject -Namespace "root\securitycenter2" -Class AntiVirusProduct -ErrorAction SilentlyContinue | Select-Object DisplayName }
    Run-Cmd "142" "Memory Available"        { Get-WmiObject Win32_ComputerSystem | Select-Object @{N='MemoryGB';E={[math]::Round($_.TotalPhysicalMemory/1GB,2)}} }
    Run-Cmd "143" "CPU Cores"               { (Get-WmiObject Win32_Processor)[0].NumberOfCores }
    Run-Cmd "144" "System Uptime"           { Get-WmiObject Win32_OperatingSystem | Select-Object LastBootUpTime }
    Run-Cmd "145" "Network Adapters Count"  { (Get-WmiObject Win32_NetworkAdapter | Measure-Object).Count }
    Run-Cmd "146" "Running Services Count"  { (Get-WmiObject Win32_Service | Where-Object { $_.State -eq "Running" } | Measure-Object).Count }
    Run-Cmd "147" "Total Users"             { (Get-WmiObject Win32_UserAccount | Measure-Object).Count }
    Run-Cmd "148" "Total Groups"            { (Get-WmiObject Win32_Group | Measure-Object).Count }
    Run-Cmd "149" "Drivers Installed"       { (Get-WmiObject Win32_PnPSignedDriver | Measure-Object).Count }
    Run-Cmd "150" "Unsigned Drivers"        { (Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.Signed -eq $false } | Measure-Object).Count }
    Run-Cmd "151" "NTFS Volumes"            { (Get-WmiObject Win32_LogicalDisk | Where-Object { $_.FileSystem -eq "NTFS" } | Measure-Object).Count }
    Run-Cmd "152" "Total Disk Space"        { Get-WmiObject Win32_LogicalDisk | Measure-Object -Property Size     -Sum | Select-Object @{N='TotalGB';E={[math]::Round($_.Sum/1GB,2)}} }
    Run-Cmd "153" "Free Disk Space"         { Get-WmiObject Win32_LogicalDisk | Measure-Object -Property FreeSpace-Sum | Select-Object @{N='FreeGB' ;E={[math]::Round($_.Sum/1GB,2)}} }
    Run-Cmd "154" "Security Event Records"  { Get-WmiObject Win32_NTEventlogFile | Where-Object { $_.LogFileName -like "*Security*" } | Measure-Object -Property Records -Sum | Select-Object @{N='Records';E={$_.Sum}} }
    Run-Cmd "155" "Auto-Start Count"        { (Get-WmiObject Win32_Service | Where-Object { $_.StartMode -eq "Auto" }     | Measure-Object).Count }
    Run-Cmd "156" "Disabled Services Count" { (Get-WmiObject Win32_Service | Where-Object { $_.StartMode -eq "Disabled" } | Measure-Object).Count }
    Run-Cmd "157" "Process Count"           { (Get-WmiObject Win32_Process | Measure-Object).Count }
    Run-Cmd "158" "PS Instances"            { (Get-WmiObject Win32_Process | Where-Object { $_.Name -like "*powershell*" } | Measure-Object).Count }
    Run-Cmd "159" "Disk Drives Count"       { (Get-WmiObject Win32_LogicalDisk | Measure-Object).Count }
    Run-Cmd "160" "Network Routes"          { (Get-WmiObject Win32_IP4RouteTable | Measure-Object).Count }
    Run-Cmd "161" "Shared Resources"        { (Get-WmiObject Win32_Share | Measure-Object).Count }
    Run-Cmd "162" "User Profiles Count"     { (Get-WmiObject Win32_UserProfile | Measure-Object).Count }
    Run-Cmd "163" "Boot Devices"            { Get-WmiObject Win32_BootConfiguration | Select-Object BootDirectory }
    Run-Cmd "164" "System Enclosure"        { Get-WmiObject Win32_SystemEnclosure | Select-Object Manufacturer,Type,SerialNumber }
    Run-Cmd "165" "BIOS Version"            { Get-WmiObject Win32_BIOS | Select-Object Version,Manufacturer }
    Run-Cmd "166" "Motherboard"             { Get-WmiObject Win32_BaseBoard | Select-Object Manufacturer,Product }
    Run-Cmd "167" "Video Card"              { Get-WmiObject Win32_VideoController | Select-Object Name,DriverVersion }
    Run-Cmd "168" "Sound Card"              { Get-WmiObject Win32_SoundDevice | Select-Object Name,Manufacturer | Select-Object -First 5 }
    Run-Cmd "169" "Printer Devices"         { Get-WmiObject Win32_Printer | Select-Object Name,DriverName | Select-Object -First 10 }
    Run-Cmd "170" "Network Interface Speed" { Get-WmiObject Win32_NetworkAdapter | Select-Object Name,Speed }
    Run-Cmd "171" "Mouse Devices"           { Get-WmiObject Win32_PointingDevice | Select-Object Name,Description | Select-Object -First 5 }
    Run-Cmd "172" "System Files Location"   { Get-WmiObject Win32_OperatingSystem | Select-Object SystemDrive,WindowsDirectory }
    Run-Cmd "173" "Temp Path"               { [System.IO.Path]::GetTempPath() }
    Run-Cmd "174" "User Data Path"          { $env:USERPROFILE }
    Run-Cmd "175" "Computer Domain"         { Get-WmiObject Win32_ComputerSystem | Select-Object Domain }
    Run-Cmd "176" "Computer Name"           { Get-WmiObject Win32_ComputerSystem | Select-Object Name }
    Run-Cmd "177" "Workgroup"               { Get-WmiObject Win32_ComputerSystem | Select-Object Workgroup }
    Run-Cmd "178" "System Locale"           { Get-WmiObject Win32_OperatingSystem | Select-Object Locale }
    Run-Cmd "179" "Time Zone"               { Get-WmiObject Win32_TimeZone | Select-Object StandardName }
    Run-Cmd "180" "Install Date"            { Get-WmiObject Win32_OperatingSystem | Select-Object InstallDate }
    Run-Cmd "181" "Build Number"            { Get-WmiObject Win32_OperatingSystem | Select-Object BuildNumber }
    Run-Cmd "182" "OS Architecture"         { Get-WmiObject Win32_OperatingSystem | Select-Object OSArchitecture }
    Run-Cmd "183" "OS Type"                 { Get-WmiObject Win32_OperatingSystem | Select-Object Caption }
    Run-Cmd "184" "OS Version"              { Get-WmiObject Win32_OperatingSystem | Select-Object Version }
    Run-Cmd "185" "Service Pack"            { Get-WmiObject Win32_OperatingSystem | Select-Object CSDVersion }
    Run-Cmd "186" "Registered User"         { Get-WmiObject Win32_OperatingSystem | Select-Object RegisteredUser }
    Run-Cmd "187" "Manufacturer"            { Get-WmiObject Win32_ComputerSystem | Select-Object Manufacturer }
    Run-Cmd "188" "Computer Model"          { Get-WmiObject Win32_ComputerSystem | Select-Object Model }
    Run-Cmd "189" "CD/DVD Device"           { Get-WmiObject Win32_CDROMDrive | Select-Object Name,Drive }
    Run-Cmd "190" "Modem Devices"           { Get-WmiObject Win32_Modem -ErrorAction SilentlyContinue | Select-Object Name,DeviceType | Select-Object -First 10 }
    Run-Cmd "191" "Startup Commands"        { Get-WmiObject Win32_StartupCommand | Select-Object Name,Command,User }
    Run-Cmd "192" "Mapped Drives"           { (Get-WmiObject Win32_MappedLogicalDisk -ErrorAction SilentlyContinue | Measure-Object).Count }
    Run-Cmd "193" "Total Event Records"     { Get-WmiObject Win32_NTEventlogFile | Measure-Object -Property Records -Sum | Select-Object @{N='Total';E={$_.Sum}} }
    Run-Cmd "194" "Account SID-500"         { Get-WmiObject Win32_UserAccount | Where-Object { $_.SID -like "*-500" } | Select-Object Name,SID,Disabled }
    Run-Cmd "195" "Logon Sessions Count"    { (Get-WmiObject Win32_LogonSession | Measure-Object).Count }
    Run-Cmd "196" "Physical Memory Total"   { Get-WmiObject Win32_ComputerSystem | Select-Object @{N='MemGB';E={[math]::Round($_.TotalPhysicalMemory/1GB,2)}} }
    Run-Cmd "197" "Disk Free Check"         { Get-WmiObject Win32_LogicalDisk | Select-Object DeviceID,@{N='FreeGB';E={[math]::Round($_.FreeSpace/1GB,2)}},@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}} }
    Run-Cmd "198" "Processor Load"          { Get-WmiObject Win32_Processor | Select-Object Name,LoadPercentage }
    Run-Cmd "199" "Page File Current"       { Get-WmiObject Win32_PageFileUsage -ErrorAction SilentlyContinue | Select-Object Name,CurrentUsage,PeakUsage }
    Run-Cmd "200" "System Summary"          { Get-WmiObject Win32_OperatingSystem | Select-Object Caption,BuildNumber,LastBootUpTime,OSArchitecture }
}

# ==== COMMANDS 201-300 : WMI / CIM ADVANCED ====
function Invoke-WMICIMAdvanced {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "WMI / CIM ADVANCED AUDIT (201-300)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header

    # CIM System & Hardware
    Run-Cmd "201" "CIM OS Info"             { Get-CimInstance CIM_OperatingSystem | Select-Object Caption,Version,BuildNumber,OSArchitecture }
    Run-Cmd "202" "CIM Processor"           { Get-CimInstance CIM_Processor       | Select-Object Name,MaxClockSpeed,NumberOfCores,LoadPercentage }
    Run-Cmd "203" "CIM Memory"              { Get-CimInstance CIM_PhysicalMemory  | Select-Object BankLabel,Capacity,Speed,Manufacturer }
    Run-Cmd "204" "CIM Disk Drive"          { Get-CimInstance CIM_DiskDrive       | Select-Object DeviceID,Model,Size,InterfaceType }
    Run-Cmd "205" "CIM Network Adapter"     { Get-CimInstance MSFT_NetAdapter -Namespace root\standardcimv2 -ErrorAction SilentlyContinue | Select-Object Name,InterfaceDescription,LinkSpeed,MacAddress | Select-Object -First 15 }
    Run-Cmd "206" "CIM Hotfixes"            { Get-CimInstance Win32_QuickFixEngineering | Sort-Object InstalledOn -Descending | Select-Object HotFixID,InstalledOn | Select-Object -First 20 }
    Run-Cmd "207" "CIM Firewall Rules"      { Get-CimInstance MSFT_NetFirewallRule -Namespace root\standardcimv2 -ErrorAction SilentlyContinue | Where-Object { $_.Enabled -eq $true } | Select-Object DisplayName,Direction,Action | Select-Object -First 20 }
    Run-Cmd "208" "CIM Firewall Profiles"   { Get-CimInstance MSFT_NetFirewallProfile -Namespace root\standardcimv2 -ErrorAction SilentlyContinue | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction }
    Run-Cmd "209" "CIM TCP Connections"     { Get-CimInstance MSFT_NetTCPConnection -Namespace root\standardcimv2 -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 5 } | Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort | Select-Object -First 30 }
    Run-Cmd "210" "CIM UDP Endpoints"       { Get-CimInstance MSFT_NetUDPEndpoint  -Namespace root\standardcimv2 -ErrorAction SilentlyContinue | Select-Object LocalAddress,LocalPort | Select-Object -First 20 }

    # WMI Security
    Run-Cmd "211" "WMI Event Filters"       { Get-WmiObject -Namespace root\subscription -Class __EventFilter -ErrorAction SilentlyContinue | Select-Object Name,Query }
    Run-Cmd "212" "WMI Event Consumers"     { Get-WmiObject -Namespace root\subscription -Class __EventConsumer -ErrorAction SilentlyContinue | Select-Object Name }
    Run-Cmd "213" "WMI Consumer Bindings"   { Get-WmiObject -Namespace root\subscription -Class __FilterToConsumerBinding -ErrorAction SilentlyContinue | Select-Object Filter,Consumer }
    Run-Cmd "214" "WMI Subscriptions Count" { @{ EventFilters=(Get-WmiObject -Namespace root\subscription -Class __EventFilter -ErrorAction SilentlyContinue | Measure-Object).Count; Consumers=(Get-WmiObject -Namespace root\subscription -Class __EventConsumer -ErrorAction SilentlyContinue | Measure-Object).Count } }
    Run-Cmd "215" "WMI Namespaces"          { Get-WmiObject -Namespace root -Class __Namespace | Select-Object Name }

    # CIM Storage
    Run-Cmd "216" "CIM Storage Disk"        { Get-CimInstance MSFT_Disk -Namespace root\microsoft\windows\storage -ErrorAction SilentlyContinue | Select-Object FriendlyName,Size,PartitionStyle,OperationalStatus }
    Run-Cmd "217" "CIM Partitions"          { Get-CimInstance MSFT_Partition -Namespace root\microsoft\windows\storage -ErrorAction SilentlyContinue | Select-Object DiskNumber,PartitionNumber,Size,DriveLetter | Select-Object -First 20 }
    Run-Cmd "218" "CIM Volumes"             { Get-CimInstance MSFT_Volume -Namespace root\microsoft\windows\storage -ErrorAction SilentlyContinue | Select-Object DriveLetter,FileSystem,Size,SizeRemaining | Select-Object -First 10 }
    Run-Cmd "219" "WMI Shadow Copies"       { Get-WmiObject Win32_ShadowCopy -ErrorAction SilentlyContinue | Select-Object ID,VolumeName,InstallDate,CreationTime }
    Run-Cmd "220" "WMI Disk Quotas"         { Get-WmiObject Win32_DiskQuota -ErrorAction SilentlyContinue | Select-Object User,DiskSpaceUsed,Limit | Select-Object -First 15 }

    # Process & Task Details
    Run-Cmd "221" "CIM Process List"        { Get-CimInstance Win32_Process | Select-Object ProcessId,Name,CreationDate | Select-Object -First 30 }
    Run-Cmd "222" "Scheduled Tasks Basic"   { Get-WmiObject Win32_ScheduledJob -ErrorAction SilentlyContinue | Select-Object JobId,Name,Command,RunRepeatedly }
    Run-Cmd "223" "CIM Scheduled Tasks"     { Get-CimInstance MSFT_ScheduledTask -Namespace root\microsoft\windows\taskscheduler -ErrorAction SilentlyContinue | Select-Object TaskName,TaskPath,State | Select-Object -First 30 }
    Run-Cmd "224" "WMI Process Owners"      { Get-WmiObject Win32_Process | Select-Object -First 20 | ForEach-Object { $o=$null; try{$o=$_.GetOwner().User}catch{}; [PSCustomObject]@{PID=$_.ProcessId;Name=$_.Name;Owner=$o} } }
    Run-Cmd "225" "WMI Process Details"     { Get-WmiObject Win32_Process | Sort-Object WorkingSetSize -Desc | Select-Object ProcessId,Name,@{N='MemMB';E={[math]::Round($_.WorkingSetSize/1MB,1)}},Priority | Select-Object -First 25 }

    # Network Advanced
    Run-Cmd "226" "WMI DNS Cache"           { Get-WmiObject -Namespace root\standardcimv2 -Class MSFT_DNSClientCache -ErrorAction SilentlyContinue | Select-Object Entry,Data,Type | Select-Object -First 30 }
    Run-Cmd "227" "WMI ARP Table"           { Get-WmiObject -Namespace root\standardcimv2 -Class MSFT_NetNeighbor -ErrorAction SilentlyContinue | Select-Object InterfaceAlias,IPAddress,LinkLayerAddress,State | Select-Object -First 30 }
    Run-Cmd "228" "WMI Net IP Addresses"    { Get-WmiObject -Namespace root\standardcimv2 -Class MSFT_NetIPAddress -ErrorAction SilentlyContinue | Select-Object InterfaceAlias,IPAddress,PrefixLength,AddressFamily | Select-Object -First 20 }
    Run-Cmd "229" "CIM Net Interface Stats" { Get-CimInstance Win32_PerfRawData_Tcpip_NetworkInterface -ErrorAction SilentlyContinue | Select-Object Name,BytesReceivedPerSec,BytesSentPerSec | Select-Object -First 10 }
    Run-Cmd "230" "WMI Proxy Settings"      { Get-WmiObject -Namespace root\cimv2 -Class Win32_Registry -ErrorAction SilentlyContinue | Select-Object ProposedSize | Select-Object -First 5; Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue | Select-Object ProxyEnable,ProxyServer }

    # Security & Audit
    Run-Cmd "231" "CIM AV Products"         { Get-CimInstance -Namespace root\securitycenter2 -Class AntiVirusProduct -ErrorAction SilentlyContinue | Select-Object DisplayName,productState,pathToSignedProductExe }
    Run-Cmd "232" "CIM Firewall Products"   { Get-CimInstance -Namespace root\securitycenter2 -Class FirewallProduct    -ErrorAction SilentlyContinue | Select-Object DisplayName,productState }
    Run-Cmd "233" "CIM AntiSpyware"         { Get-CimInstance -Namespace root\securitycenter2 -Class AntiSpywareProduct -ErrorAction SilentlyContinue | Select-Object DisplayName,productState }
    Run-Cmd "234" "WMI Security Providers"  { Get-WmiObject -Namespace root\securitycenter2 -List -ErrorAction SilentlyContinue | Select-Object Name }
    Run-Cmd "235" "BitLocker Status"        { Get-WmiObject -Namespace root\cimv2\security\microsoftvolumeencryption -Class Win32_EncryptableVolume -ErrorAction SilentlyContinue | Select-Object DriveLetter,EncryptionMethod,ProtectionStatus,ConversionStatus }

    # Event Logs
    Run-Cmd "236" "WMI Event Log Files"     { Get-WmiObject Win32_NTEventlogFile | Select-Object LogFileName,FileSize,NumberOfRecords,OverwritePolicy }
    Run-Cmd "237" "Security Log Records"    { Get-WmiObject Win32_NTEventlogFile | Where-Object { $_.LogFileName -eq "Security" } | Select-Object FileSize,NumberOfRecords,MaxFileSize }
    Run-Cmd "238" "System Log Records"      { Get-WmiObject Win32_NTEventlogFile | Where-Object { $_.LogFileName -eq "System"   } | Select-Object FileSize,NumberOfRecords,MaxFileSize }
    Run-Cmd "239" "Application Log Records" { Get-WmiObject Win32_NTEventlogFile | Where-Object { $_.LogFileName -eq "Application" } | Select-Object FileSize,NumberOfRecords,MaxFileSize }
    Run-Cmd "240" "WMI Recent Events(T+)"   { Get-WmiObject Win32_NTLogEvent -Filter "Logfile='System' AND TimeGenerated > '$(([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).AddHours(-6))))'" -ErrorAction SilentlyContinue | Select-Object EventCode,TimeGenerated,Message | Select-Object -First 20 }

    # Software & Updates
    Run-Cmd "241" "WMI Installed Software"  { Get-WmiObject Win32_InstalledSoftwareElement -ErrorAction SilentlyContinue | Select-Object SoftwareElementID,Version | Select-Object -First 30 }
    Run-Cmd "242" "CIM DISM Packages"       { Get-CimInstance Win32_OptionalFeature -ErrorAction SilentlyContinue | Where-Object { $_.InstallState -eq 1 } | Select-Object Caption,Name | Select-Object -First 20 }
    Run-Cmd "243" "WMI Product Features"    { Get-WmiObject Win32_SoftwareFeature -ErrorAction SilentlyContinue | Select-Object ProductName,Version,InstallState | Select-Object -First 30 } -Slow
    Run-Cmd "244" "WMI MSI Elements"        { Get-WmiObject Win32_SoftwareElement -ErrorAction SilentlyContinue | Select-Object SoftwareElementID,Manufacturer,Version | Select-Object -First 20 } -Slow
    Run-Cmd "245" "CIM Win32 Product"       { Get-CimInstance Win32_Product -ErrorAction SilentlyContinue | Select-Object Name,Version,Vendor | Select-Object -First 30 } -Slow

    # Registry & Config
    Run-Cmd "246" "WMI Registry Size"       { Get-WmiObject Win32_Registry | Select-Object CurrentSize,MaximumSize,ProposedSize }
    Run-Cmd "247" "WMI Environment Vars"    { Get-WmiObject Win32_Environment | Select-Object Name,VariableValue,SystemVariable | Select-Object -First 30 }
    Run-Cmd "248" "WMI Startup Items"       { Get-WmiObject Win32_StartupCommand | Select-Object Name,Command,Location,User }
    Run-Cmd "249" "CIM System Restore Pts"  { Get-CimInstance Win32_ShadowCopy -ErrorAction SilentlyContinue | Select-Object DeviceObject,VolumeName,CreationTime,Description }
    Run-Cmd "250" "WMI ODBC Sources"        { Get-WmiObject Win32_ODBCDataSourceSpecification -ErrorAction SilentlyContinue | Select-Object Name,Driver,DataSource | Select-Object -First 20 }

    # Hardware Extended
    Run-Cmd "251" "CIM Battery Info"        { Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object Name,BatteryStatus,EstimatedChargeRemaining,EstimatedRunTime }
    Run-Cmd "252" "WMI USB Controllers"     { Get-WmiObject Win32_USBController | Select-Object Name,Status,DeviceID }
    Run-Cmd "253" "WMI USB Hub"             { Get-WmiObject Win32_USBHub -ErrorAction SilentlyContinue | Select-Object Name,Status,DeviceID | Select-Object -First 10 }
    Run-Cmd "254" "WMI IR Devices"          { Get-WmiObject Win32_InfraredDevice -ErrorAction SilentlyContinue | Select-Object Name,Status | Select-Object -First 5 }
    Run-Cmd "255" "CIM Fan Info"            { Get-CimInstance Win32_Fan -ErrorAction SilentlyContinue | Select-Object Name,Status,DesiredSpeed }
    Run-Cmd "256" "CIM Temperature"         { Get-CimInstance MSAcpi_ThermalZoneTemperature -Namespace root\wmi -ErrorAction SilentlyContinue | Select-Object InstanceName,CurrentTemperature }
    Run-Cmd "257" "WMI Port Connections"    { Get-WmiObject Win32_PortConnector -ErrorAction SilentlyContinue | Select-Object Tag,ConnectorType,PortType | Select-Object -First 15 }
    Run-Cmd "258" "WMI Serial Ports"        { Get-WmiObject Win32_SerialPort -ErrorAction SilentlyContinue | Select-Object Name,Status,DeviceID }
    Run-Cmd "259" "WMI Parallel Ports"      { Get-WmiObject Win32_ParallelPort -ErrorAction SilentlyContinue | Select-Object Name,Status,DeviceID }
    Run-Cmd "260" "WMI PCMCIA Controller"   { Get-WmiObject Win32_PCMCIAController -ErrorAction SilentlyContinue | Select-Object Name,Status }

    # Performance
    Run-Cmd "261" "WMI CPU Perf"            { Get-WmiObject Win32_PerfFormattedData_PerfOS_Processor -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq "_Total" } | Select-Object PercentProcessorTime,PercentIdleTime }
    Run-Cmd "262" "WMI Memory Perf"         { Get-WmiObject Win32_PerfFormattedData_PerfOS_Memory   -ErrorAction SilentlyContinue | Select-Object AvailableMBytes,CacheBytes,PageFaultsPersec,PagesPerSec }
    Run-Cmd "263" "WMI Disk Perf"           { Get-WmiObject Win32_PerfFormattedData_PerfDisk_LogicalDisk -ErrorAction SilentlyContinue | Select-Object Name,PercentDiskTime,DiskBytesPerSec | Select-Object -First 10 }
    Run-Cmd "264" "WMI System Perf"         { Get-WmiObject Win32_PerfFormattedData_PerfOS_System   -ErrorAction SilentlyContinue | Select-Object Processes,Threads,SystemCallsPersec,FileControlBytesPersec }
    Run-Cmd "265" "WMI Paging File Perf"    { Get-WmiObject Win32_PerfFormattedData_PerfOS_PagingFile -ErrorAction SilentlyContinue | Select-Object Name,PercentUsage,PercentUsagePeak }

    # Network CIM Advanced
    Run-Cmd "266" "CIM IP Config"           { Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } | Select-Object Description,IPAddress,MACAddress,DefaultIPGateway }
    Run-Cmd "267" "CIM TCP Stats"           { Get-CimInstance Win32_PerfRawData_Tcpip_TCPv4 -ErrorAction SilentlyContinue | Select-Object ConnectionsEstablished,ConnectionsReset,SegmentsRetransmittedPersec }
    Run-Cmd "268" "CIM UDP Stats"           { Get-CimInstance Win32_PerfRawData_Tcpip_UDPv4 -ErrorAction SilentlyContinue | Select-Object DatagramsReceivedErrors,DatagramsSentPerSec }
    Run-Cmd "269" "WMI WINS Config"         { Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } | Select-Object Description,WINSPrimaryServer,WINSSecondaryServer }
    Run-Cmd "270" "WMI SNMP Settings"       { Get-WmiObject Win32_SNMPSetting -ErrorAction SilentlyContinue | Select-Object Agent,Community,PermittedManagers | Select-Object -First 10 }

    # WMI Audit & Compliance
    Run-Cmd "271" "WMI OS Installed Roles"  { Get-CimInstance Win32_ServerFeature -ErrorAction SilentlyContinue | Select-Object Name,ID,ParentID | Select-Object -First 20 }
    Run-Cmd "272" "WMI Shared Config"       { Get-WmiObject Win32_Share | Where-Object { $_.Type -eq 0 } | Select-Object Name,Path,Description }
    Run-Cmd "273" "WMI Admin Shares"        { Get-WmiObject Win32_Share | Where-Object { $_.Name -match "ADMIN\$|C\$|IPC\$" } | Select-Object Name,Path,Type }
    Run-Cmd "274" "WMI Remote Cmd Config"   { Get-WmiObject Win32_TerminalServiceSetting -ErrorAction SilentlyContinue | Select-Object PolicySourceTerminalServer,AllowLogoff,TerminalServerMode }
    Run-Cmd "275" "WMI Logon Policy"        { Get-WmiObject Win32_UserAccount | Select-Object Name,PasswordRequired,PasswordExpires,PasswordChangeable,Lockout | Select-Object -First 20 }

    # CIM Advanced Security
    Run-Cmd "276" "CIM AppLocker Policy"    { Get-CimInstance MSFT_AppLockerPolicy -Namespace root\microsoft\windows\applocker -ErrorAction SilentlyContinue | Select-Object * | Select-Object -First 10 }
    Run-Cmd "277" "CIM Defender Settings"   { Get-CimInstance MSFT_MpPreference -Namespace root\microsoft\windows\defender -ErrorAction SilentlyContinue | Select-Object DisableRealtimeMonitoring,DisableBehaviorMonitoring,ExclusionPath }
    Run-Cmd "278" "CIM Defender Status"     { Get-CimInstance MSFT_MpComputerStatus -Namespace root\microsoft\windows\defender -ErrorAction SilentlyContinue | Select-Object AMServiceEnabled,AntispywareEnabled,AntivirusEnabled,RealTimeProtectionEnabled,IoavProtectionEnabled }
    Run-Cmd "279" "CIM TPM Info"            { Get-CimInstance Win32_Tpm -Namespace root\cimv2\security\microsofttpm -ErrorAction SilentlyContinue | Select-Object IsActivated_InitialValue,IsEnabled_InitialValue,IsOwned_InitialValue,PhysicalPresenceVersionInfo }
    Run-Cmd "280" "CIM UAC Status"          { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -ErrorAction SilentlyContinue | Select-Object EnableLUA,ConsentPromptBehaviorAdmin,PromptOnSecureDesktop }

    # WMI Certificate & Credential
    Run-Cmd "281" "WMI Cert Authorities"    { Get-WmiObject -Namespace root\cimv2 -Class Win32_CertificateAuthority -ErrorAction SilentlyContinue | Select-Object Name,Location | Select-Object -First 10 }
    Run-Cmd "282" "WMI Credential Guard"    { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\LSA' -ErrorAction SilentlyContinue | Select-Object LsaCfgFlags,RunAsPPL,auditlsapolicy }
    Run-Cmd "283" "WMI PS Execution Policy" { Get-WmiObject Win32_Environment | Where-Object { $_.Name -like "*PSExecutionPolicyPreference*" } | Select-Object Name,VariableValue; Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell' -ErrorAction SilentlyContinue | Select-Object ExecutionPolicy }
    Run-Cmd "284" "WMI AMSI Status"         { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\AMSI' -ErrorAction SilentlyContinue | Select-Object *; Get-WmiObject Win32_Process | Where-Object { $_.Name -like "*amsi*" } | Select-Object Name,ProcessId }
    Run-Cmd "285" "WMI SecureBoot"          { Confirm-SecureBootUEFI -ErrorAction SilentlyContinue; Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State' -ErrorAction SilentlyContinue | Select-Object UEFISecureBootEnabled }

    # Application & DLL
    Run-Cmd "286" "WMI COM Objects"         { Get-WmiObject Win32_ClassicCOMClass -ErrorAction SilentlyContinue | Select-Object ComponentId,ProgId,InprocServer32 | Select-Object -First 20 }
    Run-Cmd "287" "WMI .NET Versions"       { Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.GetValue('Version') } | Select-Object -ExpandProperty PSChildName }
    Run-Cmd "288" "WMI App Compat Flags"    { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -ErrorAction SilentlyContinue }
    Run-Cmd "289" "WMI Path Hijack Check"   { $env:PATH -split ';' | ForEach-Object { [PSCustomObject]@{Path=$_;Writable=( Test-Path $_ )} } | Select-Object -First 15 }
    Run-Cmd "290" "WMI DLL SafeSearch"      { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -ErrorAction SilentlyContinue | Select-Object SafeDllSearchMode }

    # WMI Remote / Lateral
    Run-Cmd "291" "WMI Open Ports Check"    { Get-WmiObject Win32_PerfRawData_Tcpip_TCPv4 -ErrorAction SilentlyContinue | Select-Object ConnectionsEstablished,ConnectionsPassiveOpening,ConnectionsActiveOpening }
    Run-Cmd "292" "WMI WinRM Status"        { Get-WmiObject Win32_Service | Where-Object { $_.Name -eq "WinRM" } | Select-Object Name,State,StartMode }
    Run-Cmd "293" "WMI Remote Registry"     { Get-WmiObject Win32_Service | Where-Object { $_.Name -eq "RemoteRegistry" } | Select-Object Name,State,StartMode }
    Run-Cmd "294" "WMI Telnet Service"      { Get-WmiObject Win32_Service | Where-Object { $_.Name -eq "tlntsvr" } | Select-Object Name,State,StartMode }
    Run-Cmd "295" "WMI SMB Config"          { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -ErrorAction SilentlyContinue | Select-Object SMB1,EnableSecuritySignature,RequireSecuritySignature }

    # Misc WMI
    Run-Cmd "296" "WMI Page File Size"      { Get-WmiObject Win32_PageFileUsage -ErrorAction SilentlyContinue | Select-Object Name,AllocatedBaseSize,CurrentUsage,PeakUsage }
    Run-Cmd "297" "WMI Logical Net Config"  { Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } | Select-Object Description,WINSPrimaryServer,IPFilterSecurityEnabled }
    Run-Cmd "298" "WMI System Printers"     { Get-WmiObject Win32_Printer | Select-Object Name,DriverName,PortName,Default | Select-Object -First 15 }
    Run-Cmd "299" "WMI Fax Service"         { Get-WmiObject Win32_Service | Where-Object { $_.Name -eq "Fax" } | Select-Object Name,State,StartMode }
    Run-Cmd "300" "WMI Full System Digest"  { [PSCustomObject]@{
        ComputerName=$env:COMPUTERNAME; OS=(Get-WmiObject Win32_OperatingSystem).Caption; BuildNumber=(Get-WmiObject Win32_OperatingSystem).BuildNumber
        Users=(Get-WmiObject Win32_UserAccount | Measure-Object).Count; Groups=(Get-WmiObject Win32_Group | Measure-Object).Count
        Services=(Get-WmiObject Win32_Service | Measure-Object).Count; Processes=(Get-WmiObject Win32_Process | Measure-Object).Count
        Shares=(Get-WmiObject Win32_Share | Measure-Object).Count; Hotfixes=(Get-WmiObject Win32_QuickFixEngineering | Measure-Object).Count
        AutoRun=(Get-WmiObject Win32_StartupCommand | Measure-Object).Count
    } }
}

# ==== COMMANDS 301-340 : STORAGE AND DISK ====
function Invoke-StorageDisk {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "STORAGE AND DISK (301-340)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "301" "Physical Disks"               { Get-WmiObject Win32_DiskDrive | Select-Object Caption,DeviceID,Size,MediaType,InterfaceType }
    Run-Cmd "302" "Disk Partitions"              { Get-WmiObject Win32_DiskPartition | Select-Object Name,Size,Type,StartingOffset,DiskIndex }
    Run-Cmd "303" "Logical Disk to Partition"    { Get-WmiObject Win32_LogicalDiskToPartition | Select-Object Antecedent,Dependent }
    Run-Cmd "304" "Disk to Partition Map"        { Get-WmiObject Win32_DiskDriveToDiskPartition | Select-Object Antecedent,Dependent }
    Run-Cmd "305" "Volume Shadow Copies"         { Get-WmiObject Win32_ShadowCopy | Select-Object ID,VolumeName,InstallDate,Count }
    Run-Cmd "306" "Shadow Storage"               { Get-WmiObject Win32_ShadowStorage -ErrorAction SilentlyContinue | Select-Object Volume,AllocatedSpace,MaxSpace,UsedSpace }
    Run-Cmd "307" "Mounted Volumes"              { Get-WmiObject Win32_Volume | Select-Object Name,Label,Capacity,FreeSpace,DriveType }
    Run-Cmd "308" "Mapped Drives"                { Get-WmiObject Win32_MappedLogicalDisk -ErrorAction SilentlyContinue | Select-Object Name,ProviderName,Size,FreeSpace }
    Run-Cmd "309" "Disk Drive Models"            { Get-WmiObject Win32_DiskDrive | Select-Object Model,SerialNumber,FirmwareRevision,TotalCylinders }
    Run-Cmd "310" "Disk Free Space %"            { Get-WmiObject Win32_LogicalDisk | Where-Object { $_.Size -gt 0 } | Select-Object DeviceID,@{n='Free%';e={[math]::Round($_.FreeSpace/$_.Size*100,1)}} }
    Run-Cmd "311" "NTFS Volumes"                 { Get-WmiObject Win32_Volume | Where-Object { $_.FileSystem -eq "NTFS" } | Select-Object Name,Label,FileSystem }
    Run-Cmd "312" "FAT Volumes"                  { Get-WmiObject Win32_Volume | Where-Object { $_.FileSystem -like "FAT*" } | Select-Object Name,FileSystem }
    Run-Cmd "313" "Removable Media"              { Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 } | Select-Object DeviceID,Description }
    Run-Cmd "314" "Network Drive Letters"        { Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 4 } | Select-Object DeviceID,ProviderName }
    Run-Cmd "315" "Optical Drives"               { Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 5 } | Select-Object DeviceID,Description }
    Run-Cmd "316" "Disk Quota Setting"           { Get-WmiObject Win32_QuotaSetting -ErrorAction SilentlyContinue | Select-Object VolumePath,State,DefaultLimit,DefaultWarningLimit }
    Run-Cmd "317" "Disk Quota Usage"             { Get-WmiObject Win32_DiskQuota -ErrorAction SilentlyContinue | Select-Object User,DiskSpaceUsed,Limit,WarningLimit | Select-Object -First 20 }
    Run-Cmd "318" "Portable Battery"             { Get-WmiObject Win32_Battery -ErrorAction SilentlyContinue | Select-Object Name,BatteryStatus,EstimatedChargeRemaining }
    Run-Cmd "319" "Storage Reliability"          { Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction SilentlyContinue | Select-Object InstanceName,PredictFailure,Reason }
    Run-Cmd "320" "Disk Geometry"                { Get-WmiObject Win32_DiskDrive | Select-Object DeviceID,BytesPerSector,SectorsPerTrack,TotalHeads,TotalTracks }
    Run-Cmd "321" "CIM Disk Drives"              { Get-CimInstance Win32_DiskDrive | Select-Object DeviceID,Model,Size,Status }
    Run-Cmd "322" "CIM Partitions"               { Get-CimInstance Win32_DiskPartition | Select-Object Name,Size,BootPartition,PrimaryPartition }
    Run-Cmd "323" "CIM Logical Disks"            { Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID,FileSystem,Size,FreeSpace,VolumeName }
    Run-Cmd "324" "Storage Pool Info"            { Get-CimInstance -Namespace root\microsoft\windows\storage -ClassName MSFT_StoragePool -ErrorAction SilentlyContinue | Select-Object FriendlyName,HealthStatus,OperationalStatus,Size }
    Run-Cmd "325" "Virtual Disks"                { Get-CimInstance -Namespace root\microsoft\windows\storage -ClassName MSFT_VirtualDisk -ErrorAction SilentlyContinue | Select-Object FriendlyName,Size,HealthStatus }
    Run-Cmd "326" "Physical Disk Health"         { Get-CimInstance -Namespace root\microsoft\windows\storage -ClassName MSFT_PhysicalDisk -ErrorAction SilentlyContinue | Select-Object FriendlyName,MediaType,HealthStatus,Size }
    Run-Cmd "327" "BitLocker Status"             { Get-CimInstance Win32_EncryptableVolume -Namespace root\cimv2\security\microsoftvolumeencryption -ErrorAction SilentlyContinue | Select-Object DriveLetter,ProtectionStatus,EncryptionPercentage }
    Run-Cmd "328" "Volume Mount Points"          { Get-WmiObject Win32_Volume | Where-Object { $_.Name -notmatch "^[A-Za-z]:\\" } | Select-Object Name,DeviceID }
    Run-Cmd "329" "Disk Performance Counters"    { Get-WmiObject Win32_PerfRawData_PerfDisk_PhysicalDisk -ErrorAction SilentlyContinue | Select-Object Name,DiskReadBytesPerSec,DiskWriteBytesPerSec | Select-Object -First 5 }
    Run-Cmd "330" "Logical Disk Performance"     { Get-WmiObject Win32_PerfRawData_PerfDisk_LogicalDisk -ErrorAction SilentlyContinue | Select-Object Name,PercentDiskTime,AvgDiskQueueLength | Select-Object -First 5 }
    Run-Cmd "331" "Disk Size Summary"            { Get-WmiObject Win32_DiskDrive | Select-Object @{n='Disk';e={$_.DeviceID}},@{n='SizeGB';e={[math]::Round($_.Size/1GB,2)}} }
    Run-Cmd "332" "Volume Labels"                { Get-WmiObject Win32_Volume | Select-Object Name,Label,SerialNumber }
    Run-Cmd "333" "Disk Manufacturer"            { Get-WmiObject Win32_DiskDrive | Select-Object Caption,Manufacturer,SerialNumber }
    Run-Cmd "334" "Page File Usage"              { Get-WmiObject Win32_PageFileUsage | Select-Object Name,AllocatedBaseSize,CurrentUsage,PeakUsage }
    Run-Cmd "335" "NTFS Compression"             { Get-WmiObject Win32_Volume | Where-Object { $_.Compressed } | Select-Object Name,Label }
    Run-Cmd "336" "Temp Directory Path"          { [PSCustomObject]@{TempPath=$env:TEMP; SystemTemp="$env:WINDIR\Temp"; Exists=(Test-Path $env:TEMP)} }
    Run-Cmd "337" "Recycle Bin Size"             { Get-WmiObject Win32_ShadowCopy | Measure-Object -Property Count -Sum | Select-Object Sum,Count }
    Run-Cmd "338" "CIM Volume Shadow"            { Get-CimInstance Win32_ShadowCopy -ErrorAction SilentlyContinue | Select-Object ID,VolumeName,CreationTime | Select-Object -First 10 }
    Run-Cmd "339" "Disk Bus Type"                { Get-WmiObject Win32_DiskDrive | Select-Object DeviceID,InterfaceType,MediaType }
    Run-Cmd "340" "Storage Volumes Count"        { [PSCustomObject]@{PhysicalDisks=(Get-WmiObject Win32_DiskDrive|Measure-Object).Count; Partitions=(Get-WmiObject Win32_DiskPartition|Measure-Object).Count; LogicalDisks=(Get-WmiObject Win32_LogicalDisk|Measure-Object).Count; Volumes=(Get-WmiObject Win32_Volume|Measure-Object).Count} }
}

# ==== COMMANDS 341-380 : SECURITY AND FIREWALL ====
function Invoke-SecurityFirewall {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "SECURITY AND FIREWALL (341-380)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "341" "Firewall Profiles"            { Get-WmiObject -Namespace root\standardcimv2 -Class MSFT_NetFirewallProfile -ErrorAction SilentlyContinue | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction }
    Run-Cmd "342" "Firewall Rules Count"         { (Get-WmiObject -Namespace root\standardcimv2 -Class MSFT_NetFirewallRule -ErrorAction SilentlyContinue | Measure-Object).Count }
    Run-Cmd "343" "Enabled Firewall Rules"       { Get-WmiObject -Namespace root\standardcimv2 -Class MSFT_NetFirewallRule -ErrorAction SilentlyContinue | Where-Object { $_.Enabled -eq 1 } | Select-Object DisplayName,Direction,Action | Select-Object -First 20 }
    Run-Cmd "344" "Inbound Block Rules"          { Get-WmiObject -Namespace root\standardcimv2 -Class MSFT_NetFirewallRule -ErrorAction SilentlyContinue | Where-Object { $_.Direction -eq 1 -and $_.Action -eq 2 } | Select-Object DisplayName,Profile | Select-Object -First 15 }
    Run-Cmd "345" "Outbound Rules"               { Get-WmiObject -Namespace root\standardcimv2 -Class MSFT_NetFirewallRule -ErrorAction SilentlyContinue | Where-Object { $_.Direction -eq 2 } | Select-Object DisplayName,Action | Select-Object -First 15 }
    Run-Cmd "346" "Antivirus Products"           { Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct -ErrorAction SilentlyContinue | Select-Object DisplayName,ProductState,pathToSignedProductExe }
    Run-Cmd "347" "Antispyware Products"         { Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiSpywareProduct -ErrorAction SilentlyContinue | Select-Object DisplayName,ProductState }
    Run-Cmd "348" "Firewall Products"            { Get-WmiObject -Namespace root\SecurityCenter2 -Class FirewallProduct -ErrorAction SilentlyContinue | Select-Object DisplayName,ProductState }
    Run-Cmd "349" "Defender Status"              { Get-CimInstance -Namespace root\microsoft\windows\defender -Class MSFT_MpComputerStatus -ErrorAction SilentlyContinue | Select-Object RealTimeProtectionEnabled,AntivirusEnabled,AntispywareEnabled,NISEnabled }
    Run-Cmd "350" "Defender Preferences"         { Get-CimInstance -Namespace root\microsoft\windows\defender -Class MSFT_MpPreference -ErrorAction SilentlyContinue | Select-Object DisableRealtimeMonitoring,ExclusionPath,ExclusionExtension | Select-Object -First 5 }
    Run-Cmd "351" "Defender Threat History"      { Get-CimInstance -Namespace root\microsoft\windows\defender -Class MSFT_MpThreat -ErrorAction SilentlyContinue | Select-Object ThreatID,ThreatName,SeverityID | Select-Object -First 15 }
    Run-Cmd "352" "AppLocker Policy"             { Get-WmiObject -Namespace root\cimv2 -Class Win32_Environment | Where-Object { $_.Name -like "*AppLocker*" } | Select-Object Name,VariableValue; Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SrpV2' -ErrorAction SilentlyContinue }
    Run-Cmd "353" "WDAC Policy"                  { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy' -ErrorAction SilentlyContinue | Select-Object * | Select-Object -First 5 }
    Run-Cmd "354" "UAC Level"                    { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -ErrorAction SilentlyContinue | Select-Object EnableLUA,ConsentPromptBehaviorAdmin,ConsentPromptBehaviorUser }
    Run-Cmd "355" "Windows Defender Exclusions"  { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions' -ErrorAction SilentlyContinue }
    Run-Cmd "356" "LSA Protection"               { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\LSA' -ErrorAction SilentlyContinue | Select-Object RunAsPPL,LsaCfgFlags,RestrictAnonymous }
    Run-Cmd "357" "Secure Boot State"            { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State' -ErrorAction SilentlyContinue | Select-Object UEFISecureBootEnabled }
    Run-Cmd "358" "Windows Update Config"        { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' -ErrorAction SilentlyContinue | Select-Object AUOptions,ScheduledInstallDay,ScheduledInstallTime }
    Run-Cmd "359" "Audit Policy Settings"        { auditpol /get /category:* 2>$null }
    Run-Cmd "360" "WDigest Auth Status"          { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest' -ErrorAction SilentlyContinue | Select-Object UseLogonCredential }
    Run-Cmd "361" "NTLM Security Level"          { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\LSA' -ErrorAction SilentlyContinue | Select-Object LmCompatibilityLevel }
    Run-Cmd "362" "Always Install Elevated"      { Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer' -ErrorAction SilentlyContinue | Select-Object AlwaysInstallElevated; Get-ItemProperty 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer' -ErrorAction SilentlyContinue | Select-Object AlwaysInstallElevated }
    Run-Cmd "363" "ASR Rules"                    { Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules' -ErrorAction SilentlyContinue }
    Run-Cmd "364" "DEP Policy"                   { Get-WmiObject Win32_OperatingSystem | Select-Object DataExecutionPrevention_Drivers,DataExecutionPrevention_Available,DataExecutionPrevention_32BitApplications,DataExecutionPrevention_SupportPolicy }
    Run-Cmd "365" "SEHOP Status"                 { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' -ErrorAction SilentlyContinue | Select-Object DisableExceptionChainValidation }
    Run-Cmd "366" "Kernel ASLR"                  { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -ErrorAction SilentlyContinue | Select-Object MoveImages }
    Run-Cmd "367" "CFG Status"                   { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' -ErrorAction SilentlyContinue | Select-Object MitigationOptions }
    Run-Cmd "368" "TPM Status"                   { Get-CimInstance Win32_Tpm -Namespace root\cimv2\security\microsofttpm -ErrorAction SilentlyContinue | Select-Object IsActivated_InitialValue,IsEnabled_InitialValue,IsOwned_InitialValue,SpecVersion }
    Run-Cmd "369" "Credential Guard Status"      { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard' -ErrorAction SilentlyContinue | Select-Object EnableVirtualizationBasedSecurity,RequirePlatformSecurityFeatures }
    Run-Cmd "370" "Exploit Protection"           { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options' -ErrorAction SilentlyContinue | Select-Object * | Select-Object -First 10 }
    Run-Cmd "371" "Windows Firewall Log"         { Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging' -ErrorAction SilentlyContinue | Select-Object LogFilePath,LogFileSize,LogDroppedPackets,LogSuccessfulConnections }
    Run-Cmd "372" "AppContainer Status"          { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -ErrorAction SilentlyContinue | Select-Object PromptOnSecureDesktop,EnableUIADesktopToggle }
    Run-Cmd "373" "EFS Cipher State"             { Get-WmiObject -Namespace root\cimv2 -Class Win32_LogicalFileSecuritySetting -ErrorAction SilentlyContinue | Select-Object Path | Select-Object -First 10 }
    Run-Cmd "374" "Hotfix / Patch Count"         { (Get-WmiObject Win32_QuickFixEngineering | Measure-Object).Count }
    Run-Cmd "375" "Recent Hotfixes"              { Get-WmiObject Win32_QuickFixEngineering | Select-Object HotFixID,InstalledOn,Description | Sort-Object InstalledOn -Descending | Select-Object -First 15 }
    Run-Cmd "376" "WU Last Install Date"         { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\Results\Install' -ErrorAction SilentlyContinue | Select-Object LastSuccessTime }
    Run-Cmd "377" "WU Server URL"                { Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -ErrorAction SilentlyContinue | Select-Object WUServer,WUStatusServer }
    Run-Cmd "378" "Windows Event Forwarding"     { Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager' -ErrorAction SilentlyContinue }
    Run-Cmd "379" "Script Block Logging"         { Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -ErrorAction SilentlyContinue | Select-Object EnableScriptBlockLogging,EnableScriptBlockInvocationLogging }
    Run-Cmd "380" "Module Logging"               { Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging' -ErrorAction SilentlyContinue | Select-Object EnableModuleLogging }
}

# ==== COMMANDS 381-420 : REGISTRY AND CONFIG ====
function Invoke-RegistryConfig {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "REGISTRY AND CONFIG (381-420)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "381" "All Env Variables"            { Get-WmiObject Win32_Environment | Select-Object Name,VariableValue,UserName | Select-Object -First 40 }
    Run-Cmd "382" "System Env Variables"         { Get-WmiObject Win32_Environment | Where-Object { $_.SystemVariable } | Select-Object Name,VariableValue }
    Run-Cmd "383" "User Env Variables"           { Get-WmiObject Win32_Environment | Where-Object { -not $_.SystemVariable } | Select-Object Name,VariableValue,UserName | Select-Object -First 20 }
    Run-Cmd "384" "Run Keys HKLM"                { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue }
    Run-Cmd "385" "Run Keys HKCU"                { Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue }
    Run-Cmd "386" "RunOnce HKLM"                 { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -ErrorAction SilentlyContinue }
    Run-Cmd "387" "RunOnce HKCU"                 { Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -ErrorAction SilentlyContinue }
    Run-Cmd "388" "RunOnceEx HKLM"               { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx' -ErrorAction SilentlyContinue }
    Run-Cmd "389" "Wow6432 Run Keys"             { Get-ItemProperty 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue }
    Run-Cmd "390" "Terminal Server Run"          { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\Install\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue }
    Run-Cmd "391" "Policies Run Keys"            { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run' -ErrorAction SilentlyContinue; Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run' -ErrorAction SilentlyContinue }
    Run-Cmd "392" "Shell Open Commands"          { Get-Item 'HKLM:\SOFTWARE\Classes\exefile\shell\open\command' -ErrorAction SilentlyContinue | Get-ItemProperty | Select-Object '(default)' }
    Run-Cmd "393" "Command Processor AutoRun"    { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Command Processor' -ErrorAction SilentlyContinue | Select-Object AutoRun }
    Run-Cmd "394" "AppInit DLLs"                 { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows' -ErrorAction SilentlyContinue | Select-Object AppInit_DLLs,LoadAppInit_DLLs }
    Run-Cmd "395" "Winlogon Keys"                { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -ErrorAction SilentlyContinue | Select-Object Userinit,Shell,Notify }
    Run-Cmd "396" "LSA Auth Packages"            { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\LSA' -ErrorAction SilentlyContinue | Select-Object Authentication_Packages,Notification_Packages,Security_Packages }
    Run-Cmd "397" "Boot Execute"                 { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -ErrorAction SilentlyContinue | Select-Object BootExecute,Execute }
    Run-Cmd "398" "SilentProcessExit"            { Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit' -ErrorAction SilentlyContinue | Get-ItemProperty | Select-Object PSChildName,MonitorProcess,ReportingMode | Select-Object -First 10 }
    Run-Cmd "399" "IFEO Debugger Keys"           { Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options' -ErrorAction SilentlyContinue | Where-Object { (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).Debugger } | Select-Object PSChildName }
    Run-Cmd "400" "COM Hijack Candidates"        { Get-ChildItem 'HKCU:\SOFTWARE\Classes\CLSID' -ErrorAction SilentlyContinue | Select-Object PSChildName | Select-Object -First 20 }
    Run-Cmd "401" "Time Provider DLLs"           { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient' -ErrorAction SilentlyContinue | Select-Object DllName }
    Run-Cmd "402" "Alternate Shell"              { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot' -ErrorAction SilentlyContinue | Select-Object AlternateShell }
    Run-Cmd "403" "Terminal Server Startup"      { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -ErrorAction SilentlyContinue | Select-Object fDenyTSConnections,IdleWinStationPoolCount }
    Run-Cmd "404" "RDP Port Number"              { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -ErrorAction SilentlyContinue | Select-Object PortNumber }
    Run-Cmd "405" "NLA Requirement"              { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -ErrorAction SilentlyContinue | Select-Object UserAuthentication,SecurityLayer }
    Run-Cmd "406" "Remote Desktop Users"         { Get-WmiObject Win32_GroupUser | Where-Object { $_.GroupComponent -like "*Remote Desktop Users*" } | Select-Object UserComponent | Select-Object -First 10 }
    Run-Cmd "407" "WinRM Config"                 { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Client' -ErrorAction SilentlyContinue | Select-Object AllowUnencrypted }
    Run-Cmd "408" "AutoLogon Credentials"        { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -ErrorAction SilentlyContinue | Select-Object AutoAdminLogon,DefaultUserName,DefaultDomainName }
    Run-Cmd "409" "SNMP Config"                  { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities' -ErrorAction SilentlyContinue }
    Run-Cmd "410" "Proxy Settings"               { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue | Select-Object ProxyEnable,ProxyServer,ProxyOverride }
    Run-Cmd "411" "IE Zone Settings"             { Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0' -ErrorAction SilentlyContinue | Select-Object * | Select-Object -First 5 }
    Run-Cmd "412" "NFS Client Config"            { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default' -ErrorAction SilentlyContinue }
    Run-Cmd "413" "Installed Software Keys"      { Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' -ErrorAction SilentlyContinue | Get-ItemProperty | Select-Object DisplayName,DisplayVersion,Publisher | Where-Object { $_.DisplayName } | Select-Object -First 30 }
    Run-Cmd "414" "Wow6432 Software"             { Get-ChildItem 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' -ErrorAction SilentlyContinue | Get-ItemProperty | Select-Object DisplayName,DisplayVersion | Where-Object { $_.DisplayName } | Select-Object -First 20 }
    Run-Cmd "415" "User Installed Software"      { Get-ChildItem 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' -ErrorAction SilentlyContinue | Get-ItemProperty | Select-Object DisplayName,DisplayVersion | Where-Object { $_.DisplayName } | Select-Object -First 15 }
    Run-Cmd "416" "DNS Cache"                    { Get-DnsClientCache -ErrorAction SilentlyContinue | Select-Object Entry,RecordName,RecordType,TTL | Select-Object -First 20 }
    Run-Cmd "417" "NetBIOS Settings"             { Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } | Select-Object Description,TcpipNetbiosOptions }
    Run-Cmd "418" "Event Log Settings"           { Get-WmiObject Win32_NTEventlogFile | Select-Object LogfileName,MaxFileSize,NumberOfRecords,OverwritePolicy }
    Run-Cmd "419" "System Locale"                { Get-WmiObject Win32_OperatingSystem | Select-Object Locale,CountryCode,OSLanguage,MUILanguages }
    Run-Cmd "420" "Group Policy Objects"         { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History' -ErrorAction SilentlyContinue }
}

# ==== COMMANDS 421-460 : HARDWARE AND PERIPHERALS ====
function Invoke-HardwarePeripherals {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "HARDWARE AND PERIPHERALS (421-460)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "421" "All PnP Devices"              { Get-WmiObject Win32_PnPEntity | Select-Object Name,Status,DeviceID | Select-Object -First 30 }
    Run-Cmd "422" "PnP Device Classes"           { Get-WmiObject Win32_PnPEntity | Group-Object PNPClass | Select-Object Name,Count | Sort-Object Count -Descending | Select-Object -First 20 }
    Run-Cmd "423" "Problem Devices"              { Get-WmiObject Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 } | Select-Object Name,ConfigManagerErrorCode,DeviceID }
    Run-Cmd "424" "Printer Ports"               { Get-WmiObject Win32_TCPIPPrinterPort -ErrorAction SilentlyContinue | Select-Object Name,HostAddress,PortNumber,Protocol }
    Run-Cmd "425" "USB Controllers"             { Get-WmiObject Win32_USBController | Select-Object Name,DeviceID,Status,Manufacturer }
    Run-Cmd "426" "USB Hub Devices"             { Get-WmiObject Win32_USBHub -ErrorAction SilentlyContinue | Select-Object Name,DeviceID,Status | Select-Object -First 10 }
    Run-Cmd "427" "IEEE 1394 Controllers"       { Get-WmiObject Win32_1394Controller -ErrorAction SilentlyContinue | Select-Object Name,DeviceID,Status }
    Run-Cmd "428" "PCMCIA Controllers"          { Get-WmiObject Win32_PCMCIAController -ErrorAction SilentlyContinue | Select-Object Name,DeviceID,Status }
    Run-Cmd "429" "Network Adapters All"         { Get-WmiObject Win32_NetworkAdapter | Select-Object Name,AdapterType,MACAddress,Speed | Select-Object -First 20 }
    Run-Cmd "430" "Physical Network Adapters"    { Get-WmiObject Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter } | Select-Object Name,MACAddress,Speed,AdapterType }
    Run-Cmd "431" "Wireless Adapters"            { Get-WmiObject Win32_NetworkAdapter | Where-Object { $_.AdapterType -like "*Wireless*" -or $_.Name -like "*Wi-Fi*" -or $_.Name -like "*Wireless*" } | Select-Object Name,MACAddress }
    Run-Cmd "432" "Bluetooth Devices"           { Get-WmiObject Win32_PnPEntity | Where-Object { $_.PNPClass -eq "Bluetooth" } | Select-Object Name,DeviceID,Status | Select-Object -First 10 }
    Run-Cmd "433" "Audio Devices"               { Get-WmiObject Win32_SoundDevice | Select-Object Name,Manufacturer,Status,DeviceID }
    Run-Cmd "434" "Display Adapters"            { Get-WmiObject Win32_VideoController | Select-Object Name,DriverVersion,VideoMemory,CurrentHorizontalResolution,CurrentVerticalResolution }
    Run-Cmd "435" "Display Resolution"          { Get-WmiObject Win32_VideoController | Select-Object Name,CurrentHorizontalResolution,CurrentVerticalResolution,CurrentRefreshRate }
    Run-Cmd "436" "Monitors Detail"             { Get-WmiObject Win32_DesktopMonitor | Select-Object Name,MonitorType,MonitorManufacturer,ScreenHeight,ScreenWidth }
    Run-Cmd "437" "Pointing Devices"            { Get-WmiObject Win32_PointingDevice | Select-Object Name,Manufacturer,NumberOfButtons,DeviceID }
    Run-Cmd "438" "Keyboard Devices"            { Get-WmiObject Win32_Keyboard | Select-Object Name,DeviceID,Layout,NumberOfFunctionKeys }
    Run-Cmd "439" "Printers List"               { Get-WmiObject Win32_Printer | Select-Object Name,Default,WorkOffline,Status,DriverName | Select-Object -First 10 }
    Run-Cmd "440" "Printer Drivers"             { Get-WmiObject Win32_PrinterDriver | Select-Object Name,Version,SupportedPlatform | Select-Object -First 15 }
    Run-Cmd "441" "Floppy Drives"               { Get-WmiObject Win32_FloppyDrive -ErrorAction SilentlyContinue | Select-Object Name,DeviceID,Status }
    Run-Cmd "442" "Floppy Controllers"          { Get-WmiObject Win32_FloppyController -ErrorAction SilentlyContinue | Select-Object Name,DeviceID,Status }
    Run-Cmd "443" "PCI Controllers"             { Get-WmiObject Win32_PCIController -ErrorAction SilentlyContinue | Select-Object Name,DeviceID,Status | Select-Object -First 10 }
    Run-Cmd "444" "Serial Ports"                { Get-WmiObject Win32_SerialPort -ErrorAction SilentlyContinue | Select-Object Name,DeviceID,MaxBaudRate }
    Run-Cmd "445" "Parallel Ports"              { Get-WmiObject Win32_ParallelPort -ErrorAction SilentlyContinue | Select-Object Name,DeviceID,Availability }
    Run-Cmd "446" "SCSI Controllers"            { Get-WmiObject Win32_SCSIController -ErrorAction SilentlyContinue | Select-Object Name,DeviceID,Status | Select-Object -First 5 }
    Run-Cmd "447" "Infrared Device"             { Get-WmiObject Win32_InfraredDevice -ErrorAction SilentlyContinue | Select-Object Name,DeviceID,Status }
    Run-Cmd "448" "Bus Info"                    { Get-WmiObject Win32_Bus -ErrorAction SilentlyContinue | Select-Object Name,BusNum,BusType | Select-Object -First 10 }
    Run-Cmd "449" "Physical Memory Array"       { Get-WmiObject Win32_PhysicalMemoryArray | Select-Object MaxCapacity,MemoryDevices,MemoryErrorData,Location }
    Run-Cmd "450" "Memory Modules"              { Get-WmiObject Win32_PhysicalMemory | Select-Object BankLabel,DeviceLocator,Capacity,Speed,MemoryType,Manufacturer }
    Run-Cmd "451" "CPU Cache"                   { Get-WmiObject Win32_CacheMemory -ErrorAction SilentlyContinue | Select-Object Name,Level,Size,Purpose }
    Run-Cmd "452" "Processor Socket"            { Get-WmiObject Win32_Processor | Select-Object Name,SocketDesignation,UpgradeMethod,Status }
    Run-Cmd "453" "Device Memory"               { Get-WmiObject Win32_DeviceMemoryAddress -ErrorAction SilentlyContinue | Select-Object Name,StartingAddress,EndingAddress | Select-Object -First 15 }
    Run-Cmd "454" "DMA Channels"                { Get-WmiObject Win32_DMAChannel -ErrorAction SilentlyContinue | Select-Object Name,AddressSize,Availability | Select-Object -First 10 }
    Run-Cmd "455" "IRQ Resources"               { Get-WmiObject Win32_IRQResource -ErrorAction SilentlyContinue | Select-Object Name,IRQNumber,Availability | Select-Object -First 15 }
    Run-Cmd "456" "Port Resource"               { Get-WmiObject Win32_PortResource -ErrorAction SilentlyContinue | Select-Object Name,StartingAddress,EndingAddress | Select-Object -First 10 }
    Run-Cmd "457" "CIM Network Adapter"         { Get-CimInstance Win32_NetworkAdapter | Select-Object Name,MACAddress,Speed,PhysicalAdapter | Select-Object -First 15 }
    Run-Cmd "458" "CIM Video Controller"        { Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,VideoMemory }
    Run-Cmd "459" "CIM Physical Memory"         { Get-CimInstance Win32_PhysicalMemory | Select-Object BankLabel,Capacity,Speed,Manufacturer }
    Run-Cmd "460" "Hardware Device Count"       { [PSCustomObject]@{PnPDevices=(Get-WmiObject Win32_PnPEntity|Measure-Object).Count; USBDevices=(Get-WmiObject Win32_PnPEntity|Where-Object{$_.PNPClass-eq'USB'}|Measure-Object).Count; NetworkAdapters=(Get-WmiObject Win32_NetworkAdapter|Measure-Object).Count; Printers=(Get-WmiObject Win32_Printer|Measure-Object).Count} }
}

# ==== COMMANDS 461-500 : SOFTWARE AND APPLICATIONS ====
function Invoke-SoftwareApps {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "SOFTWARE AND APPLICATIONS (461-500)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "461" "Installed Products WMI"       { Get-WmiObject Win32_Product | Select-Object Name,Version,Vendor,InstallDate | Select-Object -First 30 } -Slow
    Run-Cmd "462" "Software Features"            { Get-WmiObject Win32_SoftwareFeature -ErrorAction SilentlyContinue | Select-Object Name,ProductName,Version | Select-Object -First 20 } -Slow
    Run-Cmd "463" "Software Element State"       { Get-WmiObject Win32_SoftwareElement -ErrorAction SilentlyContinue | Select-Object Name,SoftwareElementState,Version | Select-Object -First 20 }
    Run-Cmd "464" "Installed Apps via Registry"  { Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object { $_.DisplayName } | Select-Object DisplayName,DisplayVersion,Publisher,InstallDate | Select-Object -First 30 }
    Run-Cmd "465" "Recently Installed"           { Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object { $_.InstallDate } | Sort-Object InstallDate -Descending | Select-Object DisplayName,InstallDate | Select-Object -First 15 }
    Run-Cmd "466" "MSI Package Cache"            { Get-ChildItem "$env:WINDIR\Installer" -Filter "*.msi" -ErrorAction SilentlyContinue | Select-Object Name,Length,LastWriteTime | Select-Object -First 15 }
    Run-Cmd "467" "Windows Features Enabled"     { Get-WmiObject Win32_OptionalFeature -ErrorAction SilentlyContinue | Where-Object { $_.InstallState -eq 1 } | Select-Object Name,Caption | Select-Object -First 30 }
    Run-Cmd "468" "Windows Features Disabled"    { Get-WmiObject Win32_OptionalFeature -ErrorAction SilentlyContinue | Where-Object { $_.InstallState -eq 2 } | Select-Object Name | Select-Object -First 20 }
    Run-Cmd "469" "DCOM Applications"            { Get-WmiObject Win32_DCOMApplication -ErrorAction SilentlyContinue | Select-Object Name,AppID | Select-Object -First 20 }
    Run-Cmd "470" "COM Application Config"       { Get-WmiObject Win32_COMApplicationSettings -ErrorAction SilentlyContinue | Select-Object Name,ServerId | Select-Object -First 15 }
    Run-Cmd "471" "Scheduled Tasks (WMI)"        { Get-WmiObject Win32_ScheduledJob -ErrorAction SilentlyContinue | Select-Object JobId,Name,Command,StartTime }
    Run-Cmd "472" "Scheduled Tasks (CIM)"        { Get-CimInstance -Namespace root\Microsoft\Windows\TaskScheduler -ClassName MSFT_ScheduledTask -ErrorAction SilentlyContinue | Select-Object TaskName,TaskPath,State | Select-Object -First 30 }
    Run-Cmd "473" "Running Task Instances"       { Get-CimInstance -Namespace root\Microsoft\Windows\TaskScheduler -ClassName MSFT_TaskRunning -ErrorAction SilentlyContinue | Select-Object TaskName,InstanceGuid }
    Run-Cmd "474" "Scripting Engines"            { Get-WmiObject Win32_ClassicCOMClass -ErrorAction SilentlyContinue | Where-Object { $_.ProgId -like "*Script*" -or $_.ProgId -like "*Shell*" } | Select-Object ProgId,InprocServer32 | Select-Object -First 15 }
    Run-Cmd "475" "Browser Helper Objects"       { Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects' -ErrorAction SilentlyContinue | Select-Object PSChildName }
    Run-Cmd "476" "Shell Extensions"             { Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved' -ErrorAction SilentlyContinue | Get-ItemProperty | Select-Object * | Select-Object -First 15 }
    Run-Cmd "477" "Explorer Run MRU"             { Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' -ErrorAction SilentlyContinue }
    Run-Cmd "478" "Recent Documents"             { Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs' -ErrorAction SilentlyContinue | Select-Object * -First 1 }
    Run-Cmd "479" "TypedURLs History"            { Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Internet Explorer\TypedURLs' -ErrorAction SilentlyContinue }
    Run-Cmd "480" "WMI MSI Product Count"        { (Get-WmiObject Win32_Product -ErrorAction SilentlyContinue | Measure-Object).Count } -Slow
    Run-Cmd "481" "Startup Programs Registry"    { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue; Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue }
    Run-Cmd "482" "Office Installed Version"     { Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Office' -ErrorAction SilentlyContinue | Select-Object PSChildName }
    Run-Cmd "483" "Python Installations"         { Get-ChildItem 'HKLM:\SOFTWARE\Python\PythonCore' -ErrorAction SilentlyContinue | Select-Object PSChildName }
    Run-Cmd "484" "Java Installations"           { Get-ChildItem 'HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment' -ErrorAction SilentlyContinue | Select-Object PSChildName }
    Run-Cmd "485" "Git Installations"            { Get-ChildItem 'HKLM:\SOFTWARE\GitForWindows' -ErrorAction SilentlyContinue | Get-ItemProperty | Select-Object InstallPath,CurrentVersion }
    Run-Cmd "486" "Visual Studio Versions"       { Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\VisualStudio' -ErrorAction SilentlyContinue | Select-Object PSChildName }
    Run-Cmd "487" "SQL Server Instances"         { Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' -ErrorAction SilentlyContinue | Get-ItemProperty }
    Run-Cmd "488" "IIS Configuration"            { Get-WmiObject IIsWebServerSetting -Namespace root\microsoftiisv2 -ErrorAction SilentlyContinue | Select-Object Name,ServerState,ServerAutoStart | Select-Object -First 5 }
    Run-Cmd "489" "Chocolatey Packages"          { if (Test-Path "$env:ALLUSERSPROFILE\chocolatey\lib") { Get-ChildItem "$env:ALLUSERSPROFILE\chocolatey\lib" | Select-Object Name } else { "Chocolatey not found" } }
    Run-Cmd "490" "Winget Sources"               { winget source list 2>$null }
    Run-Cmd "491" "Scoop Apps"                   { if (Test-Path "$env:USERPROFILE\scoop\apps") { Get-ChildItem "$env:USERPROFILE\scoop\apps" | Select-Object Name } else { "Scoop not found" } }
    Run-Cmd "492" "Node.js Version"              { node --version 2>$null }
    Run-Cmd "493" "npm Global Packages"          { npm list -g --depth=0 2>$null }
    Run-Cmd "494" "Docker Service"               { Get-WmiObject Win32_Service | Where-Object { $_.Name -like "*docker*" -or $_.Name -like "*container*" } | Select-Object Name,State,StartMode }
    Run-Cmd "495" "WSL Distributions"            { wsl --list --verbose 2>$null }
    Run-Cmd "496" "Hyper-V VMs"                  { Get-WmiObject -Namespace root\virtualization\v2 -Class Msvm_ComputerSystem -ErrorAction SilentlyContinue | Select-Object ElementName,EnabledState | Select-Object -First 10 }
    Run-Cmd "497" "VirtualBox Installed"         { Get-WmiObject Win32_Service | Where-Object { $_.Name -like "*VirtualBox*" } | Select-Object Name,State }
    Run-Cmd "498" "VMware Services"              { Get-WmiObject Win32_Service | Where-Object { $_.Name -like "*VMware*" -or $_.Name -like "*vmx*" } | Select-Object Name,State | Select-Object -First 10 }
    Run-Cmd "499" "Antivirus Engine Paths"       { Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct -ErrorAction SilentlyContinue | Select-Object DisplayName,pathToSignedProductExe,pathToSignedReportingExe }
    Run-Cmd "500" "Software Summary"             { [PSCustomObject]@{InstalledProducts=(Get-WmiObject Win32_Product -ErrorAction SilentlyContinue | Measure-Object).Count; OptionalFeatures=(Get-WmiObject Win32_OptionalFeature | Where-Object{$_.InstallState-eq1} | Measure-Object).Count; DCOMApps=(Get-WmiObject Win32_DCOMApplication -ErrorAction SilentlyContinue | Measure-Object).Count; ScheduledJobs=(Get-WmiObject Win32_ScheduledJob -ErrorAction SilentlyContinue | Measure-Object).Count} }
}

# ==== COMMANDS 501-540 : TASKS, LOGS AND AUDIT ====
function Invoke-TasksLogsAudit {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "TASKS, LOGS AND AUDIT (501-540)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "501" "Event Log Files"              { Get-WmiObject Win32_NTEventlogFile | Select-Object LogfileName,FileSize,MaxFileSize,NumberOfRecords }
    Run-Cmd "502" "Security Event Log Size"      { Get-WmiObject Win32_NTEventlogFile | Where-Object { $_.LogfileName -eq "Security" } | Select-Object LogfileName,NumberOfRecords,FileSize,MaxFileSize }
    Run-Cmd "503" "System Event Log Size"        { Get-WmiObject Win32_NTEventlogFile | Where-Object { $_.LogfileName -eq "System" } | Select-Object LogfileName,NumberOfRecords,FileSize,MaxFileSize }
    Run-Cmd "504" "Application Log Size"         { Get-WmiObject Win32_NTEventlogFile | Where-Object { $_.LogfileName -eq "Application" } | Select-Object LogfileName,NumberOfRecords,FileSize,MaxFileSize }
    Run-Cmd "505" "Recent Security Events"       { Get-WmiObject Win32_NTLogEvent -Filter "Logfile='Security'" -ErrorAction SilentlyContinue | Select-Object EventCode,TimeGenerated,Message | Select-Object -First 10 } -Slow
    Run-Cmd "506" "Recent System Events"         { Get-WmiObject Win32_NTLogEvent -Filter "Logfile='System' AND EventType=1" -ErrorAction SilentlyContinue | Select-Object EventCode,TimeGenerated,SourceName | Select-Object -First 10 } -Slow
    Run-Cmd "507" "Recent App Events"            { Get-WmiObject Win32_NTLogEvent -Filter "Logfile='Application' AND EventType=1" -ErrorAction SilentlyContinue | Select-Object EventCode,TimeGenerated,SourceName | Select-Object -First 10 } -Slow
    Run-Cmd "508" "Event Sources"               { Get-WmiObject Win32_NTEventlogFile | Select-Object LogfileName,@{n='Sources';e={$_.Sources -join '; '}} | Select-Object -First 10 }
    Run-Cmd "509" "WMI Event Log Records"        { (Get-WmiObject Win32_NTLogEvent -Filter "Logfile='System'" -ErrorAction SilentlyContinue | Measure-Object).Count }
    Run-Cmd "510" "Logon Failures (4625)"        { Get-WmiObject Win32_NTLogEvent -Filter "Logfile='Security' AND EventCode=4625" -ErrorAction SilentlyContinue | Select-Object TimeGenerated,Message | Select-Object -First 5 } -Slow
    Run-Cmd "511" "Scheduled Task List"          { schtasks /query /fo LIST 2>$null | Select-Object -First 60 }
    Run-Cmd "512" "Scheduled Tasks XML"          { Get-ChildItem "$env:WINDIR\System32\Tasks" -ErrorAction SilentlyContinue | Select-Object Name,LastWriteTime | Select-Object -First 20 }
    Run-Cmd "513" "User Tasks Folder"            { Get-ChildItem "$env:WINDIR\System32\Tasks\Microsoft\Windows" -ErrorAction SilentlyContinue | Select-Object Name | Select-Object -First 20 }
    Run-Cmd "514" "At Jobs"                      { Get-WmiObject Win32_ScheduledJob -ErrorAction SilentlyContinue | Select-Object JobId,Command,StartTime,Status }
    Run-Cmd "515" "Process Creation Events"      { Get-WmiObject Win32_NTLogEvent -Filter "Logfile='Security' AND EventCode=4688" -ErrorAction SilentlyContinue | Select-Object TimeGenerated,Message | Select-Object -First 5 } -Slow
    Run-Cmd "516" "Service Install Events"       { Get-WmiObject Win32_NTLogEvent -Filter "Logfile='System' AND EventCode=7045" -ErrorAction SilentlyContinue | Select-Object TimeGenerated,Message | Select-Object -First 5 } -Slow
    Run-Cmd "517" "PowerShell Log Events"        { Get-WmiObject Win32_NTLogEvent -Filter "Logfile='Windows PowerShell' AND EventType=2" -ErrorAction SilentlyContinue | Select-Object EventCode,TimeGenerated,Message | Select-Object -First 10 } -Slow
    Run-Cmd "518" "WMI Activity Log"             { Get-WmiObject Win32_NTLogEvent -Filter "Logfile='Microsoft-Windows-WMI-Activity/Operational'" -ErrorAction SilentlyContinue | Select-Object EventCode,TimeGenerated | Select-Object -First 10 } -Slow
    Run-Cmd "519" "AppLocker Events"             { Get-WmiObject Win32_NTLogEvent -Filter "Logfile='Microsoft-Windows-AppLocker/EXE and DLL'" -ErrorAction SilentlyContinue | Select-Object TimeGenerated,EventCode,Message | Select-Object -First 10 } -Slow
    Run-Cmd "520" "Sysmon Events"                { Get-WmiObject Win32_NTLogEvent -Filter "Logfile='Microsoft-Windows-Sysmon/Operational'" -ErrorAction SilentlyContinue | Select-Object EventCode,TimeGenerated | Select-Object -First 10 } -Slow
    Run-Cmd "521" "Audit Policy HKLM"            { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -ErrorAction SilentlyContinue | Select-Object scenoapplygrouppolicy,auditbaseobjects,crashonauditfail }
    Run-Cmd "522" "Per-User Audit Policy"        { auditpol /get /user:$env:USERNAME 2>$null }
    Run-Cmd "523" "Security Providers"           { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders' -ErrorAction SilentlyContinue | Select-Object SecurityProviders }
    Run-Cmd "524" "Logging Level"                { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Diagnostics' -ErrorAction SilentlyContinue }
    Run-Cmd "525" "WMI Trace Log"                { Get-ChildItem "$env:WINDIR\System32\wbem\Logs" -ErrorAction SilentlyContinue | Select-Object Name,Length,LastWriteTime }
    Run-Cmd "526" "Dr Watson Log"                { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug' -ErrorAction SilentlyContinue | Select-Object Debugger,Auto }
    Run-Cmd "527" "Crash Dump Config"            { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -ErrorAction SilentlyContinue | Select-Object CrashDumpEnabled,DumpFile,MiniDumpDir }
    Run-Cmd "528" "WER Settings"                 { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting' -ErrorAction SilentlyContinue | Select-Object Disabled,LoggingDisabled,DontSendAdditionalData }
    Run-Cmd "529" "Reliability Records"          { Get-WmiObject Win32_ReliabilityRecords -ErrorAction SilentlyContinue | Select-Object EventIdentifier,SourceName,TimeGenerated,Message | Select-Object -First 10 } -Slow
    Run-Cmd "530" "Stability Index"              { Get-WmiObject Win32_ReliabilityStabilityMetrics -ErrorAction SilentlyContinue | Select-Object StartMeasurementDate,EndMeasurementDate,SystemStabilityIndex | Select-Object -First 5 }
    Run-Cmd "531" "Performance Monitor Logs"     { Get-WmiObject Win32_PerfRawData_PerfOS_System -ErrorAction SilentlyContinue | Select-Object SystemCallsPerSec,ContextSwitchesPerSec,FileWriteOperationsPerSec }
    Run-Cmd "532" "OS Performance Data"          { Get-WmiObject Win32_PerfFormattedData_PerfOS_Processor -ErrorAction SilentlyContinue | Select-Object Name,PercentProcessorTime,PercentPrivilegedTime | Select-Object -First 5 }
    Run-Cmd "533" "Network Performance"          { Get-WmiObject Win32_PerfFormattedData_Tcpip_NetworkInterface -ErrorAction SilentlyContinue | Select-Object Name,BytesReceivedPerSec,BytesSentPerSec | Select-Object -First 5 }
    Run-Cmd "534" "Memory Performance"           { Get-WmiObject Win32_PerfFormattedData_PerfOS_Memory -ErrorAction SilentlyContinue | Select-Object AvailableMBytes,PageFaultsPerSec,PagesInputPerSec }
    Run-Cmd "535" "Process Performance"          { Get-WmiObject Win32_PerfFormattedData_PerfProc_Process -ErrorAction SilentlyContinue | Select-Object Name,PercentProcessorTime,WorkingSet | Select-Object -First 10 }
    Run-Cmd "536" "Event Subscription Count"     { (Get-WmiObject Win32_NTEventlogFile | Measure-Object -Property NumberOfRecords -Sum).Sum }
    Run-Cmd "537" "Log File Paths"               { Get-WmiObject Win32_NTEventlogFile | Select-Object LogfileName,@{n='Path';e={'%SystemRoot%\System32\winevt\Logs\'+$_.LogfileName+'.evtx'}} | Select-Object -First 10 }
    Run-Cmd "538" "Remote Logging"               { Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System' -ErrorAction SilentlyContinue | Select-Object MaxSize,Retention }
    Run-Cmd "539" "Forwarded Events Log"         { Get-WmiObject Win32_NTEventlogFile | Where-Object { $_.LogfileName -like "*ForwardedEvents*" } | Select-Object LogfileName,NumberOfRecords }
    Run-Cmd "540" "Audit Logs Summary"           { Get-WmiObject Win32_NTEventlogFile | Select-Object LogfileName,NumberOfRecords | Sort-Object NumberOfRecords -Descending | Select-Object -First 10 }
}

# ==== COMMANDS 541-570 : CERTIFICATES AND CRYPTO ====
function Invoke-CertificatesCrypto {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "CERTIFICATES AND CRYPTO (541-570)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "541" "Local Machine Certs"          { Get-ChildItem Cert:\LocalMachine\My -ErrorAction SilentlyContinue | Select-Object Subject,Issuer,NotBefore,NotAfter,Thumbprint | Select-Object -First 15 }
    Run-Cmd "542" "Current User Certs"           { Get-ChildItem Cert:\CurrentUser\My -ErrorAction SilentlyContinue | Select-Object Subject,Issuer,NotBefore,NotAfter,Thumbprint | Select-Object -First 15 }
    Run-Cmd "543" "Root CA Certs"                { Get-ChildItem Cert:\LocalMachine\Root -ErrorAction SilentlyContinue | Select-Object Subject,Issuer,NotAfter | Select-Object -First 20 }
    Run-Cmd "544" "Intermediate CAs"             { Get-ChildItem Cert:\LocalMachine\CA -ErrorAction SilentlyContinue | Select-Object Subject,Issuer,NotAfter | Select-Object -First 15 }
    Run-Cmd "545" "Trusted Publisher Certs"      { Get-ChildItem Cert:\LocalMachine\TrustedPublisher -ErrorAction SilentlyContinue | Select-Object Subject,Issuer,Thumbprint | Select-Object -First 10 }
    Run-Cmd "546" "Disallowed Certs"             { Get-ChildItem Cert:\LocalMachine\Disallowed -ErrorAction SilentlyContinue | Select-Object Subject,Thumbprint | Select-Object -First 10 }
    Run-Cmd "547" "Expired Certs LM"             { Get-ChildItem Cert:\LocalMachine\My -ErrorAction SilentlyContinue | Where-Object { $_.NotAfter -lt (Get-Date) } | Select-Object Subject,NotAfter }
    Run-Cmd "548" "Expiring Soon Certs"          { Get-ChildItem Cert:\LocalMachine\My -ErrorAction SilentlyContinue | Where-Object { $_.NotAfter -lt (Get-Date).AddDays(90) -and $_.NotAfter -gt (Get-Date) } | Select-Object Subject,NotAfter }
    Run-Cmd "549" "Self-Signed Certs"            { Get-ChildItem Cert:\LocalMachine\My -ErrorAction SilentlyContinue | Where-Object { $_.Subject -eq $_.Issuer } | Select-Object Subject,Thumbprint }
    Run-Cmd "550" "Code Signing Certs"           { Get-ChildItem Cert:\LocalMachine\My -ErrorAction SilentlyContinue | Where-Object { $_.EnhancedKeyUsageList -like "*Code Signing*" } | Select-Object Subject,Issuer,NotAfter }
    Run-Cmd "551" "TLS Protocols Enabled"        { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' -ErrorAction SilentlyContinue }
    Run-Cmd "552" "SSL 2.0 Status"               { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -ErrorAction SilentlyContinue | Select-Object Enabled }
    Run-Cmd "553" "SSL 3.0 Status"               { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -ErrorAction SilentlyContinue | Select-Object Enabled }
    Run-Cmd "554" "TLS 1.0 Status"               { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -ErrorAction SilentlyContinue | Select-Object Enabled,DisabledByDefault }
    Run-Cmd "555" "TLS 1.1 Status"               { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -ErrorAction SilentlyContinue | Select-Object Enabled,DisabledByDefault }
    Run-Cmd "556" "TLS 1.2 Status"               { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -ErrorAction SilentlyContinue | Select-Object Enabled,DisabledByDefault }
    Run-Cmd "557" "TLS 1.3 Status"               { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server' -ErrorAction SilentlyContinue | Select-Object Enabled,DisabledByDefault }
    Run-Cmd "558" "Cipher Suites"                { Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -ErrorAction SilentlyContinue | Select-Object Functions }
    Run-Cmd "559" "SCHANNEL Ciphers"             { Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers' -ErrorAction SilentlyContinue | Select-Object PSChildName }
    Run-Cmd "560" "SCHANNEL Hashes"              { Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes' -ErrorAction SilentlyContinue | Select-Object PSChildName }
    Run-Cmd "561" "SCHANNEL Key Exchange"        { Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms' -ErrorAction SilentlyContinue | Select-Object PSChildName }
    Run-Cmd "562" "FIPS Mode"                    { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FipsAlgorithmPolicy' -ErrorAction SilentlyContinue | Select-Object Enabled }
    Run-Cmd "563" "EFS Config"                   { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\EFS' -ErrorAction SilentlyContinue | Select-Object EfsConfiguration,AlgorithmID }
    Run-Cmd "564" "BitLocker Recovery Keys"      { Get-CimInstance Win32_EncryptableVolume -Namespace root\cimv2\security\microsoftvolumeencryption -ErrorAction SilentlyContinue | Where-Object { $_.ProtectionStatus -eq 1 } | Select-Object DriveLetter,ProtectionStatus }
    Run-Cmd "565" "Crypto API Config"            { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Cryptography' -ErrorAction SilentlyContinue | Select-Object MachineGuid }
    Run-Cmd "566" "Kerberos Config"              { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters' -ErrorAction SilentlyContinue | Select-Object * }
    Run-Cmd "567" "WMI Cert Store Objects"       { Get-WmiObject -Namespace root\cimv2 -Class Win32_CertificateAuthority -ErrorAction SilentlyContinue | Select-Object Name,CommonName,Location }
    Run-Cmd "568" "CRL Distribution Points"      { Get-ChildItem Cert:\LocalMachine\Root -ErrorAction SilentlyContinue | Where-Object { $_.Extensions } | ForEach-Object { [System.Security.Cryptography.X509Certificates.X509Certificate2]$_ } | Select-Object Subject | Select-Object -First 10 }
    Run-Cmd "569" "Smart Card Service"           { Get-WmiObject Win32_Service | Where-Object { $_.Name -eq "SCardSvr" } | Select-Object Name,State,StartMode }
    Run-Cmd "570" "Certificate Counts"           { [PSCustomObject]@{LocalMachinePersonal=(Get-ChildItem Cert:\LocalMachine\My -ErrorAction SilentlyContinue | Measure-Object).Count; LocalMachineRoot=(Get-ChildItem Cert:\LocalMachine\Root -ErrorAction SilentlyContinue | Measure-Object).Count; LocalMachineCA=(Get-ChildItem Cert:\LocalMachine\CA -ErrorAction SilentlyContinue | Measure-Object).Count; UserPersonal=(Get-ChildItem Cert:\CurrentUser\My -ErrorAction SilentlyContinue | Measure-Object).Count} }
}

# ==== COMMANDS 571-600 : PERSISTENCE AND LATERAL MOVEMENT ====
function Invoke-PersistenceLateral {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "PERSISTENCE AND LATERAL MOVEMENT (571-600)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Run-Cmd "571" "WMI Event Filters"            { Get-WmiObject -Namespace root\subscription -Class __EventFilter -ErrorAction SilentlyContinue | Select-Object Name,Query,QueryLanguage }
    Run-Cmd "572" "WMI Event Consumers"          { Get-WmiObject -Namespace root\subscription -Class __EventConsumer -ErrorAction SilentlyContinue | Select-Object Name,__CLASS }
    Run-Cmd "573" "WMI ActiveScript Consumer"    { Get-WmiObject -Namespace root\subscription -Class ActiveScriptEventConsumer -ErrorAction SilentlyContinue | Select-Object Name,ScriptingEngine,ScriptText }
    Run-Cmd "574" "WMI CommandLine Consumer"     { Get-WmiObject -Namespace root\subscription -Class CommandLineEventConsumer -ErrorAction SilentlyContinue | Select-Object Name,CommandLineTemplate,ExecutablePath }
    Run-Cmd "575" "WMI FilterToConsumer Binding" { Get-WmiObject -Namespace root\subscription -Class __FilterToConsumerBinding -ErrorAction SilentlyContinue | Select-Object Filter,Consumer }
    Run-Cmd "576" "WMI Timer Events"             { Get-WmiObject -Namespace root\subscription -Class __TimerEvent -ErrorAction SilentlyContinue | Select-Object TimerID }
    Run-Cmd "577" "WMI Absolute Timer"           { Get-WmiObject -Namespace root\subscription -Class __AbsoluteTimerInstruction -ErrorAction SilentlyContinue | Select-Object TimerID,EventDateTime }
    Run-Cmd "578" "WMI Interval Timer"           { Get-WmiObject -Namespace root\subscription -Class __IntervalTimerInstruction -ErrorAction SilentlyContinue | Select-Object TimerID,IntervalBetweenEvents }
    Run-Cmd "579" "Services with Spaces"         { Get-WmiObject Win32_Service | Where-Object { $_.PathName -match ' ' -and $_.PathName -notmatch '"' -and $_.PathName -notmatch 'svchost' } | Select-Object Name,PathName | Select-Object -First 15 }
    Run-Cmd "580" "DLL Hijack Search Path"       { $env:PATH -split ';' | ForEach-Object { [PSCustomObject]@{Path=$_;Exists=(Test-Path $_);Writable=( try{[IO.File]::OpenWrite("$_\test_$$_.tmp")|%{$_.Close();Remove-Item "$_\test_$$_.tmp" -Force};$true}catch{$false} )} } | Select-Object -First 10 }
    Run-Cmd "581" "AlwaysInstallElevated Check"  { $hklm=(Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer' -ErrorAction SilentlyContinue).AlwaysInstallElevated; $hkcu=(Get-ItemProperty 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer' -ErrorAction SilentlyContinue).AlwaysInstallElevated; [PSCustomObject]@{HKLM_AIE=$hklm;HKCU_AIE=$hkcu;Vulnerable=($hklm -eq 1 -and $hkcu -eq 1)} }
    Run-Cmd "582" "Token Privileges Check"       { whoami /priv 2>$null }
    Run-Cmd "583" "SeDebugPrivilege"             { whoami /priv 2>$null | Select-String "SeDebugPrivilege" }
    Run-Cmd "584" "SeImpersonatePrivilege"       { whoami /priv 2>$null | Select-String "SeImpersonatePrivilege" }
    Run-Cmd "585" "Current User Groups"          { whoami /groups 2>$null }
    Run-Cmd "586" "Named Pipes"                  { [System.IO.Directory]::GetFiles('\\.\pipe\') | Select-Object -First 20 }
    Run-Cmd "587" "COM Servers in AppID"         { Get-WmiObject Win32_DCOMApplicationSetting -ErrorAction SilentlyContinue | Select-Object Caption,AppId,RunAsUser | Select-Object -First 15 }
    Run-Cmd "588" "Autorun Service DLLs"         { Get-WmiObject Win32_Service | Where-Object { $_.StartMode -eq "Auto" -and $_.PathName -like "*svchost*" } | Select-Object Name,ProcessId | Select-Object -First 15 }
    Run-Cmd "589" "Screensaver Persistence"      { Get-ItemProperty 'HKCU:\Control Panel\Desktop' -ErrorAction SilentlyContinue | Select-Object SCRNSAVE.EXE,ScreenSaverIsSecure }
    Run-Cmd "590" "Office Macros Trust"          { Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Office\*\*\Security' -ErrorAction SilentlyContinue | Select-Object VBAWarnings | Select-Object -First 5 }
    Run-Cmd "591" "PSReadLine History"           { if(Test-Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"){Get-Content "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" | Select-Object -Last 20} else {"No PS history found"} }
    Run-Cmd "592" "Recently Run Commands"        { Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' -ErrorAction SilentlyContinue }
    Run-Cmd "593" "Network Logon Creds"          { cmdkey /list 2>$null }
    Run-Cmd "594" "Lateral WMI Namespaces"       { Get-WmiObject -Namespace root -Class __Namespace | Select-Object Name }
    Run-Cmd "595" "WMI Default Namespace"        { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Wbem\CIMOM' -ErrorAction SilentlyContinue | Select-Object 'Default Namespace' }
    Run-Cmd "596" "Pass-the-Hash Risk"           { [PSCustomObject]@{NTLM_Level=(Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\LSA' -ErrorAction SilentlyContinue).LmCompatibilityLevel; WDigest=(Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest' -ErrorAction SilentlyContinue).UseLogonCredential; RestrictNTLM=(Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\LSA\MSV1_0' -ErrorAction SilentlyContinue).RestrictReceivingNTLMTraffic} }
    Run-Cmd "597" "Admin Share Status"           { Get-WmiObject Win32_Share | Where-Object { $_.Name -match '\$' } | Select-Object Name,Path,Type }
    Run-Cmd "598" "Null Session Shares"          { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -ErrorAction SilentlyContinue | Select-Object NullSessionShares,RestrictNullSessAccess }
    Run-Cmd "599" "Kerberoastable Services"      { Get-WmiObject Win32_Service | Where-Object { $_.StartName -like "*@*" -or ($_.StartName -notlike "*SYSTEM*" -and $_.StartName -notlike "*LOCAL*" -and $_.StartName -notlike "*NETWORK*" -and $_.StartName) } | Select-Object Name,StartName | Select-Object -First 10 }
    Run-Cmd "600" "Full System Digest v600"      { [PSCustomObject]@{
        ComputerName=$env:COMPUTERNAME; OS=(Get-WmiObject Win32_OperatingSystem).Caption; BuildNumber=(Get-WmiObject Win32_OperatingSystem).BuildNumber
        Users=(Get-WmiObject Win32_UserAccount | Measure-Object).Count; Groups=(Get-WmiObject Win32_Group | Measure-Object).Count
        Services=(Get-WmiObject Win32_Service | Measure-Object).Count; Processes=(Get-WmiObject Win32_Process | Measure-Object).Count
        Shares=(Get-WmiObject Win32_Share | Measure-Object).Count; Hotfixes=(Get-WmiObject Win32_QuickFixEngineering | Measure-Object).Count
        AutoRun=(Get-WmiObject Win32_StartupCommand | Measure-Object).Count; PhysicalDisks=(Get-WmiObject Win32_DiskDrive | Measure-Object).Count
        CertificatesLM=(Get-ChildItem Cert:\LocalMachine\My -ErrorAction SilentlyContinue | Measure-Object).Count
        WMISubscriptions=(Get-WmiObject -Namespace root\subscription -Class __EventFilter -ErrorAction SilentlyContinue | Measure-Object).Count
        ToolVersion="FROGMAN  | 600 Commands | MANIKANDAN | 9787091093"
    } }
}

# ==== ACTIVE DIRECTORY RECON ====
function Invoke-ADRecon {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "ACTIVE DIRECTORY RECON" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header

    $domain = (Wmi-Q -Class Win32_ComputerSystem).Domain
    Write-Host "  Domain: $domain" -ForegroundColor $ColorScheme.InfoLow
    Write-Host "  NOTE: Some AD queries require domain-joined machine & RSAT" -ForegroundColor $ColorScheme.Warning

    Run-Cmd "AD1"  "Domain Info"              { Wmi-Q -Class Win32_ComputerSystem | Select-Object Name,Domain,DomainRole,PartOfDomain }
    Run-Cmd "AD2"  "Domain Controllers"       { try { ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).DomainControllers | Select-Object Name,IPAddress,OSVersion } catch { "Not domain joined or RSAT missing" } }
    Run-Cmd "AD3"  "Domain Trusts"            { try { ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).GetAllTrustRelationships() } catch { "N/A" } }
    Run-Cmd "AD4"  "Forest Info"              { try { $f=[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest(); [PSCustomObject]@{Name=$f.Name;RootDomain=$f.RootDomain;ForestMode=$f.ForestMode;SchemaRoleOwner=$f.SchemaRoleOwner} } catch { "N/A" } }
    Run-Cmd "AD5"  "Domain Functional Level"  { try { ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).DomainMode } catch { "N/A" } }
    Run-Cmd "AD6"  "LDAP Domain Users"        { try { $searcher=[adsisearcher]"(&(objectCategory=person)(objectClass=user))"; $searcher.PropertiesToLoad.AddRange(@("samaccountname","mail","useraccountcontrol","pwdlastset")); $searcher.FindAll() | ForEach-Object { [PSCustomObject]@{User=$_.Properties["samaccountname"][0]; Mail=$_.Properties["mail"]; UAC=$_.Properties["useraccountcontrol"][0]} } | Select-Object -First 30 } catch { "N/A" } } -Slow
    Run-Cmd "AD7"  "LDAP Domain Groups"       { try { $s=[adsisearcher]"(objectCategory=group)"; $s.FindAll() | ForEach-Object { $_.Properties["samaccountname"][0] } | Select-Object -First 30 } catch { "N/A" } } -Slow
    Run-Cmd "AD8"  "LDAP Admin Groups"        { try { $s=[adsisearcher]"(&(objectCategory=group)(name=*admin*))"; $s.FindAll() | ForEach-Object { [PSCustomObject]@{Group=$_.Properties["samaccountname"][0]; DN=$_.Properties["distinguishedname"][0]} } } catch { "N/A" } }
    Run-Cmd "AD9"  "LDAP Domain Computers"    { try { $s=[adsisearcher]"(objectCategory=computer)"; $s.PropertiesToLoad.AddRange(@("name","operatingsystem","lastlogontimestamp")); $s.FindAll() | ForEach-Object { [PSCustomObject]@{Name=$_.Properties["name"][0]; OS=$_.Properties["operatingsystem"][0]} } | Select-Object -First 30 } catch { "N/A" } } -Slow
    Run-Cmd "AD10" "Password Policy"          { try { $d=[adsi]"WinNT://$domain"; [PSCustomObject]@{MinPwdLength=$d.MinPasswordLength[0]; MaxPwdAge=[timespan]::FromTicks([math]::Abs($d.MaxPasswordAge[0])).Days; MinPwdAge=[timespan]::FromTicks([math]::Abs($d.MinPasswordAge[0])).Days; LockoutThreshold=$d.MaxBadPasswordsAllowed[0]} } catch { "N/A" } }
    Run-Cmd "AD11" "Kerberoastable Accounts"  { try { $s=[adsisearcher]"(&(objectCategory=user)(servicePrincipalName=*))"; $s.PropertiesToLoad.AddRange(@("samaccountname","serviceprincipalname")); $s.FindAll() | ForEach-Object { [PSCustomObject]@{User=$_.Properties["samaccountname"][0]; SPN=$_.Properties["serviceprincipalname"][0]} } } catch { "N/A" } }
    Run-Cmd "AD12" "AS-REP Roastable"         { try { $s=[adsisearcher]"(&(objectCategory=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))"; $s.FindAll() | ForEach-Object { $_.Properties["samaccountname"][0] } } catch { "N/A" } }
    Run-Cmd "AD13" "AdminCount=1 Users"       { try { $s=[adsisearcher]"(&(objectCategory=user)(adminCount=1))"; $s.FindAll() | ForEach-Object { $_.Properties["samaccountname"][0] } } catch { "N/A" } }
    Run-Cmd "AD14" "Disabled AD Accounts"     { try { $s=[adsisearcher]"(&(objectCategory=user)(userAccountControl:1.2.840.113556.1.4.803:=2))"; $s.FindAll() | ForEach-Object { $_.Properties["samaccountname"][0] } | Select-Object -First 20 } catch { "N/A" } }
    Run-Cmd "AD15" "Stale Computer Accounts"  { try { $cutoff=(Get-Date).AddDays(-90).ToFileTime(); $s=[adsisearcher]"(&(objectCategory=computer)(lastLogonTimestamp<=$cutoff))"; $s.FindAll() | ForEach-Object { $_.Properties["name"][0] } | Select-Object -First 20 } catch { "N/A" } } -Slow
    Run-Cmd "AD16" "GPO List"                 { try { $s=[adsisearcher]"(objectCategory=groupPolicyContainer)"; $s.FindAll() | ForEach-Object { [PSCustomObject]@{Name=$_.Properties["displayname"][0]; Path=$_.Properties["adspath"][0]} } | Select-Object -First 20 } catch { "N/A" } }
    Run-Cmd "AD17" "OU Structure"             { try { $s=[adsisearcher]"(objectCategory=organizationalUnit)"; $s.FindAll() | ForEach-Object { $_.Properties["distinguishedname"][0] } | Select-Object -First 20 } catch { "N/A" } }
    Run-Cmd "AD18" "SYSVOL / NETLOGON Shares" { Get-WmiObject Win32_Share | Where-Object { $_.Name -match "SYSVOL|NETLOGON" } | Select-Object Name,Path,Description }
    Run-Cmd "AD19" "Domain Role"              { $r = (Wmi-Q -Class Win32_ComputerSystem).DomainRole; $roles=@("Standalone Workstation","Member Workstation","Standalone Server","Member Server","Backup Domain Controller","Primary Domain Controller"); [PSCustomObject]@{Role=$roles[$r]; Code=$r} }
    Run-Cmd "AD20" "LDAP Connectivity"        { try { $conn=[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain(); [PSCustomObject]@{Connected=$true; Domain=$conn.Name; PDC=$conn.PdcRoleOwner} } catch { [PSCustomObject]@{Connected=$false; Reason=$_.Exception.Message} } }
}

# ==== CLOUD METADATA DETECTION ====
function Invoke-CloudDetect {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "CLOUD METADATA DETECTION (Azure / AWS / GCP)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header

    Run-Cmd "CL1"  "Azure IMDS Check"         {
        try {
            $r = Invoke-RestMethod -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01" -Headers @{Metadata="true"} -TimeoutSec 3 -ErrorAction Stop
            [PSCustomObject]@{Cloud="Azure"; SubscriptionId=$r.compute.subscriptionId; ResourceGroup=$r.compute.resourceGroupName; VMName=$r.compute.name; Location=$r.compute.location; VMSize=$r.compute.vmSize; OSType=$r.compute.osType; Publisher=$r.compute.storageProfile.imageReference.publisher}
        } catch { [PSCustomObject]@{Cloud="Azure"; Status="Not Azure or IMDS unreachable"} }
    }
    Run-Cmd "CL2"  "AWS IMDS Check"           {
        try {
            $token = Invoke-RestMethod -Method PUT -Uri "http://169.254.169.254/latest/api/token" -Headers @{"X-aws-ec2-metadata-token-ttl-seconds"="10"} -TimeoutSec 3 -ErrorAction Stop
            $id    = Invoke-RestMethod -Uri "http://169.254.169.254/latest/meta-data/instance-id" -Headers @{"X-aws-ec2-metadata-token"=$token} -TimeoutSec 3
            $type  = Invoke-RestMethod -Uri "http://169.254.169.254/latest/meta-data/instance-type" -Headers @{"X-aws-ec2-metadata-token"=$token} -TimeoutSec 3
            $az    = Invoke-RestMethod -Uri "http://169.254.169.254/latest/meta-data/placement/availability-zone" -Headers @{"X-aws-ec2-metadata-token"=$token} -TimeoutSec 3
            $acct  = Invoke-RestMethod -Uri "http://169.254.169.254/latest/dynamic/instance-identity/document" -Headers @{"X-aws-ec2-metadata-token"=$token} -TimeoutSec 3
            [PSCustomObject]@{Cloud="AWS"; InstanceId=$id; InstanceType=$type; AZ=$az; AccountId=$acct.accountId; Region=$acct.region; AMI=$acct.imageId}
        } catch { [PSCustomObject]@{Cloud="AWS"; Status="Not AWS or IMDS unreachable"} }
    }
    Run-Cmd "CL3"  "GCP Metadata Check"       {
        try {
            $r = Invoke-RestMethod -Uri "http://metadata.google.internal/computeMetadata/v1/instance/?recursive=true" -Headers @{"Metadata-Flavor"="Google"} -TimeoutSec 3 -ErrorAction Stop
            [PSCustomObject]@{Cloud="GCP"; ProjectId=$r.project; Zone=$r.zone; MachineType=$r.machineType; Name=$r.name}
        } catch { [PSCustomObject]@{Cloud="GCP"; Status="Not GCP or metadata unreachable"} }
    }
    Run-Cmd "CL4"  "Azure Arc Installed"       { Get-WmiObject Win32_Service | Where-Object { $_.Name -like "*himds*" -or $_.Name -like "*GCArcAgent*" } | Select-Object Name,State,StartMode }
    Run-Cmd "CL5"  "Azure VM Agent"            { Get-WmiObject Win32_Service | Where-Object { $_.Name -eq "WindowsAzureGuestAgent" -or $_.Name -eq "WaAppAgent" } | Select-Object Name,State }
    Run-Cmd "CL6"  "AWS SSM Agent"             { Get-WmiObject Win32_Service | Where-Object { $_.Name -like "*AmazonSSM*" } | Select-Object Name,State }
    Run-Cmd "CL7"  "AWS CloudWatch Agent"      { Get-WmiObject Win32_Service | Where-Object { $_.Name -like "*AmazonCloudWatch*" } | Select-Object Name,State }
    Run-Cmd "CL8"  "Cloud Env Variables"       { Get-WmiObject Win32_Environment | Where-Object { $_.Name -match "AWS_|AZURE_|GOOGLE_|GCP_|CLOUD" } | Select-Object Name,VariableValue }
    Run-Cmd "CL9"  "Cloud Installed Software"  { Get-WmiObject Win32_Product -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "Azure|Amazon|AWS|Google Cloud|GCP" } | Select-Object Name,Version,Vendor }
    Run-Cmd "CL10" "Docker Running"            { Get-WmiObject Win32_Service | Where-Object { $_.Name -eq "docker" } | Select-Object Name,State,StartMode }
    Run-Cmd "CL11" "Kubernetes Node Check"     { Get-WmiObject Win32_Service | Where-Object { $_.Name -match "kubelet|kube-proxy|containerd" } | Select-Object Name,State }
    Run-Cmd "CL12" "Cloud CLI Tools"           { @("aws","az","gcloud","kubectl","terraform","helm") | ForEach-Object { $p=Get-Command $_ -ErrorAction SilentlyContinue; [PSCustomObject]@{Tool=$_; Found=($null -ne $p); Path=if($p){$p.Source}else{"Not found"}} } }
    Run-Cmd "CL13" "Azure AD Join Status"      { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo' -ErrorAction SilentlyContinue | Select-Object * | Select-Object -First 5 }
    Run-Cmd "CL14" "Azure Arc Endpoints"       { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Azure Connected Machine Agent' -ErrorAction SilentlyContinue | Select-Object * | Select-Object -First 5 }
    Run-Cmd "CL15" "IMDSv2 Token Test"         {
        try { $t=Invoke-RestMethod -Method PUT -Uri "http://169.254.169.254/latest/api/token" -Headers @{"X-aws-ec2-metadata-token-ttl-seconds"="10"} -TimeoutSec 2 -ErrorAction Stop; [PSCustomObject]@{IMDS="Reachable";Type="AWS-style";Token=$t.Substring(0,10)+"..."} }
        catch { [PSCustomObject]@{IMDS="Unreachable";Info="No cloud IMDS detected"} }
    }
    Run-Cmd "CL16" "Cloud Indicators Summary"  {
        $isAzure = $null -ne (Get-WmiObject Win32_Service | Where-Object { $_.Name -eq "WindowsAzureGuestAgent" })
        $isAWS   = $null -ne (Get-WmiObject Win32_Service | Where-Object { $_.Name -like "*AmazonSSM*" })
        $isDocker= $null -ne (Get-WmiObject Win32_Service | Where-Object { $_.Name -eq "docker" })
        $isK8s   = $null -ne (Get-WmiObject Win32_Service | Where-Object { $_.Name -match "kubelet" })
        [PSCustomObject]@{AzureIndicators=$isAzure; AWSIndicators=$isAWS; DockerRunning=$isDocker; KubernetesNode=$isK8s; CloudEnvVarCount=(Get-WmiObject Win32_Environment | Where-Object { $_.Name -match "AWS_|AZURE_|GOOGLE_" }).Count}
    }
}

# ==== BROWSER ARTIFACTS ====
function Invoke-BrowserArtifacts {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "BROWSER ARTIFACTS (History / Saved Creds Locations)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Write-Host "  NOTE: Shows file paths & metadata only. No plaintext password extraction." -ForegroundColor $ColorScheme.Warning

    # Chrome
    Run-Cmd "BR1"  "Chrome History DB"        { $p="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"; if(Test-Path $p){Get-Item $p|Select-Object FullName,Length,LastWriteTime}else{"Chrome History not found"} }
    Run-Cmd "BR2"  "Chrome Login Data"        { $p="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"; if(Test-Path $p){Get-Item $p|Select-Object FullName,Length,LastWriteTime}else{"Chrome Login Data not found"} }
    Run-Cmd "BR3"  "Chrome Cookies"           { $p="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies"; if(Test-Path $p){Get-Item $p|Select-Object FullName,Length,LastWriteTime}else{"Chrome Cookies not found"} }
    Run-Cmd "BR4"  "Chrome Extensions"        { $p="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Extensions"; if(Test-Path $p){Get-ChildItem $p|Select-Object Name,LastWriteTime|Select-Object -First 20}else{"Chrome Extensions not found"} }
    Run-Cmd "BR5"  "Chrome Profile List"      { $p="$env:LOCALAPPDATA\Google\Chrome\User Data"; if(Test-Path $p){Get-ChildItem $p -Directory|Select-Object Name,LastWriteTime}else{"Chrome not found"} }
    Run-Cmd "BR6"  "Chrome Local State"       { $p="$env:LOCALAPPDATA\Google\Chrome\User Data\Local State"; if(Test-Path $p){Get-Item $p|Select-Object FullName,Length,LastWriteTime}else{"Not found"} }
    # Edge
    Run-Cmd "BR7"  "Edge History DB"          { $p="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History"; if(Test-Path $p){Get-Item $p|Select-Object FullName,Length,LastWriteTime}else{"Edge History not found"} }
    Run-Cmd "BR8"  "Edge Login Data"          { $p="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"; if(Test-Path $p){Get-Item $p|Select-Object FullName,Length,LastWriteTime}else{"Edge Login Data not found"} }
    Run-Cmd "BR9"  "Edge Cookies"             { $p="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cookies"; if(Test-Path $p){Get-Item $p|Select-Object FullName,Length,LastWriteTime}else{"Edge Cookies not found"} }
    Run-Cmd "BR10" "Edge Extensions"          { $p="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Extensions"; if(Test-Path $p){Get-ChildItem $p|Select-Object Name,LastWriteTime|Select-Object -First 15}else{"Not found"} }
    # Firefox
    Run-Cmd "BR11" "Firefox Profile Dir"      { $p="$env:APPDATA\Mozilla\Firefox\Profiles"; if(Test-Path $p){Get-ChildItem $p -Directory|Select-Object Name,LastWriteTime}else{"Firefox not found"} }
    Run-Cmd "BR12" "Firefox Logins.json"      { Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Recurse -Filter "logins.json" -ErrorAction SilentlyContinue | Select-Object FullName,Length,LastWriteTime }
    Run-Cmd "BR13" "Firefox Key4.db"          { Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Recurse -Filter "key4.db" -ErrorAction SilentlyContinue | Select-Object FullName,Length,LastWriteTime }
    Run-Cmd "BR14" "Firefox Cookies.sqlite"   { Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Recurse -Filter "cookies.sqlite" -ErrorAction SilentlyContinue | Select-Object FullName,Length,LastWriteTime }
    Run-Cmd "BR15" "Firefox History (places)" { Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Recurse -Filter "places.sqlite" -ErrorAction SilentlyContinue | Select-Object FullName,Length,LastWriteTime }
    # IE / Legacy
    Run-Cmd "BR16" "IE Saved Passwords Path"  { "$env:APPDATA\Microsoft\Credentials" | ForEach-Object { if(Test-Path $_){Get-ChildItem $_ -ErrorAction SilentlyContinue | Select-Object Name,Length,LastWriteTime}else{"Not found"} } }
    Run-Cmd "BR17" "Windows Credential Store" { cmdkey /list 2>$null }
    Run-Cmd "BR18" "DPAPI Master Keys"        { $p="$env:APPDATA\Microsoft\Protect"; if(Test-Path $p){Get-ChildItem $p -Recurse -ErrorAction SilentlyContinue | Select-Object FullName,LastWriteTime | Select-Object -First 10}else{"Not found"} }
    Run-Cmd "BR19" "Installed Browsers"       { @("chrome","msedge","firefox","brave","opera","vivaldi","iexplore") | ForEach-Object { $n=$_; $found=Get-WmiObject Win32_Process | Where-Object { $_.Name -like "*$n*" }; [PSCustomObject]@{Browser=$n; Running=($null -ne $found -and $found.Count -gt 0)} } }
    Run-Cmd "BR20" "Browser Security Summary" {
        $cChrome = Test-Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
        $cEdge   = Test-Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
        $cFF     = @(Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Recurse -Filter "logins.json" -ErrorAction SilentlyContinue).Count -gt 0
        [PSCustomObject]@{ChromeCredFileExists=$cChrome; EdgeCredFileExists=$cEdge; FirefoxLoginsExist=$cFF; WindowsCredStore=((cmdkey /list 2>$null) -ne $null)}
    }
}

# ==== CVE / VULNERABILITY MATCHING ====
function Invoke-CVEMatch {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "CVE / VULNERABILITY MATCHING (Patch-Based)" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header
    Write-Host "  Comparing installed patches against known critical CVEs..." -ForegroundColor $ColorScheme.InfoLow

    # CVE database: KB -> CVE details
    $cveDB = @(
        [PSCustomObject]@{KB="KB5034441";CVE="CVE-2024-21412";CVSS="8.1";Desc="Windows SmartScreen Security Feature Bypass";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5034763";CVE="CVE-2024-21338";CVSS="7.8";Desc="Windows Kernel Elevation of Privilege";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5032189";CVE="CVE-2023-36036";CVSS="7.8";Desc="Windows Cloud Files Mini Filter EoP";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5031445";CVE="CVE-2023-41763";CVSS="5.3";Desc="Skype for Business Info Disclosure";Severity="MEDIUM"}
        [PSCustomObject]@{KB="KB5031356";CVE="CVE-2023-44487";CVSS="7.5";Desc="HTTP/2 Rapid Reset DDoS (CVSS 7.5)";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5030219";CVE="CVE-2023-38148";CVSS="8.8";Desc="ICS RCE over network";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB5029263";CVE="CVE-2023-35385";CVSS="9.8";Desc="MSMQ RCE (BleedingPipe variant)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB5028166";CVE="CVE-2023-32049";CVSS="8.8";Desc="Windows SmartScreen Bypass";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5027231";CVE="CVE-2023-29360";CVSS="8.4";Desc="TPMVSC EoP";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5026361";CVE="CVE-2023-28252";CVSS="7.8";Desc="CLFS EoP (used in ransomware)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB5025221";CVE="CVE-2023-23397";CVSS="9.8";Desc="Outlook NTLM Hash Theft (zero-click)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB5022842";CVE="CVE-2023-21674";CVSS="8.8";Desc="ALPC EoP (sandbox escape)";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5021233";CVE="CVE-2022-44698";CVSS="5.4";Desc="SmartScreen Bypass";Severity="MEDIUM"}
        [PSCustomObject]@{KB="KB5020030";CVE="CVE-2022-41128";CVSS="8.8";Desc="JScript9 RCE";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB5018427";CVE="CVE-2022-37969";CVSS="7.8";Desc="Windows CLFS EoP (wildly exploited)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB5017308";CVE="CVE-2022-34718";CVSS="9.8";Desc="Windows TCP/IP RCE";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB5015807";CVE="CVE-2022-30190";CVSS="7.8";Desc="Follina MSDT RCE (in-the-wild)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB5013942";CVE="CVE-2022-26925";CVSS="8.1";Desc="LSA Spoofing / PetitPotam";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5011831";CVE="CVE-2022-24521";CVSS="7.8";Desc="CLFS EoP";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5010342";CVE="CVE-2022-21999";CVSS="7.8";Desc="Windows Print Spooler EoP";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5009566";CVE="CVE-2022-21907";CVSS="9.8";Desc="HTTP Protocol Stack RCE (wormable)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB5008212";CVE="CVE-2021-43890";CVSS="7.1";Desc="Windows AppX Installer Spoofing";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5007186";CVE="CVE-2021-42321";CVSS="8.8";Desc="Exchange RCE (post-auth)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB5006670";CVE="CVE-2021-40449";CVSS="7.8";Desc="Win32k EoP (used in APT campaigns)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB5005030";CVE="CVE-2021-36958";CVSS="7.3";Desc="Print Spooler RCE (PrintNightmare variant)";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5004945";CVE="CVE-2021-34527";CVSS="8.8";Desc="PrintNightmare - Print Spooler RCE";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB5003637";CVE="CVE-2021-31956";CVSS="7.8";Desc="NTFS EoP (used in zero-days)";Severity="HIGH"}
        [PSCustomObject]@{KB="KB5000802";CVE="CVE-2021-26897";CVSS="9.8";Desc="Windows DNS Server RCE (wormable)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB4601315";CVE="CVE-2021-1732";CVSS="7.8";Desc="Win32k EoP (exploited in-the-wild)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB4592438";CVE="CVE-2020-17049";CVSS="7.2";Desc="Kerberos Bronze Bit Attack";Severity="HIGH"}
        [PSCustomObject]@{KB="KB4586793";CVE="CVE-2020-16898";CVSS="9.8";Desc="Bad Neighbor - ICMPv6 RCE (wormable)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB4565503";CVE="CVE-2020-1350";CVSS="10.0";Desc="SigRed - Windows DNS RCE (wormable)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB4551762";CVE="CVE-2020-0796";CVSS="10.0";Desc="SMBGhost - SMBv3 RCE (wormable)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB4534271";CVE="CVE-2020-0601";CVSS="8.1";Desc="CurveBall - CryptoAPI Spoofing (NSA)";Severity="HIGH"}
        [PSCustomObject]@{KB="KB4512508";CVE="CVE-2019-0708";CVSS="9.8";Desc="BlueKeep - RDP RCE (wormable)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB4499175";CVE="CVE-2019-0863";CVSS="7.8";Desc="Windows Error Reporting EoP";Severity="HIGH"}
        [PSCustomObject]@{KB="KB4503293";CVE="CVE-2019-1069";CVSS="7.8";Desc="Task Scheduler EoP";Severity="HIGH"}
        [PSCustomObject]@{KB="KB4487017";CVE="CVE-2019-0543";CVSS="7.8";Desc="Win32k EoP";Severity="HIGH"}
        [PSCustomObject]@{KB="KB4471321";CVE="CVE-2018-8611";CVSS="7.8";Desc="Win32k EoP (used by Lazarus APT)";Severity="HIGH"}
        [PSCustomObject]@{KB="KB4093118";CVE="CVE-2018-8120";CVSS="7.0";Desc="Win32k EoP";Severity="HIGH"}
        [PSCustomObject]@{KB="KB4012212";CVE="CVE-2017-0144";CVSS="8.1";Desc="EternalBlue - SMBv1 RCE (WannaCry)";Severity="CRITICAL"}
        [PSCustomObject]@{KB="KB3197867";CVE="CVE-2016-7255";CVSS="7.8";Desc="Win32k EoP (used by Fancy Bear APT)";Severity="HIGH"}
        [PSCustomObject]@{KB="KB3187754";CVE="CVE-2016-3309";CVSS="7.8";Desc="Win32k EoP";Severity="HIGH"}
    )

    # Get installed KBs
    Write-Host "  Loading installed hotfixes..." -ForegroundColor $ColorScheme.InfoLow
    $installedKBs = @(Get-WmiObject Win32_QuickFixEngineering | Select-Object -ExpandProperty HotFixID)
    $buildNum = [int]((Get-WmiObject Win32_OperatingSystem).BuildNumber)

    Write-Host "  Installed patches: $($installedKBs.Count)  |  Build: $buildNum" -ForegroundColor $ColorScheme.InfoLow
    Write-Host ""

    $missing = @(); $present = @()
    foreach ($cve in $cveDB) {
        $found = $installedKBs -contains $cve.KB
        if ($found) { $present += $cve }
        else         { $missing += $cve }
    }

    Write-Host "  ====== MISSING PATCHES (VULNERABLE) ======" -ForegroundColor $ColorScheme.Alert
    if ($missing.Count -gt 0) {
        $missing | Sort-Object CVSS -Descending | Format-Table KB,CVE,CVSS,Severity,Desc -AutoSize | Out-String | Write-Host -ForegroundColor $ColorScheme.Alert
    } else {
        Write-Host "  [OK] All tracked CVEs are patched!" -ForegroundColor $ColorScheme.Success
    }

    Write-Host "  ====== PATCHED CVEs ($($present.Count)) ======" -ForegroundColor $ColorScheme.Success
    $present | Sort-Object CVSS -Descending | Format-Table KB,CVE,CVSS,Severity -AutoSize | Out-String | Write-Host -ForegroundColor $ColorScheme.Success

    Write-Host "  ====== SUMMARY ======" -ForegroundColor $ColorScheme.Title
    $critMissing = @($missing | Where-Object { $_.Severity -eq "CRITICAL" }).Count
    $highMissing = @($missing | Where-Object { $_.Severity -eq "HIGH" }).Count
    [PSCustomObject]@{
        TotalCVEsChecked = $cveDB.Count
        MissingPatches   = $missing.Count
        PatchedCVEs      = $present.Count
        CriticalMissing  = $critMissing
        HighMissing      = $highMissing
        InstalledKBs     = $installedKBs.Count
        OSBuildNumber    = $buildNum
        RiskLevel        = if($critMissing -gt 0){"CRITICAL"}elseif($highMissing -gt 2){"HIGH"}elseif($missing.Count -gt 0){"MEDIUM"}else{"LOW"}
    } | Format-Table -AutoSize | Out-String | Write-Host
}

# ==== THREAT DETECTION ====
function Invoke-ThreatDetection {
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Alert
    Write-Host "THREAT DETECTION" -ForegroundColor $ColorScheme.Alert
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Alert
    Run-Cmd "T1"  "Unsigned Drivers"           { Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.Signed -eq $false } | Select-Object Name,DriverVersion }
    Run-Cmd "T2"  "Empty Password Accounts"    { Get-WmiObject Win32_UserAccount | Where-Object { $_.PasswordRequired -eq $false } | Select-Object Name }
    Run-Cmd "T3"  "Suspicious PowerShell"      { Get-WmiObject Win32_Process | Where-Object { $_.CommandLine -match "-enc|-hidden|-nop|-bypass|-windowstyle" } | Select-Object ProcessId,Name,CommandLine }
    Run-Cmd "T4"  "Suspicious Service Paths"   { Get-WmiObject Win32_Service | Where-Object { $_.PathName -match "AppData|Temp" } | Select-Object Name,PathName }
    Run-Cmd "T5"  "Disabled Firewall"          { Get-WmiObject -Namespace "root\standardcimv2" -Class MSFT_NetFirewallProfile -ErrorAction SilentlyContinue | Where-Object { $_.Enabled -eq $false } | Select-Object Name }
    Run-Cmd "T6"  "Admin Group Members"        { Get-WmiObject Win32_GroupUser | Where-Object { $_.GroupComponent -like "*Administrators*" } | Select-Object UserComponent | Select-Object -First 20 }
    Run-Cmd "T7"  "Auto-Start Count"           { (Get-WmiObject Win32_Service | Where-Object { $_.StartMode -eq "Auto" } | Measure-Object).Count }
    Run-Cmd "T8"  "Unquoted Service Paths"     { Get-WmiObject Win32_Service | Where-Object { $_.PathName -match ' ' -and $_.PathName -notmatch '"' } | Select-Object Name,PathName | Select-Object -First 10 }
    Run-Cmd "T9"  "Startup Items"              { Get-WmiObject Win32_StartupCommand | Select-Object Name,Command,Location,User }
    Run-Cmd "T10" "WMI Subscriptions Exist"    { Get-WmiObject -Namespace root\subscription -Class __EventFilter -ErrorAction SilentlyContinue | Select-Object Name,Query }
    Run-Cmd "T11" "WMI Event Consumers"        { Get-WmiObject -Namespace root\subscription -Class __EventConsumer -ErrorAction SilentlyContinue | Select-Object Name }
    Run-Cmd "T12" "No AV Installed"            { Get-WmiObject -Namespace root\securitycenter2 -Class AntiVirusProduct -ErrorAction SilentlyContinue | Select-Object DisplayName }
    Run-Cmd "T13" "Defender Disabled"          { Get-CimInstance MSFT_MpComputerStatus -Namespace root\microsoft\windows\defender -ErrorAction SilentlyContinue | Select-Object RealTimeProtectionEnabled,AntivirusEnabled }
    Run-Cmd "T14" "SMBv1 Enabled"              { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -ErrorAction SilentlyContinue | Select-Object SMB1 }
    Run-Cmd "T15" "Remote Registry Enabled"    { Get-WmiObject Win32_Service | Where-Object { $_.Name -eq "RemoteRegistry" -and $_.State -eq "Running" } | Select-Object Name,State }
    Run-Cmd "T16" "UAC Disabled"               { Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -ErrorAction SilentlyContinue | Select-Object EnableLUA }
    Run-Cmd "T17" "Credential Guard Off"       { Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\LSA' -ErrorAction SilentlyContinue | Select-Object LsaCfgFlags }
    Run-Cmd "T18" "PS Exec Policy Bypass"      { Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell' -ErrorAction SilentlyContinue | Select-Object ExecutionPolicy }
}

# ==== RISK SCORING ====
function Compute-RiskScore {
    param($Data)
    $findings = @()
    $score = 0

    $noPwd = @($Data["NoPasswordAccounts"])
    if ($noPwd.Count -gt 0) {
        $score += 25
        $findings += [PSCustomObject]@{ Severity="CRITICAL"; Finding="Accounts with no password required ($($noPwd.Count) account(s))"; Points=25 }
    }
    $unsDrv = @($Data["UnsignedDrivers"])
    if ($unsDrv.Count -gt 0) {
        $pts = [math]::Min(20, $unsDrv.Count * 4)
        $score += $pts
        $findings += [PSCustomObject]@{ Severity="HIGH"; Finding="Unsigned kernel drivers detected ($($unsDrv.Count))"; Points=$pts }
    }
    $fwOff = @($Data["Firewall"] | Where-Object { $_.Enabled -eq $false })
    if ($fwOff.Count -gt 0) {
        $score += 20
        $findings += [PSCustomObject]@{ Severity="CRITICAL"; Finding="Firewall disabled on $($fwOff.Count) profile(s): $(($fwOff.Name -join ', '))"; Points=20 }
    }
    $av = @($Data["AntiVirus"])
    if ($av.Count -eq 0) {
        $score += 20
        $findings += [PSCustomObject]@{ Severity="HIGH"; Finding="No antivirus product detected via WMI SecurityCenter2"; Points=20 }
    }
    $suspSvc = @($Data["SuspiciousServicePaths"])
    if ($suspSvc.Count -gt 0) {
        $score += 15
        $findings += [PSCustomObject]@{ Severity="HIGH"; Finding="Services running from AppData/Temp ($($suspSvc.Count))"; Points=15 }
    }
    $suspPS = @($Data["SuspiciousPowerShell"])
    if ($suspPS.Count -gt 0) {
        $score += 20
        $findings += [PSCustomObject]@{ Severity="CRITICAL"; Finding="PowerShell running with suspicious flags ($($suspPS.Count) process(es))"; Points=20 }
    }
    $unquoted = @($Data["UnquotedServicePaths"])
    if ($unquoted.Count -gt 0) {
        $score += 15
        $findings += [PSCustomObject]@{ Severity="HIGH"; Finding="Unquoted service paths found ($($unquoted.Count)) -- privilege escalation risk"; Points=15 }
    }
    $nonAdminShares = @($Data["Shares"] | Where-Object { $_.Name -notmatch "ADMIN\$|IPC\$|C\$|print\$" })
    if ($nonAdminShares.Count -gt 0) {
        $score += 10
        $findings += [PSCustomObject]@{ Severity="MEDIUM"; Finding="Non-default network shares present ($($nonAdminShares.Count))"; Points=10 }
    }
    $hf = @($Data["Hotfixes"])
    if ($hf.Count -lt 5) {
        $score += 15
        $findings += [PSCustomObject]@{ Severity="HIGH"; Finding="Very few hotfixes found ($($hf.Count)) -- system may be unpatched"; Points=15 }
    }
    $startup = @($Data["StartupCommands"])
    if ($startup.Count -gt 3) {
        $score += 10
        $findings += [PSCustomObject]@{ Severity="MEDIUM"; Finding="Many startup items registered ($($startup.Count))"; Points=10 }
    }
    $wmiSub = @($Data["WMISubscriptions"])
    if ($wmiSub.Count -gt 0) {
        $score += 20
        $findings += [PSCustomObject]@{ Severity="CRITICAL"; Finding="WMI event subscriptions found ($($wmiSub.Count)) -- common malware persistence"; Points=20 }
    }
    $uacOff = $Data["UACStatus"]
    if ($uacOff -and $uacOff.EnableLUA -eq 0) {
        $score += 15
        $findings += [PSCustomObject]@{ Severity="HIGH"; Finding="UAC is disabled -- privilege elevation trivial"; Points=15 }
    }
    $smb1 = $Data["SMBv1"]
    if ($smb1 -and $smb1.SMB1 -eq 1) {
        $score += 15
        $findings += [PSCustomObject]@{ Severity="HIGH"; Finding="SMBv1 enabled -- EternalBlue / WannaCry risk"; Points=15 }
    }

    $score = [math]::Min(100, $score)
    $level = if ($score -ge 75) {"CRITICAL"} elseif ($score -ge 50) {"HIGH"} elseif ($score -ge 25) {"MEDIUM"} else {"LOW"}
    return [PSCustomObject]@{ Score=$score; Level=$level; Findings=$findings }
}

# ==== MITRE MAPPING (100+ TTPs) ====
function Get-MitreMapping {
    param($Data)
    $t = @()

    # Always-present discovery TTPs
    $t += [PSCustomObject]@{ TechID="T1082"; Name="System Information Discovery"; Tactic="Discovery"; Reason="Full OS, hardware and config enumerable by any local user via WMI."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1082/" }
    $t += [PSCustomObject]@{ TechID="T1049"; Name="System Network Connections Discovery"; Tactic="Discovery"; Reason="Network shares, routes and adapter config readable without admin rights."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1049/" }
    $t += [PSCustomObject]@{ TechID="T1087"; Name="Account Discovery"; Tactic="Discovery"; Reason="Local users, groups and SIDs enumerable -- helps attacker identify high-value targets."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1087/" }
    $t += [PSCustomObject]@{ TechID="T1057"; Name="Process Discovery"; Tactic="Discovery"; Reason="All running processes and their command lines visible via WMI."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1057/" }
    $t += [PSCustomObject]@{ TechID="T1016"; Name="System Network Configuration Discovery"; Tactic="Discovery"; Reason="IP address, DNS, DHCP, routing table accessible via WMI to standard users."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1016/" }
    $t += [PSCustomObject]@{ TechID="T1012"; Name="Query Registry"; Tactic="Discovery"; Reason="Registry values such as environment variables and paths are readable via WMI and direct queries."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1012/" }
    $t += [PSCustomObject]@{ TechID="T1033"; Name="System Owner/User Discovery"; Tactic="Discovery"; Reason="Logged-on users, profiles and session info readable via Win32_LoggedOnUser."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1033/" }
    $t += [PSCustomObject]@{ TechID="T1083"; Name="File and Directory Discovery"; Tactic="Discovery"; Reason="Disk volumes, mount points and paths enumerable via WMI logical disk classes."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1083/" }
    $t += [PSCustomObject]@{ TechID="T1135"; Name="Network Share Discovery"; Tactic="Discovery"; Reason="All shares enumerable via Win32_Share without admin rights."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1135/" }
    $t += [PSCustomObject]@{ TechID="T1069"; Name="Permission Groups Discovery"; Tactic="Discovery"; Reason="Local groups, membership and SIDs enumerable via WMI."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1069/" }
    $t += [PSCustomObject]@{ TechID="T1518"; Name="Software Discovery"; Tactic="Discovery"; Reason="Installed software, versions and vendors readable via Win32_Product and WMI."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1518/" }
    $t += [PSCustomObject]@{ TechID="T1046"; Name="Network Service Discovery"; Tactic="Discovery"; Reason="Running services including network listeners visible via WMI."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1046/" }
    $t += [PSCustomObject]@{ TechID="T1047"; Name="Windows Management Instrumentation"; Tactic="Execution"; Reason="WMI itself used as execution vehicle by attackers for lateral movement and persistence."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1047/" }
    $t += [PSCustomObject]@{ TechID="T1120"; Name="Peripheral Device Discovery"; Tactic="Discovery"; Reason="USB, serial, audio and video devices all enumerable via WMI PnP classes."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1120/" }
    $t += [PSCustomObject]@{ TechID="T1010"; Name="Application Window Discovery"; Tactic="Discovery"; Reason="Running processes and their sessions visible -- window discovery possible."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1010/" }

    # Conditional TTPs based on data findings
    if (@($Data["NoPasswordAccounts"]).Count -gt 0) {
        $t += [PSCustomObject]@{ TechID="T1078"; Name="Valid Accounts"; Tactic="Initial Access / Persistence / Defense Evasion"; Reason="Accounts exist with no password -- attacker can authenticate without credentials."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1078/" }
        $t += [PSCustomObject]@{ TechID="T1078.001"; Name="Default Accounts"; Tactic="Defense Evasion"; Reason="Accounts with blank passwords may represent default or unfinished account setup."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1078/001/" }
        $t += [PSCustomObject]@{ TechID="T1110"; Name="Brute Force"; Tactic="Credential Access"; Reason="No-password accounts are trivially compromised -- no brute force even needed."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1110/" }
    }
    if (@($Data["UnsignedDrivers"]).Count -gt 0) {
        $t += [PSCustomObject]@{ TechID="T1014"; Name="Rootkit"; Tactic="Defense Evasion"; Reason="Unsigned kernel-mode drivers present -- attacker can load malicious drivers."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1014/" }
        $t += [PSCustomObject]@{ TechID="T1553.006"; Name="Code Signing Policy Modification"; Tactic="Defense Evasion"; Reason="Unsigned drivers loaded suggests code signing enforcement may be weakened."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1553/006/" }
        $t += [PSCustomObject]@{ TechID="T1068"; Name="Exploitation for Privilege Escalation"; Tactic="Privilege Escalation"; Reason="Unsigned/vulnerable drivers can be exploited for kernel-level privilege escalation."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1068/" }
    }
    if (@($Data["SuspiciousPowerShell"]).Count -gt 0) {
        $t += [PSCustomObject]@{ TechID="T1059.001"; Name="PowerShell"; Tactic="Execution"; Reason="PowerShell running with -enc/-hidden/-nop/-bypass flags -- obfuscated execution."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1059/001/" }
        $t += [PSCustomObject]@{ TechID="T1027"; Name="Obfuscated Files or Information"; Tactic="Defense Evasion"; Reason="Encoded/hidden PowerShell arguments indicate payload obfuscation."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1027/" }
        $t += [PSCustomObject]@{ TechID="T1620"; Name="Reflective Code Loading"; Tactic="Defense Evasion"; Reason="Hidden PowerShell may load code directly into memory without touching disk."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1620/" }
        $t += [PSCustomObject]@{ TechID="T1140"; Name="Deobfuscate/Decode Files or Information"; Tactic="Defense Evasion"; Reason="Base64-encoded PowerShell decodes payloads at runtime to evade static analysis."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1140/" }
        $t += [PSCustomObject]@{ TechID="T1562.001"; Name="Disable or Modify Tools"; Tactic="Defense Evasion"; Reason="-bypass and -nop flags disable PowerShell's built-in security controls."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1562/001/" }
    }
    $fwOff = @($Data["Firewall"] | Where-Object { $_.Enabled -eq $false })
    if ($fwOff.Count -gt 0) {
        $t += [PSCustomObject]@{ TechID="T1562.004"; Name="Disable/Modify System Firewall"; Tactic="Defense Evasion"; Reason="Firewall disabled -- all traffic is unfiltered, C2 and lateral movement unrestricted."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1562/004/" }
        $t += [PSCustomObject]@{ TechID="T1021"; Name="Remote Services"; Tactic="Lateral Movement"; Reason="Without firewall, RDP, SMB, WinRM and WMI are reachable from network."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1021/" }
        $t += [PSCustomObject]@{ TechID="T1571"; Name="Non-Standard Port"; Tactic="Command and Control"; Reason="No firewall means C2 beacons can use any port without being blocked."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1571/" }
        $t += [PSCustomObject]@{ TechID="T1090"; Name="Proxy"; Tactic="Command and Control"; Reason="No firewall allows C2 traffic over any proxy or tunneling method."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1090/" }
        $t += [PSCustomObject]@{ TechID="T1219"; Name="Remote Access Software"; Tactic="Command and Control"; Reason="No firewall allows remote access tools to connect from any address."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1219/" }
    }
    if (@($Data["SuspiciousServicePaths"]).Count -gt 0) {
        $t += [PSCustomObject]@{ TechID="T1543.003"; Name="Windows Service"; Tactic="Persistence / Privilege Escalation"; Reason="Services running from AppData or Temp -- common malware persistence via service."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1543/003/" }
        $t += [PSCustomObject]@{ TechID="T1569.002"; Name="Service Execution"; Tactic="Execution"; Reason="Malicious service executable in user-writable paths can be executed via service control."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1569/002/" }
    }
    if (@($Data["UnquotedServicePaths"]).Count -gt 0) {
        $t += [PSCustomObject]@{ TechID="T1574.009"; Name="Path Interception -- Unquoted Path"; Tactic="Persistence / Privilege Escalation"; Reason="Unquoted service paths allow crafted executable in parent directory to run as SYSTEM."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1574/009/" }
        $t += [PSCustomObject]@{ TechID="T1574"; Name="Hijack Execution Flow"; Tactic="Defense Evasion"; Reason="Path interception is a form of execution flow hijacking in Windows."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1574/" }
    }
    $nonAdmin = @($Data["Shares"] | Where-Object { $_.Name -notmatch "ADMIN\$|IPC\$|C\$|print\$" })
    if ($nonAdmin.Count -gt 0) {
        $t += [PSCustomObject]@{ TechID="T1039"; Name="Data from Network Shared Drive"; Tactic="Collection"; Reason="Non-default shares available -- attacker can collect sensitive files from network."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1039/" }
        $t += [PSCustomObject]@{ TechID="T1021.002"; Name="SMB/Windows Admin Shares"; Tactic="Lateral Movement"; Reason="Accessible shares may be used to push payloads to other systems."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1021/002/" }
        $t += [PSCustomObject]@{ TechID="T1074"; Name="Data Staged"; Tactic="Collection"; Reason="Network shares can be used to stage collected data before exfiltration."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1074/" }
    }
    if (@($Data["StartupCommands"]).Count -gt 0) {
        $t += [PSCustomObject]@{ TechID="T1547.001"; Name="Registry Run Keys / Startup Folder"; Tactic="Persistence"; Reason="Startup commands detected -- malicious ones execute automatically on every login."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1547/001/" }
        $t += [PSCustomObject]@{ TechID="T1037"; Name="Boot or Logon Initialization Scripts"; Tactic="Persistence"; Reason="Startup commands run at logon -- common persistence vector."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1037/" }
    }
    if (@($Data["AntiVirus"]).Count -eq 0) {
        $t += [PSCustomObject]@{ TechID="T1562.001"; Name="Disable or Modify Tools"; Tactic="Defense Evasion"; Reason="No AV detected -- malware can execute, persist and spread without signature-based detection."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1562/001/" }
        $t += [PSCustomObject]@{ TechID="T1036"; Name="Masquerading"; Tactic="Defense Evasion"; Reason="Without AV, malware can masquerade as legitimate executables with no detection."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1036/" }
    }
    if (@($Data["WMISubscriptions"]).Count -gt 0) {
        $t += [PSCustomObject]@{ TechID="T1546.003"; Name="WMI Event Subscription"; Tactic="Privilege Escalation / Persistence"; Reason="WMI subscriptions found -- strong indicator of fileless persistence mechanism."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1546/003/" }
        $t += [PSCustomObject]@{ TechID="T1546"; Name="Event Triggered Execution"; Tactic="Persistence"; Reason="WMI event subscriptions trigger code execution automatically on system events."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1546/" }
    }
    if ($Data["Hotfixes"] -and @($Data["Hotfixes"]).Count -lt 5) {
        $t += [PSCustomObject]@{ TechID="T1190"; Name="Exploit Public-Facing Application"; Tactic="Initial Access"; Reason="Very few patches installed -- known CVEs likely unpatched, enabling exploitation."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1190/" }
        $t += [PSCustomObject]@{ TechID="T1210"; Name="Exploitation of Remote Services"; Tactic="Lateral Movement"; Reason="Unpatched system is vulnerable to remote exploitation of network services."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1210/" }
        $t += [PSCustomObject]@{ TechID="T1203"; Name="Exploitation for Client Execution"; Tactic="Execution"; Reason="Unpatched client applications may be vulnerable to exploit-based execution."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1203/" }
    }

    # Additional always-applicable TTPs covering key MITRE categories
    $t += [PSCustomObject]@{ TechID="T1003"; Name="OS Credential Dumping"; Tactic="Credential Access"; Reason="Process memory, registry and WMI access patterns can support LSASS dumping by privileged attackers."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1003/" }
    $t += [PSCustomObject]@{ TechID="T1003.001"; Name="LSASS Memory"; Tactic="Credential Access"; Reason="LSASS process memory accessible to admin users -- credential dumping risk if admin account compromised."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1003/001/" }
    $t += [PSCustomObject]@{ TechID="T1053.005"; Name="Scheduled Task/Job"; Tactic="Execution / Persistence"; Reason="Scheduled tasks readable via WMI -- attackers enumerate and abuse task scheduler for persistence."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1053/005/" }
    $t += [PSCustomObject]@{ TechID="T1055"; Name="Process Injection"; Tactic="Defense Evasion / Privilege Escalation"; Reason="Running processes visible -- DLL injection and process hollowing require process enumeration first."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1055/" }
    $t += [PSCustomObject]@{ TechID="T1055.001"; Name="DLL Injection"; Tactic="Defense Evasion"; Reason="Process list and module enumeration via WMI enables DLL injection targeting."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1055/001/" }
    $t += [PSCustomObject]@{ TechID="T1059.003"; Name="Windows Command Shell"; Tactic="Execution"; Reason="CMD.exe instances visible -- command-line execution vector for attackers."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1059/003/" }
    $t += [PSCustomObject]@{ TechID="T1059.005"; Name="Visual Basic"; Tactic="Execution"; Reason="VBScript/WScript is available on Windows -- scripting execution vector."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1059/005/" }
    $t += [PSCustomObject]@{ TechID="T1059.007"; Name="JavaScript"; Tactic="Execution"; Reason="WScript and mshta.exe can execute JavaScript -- fileless execution vector."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1059/007/" }
    $t += [PSCustomObject]@{ TechID="T1070"; Name="Indicator Removal"; Tactic="Defense Evasion"; Reason="Event log sizes and contents visible -- attackers may clear logs to remove evidence."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1070/" }
    $t += [PSCustomObject]@{ TechID="T1070.001"; Name="Clear Windows Event Logs"; Tactic="Defense Evasion"; Reason="Security/System event logs are accessible and can be cleared by administrators."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1070/001/" }
    $t += [PSCustomObject]@{ TechID="T1071"; Name="Application Layer Protocol"; Tactic="Command and Control"; Reason="Network adapter configuration shows internet connectivity enabling C2 over HTTP/S/DNS."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1071/" }
    $t += [PSCustomObject]@{ TechID="T1098"; Name="Account Manipulation"; Tactic="Persistence"; Reason="User accounts and group memberships enumerable -- attackers add accounts to privileged groups."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1098/" }
    $t += [PSCustomObject]@{ TechID="T1112"; Name="Modify Registry"; Tactic="Defense Evasion"; Reason="Registry is a persistence target -- run keys, service configs and security settings all modifiable."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1112/" }
    $t += [PSCustomObject]@{ TechID="T1136"; Name="Create Account"; Tactic="Persistence"; Reason="User account information enumerable -- attackers create hidden accounts for persistent access."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1136/" }
    $t += [PSCustomObject]@{ TechID="T1197"; Name="BITS Jobs"; Tactic="Persistence / Defense Evasion"; Reason="Background Intelligent Transfer Service can be abused for stealthy downloads and persistence."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1197/" }
    $t += [PSCustomObject]@{ TechID="T1218"; Name="System Binary Proxy Execution"; Tactic="Defense Evasion"; Reason="Signed Windows binaries (regsvr32, mshta, certutil) can proxy malicious code execution."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1218/" }
    $t += [PSCustomObject]@{ TechID="T1218.003"; Name="CMSTP"; Tactic="Defense Evasion"; Reason="CMSTP.exe can be abused to execute arbitrary DLLs and bypass AppLocker."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1218/003/" }
    $t += [PSCustomObject]@{ TechID="T1218.005"; Name="Mshta"; Tactic="Defense Evasion"; Reason="Mshta.exe can execute malicious HTA files to bypass application whitelisting."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1218/005/" }
    $t += [PSCustomObject]@{ TechID="T1218.010"; Name="Regsvr32"; Tactic="Defense Evasion"; Reason="Regsvr32 can load COM scriptlets remotely bypassing security tools."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1218/010/" }
    $t += [PSCustomObject]@{ TechID="T1218.011"; Name="Rundll32"; Tactic="Defense Evasion"; Reason="Rundll32 can execute arbitrary DLL exports, often abused to evade detection."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1218/011/" }
    $t += [PSCustomObject]@{ TechID="T1547.004"; Name="Winlogon Helper DLL"; Tactic="Persistence"; Reason="Winlogon registry key abusable for persistent DLL loading at every logon."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1547/004/" }
    $t += [PSCustomObject]@{ TechID="T1547.005"; Name="Security Support Provider"; Tactic="Persistence"; Reason="SSP DLLs loaded by LSASS -- malicious SSPs can steal credentials on every authentication."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1547/005/" }
    $t += [PSCustomObject]@{ TechID="T1548.002"; Name="Bypass User Account Control"; Tactic="Privilege Escalation"; Reason="UAC bypass techniques allow elevation from medium to high integrity without prompt."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1548/002/" }
    $t += [PSCustomObject]@{ TechID="T1550.002"; Name="Pass the Hash"; Tactic="Defense Evasion / Lateral Movement"; Reason="NTLM hashes extractable from memory can be used for lateral movement without passwords."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1550/002/" }
    $t += [PSCustomObject]@{ TechID="T1552"; Name="Unsecured Credentials"; Tactic="Credential Access"; Reason="Environment variables, registry and config files may contain hardcoded credentials."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1552/" }
    $t += [PSCustomObject]@{ TechID="T1552.002"; Name="Credentials in Registry"; Tactic="Credential Access"; Reason="Windows registry often contains stored credentials for services, VPNs and applications."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1552/002/" }
    $t += [PSCustomObject]@{ TechID="T1555"; Name="Credentials from Password Stores"; Tactic="Credential Access"; Reason="Windows Credential Manager and browser stores can be accessed by malware."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1555/" }
    $t += [PSCustomObject]@{ TechID="T1558"; Name="Steal or Forge Kerberos Tickets"; Tactic="Credential Access"; Reason="Domain-joined systems are vulnerable to Kerberoasting and Pass-the-Ticket attacks."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1558/" }
    $t += [PSCustomObject]@{ TechID="T1560"; Name="Archive Collected Data"; Tactic="Collection"; Reason="Collected audit data represents sensitive information that could be archived and exfiltrated."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1560/" }
    $t += [PSCustomObject]@{ TechID="T1486"; Name="Data Encrypted for Impact"; Tactic="Impact"; Reason="Unpatched or unprotected system vulnerable to ransomware encryption of all files."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1486/" }
    $t += [PSCustomObject]@{ TechID="T1489"; Name="Service Stop"; Tactic="Impact"; Reason="Service control accessible -- attackers stop AV/EDR services to disable defenses."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1489/" }
    $t += [PSCustomObject]@{ TechID="T1490"; Name="Inhibit System Recovery"; Tactic="Impact"; Reason="Shadow copies enumerable -- ransomware typically deletes VSS copies before encrypting."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1490/" }
    $t += [PSCustomObject]@{ TechID="T1491"; Name="Defacement"; Tactic="Impact"; Reason="System with insufficient controls vulnerable to web or desktop defacement."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1491/" }
    $t += [PSCustomObject]@{ TechID="T1499"; Name="Endpoint Denial of Service"; Tactic="Impact"; Reason="Process and memory information readable -- resource exhaustion attacks aided by enumeration."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1499/" }
    $t += [PSCustomObject]@{ TechID="T1021.001"; Name="Remote Desktop Protocol"; Tactic="Lateral Movement"; Reason="RDP settings visible via WMI -- enabled RDP expands attack surface for lateral movement."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1021/001/" }
    $t += [PSCustomObject]@{ TechID="T1021.006"; Name="Windows Remote Management"; Tactic="Lateral Movement"; Reason="WinRM service state visible -- if running, enables authenticated remote execution."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1021/006/" }
    $t += [PSCustomObject]@{ TechID="T1091"; Name="Replication Through Removable Media"; Tactic="Initial Access / Lateral Movement"; Reason="USB and removable media devices enumerable -- autorun and Stuxnet-style spread possible."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1091/" }
    $t += [PSCustomObject]@{ TechID="T1127"; Name="Trusted Developer Utilities Proxy Execution"; Tactic="Defense Evasion"; Reason="MSBuild, csc.exe and other dev tools can compile and execute code, bypassing whitelisting."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1127/" }
    $t += [PSCustomObject]@{ TechID="T1134"; Name="Access Token Manipulation"; Tactic="Defense Evasion / Privilege Escalation"; Reason="Running as SYSTEM or high-integrity processes enable token impersonation attacks."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1134/" }
    $t += [PSCustomObject]@{ TechID="T1176"; Name="Browser Extensions"; Tactic="Persistence"; Reason="Browser data enumerable -- malicious extensions can persist and steal credentials."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1176/" }
    $t += [PSCustomObject]@{ TechID="T1480"; Name="Execution Guardrails"; Tactic="Defense Evasion"; Reason="System fingerprinting data enables malware to verify target before executing payload."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1480/" }
    $t += [PSCustomObject]@{ TechID="T1497"; Name="Virtualization/Sandbox Evasion"; Tactic="Defense Evasion"; Reason="Hardware, BIOS and system identifiers readable -- used by malware to detect sandbox analysis."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1497/" }
    $t += [PSCustomObject]@{ TechID="T1543.001"; Name="Launch Agent"; Tactic="Persistence"; Reason="Auto-start and service mechanisms enable malware persistence across reboots."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1543/001/" }
    $t += [PSCustomObject]@{ TechID="T1547.009"; Name="Shortcut Modification"; Tactic="Persistence / Privilege Escalation"; Reason="Startup folder and shortcut paths readable -- malicious shortcuts can be planted for persistence."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1547/009/" }
    $t += [PSCustomObject]@{ TechID="T1548.004"; Name="Elevated Execution with Prompt"; Tactic="Privilege Escalation"; Reason="UAC prompts can be spoofed or auto-elevated with certain OS configurations."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1548/004/" }
    $t += [PSCustomObject]@{ TechID="T1556"; Name="Modify Authentication Process"; Tactic="Credential Access / Defense Evasion"; Reason="Authentication packages and LSA configuration readable -- attack entry point."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1556/" }
    $t += [PSCustomObject]@{ TechID="T1574.001"; Name="DLL Search Order Hijacking"; Tactic="Persistence / Privilege Escalation"; Reason="PATH environment variables and search order enumerable -- DLL hijacking locations identifiable."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1574/001/" }
    $t += [PSCustomObject]@{ TechID="T1574.002"; Name="DLL Side-Loading"; Tactic="Defense Evasion / Persistence"; Reason="Third-party applications in non-standard paths may load unsigned DLLs from their directory."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1574/002/" }
    $t += [PSCustomObject]@{ TechID="T1574.011"; Name="Services Registry Permissions Weakness"; Tactic="Persistence / Privilege Escalation"; Reason="Service registry keys with weak ACLs allow attackers to modify service binary paths."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1574/011/" }
    $t += [PSCustomObject]@{ TechID="T1059.002"; Name="AppleScript / CMD Shell Variants"; Tactic="Execution"; Reason="Multiple shell execution environments available (wscript, cscript, mshta, rundll32)."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1059/" }
    $t += [PSCustomObject]@{ TechID="T1040"; Name="Network Sniffing"; Tactic="Discovery / Credential Access"; Reason="Network adapter promiscuous mode and routing info readable -- enabling sniffing setup."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1040/" }
    $t += [PSCustomObject]@{ TechID="T1048"; Name="Exfiltration Over Alternative Protocol"; Tactic="Exfiltration"; Reason="No firewall means data can be exfiltrated over DNS, ICMP, SMTP or custom protocols."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1048/" }
    $t += [PSCustomObject]@{ TechID="T1041"; Name="Exfiltration Over C2 Channel"; Tactic="Exfiltration"; Reason="Outbound traffic unmonitored -- C2 channel can double as exfiltration path."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1041/" }
    $t += [PSCustomObject]@{ TechID="T1567"; Name="Exfiltration Over Web Service"; Tactic="Exfiltration"; Reason="No content filtering means data can be uploaded to Pastebin, GitHub or cloud storage."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1567/" }
    $t += [PSCustomObject]@{ TechID="T1571"; Name="Non-Standard Port"; Tactic="Command and Control"; Reason="No port restrictions means C2 can operate on any port."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1571/" }
    $t += [PSCustomObject]@{ TechID="T1572"; Name="Protocol Tunneling"; Tactic="Command and Control"; Reason="Open network enables DNS tunneling, ICMP tunneling and other covert channels."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1572/" }
    $t += [PSCustomObject]@{ TechID="T1564"; Name="Hide Artifacts"; Tactic="Defense Evasion"; Reason="NTFS alternate data streams and hidden files can be used to conceal malware."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1564/" }
    $t += [PSCustomObject]@{ TechID="T1564.004"; Name="NTFS File Attributes"; Tactic="Defense Evasion"; Reason="NTFS alternate data streams allow hiding executable payloads within legitimate files."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1564/004/" }

    # ===== ADDITIONAL TTPs: Credential Access =====
    $t += [PSCustomObject]@{ TechID="T1003.002"; Name="SAM Database"; Tactic="Credential Access"; Reason="SAM database readable by SYSTEM -- contains hashed local credentials."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1003/002/" }
    $t += [PSCustomObject]@{ TechID="T1003.003"; Name="NTDS Database"; Tactic="Credential Access"; Reason="If domain controller, NTDS.dit holds all domain credential hashes."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1003/003/" }
    $t += [PSCustomObject]@{ TechID="T1003.004"; Name="LSA Secrets"; Tactic="Credential Access"; Reason="LSA secrets in registry hold service account and cached credentials."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1003/004/" }
    $t += [PSCustomObject]@{ TechID="T1003.005"; Name="Cached Domain Credentials"; Tactic="Credential Access"; Reason="Cached domain logon credentials stored locally enable offline cracking."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1003/005/" }
    $t += [PSCustomObject]@{ TechID="T1552.001"; Name="Credentials In Files"; Tactic="Credential Access"; Reason="Browser credential databases and config files may contain plaintext or encoded passwords."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1552/001/" }
    $t += [PSCustomObject]@{ TechID="T1552.002"; Name="Credentials in Registry"; Tactic="Credential Access"; Reason="AutoLogon, SNMP community strings and other creds stored in registry keys."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1552/002/" }
    $t += [PSCustomObject]@{ TechID="T1552.004"; Name="Private Keys"; Tactic="Credential Access"; Reason="Certificate stores contain private keys accessible to admins and possibly lower-privileged users."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1552/004/" }
    $t += [PSCustomObject]@{ TechID="T1555"; Name="Credentials from Password Stores"; Tactic="Credential Access"; Reason="Windows Credential Manager, browser databases hold stored credentials."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1555/" }
    $t += [PSCustomObject]@{ TechID="T1555.003"; Name="Credentials from Web Browsers"; Tactic="Credential Access"; Reason="Chrome/Edge/Firefox credential databases present -- extractable with DPAPI bypass."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1555/003/" }
    $t += [PSCustomObject]@{ TechID="T1539"; Name="Steal Web Session Cookie"; Tactic="Credential Access"; Reason="Browser cookie databases present -- session theft enables account takeover."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1539/" }
    $t += [PSCustomObject]@{ TechID="T1528"; Name="Steal Application Access Token"; Tactic="Credential Access"; Reason="OAuth tokens and API keys may be cached in browser storage or config files."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1528/" }
    $t += [PSCustomObject]@{ TechID="T1606"; Name="Forge Web Credentials"; Tactic="Credential Access"; Reason="Certificate infrastructure visible -- forged tokens possible if CA compromised."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1606/" }

    # ===== ADDITIONAL TTPs: Lateral Movement =====
    $t += [PSCustomObject]@{ TechID="T1021.003"; Name="Distributed Component Object Model"; Tactic="Lateral Movement"; Reason="DCOM applications enumerable -- DCOM-based lateral movement (MMC20, ShellWindows) possible."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1021/003/" }
    $t += [PSCustomObject]@{ TechID="T1021.004"; Name="SSH"; Tactic="Lateral Movement"; Reason="OpenSSH server for Windows may be installed -- enables lateral movement via SSH keys."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1021/004/" }
    $t += [PSCustomObject]@{ TechID="T1021.005"; Name="VNC"; Tactic="Lateral Movement"; Reason="VNC/remote desktop tools installed may enable authenticated lateral movement."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1021/005/" }
    $t += [PSCustomObject]@{ TechID="T1550.002"; Name="Pass the Hash"; Tactic="Lateral Movement / Defense Evasion"; Reason="NTLM enabled and WDigest may cache creds in memory -- enables PtH attacks."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1550/002/" }
    $t += [PSCustomObject]@{ TechID="T1550.003"; Name="Pass the Ticket"; Tactic="Lateral Movement / Defense Evasion"; Reason="Kerberos ticket caching -- Golden/Silver ticket attacks target domain-joined systems."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1550/003/" }
    $t += [PSCustomObject]@{ TechID="T1534"; Name="Internal Spearphishing"; Tactic="Lateral Movement"; Reason="Network shares and email client info readable -- used to craft internal phishing messages."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1534/" }

    # ===== ADDITIONAL TTPs: Initial Access =====
    $t += [PSCustomObject]@{ TechID="T1566.001"; Name="Spearphishing Attachment"; Tactic="Initial Access"; Reason="Office macros and scripting engines present -- malicious documents can execute payloads."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1566/001/" }
    $t += [PSCustomObject]@{ TechID="T1566.002"; Name="Spearphishing Link"; Tactic="Initial Access"; Reason="Browsers installed and internet-connected -- malicious links can deliver drive-by exploits."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1566/002/" }
    $t += [PSCustomObject]@{ TechID="T1195"; Name="Supply Chain Compromise"; Tactic="Initial Access"; Reason="Third-party software present -- compromised updates or installers are supply chain vectors."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1195/" }
    $t += [PSCustomObject]@{ TechID="T1200"; Name="Hardware Additions"; Tactic="Initial Access"; Reason="USB devices enumerable -- HID injection attacks (Rubber Ducky, BadUSB) possible."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1200/" }
    $t += [PSCustomObject]@{ TechID="T1133"; Name="External Remote Services"; Tactic="Initial Access / Persistence"; Reason="VPN, RDP and remote access services enumerable -- brute force entry point."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1133/" }

    # ===== ADDITIONAL TTPs: Collection =====
    $t += [PSCustomObject]@{ TechID="T1560"; Name="Archive Collected Data"; Tactic="Collection"; Reason="Compression tools available (7-zip, WinRAR) -- enables data archiving before exfiltration."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1560/" }
    $t += [PSCustomObject]@{ TechID="T1005"; Name="Data from Local System"; Tactic="Collection"; Reason="Local filesystem and mounted volumes accessible -- sensitive files can be harvested."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1005/" }
    $t += [PSCustomObject]@{ TechID="T1025"; Name="Data from Removable Media"; Tactic="Collection"; Reason="Removable media drives present -- USB-based data theft possible."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1025/" }
    $t += [PSCustomObject]@{ TechID="T1056.001"; Name="Keylogging"; Tactic="Collection / Credential Access"; Reason="Keyboard devices and input hooks accessible to kernel-level malware."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1056/001/" }
    $t += [PSCustomObject]@{ TechID="T1113"; Name="Screen Capture"; Tactic="Collection"; Reason="Video controller and display drivers accessible -- screen capture trivial with user-level code."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1113/" }
    $t += [PSCustomObject]@{ TechID="T1123"; Name="Audio Capture"; Tactic="Collection"; Reason="Sound devices enumerable -- audio capture possible with low-privilege code."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1123/" }
    $t += [PSCustomObject]@{ TechID="T1125"; Name="Video Capture"; Tactic="Collection"; Reason="USB camera devices enumerable -- video capture possible if webcam connected."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1125/" }
    $t += [PSCustomObject]@{ TechID="T1114"; Name="Email Collection"; Tactic="Collection"; Reason="Outlook/mail client data accessible on disk -- PST files can be exfiltrated."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1114/" }
    $t += [PSCustomObject]@{ TechID="T1530"; Name="Data from Cloud Storage"; Tactic="Collection"; Reason="Cloud CLI tools present -- OneDrive, S3 or GCS data accessible via stored tokens."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1530/" }

    # ===== ADDITIONAL TTPs: Defense Evasion =====
    $t += [PSCustomObject]@{ TechID="T1218.001"; Name="Compiled HTML File"; Tactic="Defense Evasion"; Reason="CHM files can execute scripts via hh.exe -- whitelisting bypass."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1218/001/" }
    $t += [PSCustomObject]@{ TechID="T1218.003"; Name="CMSTP"; Tactic="Defense Evasion"; Reason="CMSTP.exe can execute malicious INF files -- UAC and AppLocker bypass."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1218/003/" }
    $t += [PSCustomObject]@{ TechID="T1218.005"; Name="Mshta"; Tactic="Defense Evasion"; Reason="mshta.exe executes HTA files and remote scripts -- LOLBin execution."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1218/005/" }
    $t += [PSCustomObject]@{ TechID="T1218.007"; Name="Msiexec"; Tactic="Defense Evasion"; Reason="msiexec.exe can execute remote MSI payloads -- signed binary LOLBin abuse."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1218/007/" }
    $t += [PSCustomObject]@{ TechID="T1218.010"; Name="Regsvr32"; Tactic="Defense Evasion"; Reason="regsvr32 can execute COM scriptlets remotely (Squiblydoo) -- AppLocker bypass."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1218/010/" }
    $t += [PSCustomObject]@{ TechID="T1218.011"; Name="Rundll32"; Tactic="Defense Evasion"; Reason="rundll32.exe executes arbitrary DLL exports -- whitelisting and AV bypass."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1218/011/" }
    $t += [PSCustomObject]@{ TechID="T1202"; Name="Indirect Command Execution"; Tactic="Defense Evasion"; Reason="forfiles, pcalua, and other LOLBins enable indirect command execution."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1202/" }
    $t += [PSCustomObject]@{ TechID="T1222"; Name="File/Directory Permissions Modification"; Tactic="Defense Evasion"; Reason="icacls and cacls can modify ACLs to hide or protect attacker files."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1222/" }
    $t += [PSCustomObject]@{ TechID="T1562.002"; Name="Disable Windows Event Logging"; Tactic="Defense Evasion"; Reason="Event log service state and size limits visible -- logs can be disabled or size-limited."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1562/002/" }
    $t += [PSCustomObject]@{ TechID="T1562.003"; Name="HISTCONTROL"; Tactic="Defense Evasion"; Reason="PowerShell history and logging settings enumerable -- can be disabled."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1562/003/" }
    $t += [PSCustomObject]@{ TechID="T1601"; Name="Modify System Image"; Tactic="Defense Evasion"; Reason="UEFI/firmware accessible on some hardware -- persistent firmware implants possible."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1601/" }

    # ===== ADDITIONAL TTPs: Persistence =====
    $t += [PSCustomObject]@{ TechID="T1137"; Name="Office Application Startup"; Tactic="Persistence"; Reason="Office installed -- VBA macros, add-ins and templates enable persistent Office-based malware."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1137/" }
    $t += [PSCustomObject]@{ TechID="T1547.002"; Name="Authentication Package"; Tactic="Persistence / Privilege Escalation"; Reason="LSA authentication packages loaded at boot -- malicious packages persist as kernel modules."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1547/002/" }
    $t += [PSCustomObject]@{ TechID="T1547.004"; Name="Winlogon Helper DLL"; Tactic="Persistence / Privilege Escalation"; Reason="Winlogon registry keys visible -- malicious DLL injection into logon process possible."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1547/004/" }
    $t += [PSCustomObject]@{ TechID="T1547.005"; Name="Security Support Provider"; Tactic="Persistence / Privilege Escalation"; Reason="SSP DLLs loaded into LSASS at boot -- malicious SSP captures plaintext credentials."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1547/005/" }
    $t += [PSCustomObject]@{ TechID="T1547.010"; Name="Port Monitors"; Tactic="Persistence / Privilege Escalation"; Reason="Print spooler port monitors run as SYSTEM -- malicious DLL executed with SYSTEM privileges."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1547/010/" }
    $t += [PSCustomObject]@{ TechID="T1547.012"; Name="Print Processors"; Tactic="Persistence"; Reason="Print processor DLLs loaded by spooler -- enables spooler-based persistence."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1547/012/" }
    $t += [PSCustomObject]@{ TechID="T1542.001"; Name="System Firmware"; Tactic="Persistence / Defense Evasion"; Reason="UEFI SecureBoot state visible -- disabled SecureBoot allows firmware-level persistence."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1542/001/" }
    $t += [PSCustomObject]@{ TechID="T1542.003"; Name="Bootkit"; Tactic="Persistence / Defense Evasion"; Reason="MBR/bootloader integrity not monitored -- bootkit installation possible without UEFI SecureBoot."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1542/003/" }

    # ===== ADDITIONAL TTPs: Privilege Escalation =====
    $t += [PSCustomObject]@{ TechID="T1548.002"; Name="Bypass User Account Control"; Tactic="Privilege Escalation / Defense Evasion"; Reason="UAC configuration readable -- UAC bypass techniques vary based on UAC level set."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1548/002/" }
    $t += [PSCustomObject]@{ TechID="T1611"; Name="Escape to Host"; Tactic="Privilege Escalation"; Reason="Container/VM escape techniques target hypervisor or host OS from guest environment."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1611/" }
    $t += [PSCustomObject]@{ TechID="T1098"; Name="Account Manipulation"; Tactic="Persistence / Privilege Escalation"; Reason="Local user account management accessible -- attackers add accounts or modify group memberships."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1098/" }
    $t += [PSCustomObject]@{ TechID="T1098.001"; Name="Additional Cloud Credentials"; Tactic="Persistence"; Reason="Cloud CLI tools present -- additional credentials can be added to cloud identities."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1098/001/" }

    # ===== ADDITIONAL TTPs: Impact =====
    $t += [PSCustomObject]@{ TechID="T1485"; Name="Data Destruction"; Tactic="Impact"; Reason="Volume shadow copies deletable -- ransomware destroys backups before encrypting."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1485/" }
    $t += [PSCustomObject]@{ TechID="T1486"; Name="Data Encrypted for Impact"; Tactic="Impact"; Reason="Weak/no BitLocker + no endpoint protection = ransomware can encrypt all data."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1486/" }
    $t += [PSCustomObject]@{ TechID="T1489"; Name="Service Stop"; Tactic="Impact"; Reason="Service control accessible -- ransomware stops AV, backup and database services before encrypting."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1489/" }
    $t += [PSCustomObject]@{ TechID="T1490"; Name="Inhibit System Recovery"; Tactic="Impact"; Reason="Shadow copy management accessible -- attackers delete backups to prevent recovery."; Severity="CRITICAL"; Link="https://attack.mitre.org/techniques/T1490/" }
    $t += [PSCustomObject]@{ TechID="T1529"; Name="System Shutdown/Reboot"; Tactic="Impact"; Reason="Shutdown and reboot commands accessible -- used by wipers to finalize disk destruction."; Severity="HIGH"; Link="https://attack.mitre.org/techniques/T1529/" }

    # ===== ADDITIONAL TTPs: Discovery =====
    $t += [PSCustomObject]@{ TechID="T1010"; Name="Application Window Discovery"; Tactic="Discovery"; Reason="Running process windows enumerable -- malware discovers active apps for context-aware attacks."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1010/" }
    $t += [PSCustomObject]@{ TechID="T1007"; Name="System Service Discovery"; Tactic="Discovery"; Reason="All services enumerable without admin rights via WMI."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1007/" }
    $t += [PSCustomObject]@{ TechID="T1124"; Name="System Time Discovery"; Tactic="Discovery"; Reason="System time, timezone and NTP config readable -- used in time-based evasion."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1124/" }
    $t += [PSCustomObject]@{ TechID="T1614"; Name="System Location Discovery"; Tactic="Discovery"; Reason="Locale, language and country code readable -- used in region-targeted malware."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1614/" }
    $t += [PSCustomObject]@{ TechID="T1422"; Name="System Network Configuration Discovery (Mobile)"; Tactic="Discovery"; Reason="Full network topology including routes, DNS and shares enumerable."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1016/" }
    $t += [PSCustomObject]@{ TechID="T1217"; Name="Browser Information Discovery"; Tactic="Discovery"; Reason="Installed browsers and their profile directories enumerable."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1217/" }
    $t += [PSCustomObject]@{ TechID="T1120"; Name="Peripheral Device Discovery"; Tactic="Discovery"; Reason="All peripheral devices (USB, Bluetooth, printers) enumerable via WMI."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1120/" }
    $t += [PSCustomObject]@{ TechID="T1018"; Name="Remote System Discovery"; Tactic="Discovery"; Reason="Network config and shares reveal other systems -- attacker builds target list."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1018/" }
    $t += [PSCustomObject]@{ TechID="T1482"; Name="Domain Trust Discovery"; Tactic="Discovery"; Reason="Active Directory trust relationships enumerable -- attack paths across forests identified."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1482/" }
    $t += [PSCustomObject]@{ TechID="T1615"; Name="Group Policy Discovery"; Tactic="Discovery"; Reason="Applied GPOs and policy settings readable -- used to identify security controls in place."; Severity="INFO"; Link="https://attack.mitre.org/techniques/T1615/" }

    # ===== ADDITIONAL TTPs: Exfiltration / C2 =====
    $t += [PSCustomObject]@{ TechID="T1132"; Name="Data Encoding"; Tactic="Command and Control"; Reason="Standard encoding (Base64, XOR) used to obfuscate C2 traffic."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1132/" }
    $t += [PSCustomObject]@{ TechID="T1001"; Name="Data Obfuscation"; Tactic="Command and Control"; Reason="C2 traffic can be obfuscated using junk data or protocol mimicry."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1001/" }
    $t += [PSCustomObject]@{ TechID="T1095"; Name="Non-Application Layer Protocol"; Tactic="Command and Control"; Reason="ICMP, UDP or raw socket C2 channels bypass HTTP-only proxy monitoring."; Severity="MEDIUM"; Link="https://attack.mitre.org/techniques/T1095/" }
    $t += [PSCustomObject]@{ TechID="T1008"; Name="Fallback Channels"; Tactic="Command and Control"; Reason="Multiple network interfaces enable redundant C2 channels."; Severity="LOW"; Link="https://attack.mitre.org/techniques/T1008/" }

    return $t
}

# ==== DATA COLLECTION ====
function Collect-AuditData {
    $d = [ordered]@{}
    Write-Host "  [1/7] System info..." -ForegroundColor $ColorScheme.InfoLow
    $d["OS"]                  = Get-WmiObject Win32_OperatingSystem  | Select-Object Caption,Version,BuildNumber,OSArchitecture,LastBootUpTime,InstallDate
    $d["Computer"]            = Get-WmiObject Win32_ComputerSystem   | Select-Object Name,Model,Manufacturer,Domain,DomainRole,@{N="MemGB";E={[math]::Round($_.TotalPhysicalMemory/1GB,2)}}
    $d["Processor"]           = Get-WmiObject Win32_Processor        | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed,LoadPercentage
    $d["BIOS"]                = Get-WmiObject Win32_BIOS             | Select-Object Manufacturer,Name,SerialNumber,Version,ReleaseDate
    $d["Disks"]               = Get-WmiObject Win32_LogicalDisk      | Select-Object DeviceID,FileSystem,@{N="SizeGB";E={[math]::Round($_.Size/1GB,2)}},@{N="FreeGB";E={[math]::Round($_.FreeSpace/1GB,2)}}

    Write-Host "  [2/7] Users and groups..." -ForegroundColor $ColorScheme.InfoLow
    $d["LocalUsers"]          = Get-WmiObject Win32_UserAccount | Where-Object { $_.LocalAccount }              | Select-Object Name,SID,Disabled,PasswordRequired,Lockout
    $d["LocalGroups"]         = Get-WmiObject Win32_Group       | Where-Object { $_.LocalAccount }              | Select-Object Name,SID,Description
    $d["NoPasswordAccounts"]  = Get-WmiObject Win32_UserAccount | Where-Object { $_.PasswordRequired -eq $false } | Select-Object Name,Disabled
    $d["AdminGroupMembers"]   = Get-WmiObject Win32_GroupUser   | Where-Object { $_.GroupComponent -like "*Administrators*" } | Select-Object UserComponent

    Write-Host "  [3/7] Services..." -ForegroundColor $ColorScheme.InfoLow
    $d["RunningServices"]         = Get-WmiObject Win32_Service | Where-Object { $_.State -eq "Running" }               | Select-Object Name,StartMode,PathName,StartName
    $d["AutoStartServices"]       = Get-WmiObject Win32_Service | Where-Object { $_.StartMode -eq "Auto" }              | Select-Object Name,State,PathName
    $d["SuspiciousServicePaths"]  = Get-WmiObject Win32_Service | Where-Object { $_.PathName -match "AppData|Temp" }    | Select-Object Name,PathName
    $d["UnquotedServicePaths"]    = Get-WmiObject Win32_Service | Where-Object { $_.PathName -match ' ' -and $_.PathName -notmatch '"' } | Select-Object Name,PathName

    Write-Host "  [4/7] Processes..." -ForegroundColor $ColorScheme.InfoLow
    $d["TopProcessesByMemory"]= Get-WmiObject Win32_Process | Sort-Object WorkingSetSize -Descending | Select-Object -First 20 ProcessId,Name,@{N="MemMB";E={[math]::Round($_.WorkingSetSize/1MB,1)}},SessionId
    $d["SuspiciousPowerShell"]= Get-WmiObject Win32_Process | Where-Object { $_.CommandLine -match "-enc|-hidden|-nop|-bypass" } | Select-Object ProcessId,Name,CommandLine
    $d["StartupCommands"]     = Get-WmiObject Win32_StartupCommand | Select-Object Name,Command,Location,User

    Write-Host "  [5/7] Network..." -ForegroundColor $ColorScheme.InfoLow
    $d["NetworkConfig"]       = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } | Select-Object Description,IPAddress,SubnetMask,DefaultIPGateway,DNSServerSearchOrder
    $d["Shares"]              = Get-WmiObject Win32_Share | Select-Object Name,Path,Type,Description
    $d["Routes"]              = Get-WmiObject Win32_IP4RouteTable | Select-Object -First 20 Destination,NextHop,Metric

    Write-Host "  [6/7] Security..." -ForegroundColor $ColorScheme.InfoLow
    $d["Hotfixes"]            = Get-WmiObject Win32_QuickFixEngineering | Sort-Object InstalledOn -Descending | Select-Object HotFixID,Description,InstalledOn | Select-Object -First 20
    $d["AntiVirus"]           = Get-WmiObject -Namespace "root\securitycenter2" -Class AntiVirusProduct -ErrorAction SilentlyContinue | Select-Object DisplayName,productState
    $d["Firewall"]            = Get-WmiObject -Namespace "root\standardcimv2" -Class MSFT_NetFirewallProfile -ErrorAction SilentlyContinue | Select-Object Name,Enabled
    $d["UnsignedDrivers"]     = Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.Signed -eq $false } | Select-Object Name,DriverVersion
    $d["Software"]            = Get-WmiObject Win32_Product -ErrorAction SilentlyContinue | Select-Object Name,Version,Vendor | Select-Object -First 40

    Write-Host "  [7/7] WMI persistence & config..." -ForegroundColor $ColorScheme.InfoLow
    $d["WMISubscriptions"]    = Get-WmiObject -Namespace root\subscription -Class __EventFilter -ErrorAction SilentlyContinue | Select-Object Name,Query
    $d["WMIConsumers"]        = Get-WmiObject -Namespace root\subscription -Class __EventConsumer -ErrorAction SilentlyContinue | Select-Object Name
    $d["DefenderStatus"]      = Get-CimInstance MSFT_MpComputerStatus -Namespace root\microsoft\windows\defender -ErrorAction SilentlyContinue | Select-Object RealTimeProtectionEnabled,AntivirusEnabled
    $d["UACStatus"]           = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -ErrorAction SilentlyContinue | Select-Object EnableLUA
    $d["SMBv1"]               = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -ErrorAction SilentlyContinue | Select-Object SMB1
    $d["BitLocker"]           = Get-WmiObject -Namespace "root\cimv2\security\microsoftvolumeencryption" -Class Win32_EncryptableVolume -ErrorAction SilentlyContinue | Select-Object DriveLetter,ProtectionStatus
    $d["TPM"]                 = Get-CimInstance Win32_Tpm -Namespace root\cimv2\security\microsofttpm -ErrorAction SilentlyContinue | Select-Object IsActivated_InitialValue,IsEnabled_InitialValue,IsOwned_InitialValue

    $d["GeneratedAt"]         = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $d["ComputerName"]        = $env:COMPUTERNAME
    $d["RunBy"]               = $env:USERNAME
    $d["Author"]              = "MANIKANDAN"
    $d["Contact"]             = "9787091093"
    return $d
}

# ==== EXPORT: JSON ====
function Export-ToJSON {
    param($Data, $FilePath)
    try {
        $Data | ConvertTo-Json -Depth 6 | Out-File -FilePath $FilePath -Encoding UTF8
        Write-Host "  [OK] JSON: $FilePath" -ForegroundColor $ColorScheme.Success
    } catch { Write-Host "  [ERR] JSON: $_" -ForegroundColor $ColorScheme.Alert }
}

# ==== EXPORT: CSV ====
function Export-ToCSV {
    param($Data, $BaseDir, $BaseName)
    $skip = @("GeneratedAt","ComputerName","RunBy","Author","Contact","UACStatus","SMBv1")
    $count = 0
    foreach ($section in $Data.Keys) {
        if ($section -in $skip) { continue }
        $arr = @($Data[$section])
        if ($arr.Count -eq 0) { continue }
        try {
            if ($arr[0] -is [PSObject] -and $arr[0].PSObject.Properties.Name.Count -gt 0) {
                $arr | Export-Csv -Path (Join-Path $BaseDir ($BaseName + "_" + $section + ".csv")) -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
                $count++
            }
        } catch {}
    }
    Write-Host "  [OK] CSV: $count files -> $BaseDir" -ForegroundColor $ColorScheme.Success
}

# ==== EXPORT: YAML ====
function Export-ToYAML {
    param($Data, $FilePath)
    try {
        $skip = @("GeneratedAt","ComputerName","RunBy","Author","Contact")
        $yaml = "# WMI Audit Frogman v16 - YAML Export`n"
        $yaml += "# Author: MANIKANDAN | 9787091093`n"
        $yaml += "# Generated: $($Data['GeneratedAt'])`n"
        $yaml += "ComputerName: $($Data['ComputerName'])`n"
        $yaml += "RunBy: $($Data['RunBy'])`n"
        $yaml += "GeneratedAt: $($Data['GeneratedAt'])`n"
        $yaml += "---`n"
        foreach ($section in $Data.Keys) {
            if ($section -in $skip) { continue }
            $yaml += ("`n" + $section + ":`n")
            $arr = @($Data[$section])
            if ($arr.Count -eq 0 -or $null -eq $Data[$section]) {
                $yaml += "  - null`n"
            } elseif ($arr[0] -is [PSObject] -and $arr[0].PSObject.Properties.Name.Count -gt 0) {
                foreach ($row in $arr) {
                    $yaml += "  -`n"
                    foreach ($prop in $row.PSObject.Properties) {
                        $val = "$($prop.Value)" -replace '"','\"' -replace ':','\:'
                        if ($val -match '\n|\r') { $val = ($val -split '\r?\n' | ForEach-Object { "    $_" }) -join "`n" ; $yaml += "    $($prop.Name): |`n$val`n" }
                        else { $yaml += "    $($prop.Name): `"$val`"`n" }
                    }
                }
            } else {
                foreach ($item in $arr) {
                    $v = "$item" -replace '"','\"'
                    $yaml += "  - `"$v`"`n"
                }
            }
        }
        [System.IO.File]::WriteAllText($FilePath, $yaml, [System.Text.Encoding]::UTF8)
        Write-Host "  [OK] YAML: $FilePath" -ForegroundColor $ColorScheme.Success
    } catch { Write-Host "  [ERR] YAML: $_" -ForegroundColor $ColorScheme.Alert }
}

# ==== EXPORT: HTML (v17 - FULL REWRITE) ====
function Export-ToHTML {
    param($Data, $FilePath, $Risk, $Mitre)
    try {
        $ts  = $Data["GeneratedAt"]
        $cn  = $Data["ComputerName"]
        $ru  = $Data["RunBy"]
        $sc  = $Risk.Score
        $lv  = $Risk.Level
        $scoreColor = if ($sc -ge 75){"#f85149"} elseif($sc -ge 50){"#f0883e"} elseif($sc -ge 25){"#e3b341"} else{"#3fb950"}

        $navHtml = ""; $sectHtml = ""
        $skip = @("GeneratedAt","ComputerName","RunBy","Author","Contact")
        $sectionCount = 0
        foreach ($section in $Data.Keys) {
            if ($section -in $skip) { continue }
            $sectionCount++
            $arr = @($Data[$section])
            $sid = "s_$($section -replace '[^a-zA-Z0-9]','_')"
            $navHtml += "<li><a href='#$sid' id='nav_$sid' class='navlink'><span class='navicon'>&#9632;</span><span class='navtxt'>$section</span><span class='navcnt' id='cnt_$sid'></span></a></li>`n"
            $sectHtml += "<section id='$sid' class='datasec'><h2 class='sech2'><span class='secnum'>$sectionCount</span>$section</h2>`n"
            if ($arr.Count -eq 0 -or $null -eq $Data[$section]) {
                $sectHtml += "<p class='nodata'>&#9711; No data returned</p>"
            } elseif ($arr[0] -is [PSObject] -and $arr[0].PSObject.Properties.Name.Count -gt 0) {
                $props = $arr[0].PSObject.Properties.Name
                $sectHtml += "<div class='tw'><table><thead><tr>"
                foreach ($p in $props) { $sectHtml += "<th>$p</th>" }
                $sectHtml += "</tr></thead><tbody>"
                foreach ($row in $arr) {
                    $sectHtml += "<tr>"
                    foreach ($p in $props) {
                        $v = "$($row.$p)"
                        $cls = if ($v -in @("True","Running","OK","Enabled","1")) {" class='vg'"} elseif ($v -in @("False","Stopped","Error","Disabled","0")) {" class='vb'"} else {""}
                        $sectHtml += "<td$cls>" + [System.Net.WebUtility]::HtmlEncode($v) + "</td>"
                    }
                    $sectHtml += "</tr>"
                }
                $sectHtml += "</tbody></table></div>"
            } else {
                $sectHtml += "<p class='scalar'>" + [System.Net.WebUtility]::HtmlEncode("$($arr[0])") + "</p>"
            }
            $sectHtml += "</section>`n"
        }

        $riskRows = ""
        $critCount = 0; $highCount = 0; $medCount = 0
        foreach ($f in $Risk.Findings) {
            $bc = if ($f.Severity -eq "CRITICAL"){$critCount++;"bcrit"} elseif($f.Severity -eq "HIGH"){$highCount++;"bhigh"} else{$medCount++;"bmed"}
            $riskRows += "<tr class='rfind sev_$($f.Severity)'><td><span class='badge $bc sevbadge' data-sev='$($f.Severity)'>$($f.Severity)</span></td><td>$($f.Finding)</td><td class='pts'>+$($f.Points)</td></tr>"
        }
        if (-not $riskRows) { $riskRows = "<tr><td colspan='3' class='nodata'>&#9711; No risk findings &mdash; system looks clean</td></tr>" }

        $mitreCards = ""
        foreach ($technique in $Mitre) {
            $bc = if ($technique.Severity -eq "CRITICAL"){"bcrit"} elseif($technique.Severity -eq "HIGH"){"bhigh"} elseif($technique.Severity -eq "MEDIUM"){"bmed"} else{"binfo"}
            $mitreCards += "<div class='mc'><div class='mh'><a class='mid' href='$($technique.Link)' target='_blank'>$($technique.TechID)</a><span class='mn'>$($technique.Name)</span><span class='badge $bc'>$($technique.Severity)</span></div><div class='mt2'>&#9656; $($technique.Tactic)</div><div class='mr'>$($technique.Reason)</div></div>`n"
        }

        $html = @"
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>WMI Frogman Audit v16 &mdash; $cn</title>
<style>
/* ===== THEME VARIABLES ===== */
[data-theme="dark"] {
  --bg:#0a0e17;--bg2:#0f1521;--bg3:#161e2e;--bg4:#1c2535;
  --border:#1e2d42;--border2:#162030;
  --text:#d4dce8;--text2:#7a90a8;--text3:#4a6080;
  --green:#00e676;--green2:#00b358;--blue:#4fc3f7;--blue2:#0288d1;
  --orange:#ffb74d;--red:#ef5350;--yellow:#ffd54f;--purple:#ce93d8;
  --cyan:#80deea;--sidebar-w:250px;
  --shadow:0 4px 24px rgba(0,0,0,.5);--shadow2:0 2px 8px rgba(0,0,0,.3);
  --glow-green:0 0 12px rgba(0,230,118,.25);--glow-blue:0 0 12px rgba(79,195,247,.2);
}
[data-theme="light"] {
  --bg:#f0f4f8;--bg2:#ffffff;--bg3:#e8ecf2;--bg4:#dde3eb;
  --border:#c8d4e0;--border2:#d8e0ea;
  --text:#1a2535;--text2:#4a5870;--text3:#8898b0;
  --green:#1b7a40;--green2:#238f50;--blue:#1565c0;--blue2:#1976d2;
  --orange:#e65100;--red:#c62828;--yellow:#f57f17;--purple:#6a1b9a;
  --cyan:#00838f;--sidebar-w:250px;
  --shadow:0 4px 24px rgba(0,0,0,.12);--shadow2:0 2px 8px rgba(0,0,0,.08);
  --glow-green:0 0 0px transparent;--glow-blue:0 0 0px transparent;
}
/* ===== RESET ===== */
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
html{scroll-behavior:smooth;font-size:14px}
body{font-family:'Segoe UI',system-ui,-apple-system,sans-serif;background:var(--bg);color:var(--text);display:flex;min-height:100vh;transition:background .3s,color .3s;overflow-x:hidden}
a{color:var(--blue);text-decoration:none;transition:color .15s}
a:hover{color:var(--cyan);text-decoration:underline}
/* ===== SCROLLBAR ===== */
::-webkit-scrollbar{width:6px;height:6px}
::-webkit-scrollbar-track{background:var(--bg)}
::-webkit-scrollbar-thumb{background:var(--border);border-radius:3px}
::-webkit-scrollbar-thumb:hover{background:var(--text3)}
/* ===== SIDEBAR ===== */
#sb{width:var(--sidebar-w);min-width:var(--sidebar-w);background:var(--bg2);border-right:1px solid var(--border);padding:0;position:fixed;top:0;left:0;height:100vh;overflow-y:auto;z-index:200;flex-shrink:0;transition:transform .3s cubic-bezier(.4,0,.2,1),background .3s;box-shadow:var(--shadow)}
#sb.collapsed{transform:translateX(-100%)}
#sb-logo{padding:18px 16px 14px;border-bottom:1px solid var(--border);background:linear-gradient(135deg,var(--bg3),var(--bg2));position:relative;overflow:hidden}
#sb-logo::before{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(0,230,118,.07),transparent);animation:logobg 4s ease-in-out infinite alternate;pointer-events:none}
@keyframes logobg{from{opacity:.4}to{opacity:1}}
.logo-frog{font-size:1.1em;font-weight:800;color:var(--green);letter-spacing:1.5px;text-shadow:var(--glow-green);animation:pulse-green 3s ease-in-out infinite}
@keyframes pulse-green{0%,100%{text-shadow:var(--glow-green)}50%{text-shadow:0 0 20px rgba(0,230,118,.5)}}
.logo-sub{font-size:.7em;color:var(--text2);margin-top:3px;display:block;letter-spacing:.5px}
.logo-author{font-size:.65em;color:var(--text3);margin-top:2px}
/* Search in sidebar */
#sb-search{padding:10px 12px;border-bottom:1px solid var(--border)}
#sb-search input{width:100%;padding:6px 10px;background:var(--bg3);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:.75em;outline:none;transition:border .15s,box-shadow .15s}
#sb-search input:focus{border-color:var(--blue);box-shadow:0 0 0 2px rgba(79,195,247,.15)}
/* Nav sections */
.sb-group{padding:8px 12px 2px;color:var(--text3);font-size:.62em;text-transform:uppercase;letter-spacing:1.5px;font-weight:700;margin-top:4px}
#navlist{list-style:none;padding-bottom:20px}
.navlink{display:flex;align-items:center;gap:7px;padding:6px 12px 6px 16px;color:var(--text2);font-size:.74em;font-weight:500;border-left:3px solid transparent;transition:all .18s cubic-bezier(.4,0,.2,1);position:relative;overflow:hidden;white-space:nowrap}
.navlink::after{content:'';position:absolute;right:0;top:0;height:100%;width:0;background:linear-gradient(90deg,transparent,rgba(79,195,247,.06));transition:width .2s}
.navlink:hover{color:var(--blue);border-left-color:var(--blue);background:var(--bg3);text-decoration:none}
.navlink:hover::after{width:100%}
.navlink.active{color:var(--cyan);border-left-color:var(--green);background:linear-gradient(90deg,rgba(0,230,118,.07),transparent);font-weight:600}
.navlink.active .navicon{color:var(--green);animation:blink-icon .8s ease-in-out infinite alternate}
@keyframes blink-icon{from{opacity:.5}to{opacity:1}}
.navicon{font-size:.5em;color:var(--text3);flex-shrink:0;transition:color .18s}
.navtxt{flex:1;overflow:hidden;text-overflow:ellipsis}
.navcnt{background:var(--bg4);color:var(--text3);font-size:.65em;padding:1px 6px;border-radius:10px;flex-shrink:0;transition:all .2s;display:none}
.navcnt.has-results{display:inline-block;background:rgba(0,230,118,.15);color:var(--green)}
.navcnt.no-results{display:inline-block;background:rgba(239,83,80,.1);color:var(--red)}
/* Sidebar collapse btn */
#sb-toggle{position:fixed;top:14px;left:14px;z-index:300;background:var(--bg2);border:1px solid var(--border);border-radius:8px;padding:7px 10px;cursor:pointer;color:var(--text2);font-size:.85em;transition:all .2s;box-shadow:var(--shadow2);display:none}
#sb-toggle:hover{color:var(--blue);border-color:var(--blue)}
/* ===== MAIN ===== */
#main{margin-left:var(--sidebar-w);flex:1;padding:28px 32px;min-width:0;transition:margin .3s}
#main.full{margin-left:0}
/* ===== HEADER ===== */
.frog-banner{font-family:Consolas,'Courier New',monospace;color:var(--green);white-space:pre;line-height:1.35;font-size:.82em;margin-bottom:14px;text-shadow:var(--glow-green);animation:fadeSlideIn .6s ease}
@keyframes fadeSlideIn{from{opacity:0;transform:translateY(-10px)}to{opacity:1;transform:translateY(0)}}
h1.page-title{color:var(--green);font-size:1.5em;font-weight:800;letter-spacing:.5px;margin-bottom:4px;text-shadow:var(--glow-green)}
.author-bar{color:var(--text2);font-size:.75em;margin-bottom:12px;padding:6px 0;border-bottom:1px solid var(--border);display:flex;flex-wrap:wrap;gap:12px;align-items:center}
.author-bar strong{color:var(--blue)}
/* ===== CONTROLS BAR ===== */
.controls-bar{display:flex;gap:10px;align-items:center;margin-bottom:16px;flex-wrap:wrap}
/* Theme toggle */
.theme-btn{background:var(--bg3);border:1px solid var(--border);border-radius:20px;padding:6px 14px;cursor:pointer;font-size:.75em;color:var(--text2);display:flex;align-items:center;gap:6px;transition:all .2s;font-family:inherit}
.theme-btn:hover{border-color:var(--blue);color:var(--blue)}
.theme-toggle-track{width:32px;height:16px;background:var(--border);border-radius:8px;position:relative;transition:background .3s}
.theme-toggle-thumb{width:12px;height:12px;border-radius:50%;background:var(--text3);position:absolute;top:2px;left:2px;transition:all .3s;transform:translateX(0)}
[data-theme="light"] .theme-toggle-thumb{transform:translateX(16px);background:var(--blue)}
[data-theme="light"] .theme-toggle-track{background:rgba(21,101,192,.3)}
/* Sound btn */
.sound-btn{background:var(--bg3);border:1px solid var(--border);border-radius:20px;padding:6px 14px;cursor:pointer;font-size:.75em;color:var(--text2);display:flex;align-items:center;gap:6px;transition:all .2s;font-family:inherit}
.sound-btn:hover{border-color:var(--orange);color:var(--orange)}
.sound-btn.active{border-color:var(--green);color:var(--green);background:rgba(0,230,118,.08)}
/* Meta info */
.meta{color:var(--text2);font-size:.78em;display:flex;flex-wrap:wrap;gap:14px;margin-bottom:16px;padding:10px 14px;background:var(--bg2);border:1px solid var(--border);border-radius:8px}
.meta strong{color:var(--text)}
/* ===== SEARCH BAR ===== */
.searchbar{margin-bottom:20px;position:relative}
.search-wrap{position:relative;display:flex;gap:8px;align-items:center}
#gs{flex:1;padding:10px 16px 10px 42px;background:var(--bg2);border:1px solid var(--border);border-radius:8px;color:var(--text);font-size:.88em;outline:none;transition:border .15s,box-shadow .2s;font-family:inherit}
#gs:focus{border-color:var(--blue);box-shadow:0 0 0 3px rgba(79,195,247,.12)}
#gs::placeholder{color:var(--text3)}
.srchicon{position:absolute;left:14px;top:50%;transform:translateY(-50%);color:var(--text3);pointer-events:none;font-size:1em}
#gs-clear{background:var(--bg3);border:1px solid var(--border);border-radius:6px;padding:6px 12px;cursor:pointer;color:var(--text2);font-size:.76em;white-space:nowrap;transition:all .15s;font-family:inherit}
#gs-clear:hover{color:var(--red);border-color:var(--red)}
.search-nav{display:flex;gap:4px;align-items:center}
.snav-btn{background:var(--bg3);border:1px solid var(--border);border-radius:5px;width:26px;height:26px;cursor:pointer;color:var(--text2);display:flex;align-items:center;justify-content:center;font-size:.8em;transition:all .15s;font-family:inherit}
.snav-btn:hover{color:var(--blue);border-color:var(--blue)}
#sc2{font-size:.74em;color:var(--text2);margin-top:5px;min-height:16px;display:flex;align-items:center;gap:8px}
.match-hl{background:rgba(255,213,79,.28);color:var(--yellow);border-radius:2px;padding:0 1px;font-weight:600}
/* ===== RISK SECTION ===== */
.rblock{background:var(--bg2);border:1px solid var(--border);border-radius:12px;padding:22px;margin-bottom:26px;box-shadow:var(--shadow2);transition:background .3s}
.rblock-title{color:var(--blue);font-size:.95em;font-weight:700;margin-bottom:16px;display:flex;align-items:center;gap:8px}
.rblock-title::before{content:'';display:block;width:4px;height:18px;background:var(--blue);border-radius:2px}
.grow{display:flex;align-items:center;gap:20px;margin-bottom:18px;flex-wrap:wrap}
.gc{width:108px;height:108px;border-radius:50%;background:conic-gradient($scoreColor ${sc}%,var(--border) 0);display:flex;align-items:center;justify-content:center;position:relative;flex-shrink:0;animation:spin-in .8s cubic-bezier(.4,0,.2,1);box-shadow:0 0 20px rgba(0,0,0,.3)}
@keyframes spin-in{from{transform:rotate(-90deg) scale(.5);opacity:0}to{transform:rotate(0) scale(1);opacity:1}}
.gc::before{content:'';position:absolute;width:76px;height:76px;background:var(--bg2);border-radius:50%;transition:background .3s}
.gl{position:relative;z-index:1;font-size:1.5em;font-weight:800;color:$scoreColor;font-family:Consolas,monospace;animation:count-up .8s ease}
.gm h3{font-size:1em;color:$scoreColor;margin-bottom:4px;font-weight:700}
.gm p{color:var(--text2);font-size:.8em;margin-bottom:2px}
.rbw{flex:1;min-width:200px}
.rbb{background:var(--bg3);border-radius:20px;height:12px;overflow:hidden;margin-bottom:6px;box-shadow:inset 0 1px 3px rgba(0,0,0,.3)}
.rbf{height:100%;border-radius:20px;background:linear-gradient(90deg,$scoreColor,#f0883e);width:${sc}%;animation:bar-grow .8s cubic-bezier(.4,0,.2,1);box-shadow:0 0 8px rgba(240,136,62,.3)}
@keyframes bar-grow{from{width:0}to{width:${sc}%}}
.rbl{display:flex;justify-content:space-between;font-size:.65em;color:var(--text3)}
/* Risk filter buttons */
.risk-filters{display:flex;gap:8px;margin-bottom:12px;flex-wrap:wrap;align-items:center}
.risk-filters span{font-size:.73em;color:var(--text2)}
.rfbtn{background:var(--bg3);border:1px solid var(--border);border-radius:16px;padding:4px 12px;cursor:pointer;font-size:.72em;font-weight:700;transition:all .2s;font-family:inherit;color:var(--text2)}
.rfbtn:hover,.rfbtn.active{transform:translateY(-1px);box-shadow:var(--shadow2)}
.rfbtn.f-all.active{border-color:var(--blue);color:var(--blue);background:rgba(79,195,247,.1)}
.rfbtn.f-crit.active{border-color:#f85149;color:#f85149;background:rgba(248,81,73,.1)}
.rfbtn.f-high.active{border-color:#f0883e;color:#f0883e;background:rgba(240,136,62,.1)}
.rfbtn.f-med.active{border-color:#e3b341;color:#e3b341;background:rgba(227,179,65,.1)}
/* ===== TABLES ===== */
.tw{overflow-x:auto;border-radius:8px;border:1px solid var(--border);margin-top:8px;width:100%}
table{width:100%;border-collapse:collapse;font-size:.79em;table-layout:auto}
thead tr{background:var(--bg3)}
th{padding:9px 14px;text-align:left;color:var(--cyan);font-weight:700;border-bottom:1px solid var(--border);white-space:nowrap;position:sticky;top:0;background:var(--bg3);z-index:2;font-size:.85em;letter-spacing:.3px}
td{padding:7px 14px;border-bottom:1px solid var(--border2);vertical-align:top;word-break:break-word;white-space:normal;max-width:480px;line-height:1.4}
tr:hover td{background:var(--bg4)}
tr.hiddenrow{display:none}
tr.rfind.hidden-sev{display:none}
.vg{color:var(--green);font-weight:600}
.vb{color:var(--red);font-weight:600}
.nodata{color:var(--text3);font-size:.82em;font-style:italic;padding:8px 4px;display:block}
.scalar{color:var(--text2);font-size:.85em;padding:4px 0;word-break:break-all;font-family:Consolas,monospace}
.pts{color:var(--orange);font-weight:700;white-space:nowrap;font-family:Consolas,monospace}
/* ===== BADGES ===== */
.badge{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.68em;font-weight:800;letter-spacing:.6px;white-space:nowrap;cursor:default}
.sevbadge{cursor:pointer;transition:transform .15s,box-shadow .15s}
.sevbadge:hover{transform:translateY(-1px);box-shadow:0 2px 8px rgba(0,0,0,.3)}
.bcrit{background:#3d1a1a;color:#f85149;border:1px solid rgba(248,81,73,.4)}
.bhigh{background:#2d1e0e;color:#f0883e;border:1px solid rgba(240,136,62,.4)}
.bmed{background:#2a2210;color:#e3b341;border:1px solid rgba(227,179,65,.4)}
.binfo{background:#0d1f2e;color:#4fc3f7;border:1px solid rgba(79,195,247,.3)}
[data-theme="light"] .bcrit{background:#ffeaea;color:#c62828;border-color:rgba(198,40,40,.3)}
[data-theme="light"] .bhigh{background:#fff3e0;color:#e65100;border-color:rgba(230,81,0,.3)}
[data-theme="light"] .bmed{background:#fffde7;color:#f57f17;border-color:rgba(245,127,23,.3)}
[data-theme="light"] .binfo{background:#e3f2fd;color:#1565c0;border-color:rgba(21,101,192,.3)}
/* ===== MITRE GRID ===== */
.mg{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:12px;margin-top:12px}
.mc{background:var(--bg2);border:1px solid var(--border);border-radius:10px;padding:16px;transition:all .2s;animation:fadeSlideIn .4s ease}
.mc:hover{border-color:var(--blue);transform:translateY(-2px);box-shadow:var(--shadow)}
.mh{display:flex;align-items:center;gap:8px;margin-bottom:7px;flex-wrap:wrap}
.mid{font-family:Consolas,'Courier New',monospace;background:var(--bg3);padding:3px 8px;border-radius:5px;font-size:.78em;color:var(--blue);font-weight:700;white-space:nowrap;border:1px solid var(--border);transition:all .15s}
.mid:hover{background:var(--blue);color:var(--bg);border-color:var(--blue)}
.mn{font-weight:700;font-size:.87em;flex:1;min-width:0}
.mt2{font-size:.72em;color:var(--purple);margin-bottom:6px;font-weight:600}
.mr{font-size:.76em;color:var(--text2);line-height:1.55}
/* ===== SECTIONS ===== */
.datasec{margin-bottom:32px;animation:fadeSlideIn .3s ease}
.datasec.hidden-sec{display:none}
.sech2{color:var(--blue);font-size:.92em;margin-bottom:10px;padding-bottom:6px;border-bottom:2px solid var(--border);display:flex;align-items:center;gap:8px;font-weight:700;letter-spacing:.3px}
.secnum{background:var(--bg3);color:var(--text3);border-radius:4px;padding:1px 7px;font-size:.78em;font-family:Consolas,monospace;border:1px solid var(--border);flex-shrink:0}
/* ===== FOOTER ===== */
.footer{margin-top:36px;padding-top:16px;border-top:1px solid var(--border);color:var(--text3);font-size:.72em;display:flex;justify-content:space-between;flex-wrap:wrap;gap:8px}
/* ===== MOBILE / RESPONSIVE ===== */
@media (max-width:900px){
  :root{--sidebar-w:0px}
  #sb{transform:translateX(-250px);width:250px}
  #sb.open{transform:translateX(0)}
  #main{margin-left:0!important;padding:16px}
  #sb-toggle{display:flex;align-items:center;gap:5px}
  .mg{grid-template-columns:1fr}
}
@media (max-width:600px){
  #main{padding:10px}
  .controls-bar{gap:6px}
  .meta{flex-direction:column;gap:6px}
}
/* ===== PRINT ===== */
@media print{
  @page{margin:10mm}
  *{-webkit-print-color-adjust:exact!important;print-color-adjust:exact!important}
  body{display:block!important}
  #sb,#sb-toggle,.searchbar,.controls-bar{display:none!important}
  #main{margin-left:0!important;padding:8px!important}
  .tw,.mc,.rblock{page-break-inside:avoid}
}
</style>
</head>
<body>
<button id="sb-toggle" onclick="toggleSidebar()" title="Toggle Sidebar">&#9776; Menu</button>
<nav id="sb">
  <div id="sb-logo">
    <div class="logo-frog">&#128056; WMI FROGMAN v16</div>
    <span class="logo-sub">600 Commands &bull; $($Mitre.Count) MITRE TTPs</span>
    <span class="logo-author">MANIKANDAN &bull; 9787091093</span>
  </div>
  <div id="sb-search">
    <input type="text" id="sb-gs" placeholder="&#128269; Filter sections..." oninput="filterNav(this.value)">
  </div>
  <div class="sb-group">Overview</div>
  <ul>
    <li><a href="#risk_sec" class="navlink"><span class="navicon">&#9632;</span><span class="navtxt">&#9888; Risk Score ($sc/100)</span></a></li>
    <li><a href="#mitre_sec" class="navlink"><span class="navicon">&#9632;</span><span class="navtxt">&#9874; MITRE ATT&amp;CK ($($Mitre.Count))</span></a></li>
  </ul>
  <div class="sb-group">Data Sections ($sectionCount)</div>
  <ul id="navlist">$navHtml</ul>
</nav>
<main id="main">
<pre class="frog-banner">   &#64;..&#64;     WMI AUDIT FROGMAN v16 &#128056;
  ( &#9679;  &#9679; )  Cyber Recon &amp; Enumeration Report
 (  =vv=  )  600 Commands &bull; $($Mitre.Count) MITRE TTPs
  &#732;&#732; ~~~ &#732;&#732;   Generated: $ts</pre>
<h1 class="page-title">WMI Frogman System Audit Report</h1>
<div class="author-bar">
  <span>Author: <strong>MANIKANDAN</strong></span>
  <span>&#128222; <strong>9787091093</strong></span>
  <span>Tool: <strong>WMI Audit Frogman v16</strong></span>
</div>
<div class="controls-bar">
  <button class="theme-btn" onclick="toggleTheme()" title="Toggle light/dark theme">
    <div class="theme-toggle-track"><div class="theme-toggle-thumb"></div></div>
    <span id="theme-label">&#9790; Dark</span>
  </button>
  <button class="sound-btn active" id="sound-btn" onclick="toggleSound()" title="Toggle startup sound">&#9836; Sound ON</button>
</div>
<div class="meta">
  <span><strong>Computer:</strong> $cn</span>
  <span><strong>Run by:</strong> $ru</span>
  <span><strong>Generated:</strong> $ts</span>
  <span><strong>Risk Score:</strong> <span style="color:$scoreColor;font-weight:700">$lv ($sc/100)</span></span>
  <span><strong>MITRE TTPs:</strong> $($Mitre.Count)</span>
  <span><strong>Sections:</strong> $sectionCount</span>
</div>
<div class="searchbar">
  <div class="search-wrap">
    <span class="srchicon">&#128269;</span>
    <input type="text" id="gs" placeholder="Search all data &mdash; type IP, SID, name, path, port, CVE, user, service..." autocomplete="off">
    <div class="search-nav">
      <button class="snav-btn" onclick="searchNav(-1)" title="Previous match">&#8679;</button>
      <button class="snav-btn" onclick="searchNav(1)" title="Next match">&#8681;</button>
    </div>
    <button id="gs-clear" onclick="clearSearch()">&#10005; Clear</button>
  </div>
  <div id="sc2"></div>
</div>
<div class="rblock" id="risk_sec">
  <div class="rblock-title">&#9888; Risk Score Analysis</div>
  <div class="grow">
    <div class="gc"><span class="gl">$sc</span></div>
    <div class="gm">
      <h3>$lv RISK</h3>
      <p>Score: $sc / 100</p>
      <p>$(@($Risk.Findings).Count) finding(s) detected</p>
      <p style="color:var(--text3);font-size:.75em;margin-top:4px">&#9432; Click any severity badge to jump to findings</p>
    </div>
    <div class="rbw">
      <div class="rbb"><div class="rbf"></div></div>
      <div class="rbl"><span>0</span><span>25 Low</span><span>50 Med</span><span>75 High</span><span>100</span></div>
    </div>
  </div>
  <div class="risk-filters">
    <span>Filter:</span>
    <button class="rfbtn f-all active" onclick="filterRisk('ALL')">ALL ($(@($Risk.Findings).Count))</button>
    <button class="rfbtn f-crit" onclick="filterRisk('CRITICAL')">&#9888; CRITICAL ($critCount)</button>
    <button class="rfbtn f-high" onclick="filterRisk('HIGH')">&#9650; HIGH ($highCount)</button>
    <button class="rfbtn f-med" onclick="filterRisk('MEDIUM')">&#9654; MEDIUM ($medCount)</button>
  </div>
  <div class="tw"><table>
    <thead><tr><th>Severity</th><th>Finding</th><th>Points</th></tr></thead>
    <tbody id="risk-tbody">$riskRows</tbody>
  </table></div>
</div>
<section id="mitre_sec" class="datasec">
  <h2 class="sech2"><span class="secnum">M</span>MITRE ATT&amp;CK &mdash; $($Mitre.Count) Applicable Techniques</h2>
  <p style="color:var(--text2);font-size:.77em;margin-bottom:14px">&#128279; Click any technique ID to open official MITRE ATT&amp;CK page. Findings based on your system configuration.</p>
  <div class="mg">$mitreCards</div>
</section>
$sectHtml
<div class="footer">
  <span>WMI Audit Frogman v16 &bull; MANIKANDAN &bull; 9787091093</span>
  <span>$cn &bull; $ts</span>
  <span>PDF: Ctrl+P &rarr; Background Graphics &rarr; Save as PDF</span>
</div>
</main>
<script>
// ====== SOUND ENGINE ======
var soundEnabled = true;
var AudioCtx = window.AudioContext || window.webkitAudioContext;
var actx = null;
function getCtx(){if(!actx && AudioCtx) actx = new AudioCtx(); return actx;}
function playTone(freq,dur,type,vol,delay){
  var ctx=getCtx(); if(!ctx||!soundEnabled) return;
  var o=ctx.createOscillator(), g=ctx.createGain();
  o.connect(g); g.connect(ctx.destination);
  o.type=type||'sine'; o.frequency.value=freq;
  var t=ctx.currentTime+(delay||0);
  g.gain.setValueAtTime(0,t);
  g.gain.linearRampToValueAtTime(vol||0.18,t+0.02);
  g.gain.exponentialRampToValueAtTime(0.001,t+dur);
  o.start(t); o.stop(t+dur+0.05);
}
function playDeepIntro(){
  if(!soundEnabled) return;
  // Deep cinematic boot sequence
  playTone(55,0.6,'sine',0.25,0);
  playTone(110,0.4,'sine',0.18,0.1);
  playTone(82,0.8,'triangle',0.2,0.3);
  playTone(165,0.5,'sine',0.15,0.6);
  playTone(220,0.3,'sine',0.12,0.9);
  playTone(330,0.4,'sine',0.1,1.1);
  playTone(440,0.6,'sine',0.2,1.3);
  playTone(550,0.8,'sine',0.15,1.5);
  // Final chord
  setTimeout(function(){
    playTone(440,1.2,'sine',0.15,0);
    playTone(554,1.2,'sine',0.12,0);
    playTone(659,1.5,'sine',0.1,0);
  },1900);
}
function playClickSound(){
  playTone(880,0.08,'sine',0.08,0);
  playTone(1100,0.06,'sine',0.06,0.05);
}
function playScrollSound(){
  playTone(660,0.05,'sine',0.06,0);
}
function toggleSound(){
  soundEnabled=!soundEnabled;
  var btn=document.getElementById('sound-btn');
  btn.textContent=soundEnabled?'\u266C Sound ON':'\u266A Sound OFF';
  btn.classList.toggle('active',soundEnabled);
  if(soundEnabled) playDeepIntro();
}
window.addEventListener('load',function(){setTimeout(playDeepIntro,400);});

// ====== THEME TOGGLE ======
function toggleTheme(){
  var h=document.documentElement;
  var isDark=h.getAttribute('data-theme')==='dark';
  h.setAttribute('data-theme',isDark?'light':'dark');
  document.getElementById('theme-label').textContent=isDark?'\u2600 Light':'\u263E Dark';
  playClickSound();
  localStorage.setItem('frogman-theme',isDark?'light':'dark');
}
(function(){
  var t=localStorage.getItem('frogman-theme');
  if(t){
    document.documentElement.setAttribute('data-theme',t);
    document.getElementById('theme-label').textContent=t==='light'?'\u2600 Light':'\u263E Dark';
  }
})();

// ====== SIDEBAR TOGGLE (mobile) ======
function toggleSidebar(){
  var sb=document.getElementById('sb');
  sb.classList.toggle('open');
  playClickSound();
}
// Close sidebar on outside click (mobile)
document.addEventListener('click',function(e){
  var sb=document.getElementById('sb');
  var btn=document.getElementById('sb-toggle');
  if(window.innerWidth<=900 && sb.classList.contains('open') && !sb.contains(e.target) && e.target!==btn){
    sb.classList.remove('open');
  }
});

// ====== NAV SIDEBAR FILTER ======
function filterNav(q){
  q=q.trim().toLowerCase();
  document.querySelectorAll('#navlist .navlink').forEach(function(a){
    var txt=a.querySelector('.navtxt');
    if(!txt) return;
    var show=!q||txt.textContent.toLowerCase().indexOf(q)>=0;
    a.parentElement.style.display=show?'':'none';
  });
}

// ====== SEARCH ENGINE (FIXED & SMART) ======
var searchMatches=[], searchIdx=-1, currentQuery='';
function escapeRx(s){return s.replace(/[.*+?^`${}()|[\]\\]/g,'\\`$&');}
function clearHighlights(el){
  var marks=el.querySelectorAll('mark.match-hl');
  marks.forEach(function(m){
    var parent=m.parentNode;
    parent.replaceChild(document.createTextNode(m.textContent),m);
    parent.normalize();
  });
}
function highlightText(el,rx){
  if(el.nodeType===3){
    var txt=el.textContent;
    if(rx.test(txt)){
      var frag=document.createDocumentFragment();
      var last=0; rx.lastIndex=0;
      var m;
      while((m=rx.exec(txt))!==null){
        frag.appendChild(document.createTextNode(txt.slice(last,m.index)));
        var mark=document.createElement('mark');
        mark.className='match-hl'; mark.textContent=m[0];
        frag.appendChild(mark);
        last=rx.lastIndex;
      }
      frag.appendChild(document.createTextNode(txt.slice(last)));
      el.parentNode.replaceChild(frag,el);
      return true;
    }
  } else if(el.nodeType===1 && el.nodeName!=='MARK' && el.nodeName!=='SCRIPT' && el.nodeName!=='STYLE'){
    var found=false;
    Array.from(el.childNodes).forEach(function(child){if(highlightText(child,rx)) found=true;});
    return found;
  }
  return false;
}
document.getElementById('gs').addEventListener('input',function(){
  doSearch(this.value.trim());
});
function doSearch(q){
  currentQuery=q;
  searchMatches=[]; searchIdx=-1;
  var sc2=document.getElementById('sc2');
  // Clear all highlights and show everything first
  document.querySelectorAll('table tbody tr').forEach(function(r){r.classList.remove('hiddenrow');});
  document.querySelectorAll('.datasec').forEach(function(s){
    s.classList.remove('hidden-sec');
    clearHighlights(s);
  });
  document.querySelectorAll('.navcnt').forEach(function(c){c.className='navcnt';c.textContent='';});
  if(!q){sc2.textContent='';sc2.style.color='';return;}
  var rx=new RegExp(escapeRx(q),'gi');
  var totalRows=0, visRows=0;
  // Per-section counts
  document.querySelectorAll('.datasec').forEach(function(sec){
    var secId=sec.id;
    var navId='cnt_'+secId;
    var rows=sec.querySelectorAll('table tbody tr');
    var secMatch=0;
    rows.forEach(function(r){
      totalRows++;
      var txt=r.textContent.toLowerCase();
      if(txt.indexOf(q.toLowerCase())>=0){
        r.classList.remove('hiddenrow');
        secMatch++; visRows++;
        searchMatches.push(r);
      } else {
        r.classList.add('hiddenrow');
      }
    });
    // Also check scalar/nodata text
    var scalar=sec.querySelector('.scalar');
    var scalarMatch=scalar && scalar.textContent.toLowerCase().indexOf(q.toLowerCase())>=0;
    // Hide section if no matches and has table
    if(rows.length>0 && secMatch===0 && !scalarMatch){
      sec.classList.add('hidden-sec');
    } else {
      sec.classList.remove('hidden-sec');
    }
    // Update nav counter
    var cnt=document.getElementById(navId);
    if(cnt){
      if(rows.length>0){
        cnt.style.display='inline-block';
        cnt.textContent=secMatch;
        cnt.className='navcnt '+(secMatch>0?'has-results':'no-results');
      }
    }
    // Highlight matches
    if(secMatch>0 || scalarMatch){
      var rx2=new RegExp(escapeRx(q),'gi');
      highlightText(sec,rx2);
    }
  });
  if(searchMatches.length>0){searchIdx=0;scrollToMatch(0);}
  var msg=visRows+' of '+totalRows+' rows match "'+q+'"';
  if(searchMatches.length) msg+=' \u2022 '+searchMatches.length+' highlighted';
  sc2.textContent=msg;
  sc2.style.color=visRows>0?'var(--green)':'var(--red)';
}
function searchNav(dir){
  if(searchMatches.length===0) return;
  searchIdx=(searchIdx+dir+searchMatches.length)%searchMatches.length;
  scrollToMatch(searchIdx);
}
function scrollToMatch(idx){
  if(idx<0||idx>=searchMatches.length) return;
  playScrollSound();
  searchMatches[idx].scrollIntoView({behavior:'smooth',block:'center'});
  searchMatches[idx].style.outline='2px solid var(--yellow)';
  searchMatches[idx].style.outlineOffset='2px';
  var prev=document.querySelector('tr.current-match');
  if(prev) prev.classList.remove('current-match');
  searchMatches[idx].classList.add('current-match');
  setTimeout(function(){
    if(searchMatches[idx]) searchMatches[idx].style.outline='';
  },1500);
}
function clearSearch(){
  document.getElementById('gs').value='';
  doSearch('');
  playClickSound();
}

// ====== RISK SEVERITY FILTER ======
function filterRisk(sev){
  document.querySelectorAll('.rfbtn').forEach(function(b){b.classList.remove('active');});
  var btn=document.querySelector('.rfbtn.f-'+sev.toLowerCase());
  if(!btn) document.querySelector('.rfbtn.f-all').classList.add('active');
  else btn.classList.add('active');
  document.querySelectorAll('#risk-tbody tr.rfind').forEach(function(r){
    if(sev==='ALL'||r.classList.contains('sev_'+sev)){
      r.classList.remove('hidden-sev');
    } else {
      r.classList.add('hidden-sev');
    }
  });
  playClickSound();
}
// Severity badge click = scroll to that severity
document.addEventListener('click',function(e){
  if(e.target.classList.contains('sevbadge')){
    var sev=e.target.getAttribute('data-sev');
    if(sev){
      filterRisk(sev);
      document.getElementById('risk_sec').scrollIntoView({behavior:'smooth',block:'start'});
      playClickSound();
    }
  }
});

// ====== SMOOTH NAV ======
document.querySelectorAll('#sb a[href^="#"]').forEach(function(a){
  a.addEventListener('click',function(e){
    var t=document.querySelector(this.getAttribute('href'));
    if(t){e.preventDefault();t.scrollIntoView({behavior:'smooth',block:'start'});playScrollSound();}
    if(window.innerWidth<=900){document.getElementById('sb').classList.remove('open');}
  });
});

// ====== ACTIVE NAV HIGHLIGHT ======
var allSecEls=Array.from(document.querySelectorAll('section,.rblock'));
var ticking=false;
window.addEventListener('scroll',function(){
  if(!ticking){
    requestAnimationFrame(function(){
      var cur='';
      allSecEls.forEach(function(s){if(window.scrollY>=s.offsetTop-120) cur=s.id;});
      document.querySelectorAll('#sb a.navlink').forEach(function(a){
        a.classList.toggle('active',a.getAttribute('href')==='#'+cur);
      });
      ticking=false;
    });
    ticking=true;
  }
},{passive:true});
</script>
</body>
</html>
"@
        [System.IO.File]::WriteAllText($FilePath, $html, [System.Text.Encoding]::UTF8)
        Write-Host "  [OK] HTML: $FilePath" -ForegroundColor $ColorScheme.Success
        return $FilePath
    } catch {
        Write-Host "  [ERR] HTML: $_" -ForegroundColor $ColorScheme.Alert
        return $null
    }
}


# ==== PDF ====
function Open-HTMLAsPDF {
    param($HtmlPath)
    $pdfPath  = $HtmlPath -replace '\.html$','.pdf'
    $tempHtml = $HtmlPath -replace '\.html$','_print.html'

    # Build print-safe CSS using string concatenation (no here-strings)
    $css  = '<style id="pdf-fix">'
    $css += '*, *::before, *::after {'
    $css += '  animation:none!important; animation-duration:0s!important;'
    $css += '  transition:none!important; transition-duration:0s!important; }'
    $css += '#sb,#sb-toggle,.controls-bar,.searchbar,.risk-filters,'
    $css += '.search-nav,#gs-clear,.snav-btn,.sound-btn,.theme-btn { display:none!important; }'
    $css += '#main { margin-left:0!important; padding:20px 24px!important;'
    $css += '        display:block!important; overflow:visible!important; }'
    $css += 'body  { display:block!important; overflow:visible!important; }'
    $css += '.datasec,.hidden-sec { display:block!important; }'
    $css += 'tr.hiddenrow          { display:table-row!important; }'
    $css += 'tr.rfind.hidden-sev  { display:table-row!important; }'
    $css += '.tw { overflow:visible!important; overflow-x:visible!important;'
    $css += '      max-height:none!important; }'
    $css += 'table { width:100%!important; table-layout:auto!important; }'
    $css += 'td    { white-space:normal!important; word-break:break-word!important; }'
    $css += '.mg { display:block!important; }'
    $css += '.mc { display:block!important; margin-bottom:8px!important; }'
    $css += '* { -webkit-print-color-adjust:exact!important;'
    $css += '    print-color-adjust:exact!important; }'
    $css += '.rblock,.datasec,.mc,table { page-break-inside:avoid; break-inside:avoid; }'
    $css += 'h2.sech2 { page-break-after:avoid; break-after:avoid; }'
    $css += '</style>'

    try {
        $content = [System.IO.File]::ReadAllText($HtmlPath, [System.Text.Encoding]::UTF8)
        $content = $content -replace '</head>', ($css + "`n</head>")
        $content = $content -replace '<nav id="sb">', '<nav id="sb" style="display:none!important;width:0!important">'
        [System.IO.File]::WriteAllText($tempHtml, $content, [System.Text.Encoding]::UTF8)
    }
    catch {
        Write-Host "  [WARN] Could not create print temp file: $_" -ForegroundColor $ColorScheme.Warning
        $tempHtml = $HtmlPath
    }

    $browsers = @(
        "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe",
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
    )
    $browser = $browsers | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($browser) {
        $fp = ($tempHtml -replace '\\', '/')

        $argList = @(
            '--headless=new',
            '--disable-gpu',
            '--no-sandbox',
            '--run-all-compositor-stages-before-draw',
            '--virtual-time-budget=10000',
            '--disable-web-security',
            '--print-to-pdf-no-header',
            '--no-pdf-header-footer',
            '--disable-extensions',
            '--hide-scrollbars',
            ('--print-to-pdf="' + $pdfPath + '"'),
            ('"file:///' + $fp + '"')
        )
        $argStr = $argList -join ' '

        Write-Host "  Generating PDF (headless - allow up to 30s)..." -ForegroundColor $ColorScheme.InfoLow
        $proc = Start-Process $browser -ArgumentList $argStr -PassThru -WindowStyle Hidden -ErrorAction SilentlyContinue
        $proc | Wait-Process -Timeout 90 -ErrorAction SilentlyContinue

        if (($tempHtml -ne $HtmlPath) -and (Test-Path $tempHtml)) {
            Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue
        }

        if (Test-Path $pdfPath) {
            $kb = [math]::Round((Get-Item $pdfPath).Length / 1KB, 1)
            Write-Host "  [OK] PDF: $pdfPath  ($kb KB)" -ForegroundColor $ColorScheme.Success
            if ((Get-Item $pdfPath).Length -lt 100000) {
                Write-Host "  [WARN] PDF is very small (${kb} KB) - some pages may be blank." -ForegroundColor $ColorScheme.Warning
                Write-Host "  [TIP]  Open the HTML and press Ctrl+P, choose Save as PDF." -ForegroundColor $ColorScheme.InfoLow
                Write-Host "         Tick Background graphics in the print dialog." -ForegroundColor $ColorScheme.InfoLow
            }
        }
        else {
            Write-Host "  [WARN] Headless PDF did not produce a file." -ForegroundColor $ColorScheme.Warning
            Write-Host "  [TIP]  Opening HTML - press Ctrl+P, Save as PDF." -ForegroundColor $ColorScheme.InfoLow
            Write-Host "         Tick Background graphics in the print dialog." -ForegroundColor $ColorScheme.InfoLow
            Start-Process $HtmlPath
        }
    }
    else {
        Write-Host "  [INFO] Chrome/Edge not found - opening HTML in default browser." -ForegroundColor $ColorScheme.Warning
        Write-Host "  [TIP]  Press Ctrl+P, Save as PDF, tick Background graphics." -ForegroundColor $ColorScheme.InfoLow
        Start-Process $HtmlPath
    }
}
# ==== EXPORT MENU ====
function Export-Reports {
    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    Write-Host ("`n" + ("=" * 70)) -ForegroundColor $ColorScheme.Header
    Write-Host "EXPORT REPORTS" -ForegroundColor $ColorScheme.Title
    Write-Host ("=" * 70) -ForegroundColor $ColorScheme.Header

    $defPath = if ($script:OutputPath -and (Test-Path $script:OutputPath)) {$script:OutputPath}
               elseif (Test-Path "$env:USERPROFILE\Documents") {"$env:USERPROFILE\Documents"}
               else {$env:USERPROFILE}

    Write-Host "`nDefault path: $defPath" -ForegroundColor $ColorScheme.InfoLow
    Write-Host "[1] Use default  [2] Desktop  [3] Custom" -ForegroundColor $ColorScheme.MenuNumber
    $lc = Read-Host "Location"
    switch ($lc) {
        "2" { $sp = if (Test-Path "$env:USERPROFILE\Desktop") {"$env:USERPROFILE\Desktop"} else {$defPath} }
        "3" {
            $cu = Read-Host "Enter full path"
            if (Test-Path $cu) {$sp=$cu} else {
                try {New-Item -ItemType Directory -Path $cu -Force|Out-Null;$sp=$cu}
                catch {$sp=$defPath}
            }
        }
        default { $sp = $defPath }
    }
    $script:OutputPath = $sp

    $defName = "WMIFrogman_${env:COMPUTERNAME}_$ts"
    Write-Host "`nDefault filename: $defName" -ForegroundColor $ColorScheme.InfoLow
    $cn2 = Read-Host "Filename (blank=default)"
    $bn  = if ($cn2.Trim() -ne "") {$cn2.Trim() -replace '[\\/:*?"<>|]','_'} else {$defName}

    Write-Host "`nFormat:" -ForegroundColor $ColorScheme.MenuNumber
    Write-Host "  [1] JSON  [2] HTML  [3] PDF  [4] CSV  [5] YAML  [6] ALL FORMATS" -ForegroundColor $ColorScheme.MenuNumber
    $fmt = Read-Host "Select"

    Write-Host "`nCollecting audit data..." -ForegroundColor $ColorScheme.Warning
    $ad = Collect-AuditData
    Write-Host "  Computing risk score..." -ForegroundColor $ColorScheme.InfoLow
    $risk = Compute-RiskScore -Data $ad
    Write-Host "  Mapping MITRE ATT&CK ($($ad.Count) data points)..." -ForegroundColor $ColorScheme.InfoLow
    $mitre = Get-MitreMapping -Data $ad

    $riskCol = if($risk.Score -ge 75){"Red"} elseif($risk.Score -ge 50){"Yellow"} else{"Green"}
    Write-Host ""
    Write-Host "  RISK: $($risk.Score)/100  [$($risk.Level)]  |  MITRE techniques: $($mitre.Count)" -ForegroundColor $riskCol

    switch ($fmt) {
        "1" { Export-ToJSON $ad (Join-Path $sp "$bn.json") }
        "2" { Export-ToHTML $ad (Join-Path $sp "$bn.html") $risk $mitre | Out-Null }
        "3" { $hp = Export-ToHTML $ad (Join-Path $sp "$bn.html") $risk $mitre; if ($hp) { Open-HTMLAsPDF $hp } }
        "4" { Export-ToCSV $ad $sp $bn }
        "5" { Export-ToYAML $ad (Join-Path $sp "$bn.yaml") }
        "6" {
            Export-ToJSON $ad (Join-Path $sp "$bn.json")
            $hp = Export-ToHTML $ad (Join-Path $sp "$bn.html") $risk $mitre
            if ($hp) { Open-HTMLAsPDF $hp }
            Export-ToCSV $ad $sp $bn
            Export-ToYAML $ad (Join-Path $sp "$bn.yaml")
        }
        default { Export-ToJSON $ad (Join-Path $sp "$bn.json") }
    }
    Write-Host "`n[DONE] Saved to: $sp" -ForegroundColor $ColorScheme.Success
}

# ==== MAIN ====
Initialize-SaveLocation
if ($Target -and $Target -ne $env:COMPUTERNAME) {
    Write-Host "[*] Remote target pre-set: $Target" -ForegroundColor Yellow
    if ($TargetUser) { $script:RemoteCred = Get-Credential -UserName $TargetUser -Message "Credentials for $Target" }
}
Start-MatrixRain -Lines 14
Start-FrogBlink
$script:FrogColor = Get-Random $colors
if ($Dashboard) { Start-LiveDashboard -Interval $RefreshSeconds; exit }

$go = $true
while ($go) {
    Show-Header
    $ch = Show-Menu
    switch ($ch.ToUpper()) {
        "1" { Invoke-SystemInfo }
        "2" { Invoke-UserGroupEnum }
        "3" { Invoke-ServiceEnum }
        "4" { Invoke-ProcessTasks }
        "5" { Invoke-NetworkShares }
        "6" { Invoke-PrivilegePolicy }
        "7" { Invoke-WMICIMAdvanced }
        "8" { Invoke-StorageDisk }
        "9" { Invoke-SecurityFirewall }
        "10" { Invoke-RegistryConfig }
        "11" { Invoke-HardwarePeripherals }
        "12" { Invoke-SoftwareApps }
        "13" { Invoke-TasksLogsAudit }
        "14" { Invoke-CertificatesCrypto }
        "15" { Invoke-PersistenceLateral }
        "B" {
            Write-Host "`n[*] RUNNING ALL 600 COMMANDS..." -ForegroundColor $ColorScheme.Alert
            Write-Host "    TIP: Press [S] before any slow command to skip it" -ForegroundColor $ColorScheme.InfoLow
            Invoke-SystemInfo; Invoke-UserGroupEnum; Invoke-ServiceEnum
            Invoke-ProcessTasks; Invoke-NetworkShares; Invoke-PrivilegePolicy
            Invoke-WMICIMAdvanced; Invoke-StorageDisk; Invoke-SecurityFirewall
            Invoke-RegistryConfig; Invoke-HardwarePeripherals; Invoke-SoftwareApps
            Invoke-TasksLogsAudit; Invoke-CertificatesCrypto; Invoke-PersistenceLateral
            Invoke-ThreatDetection
            Write-Host "`n[DONE] ALL 600 COMMANDS COMPLETE!" -ForegroundColor $ColorScheme.Success
        }
        "16" { Invoke-ADRecon }
        "17" { Invoke-CloudDetect }
        "18" { Invoke-BrowserArtifacts }
        "19" { Invoke-CVEMatch }
        "L"  { Start-LiveDashboard -Interval $RefreshSeconds }
        "R"  { Set-RemoteTarget }
        "C" { Invoke-ThreatDetection }
        "D" { Export-Reports }
        "Q" {
            Write-Host ""
            Show-ExitBanner
            Write-Host ""
            $go = $false
        }
        default { Write-Host "`n[!] Invalid option" -ForegroundColor $ColorScheme.Alert }
    }
    if ($go) {
        Write-Host "`nPress any key to return to menu..." -ForegroundColor $ColorScheme.InfoLow
        $null = [System.Console]::ReadKey($true)
        $script:FrogColor = Get-Random $colors
    }
}
