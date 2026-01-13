# Demo 1: File Management Basics
# Time: 10 minutes

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
New-Item -ItemType Directory -Path "c:\scripts\codemash-2026"

# Create a new text file
New-Item -ItemType File -Path "c:\scripts\codemash-2026\temp\test.txt"

# Write content to a file
"Hello, PowerShell!" | Out-File "c:\scripts\codemash-2026\temp\test.txt"

# Read content from a file
Get-Content "c:\scripts\codemash-2026\temp\test.txt"

# Append more content
"This is line 2" | Add-Content "c:\scripts\codemash-2026\temp\test.txt"
Get-Content "c:\scripts\codemash-2026\temp\test.txt"

# ---- COPYING AND MOVING ----
# Copy a file
Copy-Item "c:\scripts\codemash-2026\temp\test.txt" "c:\scripts\codemash-2026\temp\test-backup.txt"

# Verify the copy
Get-ChildItem "c:\scripts\codemash-2026"

# Move/Rename a file
Move-Item "c:\scripts\codemash-2026\temp\test-backup.txt" "c:\scripts\codemash-2026\temp\backup.txt"
Get-ChildItem "c:\scripts\codemash-2026"

# ---- DELETING ----
# Delete a file
Remove-Item "c:\scripts\codemash-2026\temp\backup.txt"

# Clean up - remove the demo folder and everything in it
Remove-Item "c:\scripts\codemash-2026" -Recurse -Force

# ============================================================
# TRY IT YOURSELF
# ============================================================
# 1. Create a folder called "MyScripts" in C:\Temp
# 2. Create 3 text files in that folder
# 3. List all the files
# 4. Copy one file to a backup
# 5. Clean up when done
# ============================================================
