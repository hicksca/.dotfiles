{ config, pkgs, lib, ... }:
let
  inherit (pkgs) stdenv fetchurl;
in
{
  home-manager.users.cah = {
    home.stateVersion = "23.11";

    # List your user-specific packages here
    home.packages = with pkgs; [
      gh
      starship
      fzf
    ];

    # Git configuration
    programs.git = {
      enable = true;
      userName = "hicksca (Carl H)";
      userEmail = "cah@hicksca.dev";

      extraConfig = {
        # user.signingKey = "EBE68890";
        # commit.gpgSign = true;

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
        format = "$directory$git_branch$git_status$character";
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
      };
    };
  };
}
