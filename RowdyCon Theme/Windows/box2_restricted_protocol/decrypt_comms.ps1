$ErrorActionPreference = "Stop"

$policy = ($env:EXEC_POLICY ?? "Restricted")
$policyNormalized = $policy.ToUpperInvariant()
$allowed = @("BYPASS","UNRESTRICTED")

if ($allowed -notcontains $policyNormalized) {
    Write-Error 'File ".\\decrypt_comms.ps1" cannot be loaded because running scripts is disabled on this system.'
    exit 1
}

# Enforce piping so output isn't trivially copy/pasted.
if ($MyInvocation.PipelineLength -le 1) {
       Write-Error "Encoded Message: 82, 67, 67.... For security reasons, you must decode the message in one-go. I'm sure you know how to convert ASCII numbers into text with PowerShell... you're paid quite well to know that."
    exit 1
}

$helper = "/usr/local/bin/get_payload"
if (-not (Test-Path $helper)) {
    Write-Error ""
    exit 1
}

$bytes = & $helper
$bytes
