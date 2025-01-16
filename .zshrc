PROMPT='%F{magenta}[%*] %F{yellow}%n %F{cyan}%c %F{green}$%f '
# RPROMPT=' %F{magenta}[%*]%f'

export HISTFILE=~/.zsh_history
export SAVEHIST=100000
setopt inc_append_history share_history
setopt INC_APPEND_HISTORY  # save history as commands are entered, not when shell exits
unsetopt HIST_IGNORE_DUPS  # do save duplicate commmands in history
unsetopt HIST_IGNORE_SPACE # do save commands that begin with a space

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin::/usr/X11/bin
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH=$HOME/workspace/scripts:$PATH
export PATH="$(brew --prefix)/opt/postgresql@15/bin:$PATH"

# Go
export PATH=$HOME/workspace/external_codebases/gocode/bin:$PATH
export GOPATH=$HOME/workspace/external_codebases/gocode

alias l='ls -alh'
alias g='git'

# fasd, a "z" replacement. Install with `brew install fasd` or from https://github.com/clvv/fasd
eval "$(fasd --init auto)"

export REPORTTIME=15 # Say how long a command took, if it took more than N seconds

# Zsh spelling correction options
#setopt CORRECT
setopt DVORAK

# Vi mode!
bindkey -v
bindkey "^?" backward-delete-char
bindkey '^H' backward-delete-char
bindkey '^W' backward-kill-word
# bindkey '^R' history-incremental-pattern-search-backward # This is defined elsewhere by fzf
bindkey "^P" vi-up-line-or-history
bindkey "^N" vi-down-line-or-history
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
autoload -U edit-command-line # We want to use 'v' in normal mode to edit and execute like in bash vi mode
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line
export KEYTIMEOUT=1

# Make ZSH prompt show Vi mode -- from https://unix.stackexchange.com/a/344028
function zle-keymap-select zle-line-init {
    # change cursor shape in iTerm2
    case $KEYMAP in
        vicmd)      print -n -- "\E]50;CursorShape=0\C-G";;  # block cursor
        viins|main) print -n -- "\E]50;CursorShape=1\C-G";;  # line cursor
    esac
    zle reset-prompt
    zle -R
}
zle -N zle-keymap-select
zle -N zle-line-init
function zle-line-finish {
    print -n -- "\E]50;CursorShape=0\C-G"  # block cursor
}
zle -N zle-line-finish

export EDITOR='vim'

export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH=$PYENV_ROOT/bin:$PATH
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
export PATH="$HOME/.local/bin:$PATH"

[[ -r /usr/local/share/zsh/site-functions/go ]] && . /usr/local/share/zsh/site-functions/go

unsetopt CORRECT_ALL
unsetopt RM_STAR_WAIT

autoload -U zmv

autoload compinit && compinit
zstyle ':completion:*' menu select

# Install through the iTerm2 menus by iTerm2 -> Install Shell Integration
source $HOME/.iterm2_shell_integration.zsh

ssh-add 2> /dev/null

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
# Use ctrl-t for context-sensitive auto-completion, rather than **tab:
export FZF_COMPLETION_TRIGGER=''
bindkey '^T' fzf-completion
bindkey '^I' $fzf_default_completion

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# Ghosted autosuggestions. Install with `brew install zsh-autosuggestions`
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -r $HOME/.system_specific_vars ]] && . $HOME/.system_specific_vars

# Fish-like syntax highlighting. Install with `brew install zsh-syntax-highlighting`. Must stay at EOF!
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
