PROMPT='%F{magenta}[%*] %F{yellow}%n %F{cyan}%c %F{green}$%f '
# RPROMPT=' %F{magenta}[%*]%f'

export HISTFILE=~/.zsh_history
export SAVEHIST=100000
setopt inc_append_history share_history


export PATH=/usr/bin:/bin:/usr/sbin:/sbin::/usr/X11/bin
export PATH=/usr/local/bin:/usr/local/sbin:$PATH # Homebrew
export PATH=$HOME/workspace/scripts:$PATH
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export PATH=/usr/local/opt/python@2/libexec/bin:$PATH

# Go
export PATH=$HOME/workspace/external_codebases/gocode/bin:$PATH
export GOPATH=$HOME/workspace/external_codebases/gocode

# EC2
# export EC2_HOME=/Users/harry/workspace/external_codebases/ec2-api-tools-1.6.5.4
# export PATH=/Users/harry/workspace/external_codebases/ec2-api-tools-1.6.5.4/bin:$PATH

# AWS
# source /usr/local/bin/aws_zsh_completer.sh

# export NODE_PATH="/usr/local/lib/node_modules"

alias l='ls -alh'
alias v='mvim'
alias e='memacs'
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

# From https://unix.stackexchange.com/a/344028
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

[[ -r /usr/local/share/zsh/site-functions/go ]] && . /usr/local/share/zsh/site-functions/go

unsetopt CORRECT_ALL
unsetopt RM_STAR_WAIT
setopt INC_APPEND_HISTORY  # save history as commands are entered, not when shell exits
setopt HIST_IGNORE_DUPS    # don't save duplicate commmands in history
unsetopt HIST_IGNORE_SPACE # do save commands that begin with a space

autoload -U zmv

source /Users/harry/.iterm2_shell_integration.zsh

ssh-add 2> /dev/null

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

# Slack dark mode -- from https://github.com/laCour/slack-night-mode/issues/73#issuecomment-355234417
SLACK_PATH='/Applications/Slack.app/Contents/Resources'
CSS_URL='https://raw.githubusercontent.com/laCour/slack-night-mode/master/css/raw/black.css'
if ! grep -q "$CSS_URL" "${SLACK_PATH}"/app.asar.unpacked/src/static/ssb-interop.js; then
bash -c "cat >> \"${SLACK_PATH}\"/app.asar.unpacked/src/static/ssb-interop.js" << EOF
document.addEventListener('DOMContentLoaded', function() {
 $.ajax({
   url: '${CSS_URL}',
   success: function(css) {
     \$("<style></style>").appendTo('head').html(css)
   }
 });
});
EOF
fi
if ! grep -q "$CSS_URL" "${SLACK_PATH}"/app.asar.unpacked/src/static/index.js; then
bash -c "cat >> \"${SLACK_PATH}\"/app.asar.unpacked/src/static/index.js" << EOF
document.addEventListener('DOMContentLoaded', function() {
 $.ajax({
   url: '${CSS_URL}',
   success: function(css) {
     \$("<style></style>").appendTo('head').html(css)
   }
 });
});
EOF
fi

[[ -r $HOME/.system_specific_vars ]] && . $HOME/.system_specific_vars

# Fish-like syntax highlighting. Install with `brew install zsh-syntax-highlighting`. Must stay at EOF!
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
