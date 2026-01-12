
eval "$(/opt/homebrew/bin/brew shellenv)"

# Python 3.13 is managed by Nix/Home Manager
# PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:${PATH}" - Removed, using Nix-managed Python 3.13

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# OrbStack initialization removed (not migrated to Nix)

# Nix
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
fi
