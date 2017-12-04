export EDITOR=vim

# Add git branch to bash command prompt
for file in {/sw,/opt/local,$HOME/local,}/etc/bash_completion; do
  [[ -r $file ]] && source $file
done

# Colors
K="\[\033[0;30m\]"
R="\[\033[0;31m\]"
G="\[\033[0;32m\]"
Y="\[\033[0;33m\]"
B="\[\033[0;34m\]"
P="\[\033[0;35m\]"
C="\[\033[0;36m\]"
W="\[\033[0;38m\]"
NC="\[\033[0;0m\]"
GBOLD="\[\033[1;32m\]"

unset PROMPT_COMMAND
TITLEBAR='\[\033]0;\u@\h - \W \007\]'

function prompt_uncolorized {
  PS1="${TITLEBAR}[\t] \u@\h \W"
  [[ $(type -t __git_ps1) = "function" ]] && PS1="${PS1}$(__git_ps1 '#%.6s')"
  export PS1="${PS1}\\$ "
  export PS2="> "
}
function prompt_colorized {
  PS1="${TITLEBAR}${P}[\t] ${Y}\u@\h ${C}\W"
  [[ $(type -t __git_ps1) = "function" ]] && PS1="${PS1}${B}$(__git_ps1 '#%.6s')"
  export PS1="${PS1}${G}\\$ ${NC}"
  export PS2="${G}> ${NC}"
}

PROMPT_COMMAND=prompt_colorized

export PAGER="less -FiRswX"
export MANPAGER=$PAGER

[[ -r $HOME/workspace/external_codebases/z/z.sh ]] && . $HOME/workspace/external_codebases/z/z.sh

# RVM setup; note that this line must come *before* sourcing fuzzycd_bash_wrapper.sh
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.
[[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion

# PhilC's fuzzycd script
#export PATH=~/scripts/fuzzycd/:$PATH
#source ~/scripts/fuzzycd/fuzzycd_bash_wrapper.sh

alias g='git'
complete -o default -o nospace -F _git g # Autocomplete for 'g' as well

alias ll='ls -al'
alias hdfs='hadoop fs'
alias psg='ps -ef | grep'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
