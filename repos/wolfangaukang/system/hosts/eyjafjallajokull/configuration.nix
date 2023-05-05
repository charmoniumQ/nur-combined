{ config, lib, hostname, inputs, ... }:

let
  inherit (lib) mkForce;
  inherit (inputs) self;
  system-lib = import "${self}/system/lib" { inherit inputs; };
  inherit (system-lib) obtainIPV4Address obtainIPV4GatewayAddress;

in {
  imports = [
    ./disk-setup.nix
    ./hardware-configuration.nix
    (import "${self}/system/profiles/sets/workstation.nix" { inherit inputs hostname lib; })
  ];

  networking.hostName = hostname;

  profile = {
    nix = {
      enableAutoOptimise = true;
      enableFlakes = true;
      enableUseSandbox = true;
    };
    mobile-devices = {
      android.enable = true;
      ios.enable = true;
    };
    sound = {
      enable = true;
      enableOSSEmulation = true;
      pipewire = {
        enable = true;
        enableAlsa32BitSupport = true;
      };
    };
    virtualization.podman.enable = true;
  };

  environment.etc.machine-id.text = "80ae91d7d531482f86a7e2092eb24af2";

  #services.openssh.settings.PermitRootLogin = mkForce "yes";

  # Extra settings (22.11)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "22.11";
}

