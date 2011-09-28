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
# DISABLE_AUTO_UPDATE="true"

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
export PATH=$PATH:/Users/harry/.rvm/bin

[[ -r $HOME/.system_specific_vars ]] && . $HOME/.system_specific_vars

alias hdfs='hadoop fs'

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
setopt CORRECT
setopt DVORAK

# Prompts for confirmation after 'rm *' etc
# Helps avoid mistakes like 'rm * o' when 'rm *.o' was intended
setopt RM_STAR_WAIT

# load RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
__rvm_project_rvmrc

