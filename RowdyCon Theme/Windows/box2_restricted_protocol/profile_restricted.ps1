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

# Default execution policy is Restricted for this challenge.
if (-not $env:EXEC_POLICY) {
    $env:EXEC_POLICY = "Restricted"
}

# Simulated execution policy control for this Linux host.
function Set-ExecutionPolicy {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ExecutionPolicy,
        [string]$Scope = "Process"
    )

    if ($Scope -notin @("Process", "CurrentUser", "System")) {
        Write-Error "Operation is not supported on this platform."
        return
    }

    $allowed = @("Restricted","AllSigned","RemoteSigned","Unrestricted","Bypass","Undefined")
    $normalized = $ExecutionPolicy
    if (-not ($allowed -contains $normalized)) {
        Write-Error "ExecutionPolicy '$ExecutionPolicy' is not supported. Allowed: $($allowed -join ', ')."
        return
    }

    $env:EXEC_POLICY = $ExecutionPolicy
    Write-Host "Execution policy for $Scope set to $ExecutionPolicy" -ForegroundColor Yellow
}

function Get-ExecutionPolicy {
    param(
        [string]$Scope
    )
    return ($env:EXEC_POLICY ?? "Restricted")
}
