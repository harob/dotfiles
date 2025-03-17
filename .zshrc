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

# Rust
export PATH=$HOME/.cargo/bin:$PATH

alias l='ls -alh --color=auto'
alias g='git'

# fasd, a "z" replacement. Install with `brew install fasd` or from https://github.com/clvv/fasd
eval "$(fasd --init auto)"

export REPORTTIME=15 # Say how long a command took, if it took more than N seconds

# Zsh spelling correction options
#setopt CORRECT
setopt DVORAK

# Vi mode!
# Install with `brew install zsh-vi-mode`
function zvm_after_init() {
    zvm_bindkey vicmd 'H' beginning-of-line
    zvm_bindkey vicmd 'L' end-of-line

    zvm_bindkey viins '^B' backward-word
    zvm_bindkey viins '^F' forward-word

    zvm_bindkey viins "^R" fzf-history-widget
}
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
export ZVM_KEYTIMEOUT=1

export EDITOR='vim'

export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

unsetopt CORRECT_ALL
unsetopt RM_STAR_WAIT

autoload -U zmv

# Use all the per-tool autocompletion's provided by homebrew -- see https://docs.brew.sh/Shell-Completion
autoload -Uz compinit && compinit
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
