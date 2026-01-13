# ============================================================
# Demo 2: Getting System Information
# Time: 10 minutes
# ============================================================
# Learn how to gather information about your system

# ---- PROCESS MANAGEMENT ----
# See all running processes
Get-Process

# Find specific processes (e.g., Chrome)
Get-Process -Name "chrome" -ErrorAction SilentlyContinue

# Show top 10 processes by CPU usage
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, WorkingSet

# Show top 10 processes by memory usage (WorkingSet is memory in bytes)
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, @{Name="MemoryMB";Expression={[math]::Round($_.WorkingSet/1MB,2)}}

# ---- SERVICE MANAGEMENT ----
# See all services
Get-Service

# See only running services
Get-Service | Where-Object {$_.Status -eq "Running"}

# See only stopped services
Get-Service | Where-Object {$_.Status -eq "Stopped"}

# Find a specific service
Get-Service -Name "WinRM"

# ---- DISK SPACE ----
# Check disk space on all drives
Get-PSDrive -PSProvider FileSystem

# Get detailed disk information
Get-WmiObject Win32_LogicalDisk | Select-Object DeviceID, 
    @{Name="SizeGB";Expression={[math]::Round($_.Size/1GB,2)}},
    @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
    @{Name="PercentFree";Expression={[math]::Round(($_.FreeSpace/$_.Size)*100,2)}}

# ---- COMPUTER INFO ----
# Get computer name
$env:COMPUTERNAME

# Get operating system info
Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber

# Get hardware info
Get-WmiObject Win32_ComputerSystem | Select-Object Manufacturer, Model, TotalPhysicalMemory

# ---- NETWORK INFO ----
# Get IP configuration
Get-NetIPConfiguration

# Get network adapters
Get-NetAdapter | Select-Object Name, Status, LinkSpeed

# ============================================================
# TRY IT YOURSELF
# ============================================================
# 1. Find all processes using more than 100MB of memory
# 2. Check if the "Windows Update" service is running
# 3. See how much free space you have on C: drive
# 4. Find your computer's IP address
# ============================================================
