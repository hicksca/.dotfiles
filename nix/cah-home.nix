{ config, pkgs, lib, ... }:
let
  inherit (pkgs) stdenv fetchurl;
in
{
  home-manager.users.cah = {
    home.stateVersion = "23.11";

    # List your user-specific packages here
    home.packages = with pkgs; [
      # core tools
      starship
      fzf
      tree
      bat
      gh #github cli
    ];

    # Git configuration
    programs.git = {
      enable = true;
      userName = "hicksca (Carl H)";
      userEmail = "cah@hicksca.dev";

      extraConfig = {
        alias.co = "checkout";
        alias.br = "branch";
        alias.ci = "commit";
        alias.st = "status";

        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
    };

    # Neovim configuration
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-nix
      ];
      extraConfig = ''
        set number
        syntax enable
        filetype plugin on
        highlight Normal ctermbg=NONE guibg=NONE
        highlight NonText ctermbg=NONE guibg=NONE
      '';
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # Shell configuration
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        nv = "nvim";
      };
      initExtra = ''
        eval -- "$(/home/cah/.nix-profile/bin/starship init zsh)"
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh
        source ${pkgs.fzf}/share/fzf/completion.zsh
        setopt autocd
      '';
      history = {
        size = 10000;
        path = "$HOME/.zsh_history";
        ignoreDups = true;
        share = true;
      };
      autocd = true;
    };
    
    # fzf configuration
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # Starship configuration
    programs.starship = {
      enable = true;
      settings = {
        format = "$nix_shell$directory$git_branch$git_status$character";
        add_newline = true;
        directory = {
          style = "blue";
          truncation_length = 1;
          truncate_to_repo = true;
          format = "[$path]($style) ";
        };
        character = {
          success_symbol = "[❯](green)";
          error_symbol = "[❯](red)";
        };
        git_branch = {
          symbol = " ";
          style = "purple";
          format = "on [$symbol$branch]($style) ";
        };
        git_status = {
          format = "[$all_status$ahead_behind]($style) ";
          style = "red";
        };
        hostname = {
          disabled = true;
        };
        username = {
          disabled = true;
        };

        # Configure the built-in nix_shell module
        nix_shell = {
          format = "[\\[$name:$state\\]]($style) ";
          style = "bold blue";
          impure_msg = "impure";
          pure_msg = "pure";
          disabled = false;
        };
      };
    };
  };
}
