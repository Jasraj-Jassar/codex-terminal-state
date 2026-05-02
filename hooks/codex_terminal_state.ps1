param(
    [ValidateSet("start-ready", "ready", "busy")]
    [string]$State = "ready"
)

$logPath = Join-Path $PSScriptRoot "codex_terminal_state.log"
function Write-HookLog {
    param([string]$Message)
    try {
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
        Add-Content -LiteralPath $logPath -Value "$timestamp [$State] $Message" -Encoding UTF8
    }
    catch {
        # Do not let logging break Codex hooks.
    }
}

$esc = [char]27
$bel = [char]7

if (-not ("CodexTerminalState.NativeConsole" -as [type])) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

namespace CodexTerminalState {
    public static class NativeConsole {
        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern SafeFileHandle CreateFile(
            string fileName,
            uint desiredAccess,
            uint shareMode,
            IntPtr securityAttributes,
            uint creationDisposition,
            uint flagsAndAttributes,
            IntPtr templateFile);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool GetConsoleMode(SafeFileHandle handle, out uint mode);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool SetConsoleMode(SafeFileHandle handle, uint mode);
    }
}
"@
}

if ($State -eq "start-ready") {
    $foreground = "White"
    $background = "DarkBlue"
    $title = "CODEX READY - BLUE"
    $sequence = "$esc]4;0;#002B7F$bel$esc]11;#002B7F$bel$esc]12;#FFFFFF$bel$esc]0;$title$bel$esc]2;$title$bel"
    $sequence += "$esc[97;44m"
} elseif ($State -eq "ready") {
    $foreground = "White"
    $background = "DarkBlue"
    $title = "CODEX READY - BLUE"
    $sequence = "$esc]4;0;#002B7F$bel$esc]11;#002B7F$bel$esc]12;#FFFFFF$bel$esc]0;$title$bel$esc]2;$title$bel"
    $sequence += "$esc[97;44m"
} else {
    $foreground = "White"
    $background = "Black"
    $title = "CODEX WORKING - BLACK"
    $sequence = "$esc]4;0;#000000$bel$esc]11;#000000$bel$esc]12;#FFFFFF$bel$esc]0;$title$bel$esc]2;$title$bel"
    $sequence += "$esc[97;40m"
}

try {
    Write-HookLog "started"

    [Console]::ForegroundColor = $foreground
    [Console]::BackgroundColor = $background
    $Host.UI.RawUI.ForegroundColor = $foreground
    $Host.UI.RawUI.BackgroundColor = $background
    [Console]::Title = $title
    Write-HookLog "set Console/RawUI colors to fg=$foreground bg=$background title=$title"

    $genericWrite = 0x40000000
    $fileShareRead = 0x00000001
    $fileShareWrite = 0x00000002
    $openExisting = 3
    $handle = [CodexTerminalState.NativeConsole]::CreateFile(
        "CONOUT$",
        $genericWrite,
        ($fileShareRead -bor $fileShareWrite),
        [IntPtr]::Zero,
        $openExisting,
        0,
        [IntPtr]::Zero
    )
    if ($handle.IsInvalid) {
        throw [System.ComponentModel.Win32Exception]::new([Runtime.InteropServices.Marshal]::GetLastWin32Error())
    }

    $mode = 0
    if ([CodexTerminalState.NativeConsole]::GetConsoleMode($handle, [ref]$mode)) {
        $enableVirtualTerminalProcessing = 0x0004
        [void][CodexTerminalState.NativeConsole]::SetConsoleMode($handle, ($mode -bor $enableVirtualTerminalProcessing))
    }

    $stream = [System.IO.FileStream]::new($handle, [System.IO.FileAccess]::Write)
    try {
        $writer = [System.IO.StreamWriter]::new($stream, [System.Text.Encoding]::ASCII)
        $writer.Write($sequence)
        $writer.Flush()
        Write-HookLog "wrote ANSI/OSC sequence to CONOUT$"
    }
    finally {
        if ($writer) { $writer.Dispose() }
        $stream.Dispose()
    }
}
catch {
    Write-HookLog "failed: $($_.Exception.GetType().FullName): $($_.Exception.Message)"
}

Write-Output '{"continue":true}'
