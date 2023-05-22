# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "i915.force_probe=4626" "i915.enable_psr=1"];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/67f2b2e1-0854-4e1f-b2da-698222a22d0c";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-6c21e3f5-46f9-4d86-9a28-9c369321fcd0".device = "/dev/disk/by-uuid/6c21e3f5-46f9-4d86-9a28-9c369321fcd0";

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/F82A-29D3";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/d05bc568-89f5-46e7-b1da-6b72476146ac"; }
    ];

  # Enable thermal data
  services.thermald.enable = true;

  # Enable fingerprint support
  # fingerprint reader: login and unlock with fingerprint (if you add one with
  # `fprintd-enroll`)
  services.fprintd.enable = true;

  hardware.opengl.extraPackages = with pkgs; [
    mesa_drivers
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp166s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

