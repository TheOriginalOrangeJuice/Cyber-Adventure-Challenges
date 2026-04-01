# Restrict Linux-style commands and keep PATH minimal to PowerShell-only locations.
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
