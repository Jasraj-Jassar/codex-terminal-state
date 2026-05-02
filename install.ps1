param(
    [string]$CodexHome = "$env:USERPROFILE\.codex"
)

$ErrorActionPreference = "Stop"

$sourceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceHook = Join-Path $sourceRoot "hooks\codex_terminal_state.ps1"
$sourceHooksJson = Join-Path $sourceRoot "hooks.json"

$hooksDir = Join-Path $CodexHome "hooks"
$targetHook = Join-Path $hooksDir "codex_terminal_state.ps1"
$targetHooksJson = Join-Path $CodexHome "hooks.json"
$targetConfig = Join-Path $CodexHome "config.toml"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

New-Item -ItemType Directory -Force -Path $hooksDir | Out-Null

if (Test-Path $targetHook) {
    Copy-Item -LiteralPath $targetHook -Destination "$targetHook.bak-$stamp" -Force
}
Copy-Item -LiteralPath $sourceHook -Destination $targetHook -Force

if (Test-Path $targetHooksJson) {
    Copy-Item -LiteralPath $targetHooksJson -Destination "$targetHooksJson.bak-$stamp" -Force
}
Copy-Item -LiteralPath $sourceHooksJson -Destination $targetHooksJson -Force

if (Test-Path $targetConfig) {
    Copy-Item -LiteralPath $targetConfig -Destination "$targetConfig.bak-$stamp" -Force
    $config = Get-Content -LiteralPath $targetConfig -Raw
} else {
    New-Item -ItemType File -Force -Path $targetConfig | Out-Null
    $config = ""
}

if ($config -notmatch "(?m)^\[features\]") {
    $config = $config.TrimEnd() + "`r`n`r`n[features]`r`ncodex_hooks = true`r`n"
} elseif ($config -match "(?m)^\[features\][\s\S]*?(?=^\[|\z)" -and $matches[0] -notmatch "(?m)^codex_hooks\s*=") {
    $config = $config -replace "(?m)^\[features\]\s*", "[features]`r`ncodex_hooks = true`r`n"
} else {
    $config = $config -replace "(?m)^codex_hooks\s*=.*$", "codex_hooks = true"
}

if ($config -notmatch "(?m)^\[tui\]") {
    $config = $config.TrimEnd() + "`r`n`r`n[tui]`r`nalternate_screen = `"never`"`r`nterminal_title = [`"run-state`", `"project-name`"]`r`n"
} else {
    if ($config -match "(?m)^\[tui\][\s\S]*?(?=^\[|\z)" -and $matches[0] -notmatch "(?m)^alternate_screen\s*=") {
        $config = $config -replace "(?m)^\[tui\]\s*", "[tui]`r`nalternate_screen = `"never`"`r`n"
    } else {
        $config = $config -replace "(?m)^alternate_screen\s*=.*$", "alternate_screen = `"never`""
    }

    if ($config -match "(?m)^\[tui\][\s\S]*?(?=^\[|\z)" -and $matches[0] -notmatch "(?m)^terminal_title\s*=") {
        $config = $config -replace "(?m)^\[tui\]\s*", "[tui]`r`nterminal_title = [`"run-state`", `"project-name`"]`r`n"
    } else {
        $config = $config -replace "(?m)^terminal_title\s*=.*$", "terminal_title = [`"run-state`", `"project-name`"]"
    }
}

Set-Content -LiteralPath $targetConfig -Value $config.TrimEnd() -Encoding UTF8

Write-Host "Installed Codex terminal state hooks."
Write-Host "Ready = blue, working = black. Restart Codex with: codex"
