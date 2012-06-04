# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="harry"
#ZSH_THEME="nicoulaj"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
 DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git cap gem heroku lein macports)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin
#export PATH=$PATH:/Users/harry/.rvm/bin

[[ -r $HOME/.system_specific_vars ]] && . $HOME/.system_specific_vars

alias hdfs='hadoop fs'
alias v='mvim'
alias be='bundle exec'

# z.sh - from https://github.com/rupa/z
[[ -r $HOME/workspace/external_codebases/z/z.sh ]] && . $HOME/workspace/external_codebases/z/z.sh
source ~/workspace/external_codebases/z/z.sh
function precmd()
{
  #vcs_info
  _z --add "$(pwd -P)"
}

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
bindkey '^R' history-incremental-search-backward # search backwards with ^R
# We want to use 'v' in normal mode to edit and execute like in bash vi mode
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line
# Useful on boxes where there is no good alternative to the ESC button. A better solution is to use Caps Lock
# as Ctrl when held down and ESC when tapped.
#bindkey "hh" vi-cmd-mode

# load RVM
#[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
#__rvm_project_rvmrc

# And let's use rbenv instead of RVM:
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

