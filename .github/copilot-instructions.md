# Copilot Instructions for codemash-2026

This repository contains PowerShell training materials for the "Stop Clicking, Start Scripting" workshop—a 4-hour beginner-friendly course on practical PowerShell automation for IT professionals.

## Project Architecture

**Core Structure:**
- **Demo Scripts** (`Demo1-5.ps1`): Five progressive, hands-on demonstrations building from file management to automation
- **Instructor Guide** (`MASTER-INSTRUCTOR-GUIDE.ps1`): Complete teaching script with timing (4 hours total), talking points, and demo sequencing
- **README.md**: Workshop overview, schedule, tips, and resources

**Design Philosophy:**
These are *teaching demos*, not production code. Each script:
1. Includes detailed comments explaining every concept
2. Shows commands progressively (simple → complex filtering)
3. Uses real-world scenarios (health checks, service monitoring)
4. Includes error handling patterns relevant to IT professionals
5. Avoids advanced PowerShell features—focuses on immediately applicable skills

## Key Patterns & Conventions

### 1. **Script Structure**
Every demo follows this template:
```powershell
# ============================================================
# Demo N: [Topic]
# Time: [duration]
# ============================================================
# [Educational context]

# ---- [SECTION HEADER] ----
# Comments explaining the "why"
[commands]
```

Use this structure for any new demo additions.

### 2. **Teaching-First Commands**
When adding examples:
- **Avoid:** Complex one-liners or advanced syntax
- **Use:** `Get-*` before `Where-Object` before `Select-Object`—show the pipeline progression
- **Explain:** Why we use `Format-Table` vs `Select-Object` (visual formatting vs data filtering)
- **Example from codebase:** [Demo2-SystemInfo.ps1](Demo2-SystemInfo.ps1#L15-L17) progressively filters services

### 3. **Error Handling for IT Pros**
Use `-ErrorAction SilentlyContinue` for graceful degradation when querying optional services/remotes:
```powershell
Get-Service -Name "Dhcp" -ErrorAction SilentlyContinue
Invoke-Command -ComputerName "Server01" -ScriptBlock {...}
```
See [Demo4-RemoteManagement.ps1](Demo4-RemoteManagement.ps1#L25) and [Demo5-Automation.ps1](Demo5-Automation.ps1#L55) for real examples.

### 4. **Real-World Reporting**
Demo 5 showcases the capstone pattern—gathering multiple data sources into a single report:
- Disk space checks with status thresholds (OK/WARNING/CRITICAL)
- Critical service validation (defined list)
- Memory and process analysis
- Event log summaries
- Output to both file and console

Reuse this pattern for any automation script examples.

### 5. **WMI vs Modern Cmdlets**
This codebase uses mixed approaches:
- **WMI** (`Get-WmiObject Win32_LogicalDisk`): Older but widely supported
- **Modern** (`Get-NetAdapter`, `Get-PSDrive`): Newer, cleaner syntax
- **Teaching Note:** Mention WMI for compatibility; show modern alternatives in comments

## Critical Workflow Patterns

### Running Scripts
- **Local execution:** Open PowerShell, navigate to repo directory, dot-source or directly execute: `.\Demo1-FileManagement.ps1`
- **Admin requirement:** Service management (Demo 3) and remote management (Demo 4) require "Run as Administrator"
- **WinRM setup:** Demo 4 requires `Enable-PSRemoting -Force` (commented out in the script—instructor enables before class)

### Testing & Validation
- **Test connectivity before remote ops:** `Test-WSMan -ComputerName` and `Test-Connection` (see [Demo4-RemoteManagement.ps1](Demo4-RemoteManagement.ps1#L18-L27))
- **Check service existence before operations:** Use `Get-Service -Name "ServiceName" -ErrorAction SilentlyContinue`
- **Validate paths exist:** Wrap file operations in conditionals or use `-Force` with confirmation

### Data Transformation Progression
When helping students or extending scripts, show this progression:
1. Raw output: `Get-Service`
2. Filter: `Where-Object {$_.Status -eq "Running"}`
3. Select columns: `Select-Object Name, Status`
4. Format: `Format-Table -AutoSize` or `Format-List`
5. Calculate derived metrics: `@{Name="MemoryMB"; Expression={[math]::Round($_.WorkingSet/1MB, 2)}}`

See [Demo2-SystemInfo.ps1](Demo2-SystemInfo.ps1#L31-L32) and [Demo5-Automation.ps1](Demo5-Automation.ps1#L19-L32) for examples.

## Integration & External Dependencies

- **PowerShell Version:** Scripts use core cmdlets compatible with PS 5.1 (Windows default) and later
- **Windows-Only:** All demos target Windows systems (WMI, services, registry, Event Log)
- **No External Modules:** Demonstrates inbox/built-in cmdlets only—great for beginners
- **Remote Admin:** Requires WinRM configured; uses `Invoke-Command` for cross-machine operations

## Conventions to Preserve

1. **Commented-out dangerous commands:** Admin operations (Start-Service, Stop-Service, Remove-Item -Recurse) are commented—instructors uncomment during class
2. **Consistent variable naming:** Use `$computers`, `$service`, `$diskInfo`, `$report` (nouns, not cryptic)
3. **Color output:** Use `Write-Host ... -ForegroundColor` for teaching feedback (progress, errors, success)
4. **Path localization:** Use `C:\Temp\PowerShellDemo` for demo paths; accommodate cross-platform in comments
5. **Timestamp formatting:** Consistent use of `Get-Date -Format 'yyyy-MM-dd HH:mm:ss'` for reports

## When Adding or Extending Content

- **New demos:** Follow the 4-hour schedule; keep each demo 10-15 minutes of teaching + practice
- **New examples:** Cite the pain point ("IT pros spend hours manually checking disk space...") before the solution
- **Advanced topics:** Add as **optional** sections marked `# ADVANCED: [topic]`—keep beginner path clear
- **Linux/Mac notes:** Comment out or note which cmdlets are Windows-specific; mention PowerShell Core alternatives if relevant

## Questions to Guide Development

- "Is this command/pattern something a busy IT pro needs in their first week using PowerShell?"
- "Can a non-programmer follow the command flow and understand why each step exists?"
- "Does this example teach a testable skill?" (Can they run it, see output, modify it, and reuse it?)
