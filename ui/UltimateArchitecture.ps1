function Get-UltimateArchitecture {
    # Prefer the operating-system architecture over the PowerShell process
    # architecture, which can differ when PowerShell is running under emulation.
    try {
        $runtimeArchitecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
        switch ($runtimeArchitecture.ToUpperInvariant()) {
            { $_ -in @('ARM64', 'AARCH64') } { return 'arm64' }
            { $_ -in @('X64', 'AMD64') } { return 'x64' }
            { $_ -in @('X86', 'I386') } { return 'x86' }
        }
    } catch { }

    try {
        $machineArchitecture = (Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name PROCESSOR_ARCHITECTURE -ErrorAction Stop).PROCESSOR_ARCHITECTURE
        switch (([string]$machineArchitecture).ToUpperInvariant()) {
            { $_ -in @('ARM64', 'AARCH64') } { return 'arm64' }
            { $_ -in @('AMD64', 'X64') } { return 'x64' }
            { $_ -in @('X86', 'I386') } { return 'x86' }
        }
    } catch { }

    foreach ($candidate in @($env:PROCESSOR_ARCHITEW6432, $env:PROCESSOR_ARCHITECTURE, $env:ULTIMATE_TOOLKIT_ARCHITECTURE)) {
        switch (([string]$candidate).ToUpperInvariant()) {
            { $_ -in @('ARM64', 'AARCH64') } { return 'arm64' }
            { $_ -in @('AMD64', 'X64') } { return 'x64' }
            { $_ -in @('X86', 'I386') } { return 'x86' }
        }
    }

    return 'unknown'
}

function Test-UltimateArm64 {
    return (Get-UltimateArchitecture) -eq 'arm64'
}

function Get-UltimateWindowsBuild {
    try {
        return [int](Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'CurrentBuildNumber' -ErrorAction Stop)
    } catch {
        return [Environment]::OSVersion.Version.Build
    }
}

function Get-Ultimate7ZipInstallerUri {
    if (Test-UltimateArm64) {
        return 'https://github.com/ip7z/7zip/releases/download/26.03/7z2603-arm64.exe'
    }

    return 'https://github.com/FR33THYFR33THY/Ultimate/releases/download/Files/7zip.exe'
}

function Get-UltimateUnattendArchitecture {
    switch ((Get-UltimateArchitecture)) {
        'arm64' { return 'arm64' }
        'x64' { return 'amd64' }
        'x86' { return 'x86' }
        default { throw 'Unable to determine the Windows architecture for the unattended setup file.' }
    }
}

function Initialize-UltimateProcessorTopologyType {
    if ('UltimateProcessorTopologyNative' -as [type]) {
        return
    }

    Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;

public static class UltimateProcessorTopologyNative
{
    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GetLogicalProcessorInformationEx(
        int relationshipType,
        IntPtr buffer,
        ref uint returnedLength);

    public static ulong[] GetCoreMasks()
    {
        uint length = 0;
        GetLogicalProcessorInformationEx(0, IntPtr.Zero, ref length);
        int error = Marshal.GetLastWin32Error();
        if (length == 0 || error != 122)
        {
            throw new Win32Exception(error, "Could not query Windows processor-core topology.");
        }

        IntPtr buffer = Marshal.AllocHGlobal(checked((int)length));
        try
        {
            if (!GetLogicalProcessorInformationEx(0, buffer, ref length))
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Could not read Windows processor-core topology.");
            }

            byte[] data = new byte[checked((int)length)];
            Marshal.Copy(buffer, data, 0, checked((int)length));
            List<ulong> masks = new List<ulong>();
            int offset = 0;

            while (offset + 8 <= data.Length)
            {
                int relationship = BitConverter.ToInt32(data, offset);
                int entrySize = BitConverter.ToInt32(data, offset + 4);
                if (entrySize < 8 || offset + entrySize > data.Length)
                {
                    throw new InvalidOperationException("Windows returned invalid processor-topology data.");
                }

                if (relationship == 0)
                {
                    if (IntPtr.Size != 8)
                    {
                        throw new PlatformNotSupportedException("Processor-affinity selection requires 64-bit PowerShell on ARM64.");
                    }

                    if (entrySize < 48)
                    {
                        throw new InvalidOperationException("Windows returned incomplete processor-core topology data.");
                    }

                    int groupCount = BitConverter.ToUInt16(data, offset + 30);
                    if (groupCount != 1)
                    {
                        throw new PlatformNotSupportedException("Processor-affinity selection currently requires each core to belong to one processor group.");
                    }

                    int group = BitConverter.ToUInt16(data, offset + 40);
                    if (group != 0)
                    {
                        throw new PlatformNotSupportedException("Processor-affinity selection currently supports processor group 0.");
                    }

                    ulong mask = BitConverter.ToUInt64(data, offset + 32);
                    if (mask == 0)
                    {
                        throw new InvalidOperationException("Windows returned an empty processor-core mask.");
                    }
                    masks.Add(mask);
                }

                offset += entrySize;
            }

            if (masks.Count == 0)
            {
                throw new InvalidOperationException("Windows did not return any processor-core masks.");
            }

            return masks.ToArray();
        }
        finally
        {
            Marshal.FreeHGlobal(buffer);
        }
    }

    public static int GetLogicalProcessorCount()
    {
        int count = 0;
        foreach (ulong coreMask in GetCoreMasks())
        {
            ulong bits = coreMask;
            while (bits != 0)
            {
                bits &= bits - 1;
                count++;
            }
        }
        return count;
    }

    public static ulong GetSingleThreadPerCoreMask()
    {
        ulong result = 0;
        foreach (ulong coreMask in GetCoreMasks())
        {
            ulong firstThread;
            unchecked { firstThread = coreMask & (~coreMask + 1UL); }
            result |= firstThread;
        }
        return result;
    }

    public static ulong GetMaskWithoutFirstCore()
    {
        ulong[] coreMasks = GetCoreMasks();
        int firstCore = -1;
        int firstProcessor = 64;

        for (int coreIndex = 0; coreIndex < coreMasks.Length; coreIndex++)
        {
            for (int processorIndex = 0; processorIndex < 64; processorIndex++)
            {
                if ((coreMasks[coreIndex] & (1UL << processorIndex)) != 0)
                {
                    if (processorIndex < firstProcessor)
                    {
                        firstProcessor = processorIndex;
                        firstCore = coreIndex;
                    }
                    break;
                }
            }
        }

        if (firstCore < 0)
        {
            throw new InvalidOperationException("Windows did not return an active processor core.");
        }

        ulong result = 0;
        for (int coreIndex = 0; coreIndex < coreMasks.Length; coreIndex++)
        {
            if (coreIndex != firstCore)
            {
                result |= coreMasks[coreIndex];
            }
        }
        if (result == 0)
        {
            throw new InvalidOperationException("Cannot exclude the first core when no other ARM64 core is available.");
        }
        return result;
    }

    public static IntPtr ToNativeMask(ulong mask)
    {
        return new IntPtr(unchecked((long)mask));
    }

    public static string FormatMaskHex(ulong mask)
    {
        return mask.ToString("X");
    }

    public static string FormatNativeMaskHex(IntPtr mask)
    {
        return unchecked((ulong)mask.ToInt64()).ToString("X");
    }
}
'@ -ErrorAction Stop | Out-Null
}

function Get-UltimateArm64ProcessorAffinityMask {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('SingleThreadPerCore', 'WithoutFirstCore')]
        [string]$Mode
    )

    if (-not (Test-UltimateArm64)) {
        throw 'ARM64 processor affinity masks can only be queried on Windows on ARM.'
    }

    Initialize-UltimateProcessorTopologyType
    switch ($Mode) {
        'SingleThreadPerCore' { return [UltimateProcessorTopologyNative]::GetSingleThreadPerCoreMask() }
        'WithoutFirstCore' { return [UltimateProcessorTopologyNative]::GetMaskWithoutFirstCore() }
    }
}

function Get-UltimateArm64LogicalProcessorCount {
    if (-not (Test-UltimateArm64)) {
        throw 'ARM64 processor topology can only be queried on Windows on ARM.'
    }

    Initialize-UltimateProcessorTopologyType
    return [UltimateProcessorTopologyNative]::GetLogicalProcessorCount()
}

function Convert-UltimateArm64ProcessorAffinityMaskToNative {
    param([Parameter(Mandatory = $true)][UInt64]$Mask)

    Initialize-UltimateProcessorTopologyType
    return [UltimateProcessorTopologyNative]::ToNativeMask($Mask)
}

function Format-UltimateArm64ProcessorAffinityMask {
    param([Parameter(Mandatory = $true)][UInt64]$Mask)

    Initialize-UltimateProcessorTopologyType
    return [UltimateProcessorTopologyNative]::FormatMaskHex($Mask)
}

function Format-UltimateArm64NativeProcessorAffinityMask {
    param([Parameter(Mandatory = $true)][IntPtr]$Mask)

    Initialize-UltimateProcessorTopologyType
    return [UltimateProcessorTopologyNative]::FormatNativeMaskHex($Mask)
}

function Stop-UltimateArm64UnsupportedKernelDriver {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Feature,
        [Parameter(Mandatory = $true)]
        [string]$Reason
    )

    if (-not (Test-UltimateArm64)) {
        return $false
    }

    Write-Host "$Feature cannot load its x64 kernel driver on ARM64." -ForegroundColor Yellow
    Write-Host $Reason -ForegroundColor Yellow
    return $true
}
