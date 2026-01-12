zstyle ":completion:*:commands" rehash 1
typeset -U path PATH
path=(
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /Library/Apple/usr/bin
)

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  autoload -Uz compinit && compinit
fi

alias python="python3"
autoload -Uz colors && colors
source $(brew --prefix)/opt/zsh-git-prompt/zshrc.sh
PROMPT="%n ($(arch)):%~"$'\n'"%# "
git_prompt() {
  if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = true ]; then
    PROMPT="%F{green}%n%f %F{cyan}($(arch))%f %F{034}%h%f:%F{020}%~%f $(git_super_status)"$'\n'"%# "
  else
    PROMPT="%F{green}%n%f %F{cyan}($(arch))%f %F{034}%h%f:%F{020}%~%f "$'\n'"%# "
  fi
}

add_newline() {
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}

precmd() {
  git_prompt
  add_newline
}

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"


