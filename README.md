# codex-terminal-state

A tiny Codex CLI helper for Windows and Arch Linux.

It changes your terminal so you can tell what Codex is doing at a glance:

- Ready: blue terminal, `CODEX READY - BLUE`
- Working: black terminal, `CODEX WORKING - BLACK`

## Install

### Windows

Open PowerShell, paste this whole line, and press Enter:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path .\codex-terminal-state) { cd .\codex-terminal-state; git pull } else { git clone https://github.com/Jasraj-Jassar/codex-terminal-state.git codex-terminal-state; cd .\codex-terminal-state }; powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1; codex"
```

### Arch Linux

Open a terminal, paste this whole line, and press Enter:

```bash
if [ -d ./codex-terminal-state ]; then cd ./codex-terminal-state && git pull; else git clone https://github.com/Jasraj-Jassar/codex-terminal-state.git codex-terminal-state && cd ./codex-terminal-state; fi && chmod +x ./install.sh ./hooks/codex_terminal_state.sh && ./install.sh && codex
```

That downloads or updates the repo, installs the hook for your OS, then starts Codex.

## Arch Notes

These instructions are for Arch and Arch-based systems that run Codex inside a normal ANSI-capable terminal such as Kitty, Alacritty, GNOME Terminal, Konsole, WezTerm, or similar.

The Linux hook writes terminal color and title changes through `/dev/tty`, so it expects Codex to be attached to a real terminal session.

## What It Changes

`codex-terminal-state` installs a Codex hook script and updates your Codex config so hooks can run.

### Windows files

Backups are created before replacing these files:

- `%USERPROFILE%\.codex\hooks.json`
- `%USERPROFILE%\.codex\hooks\codex_terminal_state.ps1`
- `%USERPROFILE%\.codex\config.toml`

Hook logs go here:

```text
%USERPROFILE%\.codex\hooks\codex_terminal_state.log
```

### Arch files

Backups are created before replacing these files:

- `~/.codex/hooks.json`
- `~/.codex/hooks/codex_terminal_state.sh`
- `~/.codex/config.toml`

Hook logs go here:

```text
~/.codex/hooks/codex_terminal_state.log
```

## Files

- `install.ps1`: Windows installer
- `install.sh`: Arch/Linux installer
- `hooks.json`: Windows hook configuration
- `hooks.arch.json`: Arch/Linux hook configuration
- `hooks/codex_terminal_state.ps1`: Windows terminal hook
- `hooks/codex_terminal_state.sh`: Arch/Linux terminal hook
