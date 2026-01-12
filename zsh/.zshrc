zstyle ":completion:*:commands" rehash 1

# Save existing PATH before typeset -U (which may reset it)
_SAVED_PATH="$PATH"

# Only set typeset -U if path array is not already set
if [[ ${#path[@]} -eq 0 ]]; then
  typeset -U path PATH
  # Restore PATH from saved value
  PATH="$_SAVED_PATH"
  # Rebuild path array from PATH
  path=(${(s/:/)PATH})
else
  typeset -U path PATH
fi

# Nix - Initialize first to set up Nix environment (if not already done in .zprofile)
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
fi

# Add /nix/var/nix/profiles/default/bin to PATH (where nix command actually exists)
# This must be done after Nix initialization to ensure it's in PATH
if [[ ":$PATH:" != *":/nix/var/nix/profiles/default/bin:"* ]]; then
  PATH="/nix/var/nix/profiles/default/bin:$PATH"
fi

# zsh-completions, zsh-autosuggestions, and syntax highlighting are managed by Home Manager
autoload -Uz compinit && compinit

alias python="python3"
autoload -Uz colors && colors
# zsh-git-prompt is replaced with a custom git_prompt function managed by Home Manager
PROMPT="%n ($(arch)):%~"$'\n'"%# "
git_prompt() {
  if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = true ]; then
    # Using git status for prompt (simplified version)
    local git_status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$git_status" -gt 0 ]; then
      PROMPT="%F{green}%n%f %F{cyan}($(arch))%f %F{034}%h%f:%F{020}%~%f %F{red}*%f "$'\n'"%# "
    else
      PROMPT="%F{green}%n%f %F{cyan}($(arch))%f %F{034}%h%f:%F{020}%~%f "$'\n'"%# "
    fi
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

# Add user-specific paths to PATH if not already present
if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
  PATH="$HOME/.cargo/bin:$PATH"
fi
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  PATH="$HOME/.local/bin:$PATH"
fi

# Ensure /nix/var/nix/profiles/default/bin is in PATH (final check)
# This is where the nix command actually exists
if [[ ":$PATH:" != *":/nix/var/nix/profiles/default/bin:"* ]]; then
  PATH="/nix/var/nix/profiles/default/bin:$PATH"
fi


