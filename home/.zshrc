#!/usr/bin/env zsh
# ~/.zshrc - Optimized ZSH Configuration with Auto Theme Switching

# =============================================================================
# THEME DETECTION AND SWITCHING
# =============================================================================
detect_system_theme() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: Check system appearance
        local theme
        theme=$(osascript -e 'tell app "System Events" to tell appearance preferences to get dark mode' 2>/dev/null)
        if [[ "$theme" == "true" ]]; then
            echo "dark"
        else
            echo "light"
        fi
    elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        # Linux: Check GNOME/KDE theme
        if command -v gsettings >/dev/null 2>&1; then
            # GNOME
            local gtk_theme
            gtk_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "")
            if [[ "$gtk_theme" =~ -[Dd]ark ]]; then
                echo "dark"
            else
                echo "light"
            fi
        elif command -v kreadconfig5 >/dev/null 2>&1; then
            # KDE
            local color_scheme
            color_scheme=$(kreadconfig5 --file kdeglobals --group General --key ColorScheme 2>/dev/null || echo "")
            if [[ "$color_scheme" =~ [Dd]ark ]]; then
                echo "dark"
            else
                echo "light"
            fi
        else
            # Fallback: check stored theme or default to dark
            if [[ -f "$HOME/.current_theme" ]]; then
                cat "$HOME/.current_theme"
            else
                echo "dark"
            fi
        fi
    else
        echo "dark"  # Default fallback
    fi
}

# Set current theme
export CURRENT_THEME=$(detect_system_theme)

# =============================================================================
# OS-SPECIFIC CONFIGURATIONS
# =============================================================================
[[ "$OSTYPE" == "linux-gnu" && -f "$HOME/.linux.plugin.zsh" ]] && source "$HOME/.linux.plugin.zsh"
[[ "$OSTYPE" == "darwin"* && -f "$HOME/.mac.plugin.zsh" ]] && source "$HOME/.mac.plugin.zsh"

# =============================================================================
# TOOL INTEGRATIONS
# =============================================================================

# kubectl completion
[[ -n $commands[kubectl] ]] && source <(kubectl completion zsh) 2>/dev/null

# rbenv setup (macOS only)
if [[ "$OSTYPE" == "darwin"* ]] && command -v rbenv >/dev/null 2>&1; then
    if [[ -d "/opt/homebrew/opt/rbenv" ]]; then
        FPATH="/opt/homebrew/opt/rbenv/completions:$FPATH"
        autoload -U compinit && compinit
    fi
    eval "$(rbenv init - --no-rehash zsh)"
fi

# pyenv setup
if command -v pyenv >/dev/null 2>&1; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - zsh)"
fi

# nvm setup (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    export NVM_DIR="$HOME/.nvm"
    if [[ -d "$NVM_DIR" && -f "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
        export PATH="$NVM_DIR/versions/node/$(nvm version)/bin:$PATH"
    fi
fi

export ANDROID_HOME=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools

# =============================================================================
# CURSOR/EDITOR DETECTION - Skip all customizations if in editor
# =============================================================================
# if [[ -n $CURSOR_SESSION ]] || [[ -n $VSCODE_PID ]] || [[ -n $VSCODE_INJECTION ]] || [[ -n $TERM_PROGRAM && $TERM_PROGRAM == "vscode" ]]; then
#     # Minimal setup for editors - just basic functionality
#     export EDITOR=nvim
#     export VISUAL=nvim
#     export GIT_OPTIONAL_LOCKS=0
#
#     # Essential aliases only
#     alias ll='ls -alF'
#     alias la='ls -a'
#     alias l='ls -l'
#     alias gs='git status'
#     alias ga='git add'
#     alias gc='git commit -m'
#
#     # Minimal history
#     HISTFILE=~/.zhistory
#     HISTSIZE=50
#     SAVEHIST=50
#
#     # Skip all other configurations
#     return
# fi

# =============================================================================
# ZSH OPTIONS
# =============================================================================
setopt correct                    # Auto correct mistakes
setopt extendedglob              # Extended globbing with regular expressions
setopt nocaseglob                # Case insensitive globbing
setopt rcexpandparam             # Array expansion with parameters
setopt nocheckjobs               # Don't warn about running processes when exiting
setopt numericglobsort           # Sort filenames numerically when it makes sense
setopt nobeep                    # No beep
setopt appendhistory             # Immediately append history instead of overwriting
setopt histignorealldups         # Remove older duplicate commands
setopt autocd                    # If only directory path is entered, cd there

# =============================================================================
# COMPLETION SYSTEM
# =============================================================================
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"    # Colored completion
zstyle ':completion:*' rehash true                         # Automatically find new executables in path
zstyle ':completion:*' accept-exact '*(N)'                 # Speed up completions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

autoload -U compinit colors zcalc
compinit -d
colors

# =============================================================================
# HISTORY CONFIGURATION
# =============================================================================
HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=500

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================
export EDITOR=nvim
export VISUAL=nvim
export LESS_TERMCAP_mb=$'\E[01;32m'      # Color man pages
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-r
export DOTBARE_DIR="$HOME/.dotfiles"
export MEKARI_DEV_DIR="$HOME/Development/mekari"
export AFIKRIM_DEV_DIR="$HOME/Development/afikrim"
export AZIFEX_DEV_DIR="$HOME/Development/azifex"
export GETBOON_DEV_DIR="$HOME/Development/getboon"

# Word separators
WORDCHARS=${WORDCHARS//\/[&.;]}

# =============================================================================
# KEY BINDINGS
# =============================================================================
bindkey -e  # Emacs key bindings

# Navigation keys
bindkey '^[[7~' beginning-of-line        # Home key
bindkey '^[[H' beginning-of-line         # Home key
bindkey '^[[8~' end-of-line             # End key
bindkey '^[[F' end-of-line              # End key
bindkey '^[[2~' overwrite-mode          # Insert key
bindkey '^[[3~' delete-char             # Delete key
bindkey '^[[C' forward-char             # Right key
bindkey '^[[D' backward-char            # Left key
bindkey '^[[5~' history-beginning-search-backward   # Page up
bindkey '^[[6~' history-beginning-search-forward    # Page down

# Home/End keys (terminfo-based)
[[ -n "${terminfo[khome]}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n "${terminfo[kend]}" ]] && bindkey "${terminfo[kend]}" end-of-line

# Word navigation with Ctrl+Arrow
bindkey '^[Oc' forward-word
bindkey '^[Od' backward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word

# Word manipulation
bindkey '^H' backward-kill-word         # Ctrl+Backspace
bindkey '^[[Z' undo                     # Shift+Tab
bindkey '^[^?' backward-kill-word

# =============================================================================
# ALIASES
# =============================================================================

# File operations
alias cp="cp -i"                        # Confirm before overwriting
alias df='df -h'                        # Human-readable sizes
alias free='free -m'                    # Show sizes in MB
alias ll='ls -alF'
alias la='ls -a'
alias l='ls -l'

# Git shortcuts
alias gs='git status'
alias gl='git log --graph --oneline'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push -u'
alias gtw='__git_worktree'       # general worktree creator
alias gtwls='git worktree list'
alias gtwrm='git worktree remove'

__tmux_short_name() {
  local verbose=${1//\//-}
  local first="${verbose%%-*}"
  [[ -z "$first" ]] && first="$verbose"
  local rest="${verbose#*-}"
  if [[ "$rest" == "$verbose" || -z "$rest" ]]; then
    echo "$first"
    return
  fi
  local second="${rest%%-*}"
  if [[ -n "$second" ]]; then
    echo "${first}-${second}"
  else
    echo "$first"
  fi
}

__set_tmux_tab_name() {
  local branch=$1
  [[ -n "$TMUX" ]] || return
  [[ -n "$branch" ]] || return

  local owner ticket verbose
  local IFS='/'
  read -r owner ticket verbose <<< "$branch"
  [[ -n "$ticket" && -n "$verbose" ]] || return

  local short=$(__tmux_short_name "$verbose")
  [[ -n "$short" ]] || return
  tmux rename-window "${ticket}/${short}"
}

if [[ -d "$HOME/.zsh/dev" ]]; then
  for plugin in "$HOME/.zsh/dev/"*.zsh; do
    [[ -e "$plugin" ]] || continue
    source "$plugin"
  done
fi

# Tmux shortcuts
alias tx='tmux'
alias txl='tmux list-sessions'
alias txa='tmux attach-session'
alias txn='tmux new-session'

# Utility shortcuts
alias pn="pnpm"
alias curls="curl -s"
alias curlt="curl -s -w '%{time_total}\n'"

# Theme switching aliases
alias theme-switch='~/.config/scripts/theme-switcher.sh'
alias theme-light='export CURRENT_THEME=light && theme-switch'
alias theme-dark='export CURRENT_THEME=dark && theme-switch'
alias theme-auto='unset CURRENT_THEME && theme-switch'

# Dev alias
alias dev='cd ~/Development'
alias dev-mekari='cd ~/Development/mekari'
alias dev-afikrim='cd ~/Development/afikrim'
alias dev-azifex='cd ~/Development/azifex'
alias dev-getboon='cd ~/Development/getboon'
alias dev-boonai='dev-getboon'

alias clpass='claude --dangerously-skip-permissions'
alias cxpass='codex --dangerously-bypass-approvals-and-sandbox'
alias cppass='copilot --allow-all-tools --allow-all-paths'

# OS-specific aliases
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    alias update='sudo apt update'
    alias upgrade='sudo apt upgrade'
    alias install='sudo apt install'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    alias update='brew update'
    alias upgrade='brew upgrade'
    alias install='brew install'
fi

# =============================================================================
# POWERLEVEL10K THEME WITH AUTO SWITCHING
# =============================================================================
# Disable configuration wizard
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Find and load Powerlevel10k
P10K_THEME_PATH=""
if [[ -f ~/.powerlevel10k/powerlevel10k.zsh-theme ]]; then
    P10K_THEME_PATH=~/.powerlevel10k/powerlevel10k.zsh-theme
elif [[ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]]; then
    P10K_THEME_PATH=/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
elif [[ -f /run/current-system/sw/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]]; then
    P10K_THEME_PATH=/run/current-system/sw/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
elif [[ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
    P10K_THEME_PATH=/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
fi

if [[ -n "$P10K_THEME_PATH" ]]; then
    source "$P10K_THEME_PATH"
    
    # Load theme-specific P10k configuration
    if [[ "$CURRENT_THEME" == "light" ]]; then
        [[ -f ~/.p10k-light.zsh ]] && source ~/.p10k-light.zsh
    else
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    fi
else
    # Fallback prompt if P10k is not available
    setopt prompt_subst
    if [[ "$CURRENT_THEME" == "light" ]]; then
        PROMPT="%B%{$fg[blue]%}%(4~|%-1~/.../%2~|%~)%u%b >%{$fg[blue]%}>%B%(?.%{$fg[blue]%}.%{$fg[red]%})>%{$reset_color%}%b "
        RPROMPT="%(?.%{$fg[green]%}✓ %{$reset_color%}.%{$fg[red]%}✗ %{$reset_color%})"
    else
        PROMPT="%B%{$fg[cyan]%}%(4~|%-1~/.../%2~|%~)%u%b >%{$fg[cyan]%}>%B%(?.%{$fg[cyan]%}.%{$fg[red]%})>%{$reset_color%}%b "
        RPROMPT="%(?.%{$fg[green]%}✓ %{$reset_color%}.%{$fg[red]%}✗ %{$reset_color%})"
    fi
fi

# =============================================================================
# PLUGIN LOADING
# =============================================================================

# Helper function to safely load plugins
load_plugin() {
    [[ -f "$1" ]] && source "$1"
}

# Core plugins
load_plugin "$HOME/.zsh/plugins/dotbare/dotbare.plugin.zsh"
load_plugin "$HOME/.zsh/plugins/ssh-tunnel/ssh-tunnel.plugin.zsh"
load_plugin "$HOME/.zsh/plugins/zsh-completions/zsh-completions.plugin.zsh"
load_plugin "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
load_plugin "$HOME/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
load_plugin "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Configure autosuggestions
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Configure history substring search
if [[ -n "${terminfo[kcuu1]}" && -n "${terminfo[kcud1]}" ]]; then
    bindkey "${terminfo[kcuu1]}" history-substring-search-up
    bindkey "${terminfo[kcud1]}" history-substring-search-down
fi
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# =============================================================================
# AUTO THEME SWITCHING ON SHELL START
# =============================================================================
# Check if theme has changed and update if needed
check_and_update_theme() {
    local current_system_theme
    current_system_theme=$(detect_system_theme)
    
    # Only update if theme actually changed
    if [[ "$CURRENT_THEME" != "$current_system_theme" ]]; then
        export CURRENT_THEME="$current_system_theme"
        
        # Run theme switcher in background to avoid slowing shell startup
        (~/.config/scripts/theme-switcher.sh &) 2>/dev/null
    fi
}

# Check theme on shell start (but not in subshells to avoid overhead)
if [[ $SHLVL -eq 1 ]]; then
    check_and_update_theme
fi

# =============================================================================
# STARTUP MESSAGE
# =============================================================================
# Print greeting only in interactive shells at top level
if [[ $- == *i* ]] && [[ $SHLVL -eq 1 ]]; then
    echo "$USER@$HOST $(uname -srm) | Theme: $CURRENT_THEME"
fi

# Added by Windsurf
export PATH="/Users/mekari/.codeium/windsurf/bin:$PATH"
