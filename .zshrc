# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Comment this out to disable weekly oh-my-zsh auto-update checks
 DISABLE_AUTO_UPDATE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
plugins=(git cap gem heroku lein zsh-syntax-highlighting osx)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

# VI prompt
vi_mode_indicator='$'
PROMPT='%F{yellow}%n@%m %F{cyan}%c%F{green} $vi_mode_indicator %f'
RPROMPT=' %F{magenta}[%*]%f'
function zle-line-init zle-keymap-select() {
  vi_mode_indicator="${${KEYMAP/vicmd/☯}/(main|viins)/$}"
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin

[[ -r $HOME/.system_specific_vars ]] && . $HOME/.system_specific_vars

alias l='ls -alh'
alias v='mvim'
alias e='memacs'
alias be='bundle exec'
alias bi='bundle install'
alias bef='bundle exec fez'
alias ber='bundle exec rake'

# fasd, a "z" replacement. Install with `brew install fasd` or from https://github.com/clvv/fasd
eval "$(fasd --init auto)"

# Say how long a command took, if it took more than N seconds
export REPORTTIME=15

# Zsh spelling correction options
#setopt CORRECT
setopt DVORAK

# Prompts for confirmation after 'rm *' etc
# Helps avoid mistakes like 'rm * o' when 'rm *.o' was intended
setopt RM_STAR_WAIT

# Vi mode!
bindkey -v
bindkey "^?" backward-delete-char                # Allow for deleting characters in vi mode
bindkey '^R' history-incremental-pattern-search-backward
bindkey "^P" vi-up-line-or-history
bindkey "^N" vi-down-line-or-history
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
autoload -U edit-command-line # We want to use 'v' in normal mode to edit and execute like in bash vi mode
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line
export KEYTIMEOUT=1
# Useful on boxes where there is no good alternative to the ESC button. A better solution is to use Caps Lock
# as Ctrl when held down and ESC when tapped.
#bindkey "hh" vi-cmd-mode

export EDITOR='vim'

export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

[[ -r /usr/local/share/zsh/site-functions/go ]] && . /usr/local/share/zsh/site-functions/go

unsetopt correct_all
unsetopt rm_star_wait
setopt INC_APPEND_HISTORY  # save history as commands are entered, not when shell exits
setopt HIST_IGNORE_DUPS    # don't save duplicate commmands in history
unsetopt HIST_IGNORE_SPACE # do save commands that begin with a space

autoload -U zmv

source /Users/harry/.iterm2_shell_integration.zsh

ssh-add

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
