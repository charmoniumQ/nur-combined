{
  lib,
  pkgs,
  data,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  time.timeZone = "America/Los_Angeles";
  networking.nameservers = [ "8.8.8.8" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  users.mutableUsers = false;
  users.users.root = {
    hashedPassword = data.keys.hashedPasswd;
    openssh.authorizedKeys.keys = [
      data.keys.sshPubKey
      data.keys.skSshPubKey
    ];
  };

  systemd.network.enable = true;
  services.resolved.enable = true;

  systemd.network.networks.eth0 = {
    matchConfig.Name = "eth0";
    DHCP = "yes";
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = lib.mkForce "prohibit-password";
    };
  };

  networking.firewall.enable = false;

  networking.useNetworkd = true;

  networking.hostName = "bootstrap";

  system.stateVersion = "24.05";
}
