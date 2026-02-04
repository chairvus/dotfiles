# ~/.config/fish/config.fish
# --- Fast, minimal Fish config for macOS + Kitty + Helix ---
set -e EDITOR
set -e VISUAL

# 0) Silence the default greeting
set -g fish_greeting

# 1) Detect Homebrew prefix (Intel or Apple Silicon)
if type -q brew
    set -l __brew_prefix (brew --prefix)
    if test -d "$__brew_prefix/bin"
        set -gx PATH "$__brew_prefix/bin" "$__brew_prefix/sbin" $PATH
    end
end

# 3) Starship prompt
if type -q starship
    starship init fish | source
end

# 4) zoxide (smarter cd)
if type -q zoxide
    zoxide init fish | source
    function zi
        z -i $argv
    end
    function zq
        zoxide query -i $argv
    end
end

# 5) Enhanced fzf + fd + ripgrep integration
# -------------------------------------------------
# Default command (fd faster than find)
if type -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --hidden --strip-cwd-prefix --exclude .git'
else
    set -gx FZF_DEFAULT_COMMAND 'find -L . -type f 2>/dev/null'
end

# General FZF styling and behavior
set -gx FZF_DEFAULT_OPTS "
  --height 40%
  --layout=reverse
  --border
  --color=16,border:237,bg+:-1,fg+:white
  --marker='* '
  --bind 'tab:toggle+down'
  --bind 'shift-tab:toggle+up'
"

# Preview engine (use bat if available)
if type -q bat
    set -gx FZF_PREVIEW_COMMAND 'bat --color=always --style=plain --line-range=:150 {}'
else
    set -gx FZF_PREVIEW_COMMAND 'head -n 150 {}'
end

# Integrations
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_CTRL_T_OPTS "--preview '$FZF_PREVIEW_COMMAND' --preview-window=right:60%:wrap"
set -gx FZF_CTRL_R_OPTS "--sort --height 40% --reverse --prompt='history> '"

# 6) Helper functions
# -------------------------------------------------
# ff: fuzzy-pick a file then open in $EDITOR
function ff
    if not type -q fzf
        echo 'fzf not found'
        return 1
    end
    set -l picker (eval $FZF_DEFAULT_COMMAND | fzf $FZF_DEFAULT_OPTS \
        --prompt='files> ' --preview "$FZF_PREVIEW_COMMAND" \
        --preview-window 'right:60%:wrap')
    if test -n "$picker"
        $EDITOR "$picker"
    end
end

# fdd: fuzzy-pick a directory and cd into it
function fdd
    if not type -q fzf
        echo 'fzf not found'
        return 1
    end
    set -l list_cmd 'fd --type d --hidden --strip-cwd-prefix --exclude .git'
    if not type -q fd
        set list_cmd 'find -L . -type d 2>/dev/null'
    end
    set -l dest (eval $list_cmd | fzf $FZF_DEFAULT_OPTS --prompt='dirs> ')
    if test -n "$dest"
        cd "$dest"
        commandline -f repaint
    end
end

# fg: search text with ripgrep + fzf, jump to file/line in Helix
function fg
    if not type -q rg
        echo 'ripgrep not found'
        return 1
    end
    if not type -q fzf
        echo 'fzf not found'
        return 1
    end
    set -l query $argv
    set -l result (rg --line-number --no-heading --hidden --smart-case --glob '!*.git/*' "$query" | \
        fzf $FZF_DEFAULT_OPTS --prompt='grep> ' \
            --preview 'set -l f (cut -d: -f1 <<< {}); set -l l (cut -d: -f2 <<< {}); test -f $f; and bat --color=always --style=plain --line-range \"$l-20:$l+20\" $f' \
            --preview-window 'right:60%:wrap')
    if test -n "$result"
        set -l file (echo $result | cut -d: -f1)
        set -l line (echo $result | cut -d: -f2)
        $EDITOR "+$line" "$file"
    end
end

# __fzf_history_search: Ctrl-R for history search
function __fzf_history_search
    if not type -q fzf
        commandline -f history-search-backward
        return
    end
    set -l chosen (history | fzf $FZF_CTRL_R_OPTS)
    if test -n "$chosen"
        commandline -r -- "$chosen"
    end
end

# Simple macOS opener: o <file|dir|url>
function o
    if test (count $argv) -eq 0
        open .
    else
        open $argv
    end
end

# 7) Key bindings
# -------------------------------------------------
function fish_user_key_bindings
    bind \ct 'set -l sel (eval $FZF_CTRL_T_COMMAND | fzf $FZF_CTRL_T_OPTS); and commandline -i -- \"$sel\"'
    bind \cr __fzf_history_search
    bind \ef ff
    bind \ed fdd
end

# 8) Useful aliases / abbr
# -------------------------------------------------
abbr -a ll 'ls -lah'
abbr -a la 'ls -A'

# sd: clean shutdown
function sd
    osascript -e 'do shell script "shutdown -h now" with administrator privileges'
end

#restart
function rs
    sudo reboot
end

# git
abbr -a gs 'git status -sb'
abbr -a ga 'git add -A'
abbr -a gc 'git commit'
abbr -a gco 'git checkout'
abbr -a gsw 'git switch'
abbr -a gp 'git push'

# docker / compose / colima
abbr -a d docker
abbr -a dps 'docker ps'
abbr -a dcu 'docker compose up'
abbr -a dcd 'docker compose down'
abbr -a cl colima

# 9) PATH extras
# -------------------------------------------------
set -Up PATH
for p in ~/.local/bin ~/.cargo/bin ~/go/bin
    if test -d $p
        contains -- $p $PATH; or set -gx PATH $p $PATH
    end
end

# 10) Python QoL
# -------------------------------------------------
function __auto_venv --on-variable PWD
    if test -f .venv/bin/activate.fish
        source .venv/bin/activate.fish ^/dev/null
    end
end

abbr -a fmt 'black . && ruff check --fix .'
abbr -a typecheck pyright

# 11) Right prompt (exit code)
# -------------------------------------------------
function fish_right_prompt
    if test $status -ne 0
        echo (set_color red)✖ $status(set_color normal)
    end
end

# 12) Disable flow control so Ctrl+S works (important for Helix)
if status is-interactive
    stty -ixon 2>/dev/null
end

# eza
if type -q eza
    alias ls="eza -lh --no-permissions --no-user --group-directories-first"
    alias ll="eza -lh --group-directories-first"
    alias la="eza -lah --group-directories-first"
    alias lg="eza -lh --git"
    alias lt="eza --tree --level=2"
end
