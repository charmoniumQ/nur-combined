{ lib, ... }:

let
  inherit (lib) mkOption;
  inherit (lib.types) int path str;

  identity = import ./resources/identity.nix;
in
{
  # Workaround for https://github.com/nix-community/home-manager/issues/2333#issuecomment-1242564101
  disabledModules = [ "config/i18n.nix" ];

  imports = [
    ./components/applications.user.nix
    ./components/browser.user.nix
    ./components/desktop.user.nix
    ./components/display.user.nix
    ./components/editor.user.nix
    ./components/fonts.user.nix
    ./components/git.user.nix
    ./components/keyboard.user.nix
    ./components/nix.user.nix
    ./components/openpgp.user.nix
    ./components/shell.user.nix
    ./components/spelling.user.nix
    ./components/terminal.user.nix
  ];

  options.host = {
    background = mkOption { type = str; };
    cores = mkOption { type = int; };
    display_density = mkOption { type = int; };
    display_width = mkOption { type = int; };
    firefoxProfile = mkOption { type = str; };
    local = mkOption { type = path; };
  };

  config = {
    # Home manager
    programs.home-manager.enable = true;
    manual.html.enable = true;

    # User
    home.username = identity.username;
    home.homeDirectory = "/home/${identity.username}";
    home.file.".face".source = identity.image;
  };
}
