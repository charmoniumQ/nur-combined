{ ... }:
{
  sane.programs.steam = {
    sandbox.method = "bwrap";
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  #< to open https:// links in portal
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.whitelistX = true;

    persist.byStore.plaintext = [
      ".steam"
      ".local/share/Steam"
    ];
  };
  # steam requires system-level config for e.g. firewall or controller support
  # programs.steam = lib.mkIf config.sane.programs.steam.enabled {
  #   enable = true;
  #   package = config.sane.programs.steam.package;
  #   # not sure if needed: stole this whole snippet from the wiki
  #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  # };
}
