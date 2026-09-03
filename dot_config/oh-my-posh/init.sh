#!/usr/bin/env sh
# ================================
# One Dark Pro shell init for bash / zsh  (Linux side of the dotfiles)
# ================================
# Wire this into your shell by adding ONE of these to ~/.bashrc or ~/.zshrc:
#     [ -f "$HOME/.config/oh-my-posh/init.sh" ] && . "$HOME/.config/oh-my-posh/init.sh"
# Native ls / cat are intentionally left untouched (parity with the Windows profile).

OMP_CONFIG="$HOME/.config/oh-my-posh/OneDarkPro.omp.json"

# --- Ensure user-local bins (oh-my-posh, chezmoi, atuin, ...) are on PATH ---
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH

# --- Oh My Posh prompt ---
if command -v oh-my-posh >/dev/null 2>&1; then
  if [ -n "$ZSH_VERSION" ]; then
    eval "$(oh-my-posh init zsh --config "$OMP_CONFIG")"
  elif [ -n "$BASH_VERSION" ]; then
    eval "$(oh-my-posh init bash --config "$OMP_CONFIG")"
  fi
fi

# --- zoxide: smarter directory jumping (adds `z` and `zi`; does NOT touch `cd`) ---
if command -v zoxide >/dev/null 2>&1; then
  if [ -n "$ZSH_VERSION" ]; then
    eval "$(zoxide init zsh --cmd z)"
  elif [ -n "$BASH_VERSION" ]; then
    eval "$(zoxide init bash --cmd z)"
  fi
fi

# --- fzf colors matched to One Dark Pro (same palette as the Windows profile) ---
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --info=inline \
--color=bg+:#3e4451,bg:#282c34,spinner:#56b6c2,hl:#e06c75 \
--color=fg:#abb2bf,header:#e06c75,info:#c678dd,pointer:#56b6c2 \
--color=marker:#98c379,fg+:#dcdfe4,prompt:#c678dd,hl+:#e06c75"
if command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# --- modern CLI tools (Linux parity; exposed under NEW names, natives untouched) ---
if command -v bat >/dev/null 2>&1; then
  export BAT_THEME='TwoDark'   # closest built-in bat theme to One Dark Pro
  alias batcat='bat'
elif command -v batcat >/dev/null 2>&1; then
  # Debian/Ubuntu ship bat as 'batcat'
  export BAT_THEME='TwoDark'
  alias bat='batcat'
fi

if command -v eza >/dev/null 2>&1; then
  alias e='eza --icons --group-directories-first'
  alias ela='eza -la --icons --group-directories-first --git'
  alias elt='eza --tree --level=2 --icons'
fi

if command -v procs >/dev/null 2>&1; then
  alias procz='procs'
fi
