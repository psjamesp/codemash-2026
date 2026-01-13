# Demo 3: Service Management

# ---- VIEWING SERVICES ----
# Get all services
Get-Service

# Get services sorted by status
Get-Service | Sort-Object Status

# Find services by name pattern
Get-Service -Name "*win*"

# Get detailed information about a specific service
Get-Service -Name "WinRM" | Format-List *

# ---- CHECKING SERVICE STATUS ----
# Check if a service is running
$service = Get-Service -Name "WinRM"
if ($service.Status -eq "Running") {
    Write-Host "WinRM service is running" -ForegroundColor Green
}
else {
    Write-Host "WinRM service is not running" -ForegroundColor Red
}

# ---- MANAGING SERVICES (REQUIRES ADMIN) ----
# Note: Open PowerShell as Administrator to run these commands

# Start a service
# Start-Service -Name "ServiceName"

# Stop a service
# Stop-Service -Name "ServiceName"

# Restart a service
# Restart-Service -Name "ServiceName"

# ---- FILTERING AND REPORTING ----
# Find all stopped services
Get-Service | Where-Object { $_.Status -eq "Stopped" } | Select-Object Name, DisplayName

# Find all automatic services that are stopped (potential issues)
Get-WmiObject Win32_Service | 
Where-Object { $_.StartMode -eq "Auto" -and $_.State -ne "Running" } |
Select-Object Name, DisplayName, State, StartMode

# Count services by status
Get-Service | Group-Object Status | Select-Object Count, Name

# ---- EXPORTING SERVICE INFO ----
# Export running services to a CSV file
Get-Service | Where-Object { $_.Status -eq "Running" } | 
Select-Object Name, DisplayName, Status |
Export-Csv "C:\Temp\RunningServices.csv" -NoTypeInformation

Write-Host "Service list exported to C:\Temp\RunningServices.csv" -ForegroundColor Green

# View the CSV
Import-Csv "C:\Temp\RunningServices.csv" | Select-Object -First 5

# Clean up
Remove-Item "C:\Temp\RunningServices.csv" -Force

# ============================================================
# TRY IT YOURSELF
# ============================================================
# 1. Find all services that have "Network" in their name
# 2. Check if the "Windows Time" service is running
# 3. Export all stopped services to a CSV file
# 4. Count how many services are running vs stopped
# ============================================================
