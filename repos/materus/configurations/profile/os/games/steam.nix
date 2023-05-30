{ config, pkgs, lib, materusPkgs, inputs, ... }:
let

  pkgsGlbic = import
    (pkgs.fetchzip {
      url = "https://github.com/NixOS/nixpkgs/archive/22.11.tar.gz";
      sha256 = "sha256-/HEZNyGbnQecrgJnfE8d0WC5c1xuPSD2LUpB6YXlg4c=";
    })
    { system = pkgs.system; };



  steamPkg = pkgs.steam.override {
    extraPkgs = pkgs: [
      pkgs.nss_latest
      pkgs.libstrangle
      pkgs.libkrb5
      pkgs.keyutils
      pkgs.libGL
      pkgs.libglvnd
      pkgs.gamescope
      pkgs.steamPackages.steam
      pkgs.libxcrypt
      pkgs.gnutls
      pkgs.xorg.libXcursor
      pkgs.xorg.libXi
      pkgs.xorg.libXinerama
      pkgs.xorg.libXScrnSaver
      pkgs.xorg.xinput
      pkgs.libinput
      pkgs.openvdb
      pkgs.tbb_2021_8
      pkgs.gtk4
      pkgs.gtk3
      pkgs.glib
      pkgs.gsettings-desktop-schemas
      pkgs.fuse
      pkgs.libsForQt5.breeze-qt5
      pkgs.libsForQt5.breeze-gtk

    ];

    extraLibraries = pkgs: [
      pkgs.libkrb5
      pkgs.keyutils
      pkgs.ncurses6
      pkgs.xorg.xinput
      pkgs.libinput
      pkgs.fontconfig
      pkgs.libxcrypt
      pkgs.gnutls
    ] ++
    (with config.hardware.opengl; if pkgs.hostPlatform.is64bit
    then [ package ] ++ extraPackages
    else [ package32 ] ++ extraPackages32);

    extraEnv = {
      XDG_DATA_DIRS = "/usr/share:\${XDG_DATA_DIRS}";
      OBS_VKCAPTURE = "1";
    };

  };

  cfg = config.materus.profile.steam;
in
{
  options.materus.profile.steam.enable = materusPkgs.lib.mkBoolOpt false "Enable materus steam settings for OS";
  options.materus.profile.steam.package = lib.mkOption {
    type = lib.types.package;
    default = steamPkg;
    description = "Package used by steam";
  };


  config = lib.mkIf cfg.enable {
    hardware.steam-hardware.enable = lib.mkDefault true;
    programs.steam = {
      enable = lib.mkDefault true;
      dedicatedServer.openFirewall = lib.mkDefault true;
      remotePlay.openFirewall = lib.mkDefault true;
    };
    environment.sessionVariables = rec {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = lib.mkDefault "\${HOME}/.steam/root/compatibilitytools.d";
    };
    environment.systemPackages = [
      steamPkg
      steamPkg.run

    ];
  };
}
