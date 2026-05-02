# codex-terminal-state

A tiny Windows helper for Codex CLI.

It changes your terminal so you can tell what Codex is doing at a glance:

- Ready: blue terminal, `CODEX READY - BLUE`
- Working: black terminal, `CODEX WORKING - BLACK`

## Install

On Windows, open PowerShell, paste this whole line, and press Enter:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path .\codex-terminal-state) { cd .\codex-terminal-state; git pull } else { git clone https://github.com/Jasraj-Jassar/codex-terminal-state.git codex-terminal-state; cd .\codex-terminal-state }; powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1; codex"
```

That downloads or updates it, installs it, then starts Codex.

## What It Changes

`codex-terminal-state` installs a Codex hook script and updates your Codex config so hooks can run.

It backs up existing files before replacing them:

- `%USERPROFILE%\.codex\hooks.json`
- `%USERPROFILE%\.codex\hooks\codex_terminal_state.ps1`
- `%USERPROFILE%\.codex\config.toml`

Hook logs go here:

```text
%USERPROFILE%\.codex\hooks\codex_terminal_state.log
```

## Files

- `install.ps1`: installs the helper
- `hooks.json`: tells Codex when to switch terminal state
- `hooks\codex_terminal_state.ps1`: changes the terminal colors and title
