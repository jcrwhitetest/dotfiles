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
| `dot_local/bin/executable_dotfiles-install-tools` | Linux | `~/.local/bin/dotfiles-install-tools` | No-sudo installer for eza / dust / procs / atuin (static GitHub release binaries) |
| `vscode/settings.json` | — | (not applied) | Reference subset of the VS Code One Dark Pro settings |
| `terminal-customization-summary.md` | — | (not applied) | Personal planning notes / rationale |
| `.chezmoiignore` | — | — | Per-OS gating (it's a template) |

> **Theme sync note:** the Oh My Posh theme is kept as two identical literal copies
> (Windows and Linux paths). It can't be a chezmoi template because the JSON is full
> of Oh My Posh's own `{{ ... }}` syntax, which chezmoi would try to evaluate. If you
> edit the theme, update both copies (they are byte-identical today).

## Tools this setup expects

`oh-my-posh`, `zoxide`, `fzf` (+ PSFzf module on Windows), `eza`, `bat`,
`ripgrep` (`rg`), `fd`, `dust`, `procs`, `atuin`. Font: **CaskaydiaCove Nerd Font Mono**.

Installed on Windows via winget. On Linux, install what the distro packages
(`zoxide`, `fzf`, `bat`, `ripgrep`, `fd-find`, `tmux`) with apt, then run
`dotfiles-install-tools` for the rest — it pulls static release binaries into
`~/.local/bin`, so it works on boxes with no (passwordless) sudo:

```sh
dotfiles-install-tools           # install whatever is missing
dotfiles-install-tools --force   # reinstall / upgrade to the latest release
dotfiles-install-tools eza atuin # just these
```

Everything degrades gracefully: `init.sh` feature-detects each tool, so a box
missing one simply doesn't get its aliases.

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

### Linux (Proxmox VMs)
New VM, once:
1. Install `oh-my-posh` and `chezmoi` into `~/.local/bin`, plus the apt-packaged
   tools listed above.
2. `chezmoi init --apply https://github.com/jcrwhitetest/dotfiles.git`
   (the repo is public, so VMs pull anonymously — no key needed).
3. Add this line to `~/.bashrc` and/or `~/.zshrc`:
   ```sh
   [ -f "$HOME/.config/oh-my-posh/init.sh" ] && . "$HOME/.config/oh-my-posh/init.sh"
   ```
4. `dotfiles-install-tools` for eza / dust / procs / atuin.
5. Join the machine to atuin sync (see below) if you want shared history.
6. `tmux.conf` applies to `~/.tmux.conf`. If a VM already has one, review the diff
   first — the prefix is remapped to **Ctrl-a**.

Afterwards the loop is: edit the repo on Windows → `git push` → `chezmoi update`
on each VM (pulls and applies in one step).

## Shell history sync (atuin)

History syncs through the hosted server at `api.atuin.sh` under the account
`tweak`. Defaults are all correct, so nothing about sync is configured in this
repo — `auto_sync` is on with a 5-minute interval out of the box.

The thing to understand: atuin encrypts history **client-side**, so the server
only ever holds ciphertext. The encryption key is generated locally and is
*not* tied to the account — an account password alone decrypts nothing. Every
machine must end up with the **same key file**, or it will sync happily and be
unable to read a thing.

Adding a machine:

```sh
# 1. from a machine that is already synced, copy the key across directly
scp ~/.local/share/atuin/key <newbox>:.local/share/atuin/key
ssh <newbox> chmod 600 .local/share/atuin/key

# 2. on the new machine — leave the key prompt BLANK to use the file above
ssh -t <newbox> "~/.local/bin/atuin login -u tweak"
atuin sync
```

If the machine has run atuin before, wipe `~/.local/share/atuin/{key,session,*.db*}`
*before* logging in. It will have generated its own unrelated key, and atuin
cannot re-encrypt existing records under a replacement key — you get a
half-readable store that is far more annoying than the lost local history.

Never open the key file in an editor while a Claude Code session is attached to
the IDE: the integration forwards your current editor selection as context, and
the key will end up in the transcript. Read it with `atuin key` in a terminal.
Losing the key means the synced history is permanently unreadable — there is no
reset, since the server has never seen it.

## Notes / decisions
- Native `ls`, `cat`, `dir`, `gci`, `Get-Content`, `ps` are left untouched. The
  modern tools are exposed under new names (`e`/`ela`/`elt`, `batcat`, `procz`) plus
  zoxide's `z`/`zi`, so nothing that expects the built-ins breaks.
- `Ctrl+r` belongs to **atuin** on both platforms (up-arrow deliberately left to
  PSReadLine / bash). On Linux `init.sh` loads fzf's key bindings first — giving
  `Ctrl+t` and `Alt+c` — then atuin, so atuin wins `Ctrl+r`. atuin's bash
  integration needs `bash-preexec`, which `dotfiles-install-tools` also fetches.
- The full Windows `settings.json` is **not** managed by chezmoi (it holds
  machine-specific paths and internal host entries); only the curated theme subset
  is captured here for reference.
