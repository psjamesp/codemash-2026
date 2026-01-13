# ============================================================
# MASTER DEMO SCRIPT - CLEAN VERSION
# Stop Clicking, Start Scripting: PowerShell for Real People
# ============================================================

# ============================================================
# SECTION 1: INTRODUCTION (0:00 - 0:30)
# ============================================================
# Show Slides 1-3

# ============================================================
# SECTION 2: FILE MANAGEMENT - DEMO 1 (0:30 - 1:00)
# ============================================================

Get-Location

Get-ChildItem

Get-ChildItem | Format-Table Name, Length, LastWriteTime

Get-ChildItem -Directory

Get-ChildItem -File

Get-ChildItem -Recurse

New-Item -ItemType Directory -Path "C:\Temp\PowerShellDemo"

New-Item -ItemType File -Path "C:\Temp\PowerShellDemo\test.txt"

"Hello, PowerShell!" | Out-File "C:\Temp\PowerShellDemo\test.txt"

Get-Content "C:\Temp\PowerShellDemo\test.txt"

"This is line 2" | Add-Content "C:\Temp\PowerShellDemo\test.txt"
Get-Content "C:\Temp\PowerShellDemo\test.txt"

Copy-Item "C:\Temp\PowerShellDemo\test.txt" "C:\Temp\PowerShellDemo\test-backup.txt"

Get-ChildItem "C:\Temp\PowerShellDemo"

Move-Item "C:\Temp\PowerShellDemo\test-backup.txt" "C:\Temp\PowerShellDemo\backup.txt"
Get-ChildItem "C:\Temp\PowerShellDemo"

Remove-Item "C:\Temp\PowerShellDemo\backup.txt"

Remove-Item "C:\Temp\PowerShellDemo" -Recurse -Force

# ---- BREAK (10 minutes) ----

# ============================================================
# SECTION 3: SYSTEM INFORMATION - DEMO 2 (1:10 - 1:45)
# ============================================================

Get-Process

Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, CPU, WorkingSet

Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 Name, @{Name="MemoryMB";Expression={[math]::Round($_.WorkingSet/1MB,2)}}

Get-Service

Get-Service | Where-Object {$_.Status -eq "Running"}

Get-Service | Where-Object {$_.Status -eq "Stopped"}

Get-Service -Name "WinRM"

Get-PSDrive -PSProvider FileSystem

Get-WmiObject Win32_LogicalDisk | Select-Object DeviceID, 
    @{Name="SizeGB";Expression={[math]::Round($_.Size/1GB,2)}},
    @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
    @{Name="PercentFree";Expression={[math]::Round(($_.FreeSpace/$_.Size)*100,2)}}

$env:COMPUTERNAME

Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber

Get-WmiObject Win32_ComputerSystem | Select-Object Manufacturer, Model, TotalPhysicalMemory

Get-NetIPConfiguration

Get-NetAdapter | Select-Object Name, Status, LinkSpeed

# ============================================================
# SECTION 4: SERVICE MANAGEMENT - DEMO 3 (1:45 - 2:15)
# ============================================================

Get-Service | Sort-Object Status

Get-Service -Name "*win*"

Get-Service -Name "WinRM" | Format-List *

$service = Get-Service -Name "WinRM"
if ($service.Status -eq "Running") {
    Write-Host "WinRM service is running" -ForegroundColor Green
} else {
    Write-Host "WinRM service is not running" -ForegroundColor Red
}

Get-Service | Where-Object {$_.Status -eq "Stopped"} | Select-Object Name, DisplayName

Get-WmiObject Win32_Service | 
    Where-Object {$_.StartMode -eq "Auto" -and $_.State -ne "Running"} |
    Select-Object Name, DisplayName, State, StartMode

Get-Service | Group-Object Status | Select-Object Count, Name

Get-Service | Where-Object {$_.Status -eq "Running"} | 
    Select-Object Name, DisplayName, Status |
    Export-Csv "C:\Temp\RunningServices.csv" -NoTypeInformation

Import-Csv "C:\Temp\RunningServices.csv" | Select-Object -First 5

Remove-Item "C:\Temp\RunningServices.csv" -Force

# ---- BREAK (10 minutes) ----

# ============================================================
# SECTION 5: WRITING BETTER SCRIPTS - CONCEPTS (2:25 - 2:40)
# ============================================================
# Show Slides 4 & 6

# ============================================================
# SECTION 6: REMOTE MANAGEMENT - DEMO 4 (2:40 - 3:20)
# ============================================================
# Show Slide 5

Get-Service WinRM

Test-WSMan -ComputerName "localhost"

$computers = @("localhost", "Server01", "Server02")
foreach ($computer in $computers) {
    $result = Test-Connection -ComputerName $computer -Count 1 -Quiet
    if ($result) {
        Write-Host "$computer is reachable" -ForegroundColor Green
    } else {
        Write-Host "$computer is not reachable" -ForegroundColor Red
    }
}

Invoke-Command -ComputerName "localhost" -ScriptBlock {
    Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object -First 5
}

$computers = @("localhost")
Invoke-Command -ComputerName $computers -ScriptBlock {
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 3
}

Invoke-Command -ComputerName "localhost" -ScriptBlock {
    $env:COMPUTERNAME
}

$computers = @("localhost")
Invoke-Command -ComputerName $computers -ScriptBlock {
    Get-PSDrive C | Select-Object @{Name="Computer";Expression={$env:COMPUTERNAME}}, Used, Free
}

Invoke-Command -ComputerName "localhost" -ScriptBlock {
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher |
    Where-Object {$_.DisplayName -ne $null} |
    Sort-Object DisplayName |
    Select-Object -First 10
}

$computers = @("localhost")

$results = Invoke-Command -ComputerName $computers -ScriptBlock {
    Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        $percentFree = ($_.FreeSpace / $_.Size) * 100
        [PSCustomObject]@{
            Computer = $env:COMPUTERNAME
            Drive = $_.DeviceID
            PercentFree = [math]::Round($percentFree, 2)
            FreeGB = [math]::Round($_.FreeSpace/1GB, 2)
            TotalGB = [math]::Round($_.Size/1GB, 2)
        }
    }
}

$results | Format-Table -AutoSize

$lowSpace = $results | Where-Object {$_.PercentFree -lt 20}
if ($lowSpace) {
    Write-Host "`nWARNING: These drives are low on space:" -ForegroundColor Red
    $lowSpace | Format-Table -AutoSize
} else {
    Write-Host "`nAll drives have adequate free space" -ForegroundColor Green
}

# ---- BREAK (10 minutes) ----

# ============================================================
# SECTION 7: AUTOMATION SCRIPT - DEMO 5 (3:30 - 4:00)
# ============================================================

$reportPath = "C:\Temp\HealthCheck-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$report = @"
========================================
SYSTEM HEALTH CHECK REPORT
Generated: $timestamp
Computer: $env:COMPUTERNAME
========================================

"@

Write-Host "Checking disk space..." -ForegroundColor Cyan

$diskInfo = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $percentFree = ($_.FreeSpace / $_.Size) * 100
    [PSCustomObject]@{
        Drive = $_.DeviceID
        TotalGB = [math]::Round($_.Size/1GB, 2)
        FreeGB = [math]::Round($_.FreeSpace/1GB, 2)
        PercentFree = [math]::Round($percentFree, 2)
        Status = if ($percentFree -lt 10) {"CRITICAL"} 
                 elseif ($percentFree -lt 20) {"WARNING"} 
                 else {"OK"}
    }
}

$report += "`nDISK SPACE:`n"
$report += $diskInfo | Format-Table -AutoSize | Out-String

Write-Host "Checking critical services..." -ForegroundColor Cyan

$criticalServices = @("WinRM", "W32Time", "EventLog", "Dhcp")

$serviceStatus = foreach ($serviceName in $criticalServices) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service) {
        [PSCustomObject]@{
            Service = $service.DisplayName
            Status = $service.Status
            Alert = if ($service.Status -ne "Running") {"ISSUE"} else {"OK"}
        }
    } else {
        [PSCustomObject]@{
            Service = $serviceName
            Status = "NOT FOUND"
            Alert = "ISSUE"
        }
    }
}

$report += "`nCRITICAL SERVICES:`n"
$report += $serviceStatus | Format-Table -AutoSize | Out-String

Write-Host "Checking CPU and memory..." -ForegroundColor Cyan

$computer = Get-WmiObject Win32_ComputerSystem
$os = Get-WmiObject Win32_OperatingSystem

$memoryInfo = [PSCustomObject]@{
    TotalMemoryGB = [math]::Round($computer.TotalPhysicalMemory/1GB, 2)
    FreeMemoryGB = [math]::Round($os.FreePhysicalMemory/1MB, 2)
    UsedMemoryGB = [math]::Round(($computer.TotalPhysicalMemory/1GB) - ($os.FreePhysicalMemory/1MB), 2)
    PercentUsed = [math]::Round(((($computer.TotalPhysicalMemory/1GB) - ($os.FreePhysicalMemory/1MB)) / ($computer.TotalPhysicalMemory/1GB)) * 100, 2)
}

$report += "`nMEMORY STATUS:`n"
$report += $memoryInfo | Format-List | Out-String

Write-Host "Getting top resource-consuming processes..." -ForegroundColor Cyan

$topCPU = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, 
    @{Name="CPU";Expression={[math]::Round($_.CPU, 2)}},
    @{Name="MemoryMB";Expression={[math]::Round($_.WorkingSet/1MB, 2)}}

$report += "`nTOP 5 PROCESSES BY CPU:`n"
$report += $topCPU | Format-Table -AutoSize | Out-String

Write-Host "Checking recent errors in Event Log..." -ForegroundColor Cyan

$recentErrors = Get-EventLog -LogName System -EntryType Error -Newest 5 -ErrorAction SilentlyContinue |
    Select-Object TimeGenerated, Source, Message

$report += "`nRECENT SYSTEM ERRORS (Last 5):`n"
if ($recentErrors) {
    $report += $recentErrors | Format-Table -AutoSize -Wrap | Out-String
} else {
    $report += "No recent errors found`n"
}

$uptime = (Get-Date) - $os.ConvertToDateTime($os.LastBootUpTime)
$report += "`nSYSTEM UPTIME:`n"
$report += "Days: $($uptime.Days), Hours: $($uptime.Hours), Minutes: $($uptime.Minutes)`n"

$report += "`n========================================`n"
$report += "SUMMARY`n"
$report += "========================================`n"

$issues = @()
if ($diskInfo | Where-Object {$_.Status -ne "OK"}) {
    $issues += "- Disk space issues detected"
}
if ($serviceStatus | Where-Object {$_.Alert -eq "ISSUE"}) {
    $issues += "- Service issues detected"
}
if ($memoryInfo.PercentUsed -gt 90) {
    $issues += "- High memory usage ($($memoryInfo.PercentUsed)%)"
}

if ($issues.Count -gt 0) {
    $report += "`nISSUES FOUND:`n"
    $report += ($issues -join "`n") + "`n"
} else {
    $report += "`nNo issues detected - system is healthy`n"
}

$report | Out-File $reportPath
Write-Host "`nReport saved to: $reportPath" -ForegroundColor Green

Write-Host "`n$report"

notepad $reportPath

# ============================================================
# WRAP UP & Q&A (4:00 - 4:15)
# ============================================================
# Show Slide 7