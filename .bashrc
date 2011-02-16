# Add git branch to bash command prompt
for file in {/sw,/opt/local,$HOME/local,}/etc/bash_completion; do
  [[ -r $file ]] && source $file
done
TITLEBAR='\[\033]0;\h:\W \007\]'
export PS1="${TITLEBAR}\u@\h \W\$(__git_ps1 '#%.6s')\\$ "

# PhilC's fuzzycd script
export PATH=~/scripts/fuzzycd/:$PATH
source ~/scripts/fuzzycd/fuzzycd_bash_wrapper.sh

