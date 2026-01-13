# ============================================================
# Demo 5: Simple Automation - Daily Health Check
# Time: 15 minutes
# ============================================================
# A practical script that checks system health and generates a report
# This is the kind of script you'd actually use every day

# ---- SETUP ----
# Define output location
$reportPath = "C:\Temp\HealthCheck-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Create header
$report = @"
========================================
SYSTEM HEALTH CHECK REPORT
Generated: $timestamp
Computer: $env:COMPUTERNAME
========================================

"@

# ---- DISK SPACE CHECK ----
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

# ---- CRITICAL SERVICES CHECK ----
Write-Host "Checking critical services..." -ForegroundColor Cyan

# Define critical services for your environment
$criticalServices = @(
    "WinRM",
    "W32Time",
    "EventLog",
    "Dhcp"  # This will be stopped/not exist on most systems - good for demo
)

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

# ---- CPU AND MEMORY CHECK ----
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

# ---- TOP PROCESSES ----
Write-Host "Getting top resource-consuming processes..." -ForegroundColor Cyan

$topCPU = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, 
    @{Name="CPU";Expression={[math]::Round($_.CPU, 2)}},
    @{Name="MemoryMB";Expression={[math]::Round($_.WorkingSet/1MB, 2)}}

$report += "`nTOP 5 PROCESSES BY CPU:`n"
$report += $topCPU | Format-Table -AutoSize | Out-String

# ---- EVENT LOG ERRORS ----
Write-Host "Checking recent errors in Event Log..." -ForegroundColor Cyan

$recentErrors = Get-EventLog -LogName System -EntryType Error -Newest 5 -ErrorAction SilentlyContinue |
    Select-Object TimeGenerated, Source, Message

$report += "`nRECENT SYSTEM ERRORS (Last 5):`n"
if ($recentErrors) {
    $report += $recentErrors | Format-Table -AutoSize -Wrap | Out-String
} else {
    $report += "No recent errors found`n"
}

# ---- UPTIME ----
$uptime = (Get-Date) - $os.ConvertToDateTime($os.LastBootUpTime)
$report += "`nSYSTEM UPTIME:`n"
$report += "Days: $($uptime.Days), Hours: $($uptime.Hours), Minutes: $($uptime.Minutes)`n"

# ---- SUMMARY ----
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

# ---- SAVE REPORT ----
$report | Out-File $reportPath
Write-Host "`nReport saved to: $reportPath" -ForegroundColor Green

# Display the report
Write-Host "`n$report"

# Open the report in Notepad
notepad $reportPath

# ============================================================
# TRY IT YOURSELF
# ============================================================
# Modify this script to:
# 1. Add more critical services to check
# 2. Change the disk space warning threshold
# 3. Add a check for specific processes you care about
# 4. Email the report (use Send-MailMessage cmdlet)
# 5. Schedule it to run daily using Task Scheduler
# ============================================================

# ============================================================
# SCHEDULING THIS SCRIPT
# ============================================================
# To run this automatically every day at 8 AM:
#
# 1. Open Task Scheduler
# 2. Create Basic Task
# 3. Name: "Daily Health Check"
# 4. Trigger: Daily at 8:00 AM
# 5. Action: Start a program
# 6. Program: powershell.exe
# 7. Arguments: -ExecutionPolicy Bypass -File "C:\Path\To\Demo5-Automation.ps1"
# ============================================================
