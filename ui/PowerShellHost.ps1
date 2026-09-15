param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptPath
)

# This host is used by UltimateUI.exe.  It deliberately keeps PowerShell
# non-interactive from the user's point of view: prompts are sent to the
# desktop UI through a small, line-oriented protocol and never to a console.
$InputMarker = "__ULTIMATE_INPUT__"
$PauseMarker = "__ULTIMATE_PAUSE__"

function global:Read-Host {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Prompt,
        [switch]$AsSecureString
    )

    [Console]::Out.WriteLine($InputMarker + $Prompt)
    [Console]::Out.Flush()
    $value = [Console]::In.ReadLine()
    if ($null -eq $value) {
        $value = ""
    }

    if ($AsSecureString) {
        return ConvertTo-SecureString $value -AsPlainText -Force
    }

    return $value
}

# Windows PowerShell exposes Pause as an alias in many installations. Remove
# the alias so that scripts always use the UI-aware implementation below.
Remove-Item Alias:Pause -Force -ErrorAction SilentlyContinue
function global:Pause {
    [Console]::Out.WriteLine($PauseMarker)
    [Console]::Out.Flush()
    [void][Console]::In.ReadLine()
}

$ErrorActionPreference = "Continue"

# Invoke the selected file directly. No script text is loaded, rewritten, or
# regenerated here; this wrapper only supplies the UI-backed prompt functions.
& $ScriptPath
if ($null -ne $global:LASTEXITCODE) {
    exit $global:LASTEXITCODE
}
exit 0
