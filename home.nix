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

        alias python="python3"
        autoload -Uz colors && colors

        PROMPT="%n ($(arch)):%~"$'\n'"%# "
        git_prompt() {
          if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = true ]; then
            local branch=$(git branch --show-current 2>/dev/null)
            local git_status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [ "$git_status" -gt 0 ]; then
              PROMPT="%F{green}%n%f %F{cyan}($(arch))%f %F{034}%h%f:%F{020}%~%f (%F{yellow}''${branch}%f|✚''${git_status}) "$'\n'"%# "
            else
              PROMPT="%F{green}%n%f %F{cyan}($(arch))%f %F{034}%h%f:%F{020}%~%f (%F{yellow}''${branch}%f) "$'\n'"%# "
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

        export PATH="$HOME/.cargo/bin:$PATH"
        export PATH="$HOME/.local/bin:$PATH"
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
