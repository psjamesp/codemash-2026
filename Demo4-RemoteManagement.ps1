# Demo 4: Remote Management Basics

# ---- PREREQUISITES ----
# Check if WinRM is running on your local machine
Get-Service WinRM

# Enable WinRM (run as Administrator)
# Enable-PSRemoting -Force

# ---- TESTING CONNECTIVITY ----
# Test if you can connect to a remote computer
Test-WSMan -ComputerName "localhost"

# Test connection to multiple computers
$computers = @("localhost", "Server01", "Server02")
foreach ($computer in $computers) {
    $result = Test-Connection -ComputerName $computer -Count 1 -Quiet
    if ($result) {
        Write-Host "$computer is reachable" -ForegroundColor Green
    }
    else {
        Write-Host "$computer is not reachable" -ForegroundColor Red
    }
}

# ---- RUNNING COMMANDS REMOTELY ----
# Run a single command on a remote computer
Invoke-Command -ComputerName "localhost" -ScriptBlock {
    Get-Service | Where-Object { $_.Status -eq "Running" } | Select-Object -First 5
}

# Run commands on multiple computers at once
$computers = @("localhost")
Invoke-Command -ComputerName $computers -ScriptBlock {
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 3
}

# Get the computer name from remote machines
Invoke-Command -ComputerName "localhost" -ScriptBlock {
    $env:COMPUTERNAME
}

# ---- INTERACTIVE REMOTE SESSION ----
# Enter an interactive session (like SSH)
# Note: This will start a remote session - type 'exit' to leave
Write-Host "Starting interactive session with localhost..." -ForegroundColor Yellow
Write-Host "Commands you type will run on the remote machine" -ForegroundColor Yellow
Write-Host "Type 'exit' to return to your local session" -ForegroundColor Yellow

# Enter-PSSession -ComputerName "localhost"

# ---- PRACTICAL EXAMPLES ----
# Check disk space on remote computers
$computers = @("localhost")
Invoke-Command -ComputerName $computers -ScriptBlock {
    Get-PSDrive C | Select-Object @{Name = "Computer"; Expression = { $env:COMPUTERNAME } }, Used, Free
}

# Get installed software on remote computers
Invoke-Command -ComputerName "localhost" -ScriptBlock {
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher |
    Where-Object { $_.DisplayName -ne $null } |
    Sort-Object DisplayName |
    Select-Object -First 10
}

# ---- COPYING FILES TO REMOTE COMPUTERS ----
# Note: This requires proper permissions and shares
# Copy-Item "C:\Temp\file.txt" -Destination "\\RemoteComputer\C$\Temp\" -Force

# ---- USING CREDENTIALS ----
# When you need to authenticate with different credentials
# $cred = Get-Credential
# Invoke-Command -ComputerName "Server01" -Credential $cred -ScriptBlock {
#     Get-Service
# }

# ============================================================
# TRY IT YOURSELF
# ============================================================
# 1. Check if you can connect to localhost
# 2. Get the top 5 processes by memory on localhost
# 3. Check the C: drive space on localhost remotely
# 4. Try an interactive session with localhost
# ============================================================

# ============================================================
# REAL WORLD SCENARIO
# ============================================================
# You need to check disk space on 10 servers and get an alert
# if any drive is below 20% free space

$computers = @("localhost")  # In real life, add your server names here

$results = Invoke-Command -ComputerName $computers -ScriptBlock {
    Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        $percentFree = ($_.FreeSpace / $_.Size) * 100
        [PSCustomObject]@{
            Computer    = $env:COMPUTERNAME
            Drive       = $_.DeviceID
            PercentFree = [math]::Round($percentFree, 2)
            FreeGB      = [math]::Round($_.FreeSpace / 1GB, 2)
            TotalGB     = [math]::Round($_.Size / 1GB, 2)
        }
    }
}

# Show all results
$results | Format-Table -AutoSize

# Show only drives with less than 20% free
$lowSpace = $results | Where-Object { $_.PercentFree -lt 20 }
if ($lowSpace) {
    Write-Host "`nWARNING: These drives are low on space:" -ForegroundColor Red
    $lowSpace | Format-Table -AutoSize
}
else {
    Write-Host "`nAll drives have adequate free space" -ForegroundColor Green
}
