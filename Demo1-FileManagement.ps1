# ============================================================
# Demo 1: File Management Basics
# Time: 10 minutes
# ============================================================
# Learn the basics of navigating and managing files with PowerShell

# ---- NAVIGATION ----
# See where you are
Get-Location

# List files in current directory
Get-ChildItem

# List files with details (size, date, etc.)
Get-ChildItem | Format-Table Name, Length, LastWriteTime

# Show only folders
Get-ChildItem -Directory

# Show only files
Get-ChildItem -File

# List files recursively (includes subfolders)
Get-ChildItem -Recurse

# ---- CREATING AND MANIPULATING FILES ----
# Create a new folder
New-Item -ItemType Directory -Path "C:\Temp\PowerShellDemo"

# Create a new text file
New-Item -ItemType File -Path "C:\Temp\PowerShellDemo\test.txt"

# Write content to a file
"Hello, PowerShell!" | Out-File "C:\Temp\PowerShellDemo\test.txt"

# Read content from a file
Get-Content "C:\Temp\PowerShellDemo\test.txt"

# Append more content
"This is line 2" | Add-Content "C:\Temp\PowerShellDemo\test.txt"
Get-Content "C:\Temp\PowerShellDemo\test.txt"

# ---- COPYING AND MOVING ----
# Copy a file
Copy-Item "C:\Temp\PowerShellDemo\test.txt" "C:\Temp\PowerShellDemo\test-backup.txt"

# Verify the copy
Get-ChildItem "C:\Temp\PowerShellDemo"

# Move/Rename a file
Move-Item "C:\Temp\PowerShellDemo\test-backup.txt" "C:\Temp\PowerShellDemo\backup.txt"
Get-ChildItem "C:\Temp\PowerShellDemo"

# ---- DELETING ----
# Delete a file
Remove-Item "C:\Temp\PowerShellDemo\backup.txt"

# Clean up - remove the demo folder and everything in it
Remove-Item "C:\Temp\PowerShellDemo" -Recurse -Force

# ============================================================
# TRY IT YOURSELF
# ============================================================
# 1. Create a folder called "MyScripts" in C:\Temp
# 2. Create 3 text files in that folder
# 3. List all the files
# 4. Copy one file to a backup
# 5. Clean up when done
# ============================================================
