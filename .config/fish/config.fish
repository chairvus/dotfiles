# ~/.config/fish/config.fish
# --- Fast, safe, reproducible Fish config (macOS) ---

# -------------------------------------------------
# 0) Basics
# -------------------------------------------------
set -g fish_greeting

# Editor
set -gx EDITOR hx
set -gx VISUAL hx

# -------------------------------------------------
# 1) Homebrew PATH (Intel & Apple Silicon safe)
# -------------------------------------------------
if type -q brew
    set -l __brew_prefix (brew --prefix)
    if test -d "$__brew_prefix/bin"
        contains -- "$__brew_prefix/bin" $PATH; or set -gx PATH "$__brew_prefix/bin" "$__brew_prefix/sbin" $PATH
    end
end

# -------------------------------------------------
# 2) Starship prompt
# -------------------------------------------------
if type -q starship
    starship init fish | source
end

# -------------------------------------------------
# 3) Zoxide (smart cd)
# -------------------------------------------------
if type -q zoxide
    zoxide init fish | source

    function zi
        z -i $argv
    end

    function zq
        zoxide query -i $argv
    end
end

# -------------------------------------------------
# 4) FZF + fd + ripgrep
# -------------------------------------------------
if type -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --hidden --strip-cwd-prefix --exclude .git'
else
    set -gx FZF_DEFAULT_COMMAND 'find -L . -type f 2>/dev/null'
end

set -gx FZF_DEFAULT_OPTS "
  --height 40%
  --layout=reverse
  --border
  --marker='* '
  --bind 'tab:toggle+down'
  --bind 'shift-tab:toggle+up'
"

if type -q bat
    set -gx FZF_PREVIEW_COMMAND 'bat --color=always --style=plain --line-range=:150 {}'
else
    set -gx FZF_PREVIEW_COMMAND 'head -n 150 {}'
end

set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_CTRL_T_OPTS "--preview '$FZF_PREVIEW_COMMAND' --preview-window=right:60%:wrap"
set -gx FZF_CTRL_R_OPTS "--sort --height 40% --reverse --prompt='history> '"

# -------------------------------------------------
# 5) Helper functions
# -------------------------------------------------
function ff
    if not type -q fzf
        echo 'fzf not found'
        return 1
    end

    set -l picker (eval $FZF_DEFAULT_COMMAND | fzf $FZF_DEFAULT_OPTS \
        --prompt='files> ' --preview "$FZF_PREVIEW_COMMAND")

    test -n "$picker"; and $EDITOR "$picker"
end

function fdd
    if not type -q fzf
        echo 'fzf not found'
        return 1
    end

    if type -q fd
        set -l list_cmd 'fd --type d --hidden --strip-cwd-prefix --exclude .git'
    else
        set -l list_cmd 'find -L . -type d 2>/dev/null'
    end

    set -l dest (eval $list_cmd | fzf $FZF_DEFAULT_OPTS --prompt='dirs> ')
    test -n "$dest"; and cd "$dest"
end

function fg
    if not type -q rg; or not type -q fzf
        echo 'rg or fzf not found'
        return 1
    end

    set -l result (rg --line-number --no-heading --hidden --smart-case \
        --glob '!*.git/*' $argv | \
        fzf $FZF_DEFAULT_OPTS --prompt='grep> ' \
        --preview 'bat --color=always --style=plain --line-range=:200 {1}')

    if test -n "$result"
        set -l file (echo $result | cut -d: -f1)
        set -l line (echo $result | cut -d: -f2)
        $EDITOR "+$line" "$file"
    end
end

if not pgrep -x mpd >/dev/null
    mpd ~/.config/mpd/mpd.conf
end

# -------------------------------------------------
# 6) Key bindings
# -------------------------------------------------
function fish_user_key_bindings
    bind \cr __fzf_history_search
    bind \ef ff
    bind \ed fdd
end

function __fzf_history_search
    if not type -q fzf
        commandline -f history-search-backward
        return
    end

    set -l chosen (history | fzf $FZF_CTRL_R_OPTS)
    test -n "$chosen"; and commandline -r -- "$chosen"
end

# -------------------------------------------------
# 7) Aliases / abbreviations
# -------------------------------------------------
abbr -a ll 'ls -lah'
abbr -a la 'ls -A'

abbr -a gs 'git status -sb'
abbr -a ga 'git add -A'
abbr -a gc 'git commit'
abbr -a gco 'git checkout'
abbr -a gsw 'git switch'
abbr -a gp 'git push'

abbr -a d docker
abbr -a dps 'docker ps'
abbr -a dcu 'docker compose up'
abbr -a dcd 'docker compose down'
abbr -a cl colima

# -------------------------------------------------
# 8) Extra PATH (SAFE)
# -------------------------------------------------
for p in ~/.local/bin ~/.cargo/bin ~/go/bin
    if test -d $p
        contains -- $p $PATH; or set -gx PATH $p $PATH
    end
end

# -------------------------------------------------
# 9) Python auto venv
# -------------------------------------------------
function __auto_venv --on-variable PWD
    if test -f .venv/bin/activate.fish
        source .venv/bin/activate.fish ^/dev/null
    end
end

abbr -a fmt 'black . && ruff check --fix .'
abbr -a typecheck pyright

# -------------------------------------------------
# 10) Right prompt (exit code)
# -------------------------------------------------
function fish_right_prompt
    if test $status -ne 0
        set_color red
        echo "✖ $status"
        set_color normal
    end
end

# -------------------------------------------------
# 11) Disable flow control (Helix friendly)
# -------------------------------------------------
if status is-interactive
    stty -ixon 2>/dev/null
end

# -------------------------------------------------
# 12) eza replacement for ls
# -------------------------------------------------
if type -q eza
    alias ls="eza -lh --no-permissions --no-user --group-directories-first"
    alias ll="eza -lh --group-directories-first"
    alias la="eza -lah --group-directories-first"
    alias lg="eza -lh --git"
    alias lt="eza --tree --level=2"
end

# Added by Antigravity
fish_add_path /Users/artha/.antigravity/antigravity/bin

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/homebrew/Caskroom/miniforge/base/bin/conda
    eval /opt/homebrew/Caskroom/miniforge/base/bin/conda "shell.fish" hook $argv | source
else
    if test -f "/opt/homebrew/Caskroom/miniforge/base/etc/fish/conf.d/conda.fish"
        . "/opt/homebrew/Caskroom/miniforge/base/etc/fish/conf.d/conda.fish"
    else
        set -x PATH /opt/homebrew/Caskroom/miniforge/base/bin $PATH
    end
end
# <<< conda initialize <<<
function yazi
    kitty @ action goto_layout stack
    sleep 0.3
    PATH=/opt/homebrew/bin:$PATH command yazi $argv
    kitty @ action goto_layout fat
end
