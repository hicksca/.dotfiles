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
    ];

    # Git configuration
    programs.git = {
      enable = true;
      userName = "hicksca (Carl H)";
      userEmail = "cah@hicksca.dev";

      extraConfig = {
        user.signingKey = "EBE68890";
        commit.gpgSign = true;

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
      '';
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # Shell configuration
    programs.bash = {
      enable = true;
      shellAliases = {
        nv = "nvim";
      };
    };

    # SSH key management
    home.file.".ssh/id_ed25519" = {
      source = "/home/cah/.ssh/id_ed25519";
    };

    home.file.".ssh/id_ed25519.pub" = {
      source = "/home/cah/.ssh/id_ed25519.pub";
    };

    home.file.".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
    '';

    # Ensure GPG_TTY is set correctly
    # home.sessionVariables.GPG_TTY = "xterm-kitty";

  };
}
