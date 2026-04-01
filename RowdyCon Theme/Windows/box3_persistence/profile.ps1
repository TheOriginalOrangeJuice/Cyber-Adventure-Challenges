# Restrict Linux-style commands and keep PATH minimal to PowerShell-safe binaries.
$env:PATH = "/opt/microsoft/powershell/7:/usr/local/bin"
[Environment]::SetEnvironmentVariable("PATH", $env:PATH, "Process")

$blocked = @('ls','cat','grep','find','awk','sed','curl','wget','less','more','nano','vi','vim','bash','sh','head','tail')
function Invoke-LinuxBlocked {
    Write-Error "Linux utilities are disabled in this environment. Use PowerShell equivalents."
}
foreach ($name in $blocked) {
    if (Get-Alias -Name $name -ErrorAction SilentlyContinue) {
        Remove-Item "Alias:$name" -ErrorAction SilentlyContinue
    }
    Set-Alias -Name $name -Value Invoke-LinuxBlocked -Option AllScope -ErrorAction SilentlyContinue
}

# Simulated scheduled tasks to mirror Windows behavior on this container.
$global:RccTasks = @(
    [pscustomobject]@{
        TaskName    = "wipe_exfil"
        Description = "Deletes anything placed in Exfiltrate every minute."
        Enabled     = -not (Test-Path "/opt/task_flags/wipe_exfil.disabled")
        Action      = "/usr/local/bin/wipe_exfil.sh"
    },
    [pscustomobject]@{
        TaskName    = "watch_exfil"
        Description = "Watches for the payload drop and broadcasts the flag."
        Enabled     = $true
        Action      = "/usr/local/bin/watch_exfil.sh"
    }
)

function Get-ScheduledTask {
    param([string]$TaskName)
    $tasks = $global:RccTasks
    if ($TaskName) {
        $tasks = $tasks | Where-Object { $_.TaskName -like $TaskName }
    }
    $tasks | Select-Object TaskName, Description, Enabled
}

function Disable-ScheduledTask {
    param([Parameter(Mandatory)] [string]$TaskName)
    if ($TaskName -eq "wipe_exfil") {
        New-Item -ItemType File -Path "/opt/task_flags/wipe_exfil.disabled" -Force | Out-Null
        $global:RccTasks = $global:RccTasks | ForEach-Object {
            if ($_.TaskName -eq $TaskName) { $_.Enabled = $false }
            $_
        }
        Write-Host "Task '$TaskName' disabled. Wiper halted." -ForegroundColor Yellow
    } else {
        Write-Warning "Task '$TaskName' cannot be disabled here."
    }
}

function Unregister-ScheduledTask {
    param([Parameter(Mandatory)] [string]$TaskName, [switch]$Confirm)
    if ($TaskName -eq "wipe_exfil") {
        New-Item -ItemType File -Path "/opt/task_flags/wipe_exfil.removed" -Force | Out-Null
        $global:RccTasks = $global:RccTasks | Where-Object { $_.TaskName -ne $TaskName }
        Write-Host "Task '$TaskName' unregistered." -ForegroundColor Yellow
    } else {
        Write-Warning "Task '$TaskName' cannot be unregistered here."
    }
}
