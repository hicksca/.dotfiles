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
      initExtra = ''
        eval -- "$(/home/cah/.nix-profile/bin/starship init bash --print-full-init)"
      '';
    };
  };
}
