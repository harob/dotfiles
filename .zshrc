PROMPT='%F{magenta}[%*] %F{yellow}%n %F{blue}${GIT_BRANCH}%f %F{cyan}%c %F{green}$%f '
# PROMPT='%F{magenta}[%*] %F{yellow}%n %F{cyan}%c %F{green}$%f '
# RPROMPT=' %F{magenta}[%*]%f'

# Set the git branch in the prompt as efficiently as possible
setopt prompt_subst
git_branch() {
  local b
  b=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || return
  printf '%s' "$b"
}
precmd_update_git_branch() {
  GIT_BRANCH=$(/usr/bin/env git symbolic-ref --quiet --short HEAD 2>/dev/null || true)
}
precmd_functions+=( precmd_update_git_branch )

# Jump to Git Route
gr() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "not in a git repo"
    return 1
  }
  cd "$root"
}

export HISTFILE=~/.zsh_history
export SAVEHIST=100000
setopt inc_append_history share_history
setopt INC_APPEND_HISTORY  # save history as commands are entered, not when shell exits
unsetopt HIST_IGNORE_DUPS  # do save duplicate commmands in history
unsetopt HIST_IGNORE_SPACE # do save commands that begin with a space

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin::/usr/X11/bin
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH=$HOME/workspace/scripts:$PATH
export PATH="$(brew --prefix)/opt/postgresql@17/bin:$PATH"

# Go
export PATH=$HOME/workspace/external_codebases/gocode/bin:$PATH
export GOPATH=$HOME/workspace/external_codebases/gocode

# Rust
export PATH=$HOME/.cargo/bin:$PATH

alias e='emacsclient -n'
alias g='git'
alias l='ls -alh --color=auto'

export REPORTTIME=5 # Say how long a command took, if it took more than N seconds

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

eval "$(direnv hook zsh)"

# Use zoxide for `z` frecency-based directory jumping
export _ZO_ECHO=1
eval "$(zoxide init zsh)"

# Make z worktree-aware: when in a git worktree, remap zoxide results
# from the root worktree to the current worktree.
function z() {
  if [[ $# -eq 0 ]]; then
    __zoxide_z
    return
  fi

  # If not in a git repo, just use zoxide normally
  local root_wt
  root_wt=$(git worktree list 2>/dev/null | head -1 | awk '{print $1}') || {
    __zoxide_z "$@"
    return
  }

  # Find which worktree we're currently in
  local current_wt
  current_wt=$(git worktree list 2>/dev/null | awk '{print $1}' | while read -r wt; do
    if [[ "$PWD/" == "$wt/"* ]]; then
      echo "$wt"
      break
    fi
  done)

  # If in the root worktree (or can't determine), use zoxide normally
  if [[ -z "$current_wt" || "$current_wt" == "$root_wt" ]]; then
    __zoxide_z "$@"
    return
  fi

  # Map current dir to root worktree, query zoxide from there
  local mapped_pwd="${root_wt}${PWD#$current_wt}"
  local dest
  dest=$(cd "$mapped_pwd" 2>/dev/null && zoxide query --exclude "$mapped_pwd" "$@") || {
    __zoxide_z "$@"
    return
  }

  # If result is inside the root worktree, remap to current worktree
  if [[ "$dest" == "$root_wt"* ]]; then
    dest="${current_wt}${dest#$root_wt}"
  fi

  echo "$dest"
  cd "$dest"
}

[[ -r $HOME/.system_specific_vars ]] && . $HOME/.system_specific_vars

# Fish-like syntax highlighting. Install with `brew install zsh-syntax-highlighting`. Must stay at EOF!
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
