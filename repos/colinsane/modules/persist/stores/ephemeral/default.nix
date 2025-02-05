{ config, lib, pkgs, sane-lib, ... }:

let
  persist-base = "/nix/persist";
  origin = config.sane.persist.stores."ephemeral".origin;
  backing = sane-lib.path.concat [ persist-base "ephemeral" ];
in
lib.mkIf config.sane.persist.enable
{

  sane.programs.gocryptfs-ephemeral = {
    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "gocryptfs-ephemeral";
      srcRoot = ./.;
      pkgs = [
        "coreutils-full"
        "gocryptfs"
      ];
    };
    sandbox.method = "landlock";
    sandbox.autodetectCliPaths = "existing";
    sandbox.capabilities = [
      # "sys_admin"  #< omitted: not required if using fuse3-sane with -o pass_fuse_fd
      "chown"
      "dac_override"
      "dac_read_search"
      "fowner"
      "lease"
      "mknod"
      "setgid"
      "setuid"
    ];
    suggestedPrograms = [ "gocryptfs" ];
  };

  sane.persist.stores."ephemeral" = {
    storeDescription = ''
      stored to disk, but encrypted to an in-memory key and cleared on every boot
      so that it's unreadable after power-off
    '';
    origin = lib.mkDefault "/mnt/persist/ephemeral";
  };

  fileSystems."${origin}" = {
    device = "gocryptfs-ephemeral#${backing}";
    fsType = "fuse3.sane";
    options = [
      "nodev"   # only works via mount.fuse; gocryptfs requires this be passed as `-ko nodev`
      "nosuid"  # only works via mount.fuse; gocryptfs requires this be passed as `-ko nosuid` (also, nosuid is default)
      "allow_other"  # root ends up being the user that mounts this, so need to make it visible to other users.
      # "defaults"  # "unknown flag: --defaults. Try 'gocryptfs -help'"
      "pass_fuse_fd"
    ];
    noCheck = true;
  };
  # let sane.fs know about our fileSystem and automatically add the appropriate dependencies
  sane.fs."${origin}" = {
    wantedBeforeBy = [ "local-fs.target" ];
    mount.depends = [
      config.sane.fs."${backing}".unit
    ];
    # hardening (systemd-analyze security mnt-persist-ephemeral.mount)
    mount.mountConfig.AmbientCapabilities = "CAP_SYS_ADMIN CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_CHOWN CAP_MKNOD CAP_LEASE CAP_SETGID CAP_SETUID CAP_FOWNER";
    # CAP_LEASE is probably not necessary -- does any fs user use leases?
    mount.mountConfig.CapabilityBoundingSet = "CAP_SYS_ADMIN CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_CHOWN CAP_MKNOD CAP_LEASE CAP_SETGID CAP_SETUID CAP_FOWNER";
    mount.mountConfig.LockPersonality = true;
    mount.mountConfig.MemoryDenyWriteExecute = true;
    mount.mountConfig.NoNewPrivileges = true;
    mount.mountConfig.ProtectClock = true;
    mount.mountConfig.ProtectHostname = true;
    mount.mountConfig.RemoveIPC = true;
    mount.mountConfig.RestrictAddressFamilies = "AF_UNIX";  # "none" works, but then it can't connect to the logger
    #VVV this includes anything it reads from, e.g. /bin/sh; /nix/store/...
    # see `systemd-analyze filesystems` for a full list
    mount.mountConfig.RestrictFileSystems = "@common-block @basic-api fuse pipefs";
    mount.mountConfig.RestrictNamespaces = true;
    mount.mountConfig.RestrictNetworkInterfaces = "";
    mount.mountConfig.RestrictRealtime = true;
    mount.mountConfig.RestrictSUIDSGID = true;
    mount.mountConfig.SystemCallArchitectures = "native";
    mount.mountConfig.SystemCallFilter = [
      # unfortunately, i need to keep @network-io (accept, bind, connect, listen, recv, send, socket, ...). not sure why (daemon control socket?).
      "@system-service" "@mount" "@sandbox" "~@cpu-emulation" "~@keyring"
    ];
    mount.mountConfig.IPAddressDeny = "any";
    mount.mountConfig.DevicePolicy = "closed";  # only allow /dev/{null,zero,full,random,urandom}
    mount.mountConfig.DeviceAllow = "/dev/fuse";
    mount.mountConfig.SocketBindDeny = "any";
    # note that anything which requires mount namespaces (ProtectHome, ReadWritePaths, ...) does NOT work.
    # it's in theory possible, via mount propagation, but systemd provides no way for that.
    # PrivateNetwork = true  BREAKS the mount action; i think systemd or udev needs that internally to communicate with the service manager?
  };
  sane.fs."${backing}".dir = {};

  sane.programs.gocryptfs-ephemeral.enableFor.system = true;
  system.fsPackages = [ pkgs.libfuse-sane ];
}
