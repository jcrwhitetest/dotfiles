# dotfiles

Personal terminal / editor setup, themed around **One Dark Pro**, managed with
[chezmoi](https://www.chezmoi.io) so the same source tree applies cleanly on both
Windows (my PC) and Linux (the Proxmox VMs), with per-OS path differences handled
by templating rather than a flat copy.

## What's in here

| Source path | Applies on | Target | Purpose |
|---|---|---|---|
| `Documents/PowerShell/Microsoft.PowerShell_profile.ps1` | Windows | `~/Documents/PowerShell/…` | pwsh profile: Oh My Posh, PSReadLine, Terminal-Icons, zoxide, PSFzf, eza/bat/procs wrappers |
| `Documents/PowerShell/OneDarkPro.omp.json` | Windows | `~/Documents/PowerShell/OneDarkPro.omp.json` | Oh My Posh theme |
| `dot_config/oh-my-posh/OneDarkPro.omp.json` | Linux | `~/.config/oh-my-posh/OneDarkPro.omp.json` | Same theme, Linux location |
| `dot_config/oh-my-posh/init.sh` | Linux | `~/.config/oh-my-posh/init.sh` | bash/zsh prompt + tool init (source it from your rc) |
| `dot_tmux.conf` | Linux | `~/.tmux.conf` | tmux defaults + One Dark Pro status bar |
| `vscode/settings.json` | — | (not applied) | Reference subset of the VS Code One Dark Pro settings |
| `terminal-customization-summary.md` | — | (not applied) | Personal planning notes / rationale |
| `.chezmoiignore` | — | — | Per-OS gating (it's a template) |

> **Theme sync note:** the Oh My Posh theme is kept as two identical literal copies
> (Windows and Linux paths). It can't be a chezmoi template because the JSON is full
> of Oh My Posh's own `{{ ... }}` syntax, which chezmoi would try to evaluate. If you
> edit the theme, update both copies (they are byte-identical today).

## Tools this setup expects

Installed on Windows via winget; install the equivalents on Linux later.

`oh-my-posh`, `zoxide`, `fzf` (+ PSFzf module on Windows), `eza`, `bat`,
`ripgrep` (`rg`), `fd`, `dust`, `procs`. Font: **CaskaydiaCove Nerd Font Mono**.

## Applying

chezmoi's source directory is set to this repo in `~/.config/chezmoi/chezmoi.toml`
(`sourceDir`). Preview and apply with:

```sh
chezmoi diff          # show what would change
chezmoi apply -v      # apply to the current machine
```

### Windows
Already the machine of origin — `chezmoi diff` should be empty. Nothing to do
beyond keeping the repo and the live files in sync via `chezmoi apply` / `chezmoi re-add`.

### Linux (Proxmox VMs) — not yet applied
1. Install chezmoi and the CLI tools listed above.
2. `chezmoi init --apply <this-repo-url>` (or point `sourceDir` at a local clone).
3. Add this line to `~/.bashrc` and/or `~/.zshrc`:
   ```sh
   [ -f "$HOME/.config/oh-my-posh/init.sh" ] && . "$HOME/.config/oh-my-posh/init.sh"
   ```
4. `tmux.conf` applies to `~/.tmux.conf`. If a VM already has one, review the diff
   first — the prefix is remapped to **Ctrl-a**.

## Notes / decisions
- Native `ls`, `cat`, `dir`, `gci`, `Get-Content`, `ps` are left untouched. The
  modern tools are exposed under new names (`e`/`ela`/`elt`, `batcat`, `procz`) plus
  zoxide's `z`/`zi`, so nothing that expects the built-ins breaks.
- The full Windows `settings.json` is **not** managed by chezmoi (it holds
  machine-specific paths and internal host entries); only the curated theme subset
  is captured here for reference.
