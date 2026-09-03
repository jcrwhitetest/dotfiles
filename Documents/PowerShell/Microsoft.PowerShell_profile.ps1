# ================================
# Tweak's PowerShell Profile
# One Dark Pro edition
# ================================

# --- Oh My Posh prompt (theme file lives next to this profile) ---
$ompTheme = Join-Path (Split-Path $PROFILE) "OneDarkPro.omp.json"
oh-my-posh init pwsh --config $ompTheme | Invoke-Expression

# --- Terminal-Icons: file/folder icons in Get-ChildItem output ---
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

# --- PSReadLine: predictive IntelliSense + nicer editing ---
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -BellStyle None

    # One Dark Pro-ish syntax coloring in the line editor
    Set-PSReadLineOption -Colors @{
        Command            = '#61afef'
        Parameter          = '#abb2bf'
        Operator           = '#56b6c2'
        Variable           = '#e5c07b'
        String             = '#98c379'
        Number             = '#d19a66'
        Type               = '#c678dd'
        Comment            = '#5c6370'
        Keyword            = '#c678dd'
        Error              = '#e06c75'
        Selection          = '#3e4451'
        InlinePrediction   = '#5c6370'
    }

    # Quality-of-life keybindings
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
}

# --- Handy aliases / functions ---
function which ($cmd) { Get-Command $cmd | Select-Object -ExpandProperty Source }
function touch ($file) { New-Item -ItemType File -Path $file -Force | Out-Null }
function ll { Get-ChildItem -Force @args }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

# ================================
# Productivity tools
# zoxide / PSFzf+fzf / eza / bat / ripgrep / fd / dust / procs
# Every block is guarded so the profile still loads if a tool isn't installed yet.
# Native ls / cat / gci / dir / Get-Content / ps are intentionally left untouched.
# ================================

# --- zoxide: smarter directory jumping (adds `z` and `zi`; does NOT touch `cd`) ---
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --cmd z | Out-String) })
}

# --- fzf colors matched to One Dark Pro (used by fzf + PSFzf) ---
$env:FZF_DEFAULT_OPTS = @(
    '--height=40%', '--layout=reverse', '--border', '--info=inline',
    '--color=bg+:#3e4451,bg:#282c34,spinner:#56b6c2,hl:#e06c75',
    '--color=fg:#abb2bf,header:#e06c75,info:#c678dd,pointer:#56b6c2',
    '--color=marker:#98c379,fg+:#dcdfe4,prompt:#c678dd,hl+:#e06c75'
) -join ' '

# Use fd as fzf's file source when available (respects .gitignore, includes hidden)
if (Get-Command fd -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
    $env:FZF_CTRL_T_COMMAND  = $env:FZF_DEFAULT_COMMAND
}

# --- PSFzf: Ctrl+t = fuzzy file picker (Ctrl+r reverse-history is owned by atuin below) ---
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -ListAvailable -Name PSFzf)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
}

# --- eza: modern `ls`, exposed under NEW names so native ls/dir/gci stay intact ---
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function e   { eza --icons --group-directories-first @args }          # basic listing
    function ela { eza -la --icons --group-directories-first --git @args } # long + hidden + git
    function elt { eza --tree --level=2 --icons @args }                   # shallow tree
}

# --- bat: `cat` with syntax highlighting, exposed as `batcat` (native cat untouched) ---
if (Get-Command bat -ErrorAction SilentlyContinue) {
    $env:BAT_THEME = 'TwoDark'   # closest built-in bat theme to One Dark Pro
    function batcat { bat @args }
}

# --- procs: modern `ps`, exposed as `procz` (native ps = Get-Process untouched) ---
if (Get-Command procs -ErrorAction SilentlyContinue) {
    function procz { procs @args }
}

# ripgrep (rg), fd, and dust are used directly by name; no wrappers needed.

# --- atuin: better shell history (owns Ctrl+r); up-arrow stays with PSReadLine ---
if (Get-Command atuin -ErrorAction SilentlyContinue) {
    # 2-line Oh My Posh prompt -> offset the post-search redraw by one line
    $env:ATUIN_POWERSHELL_PROMPT_OFFSET = -1
    atuin init powershell --disable-up-arrow | Out-String | Invoke-Expression
}

Write-Host "Profile loaded ✔" -ForegroundColor DarkMagenta
