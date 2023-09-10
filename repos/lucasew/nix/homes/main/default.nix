{ global, pkgs, lib, self, ... }:
let
  inherit (lib.hm.gvariant) mkTuple;
  inherit (pkgs.custom) colors;
in {

  imports = [
    ../base/default.nix
    ./dlna.nix
    ./helix.nix
    ./espanso.nix
    ./dconf.nix
    ./borderless-browser.nix
    ./theme

  ];

  services.espanso.enable = true;
  programs.man.enable = true;


  home = {
    homeDirectory = /home/lucasew;
    inherit (global) username;
  };

  home.packages = with pkgs; [
    anki
    calibre # a dependency is broken
    chromium
    custom.tixati
    custom.pidgin
    (custom.neovim.override { inherit colors; })
    (custom.emacs.override { inherit colors; })
    # custom.firefox # now I am using chromium
    custom.vscode.programming
    devenv
    dotenv
    discord
    jless # json viewer
    rustdesk # remote desktop for many systems
    gscan2pdf
    feh
    fortune
    graphviz
    github-cli
    gimp
    gnome.evince
    libnotify
    libreoffice
    mendeley
    ncdu
    nix-option
    nix-prefetch-scripts
    nix-output-monitor
    obsidian
    pkg
    rclone
    ripgrep
    fd
    remmina
    sqlite
    sshpass
    nbr.telegram-desktop-bin # communication
    terraform
    vlc # media
    stremio
    sunshine
    moonlight-qt
    nbr.wine-apps._7zip
    xxd
    pavucontrol # controle de volume
    pytorrentsearch
    # LSPs
    nil
    python3Packages.python-lsp-server
  ] ;

  # programs.hello-world.enable = true;

  services.redial_proxy.enable = true;

  programs = {
    # adskipped-spotify.enable = true;
    jq.enable = true;
    obs-studio = {
      enable = true;
    };
    htop = {
      enable = true;
      settings = {
        hideThreads = true;
        treeView = true;
      };
    };
  };

  gtk = {
    enable = true;
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  programs.terminator = {
    enable = true;
    config = {
      global_config.borderless = true;
    };
  };
  programs.bash.enable = true;
}
