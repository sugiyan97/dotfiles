{ config, pkgs, ... }:

let
  # Try to get username from USER environment variable first, then from HOME
  userEnv = builtins.getEnv "USER";
  homeEnv = builtins.getEnv "HOME";
  # Extract username from HOME path using regex (e.g., /Users/username -> username)
  homeMatch = if homeEnv != "" then builtins.match "/Users/(.+)" homeEnv else null;
  homeUsername = if homeMatch != null && homeMatch != [] then builtins.head homeMatch else null;
  username = if userEnv != "" then
    userEnv
  else if homeUsername != null then
    homeUsername
  else
    (builtins.abort "ERROR: Neither USER nor HOME environment variable is set. Please ensure at least one is set in your environment.");
in {
  # Home Manager needs to know the username
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # This value should be the same as the one in flake.nix
  home.stateVersion = "24.05";

  # Packages to install
  home.packages = with pkgs; [
    # Development tools
    git
    go
    yarn
    awscli2
    python313
  ];

  # Programs configuration
  programs = {
    # Zsh configuration
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      
      # Environment variables (equivalent to .zshenv)
      envExtra = ''
        . "$HOME/.cargo/env"
      '';

      # History configuration
      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };

      # Custom zshrc content
      initContent = ''
        zstyle ":completion:*:commands" rehash 1

        # Set typeset -U to make path array unique
        # typeset -U will convert existing PATH to path array without resetting it
        typeset -U path PATH

        # Set up base PATH
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

        # Nix - Initialize if not already done in .zprofile
        # Note: .zprofile is loaded before .zshrc, so Nix may already be initialized.
        # This is a fallback initialization in case .zprofile wasn't loaded or Nix wasn't initialized there.
        if [ -z "''$NIX_PATH" ] && [ -e "''$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
          . "''$HOME/.nix-profile/etc/profile.d/nix.sh"
        elif [ -z "''$NIX_PATH" ] && [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
        fi

        # Nix SSL Certificate Configuration
        # Set SSL certificate path for Git and other tools using Nix-managed certificates
        if command -v nix-build >/dev/null 2>&1; then
          # Try to get the certificate path from nixpkgs
          NIX_CERT_PATH=$(nix-build '<nixpkgs>' -A cacert --no-out-link 2>/dev/null)
          if [ -n "''$NIX_CERT_PATH" ] && [ -f "''$NIX_CERT_PATH/etc/ssl/certs/ca-bundle.crt" ]; then
            export SSL_CERT_FILE="''$NIX_CERT_PATH/etc/ssl/certs/ca-bundle.crt"
            export NIX_SSL_CERT_FILE="''${SSL_CERT_FILE}"
          elif [ -f "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt" ]; then
            export SSL_CERT_FILE="/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
            export NIX_SSL_CERT_FILE="''${SSL_CERT_FILE}"
          fi
        fi

        # Add /nix/var/nix/profiles/default/bin to PATH (where nix command actually exists)
        # This must be done after Nix initialization to ensure it's in PATH
        if [[ ":''$PATH:" != *":/nix/var/nix/profiles/default/bin:"* ]]; then
          PATH="/nix/var/nix/profiles/default/bin:''$PATH"
        fi

        # Initialize completion (Home Manager enables completion, but compinit may still be needed)
        autoload -Uz compinit && compinit

        alias python="python3"
        autoload -Uz colors && colors

        PROMPT="%n (''$(arch)):%~"''$'\n'"%# "
        git_prompt() {
          if [ "''$(git rev-parse --is-inside-work-tree 2> /dev/null)" = true ]; then
            local branch=$(git branch --show-current 2>/dev/null)
            local git_status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [ "''$git_status" -gt 0 ]; then
              PROMPT="%F{green}%n%f %F{cyan}(''$(arch))%f %F{034}%h%f:%F{020}%~%f (%F{yellow}''${branch}%f|✚''${git_status}) "''$'\n'"%# "
            else
              PROMPT="%F{green}%n%f %F{cyan}(''$(arch))%f %F{034}%h%f:%F{020}%~%f (%F{yellow}''${branch}%f) "''$'\n'"%# "
            fi
          else
            PROMPT="%F{green}%n%f %F{cyan}(''$(arch))%f %F{034}%h%f:%F{020}%~%f "''$'\n'"%# "
          fi
        }

        add_newline() {
          if [[ -z ''${PS1_NEWLINE_LOGIN} ]]; then
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
        if [[ ":''$PATH:" != *":''$HOME/.cargo/bin:"* ]]; then
          PATH="''$HOME/.cargo/bin:''$PATH"
        fi
        if [[ ":''$PATH:" != *":''$HOME/.local/bin:"* ]]; then
          PATH="''$HOME/.local/bin:''$PATH"
        fi

        # Ensure /nix/var/nix/profiles/default/bin is in PATH (final check)
        # This is where the nix command actually exists
        if [[ ":''$PATH:" != *":/nix/var/nix/profiles/default/bin:"* ]]; then
          PATH="/nix/var/nix/profiles/default/bin:''$PATH"
        fi
      '';

      # Shell aliases
      shellAliases = {
        python = "python3";
      };
    };

    # Git configuration
    git = {
      enable = true;
      settings = {
        user.name = "yoshiyukisugiyama3";
        # email is not set here - configure separately if needed
      };
    };
  };

  # XDG directories
  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
  };
}
