# Terminal & Editor Customization — Summary

Personal reference for what's been set up, what's planned, and why. Covers Windows PC (primary) with a path to Proxmox VMs later.

## Already done (Windows PC)

- **PowerShell 7+ (pwsh)** installed via `winget install Microsoft.PowerShell`, set as default profile in Windows Terminal
- **Oh My Posh** installed via `winget install JanDeDobbeleer.OhMyPosh` — cross-platform prompt engine, same binary/config works on Linux later
- **Custom "One Dark Pro" Oh My Posh theme** (`OneDarkPro.omp.json`) — built from the real Atom One Dark Pro palette since no official Oh My Posh theme matched it. Lives in the pwsh profile folder (`Split-Path $PROFILE`, the `Documents\PowerShell` folder — NOT `WindowsPowerShell`, which is 5.1's separate path)
- **PowerShell profile script** (`Microsoft.PowerShell_profile.ps1`) — wires up Oh My Posh, PSReadLine, Terminal-Icons, and a few QoL aliases (`ll`, `..`, `...`, `touch`, `which`)
- **PSReadLine** — predictive IntelliSense (history-based), One Dark Pro-matched syntax colors, custom keybindings (Tab menu-complete, history search on arrows, Ctrl+word-jump)
- **Terminal-Icons** module — file-type icons in `Get-ChildItem`/`ls` output
- **Nerd Font** (CaskaydiaCove Nerd Font Mono) installed and set in Windows Terminal → Profiles → PowerShell → Appearance
- **Windows Terminal color scheme** — "One Dark Pro" JSON added to `settings.json` `schemes` array, applied to the PowerShell profile
- **Execution policy** set to `RemoteSigned` at CurrentUser scope (`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`) — needed to let the local profile script load; downloaded files also needed `Unblock-File` to clear the internet zone flag

## Planned / discussed, not yet done

### Shell productivity (cross-platform — same tools work on Windows via winget and Linux via apt/brew)
- **zoxide** — smarter `cd`, jumps to frequent directories by partial name
- **PSFzf** + **fzf** — fuzzy search over command history (Ctrl+R) and files
- **eza** — modern `ls` replacement (icons, git status, tree view)
- **bat** — modern `cat` replacement (syntax highlighting, git gutter markers)
- **ripgrep (`rg`)** — faster `grep`, respects `.gitignore`
- **fd** — simpler/faster `find`
- **dust** — visual `du` (disk usage tree)
- **procs** — nicer `ps`

### Cross-machine / homelab
- **atuin** — cross-shell history sync (searchable SQLite DB, optional encrypted sync across machines)
- **SSH config shortcuts** (`~/.ssh/config` or `C:\Users\tweak\.ssh\config`) — named hosts instead of typing IPs, e.g. `Host proxmox`
- **tmux** (or **zellij**) — install on Proxmox host and any VM SSH'd into regularly. Runs on the *remote* machine, so sessions survive local disconnects/sleep/Wi-Fi drops — genuinely valuable given the Proxmox/Docker/Home Assistant/agent-VM pattern. Not needed locally on Windows (nothing to protect against when you're not disconnecting from yourself).
- **Dotfiles repo** — git repo holding the Oh My Posh theme, PowerShell profile, `.bashrc`/`.zshrc`, VS Code settings. **chezmoi** recommended for handling Windows-vs-Linux path/config differences from one source of truth, so edits happen once and propagate everywhere.

### Terminal emulator (optional, lower priority)
- **Windows Terminal** — current choice, fine as-is since the primary pattern is "sit at Windows, SSH into Linux" rather than sitting at a Linux GUI locally
- **WezTerm** — cross-platform (Windows + Linux), config-as-code (Lua), worth revisiting only if: (a) a Linux desktop machine enters the picture and gets used locally, or (b) Windows Terminal's lack of scripting/conditional config becomes an actual annoyance rather than a theoretical one

### VS Code integration
- **PowerShell extension** (Microsoft) — IntelliSense/debugging/PSScriptAnalyzer for `.ps1` files
- **One Dark Pro** extension (binaryify) — the real deal, matches the terminal palette
- `settings.json` additions:
  ```json
  "terminal.integrated.fontFamily": "CaskaydiaCove Nerd Font Mono",
  "editor.fontFamily": "CaskaydiaCove Nerd Font Mono",
  "editor.fontLigatures": true,
  "terminal.integrated.gpuAcceleration": "on",
  "terminal.integrated.defaultProfile.windows": "PowerShell"
  ```
- Note: VS Code's integrated terminal auto-inherits everything at the shell layer (Oh My Posh, PSReadLine, aliases) with zero extra config — only font/GPU/theme settings are VS Code-specific

### Linux desktop — considered, not currently justified
Discussed as a "someday" rather than a "should do now." Strongest case if it happens: pulling local LLM/Ollama serving off the Windows RTX 5080 onto its own box, plus easier direct USB access for split-keyboard firmware flashing, 3D printing, and Pebble watchface work. Proxmox VMs already cover anything headless/service-like (the OpenClaw agent VM, Docker, Home Assistant) — a physical desktop only adds value for GPU isolation or hands-on hardware work, not for general homelab SSH tasks.

## Rollout order
1. Finish shell tools + VS Code settings on the Windows PC (current focus)
2. Stand up the dotfiles git repo from the working Windows config
3. Apply the same dotfiles (via chezmoi or manual copy) to the Proxmox VMs/host as needed — tmux becomes relevant here first
4. Revisit WezTerm / a Linux desktop only if a concrete need shows up
