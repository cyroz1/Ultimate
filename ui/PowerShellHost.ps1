param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptPath,
    [string]$Architecture = ""
)

if (-not [string]::IsNullOrWhiteSpace($Architecture)) {
    if ($Architecture -notin @("x64", "arm64")) {
        throw "Unsupported toolkit architecture: $Architecture"
    }
    $env:ULTIMATE_TOOLKIT_ARCHITECTURE = $Architecture
}

. (Join-Path $PSScriptRoot 'UltimateArchitecture.ps1')

# This host is used by UltimateUI.exe.  It deliberately keeps PowerShell
# non-interactive from the user's point of view: prompts and file-picker
# requests are sent to the desktop UI through a small, line-oriented protocol
# and never to a console.
$InputMarker = "__ULTIMATE_INPUT__"
$PauseMarker = "__ULTIMATE_PAUSE__"
$FilePickerMarker = "__ULTIMATE_FILE_PICKER__"

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

# File dialogs created by a hidden PowerShell process can be ownerless or open
# behind the visible launcher. Route the OpenFileDialog used by the original
# scripts through the launcher while preserving its Filter, ShowDialog(), and
# FileName contract. All other New-Object calls go to the real cmdlet.
function global:New-Object {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$TypeName,
        [Parameter(Position = 1)]
        [object[]]$ArgumentList,
        [string]$ComObject,
        [System.Collections.IDictionary]$Property,
        [switch]$Strict
    )

    if ($PSBoundParameters.ContainsKey("TypeName") -and
        $TypeName -eq "System.Windows.Forms.OpenFileDialog" -and
        -not $PSBoundParameters.ContainsKey("ComObject")) {
        $dialog = [pscustomobject]@{
            Filter = "All Files (*.*)|*.*"
            FileName = ""
        }
        $dialog | Add-Member -MemberType ScriptMethod -Name ShowDialog -Value {
            $filter = [string]$this.Filter
            if ([string]::IsNullOrWhiteSpace($filter)) {
                $filter = "All Files (*.*)|*.*"
            }

            [Console]::Out.WriteLine($global:FilePickerMarker + $filter)
            [Console]::Out.Flush()
            $selected = [Console]::In.ReadLine()
            if ($null -eq $selected) {
                $selected = ""
            }
            $this.FileName = $selected

            if ([string]::IsNullOrWhiteSpace($selected)) {
                return [System.Windows.Forms.DialogResult]::Cancel
            }
            return [System.Windows.Forms.DialogResult]::OK
        } -Force
        return $dialog
    }

    Microsoft.PowerShell.Utility\New-Object @PSBoundParameters
}

$ErrorActionPreference = "Continue"

# Invoke the selected file directly. No script text is loaded, rewritten, or
# regenerated here; this wrapper only supplies the UI-backed prompt functions.
& $ScriptPath
if ($null -ne $global:LASTEXITCODE) {
    exit $global:LASTEXITCODE
}
exit 0
