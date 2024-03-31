# this builds a disk image which can be flashed onto a HDD, SD card, etc, and boot a working image.
# debug the image by building one of:
# - `nix build '.#imgs.$host' --builders "" -v`
# - `nix build '.#imgs.$host.passthru.{bootFsImg,nixFsImg,withoutBootloader}'`
# then loop-mounting it:
# - `sudo losetup -Pf ./result/nixos.img`
# - `mkdir /tmp/nixos.boot`
# - `sudo mount /dev/loop0p1 /tmp/nixos.boot`, and look inside
#
# TODO: replace mobile-nixos parts with Disko <https://github.com/nix-community/disko>
#   or just inline them here.
{ config, lib, pkgs, utils, ... }:

with lib;
let
  cfg = config.sane.image;
in
{
  options = {
    sane.image.enable = mkOption {
      default = true;
      type = types.bool;
      description = "whether to enable image targets. even so they won't be built unless you specifically reference the `system.build.img` target.";
    };
    # packages whose contents should be copied directly into the /boot partition.
    # e.g. EFI loaders, u-boot bootloader, etc.
    sane.image.extraBootFiles = mkOption {
      default = [];
      type = types.listOf types.package;
    };
    # extra (empty) directories to create in the rootfs.
    # for example, /var/log might be required by the boot process, so ensure it exists.
    sane.image.extraDirectories = mkOption {
      default = [];
      type = types.listOf types.str;
    };

    # the GPT header is fixed to Logical Block Address 1,
    # but we can actually put the partition entries anywhere.
    # this option reserves so many bytes after LBA 1 but *before* the partition entries.
    # this is not universally supported, but is an easy hack to claim space near the start
    # of the disk for other purposes (e.g. firmware blobs)
    sane.image.extraGPTPadding = mkOption {
      default = 0;
      # NB: rpi doesn't like non-zero values for this.
      # at the same time, spinning disks REALLY need partitions to be aligned to 4KiB boundaries.
      # maybe there's some imageBuilder.fileSystem type which represents empty space?
      # default = 2014 * 512;  # standard is to start part0 at sector 2048  (versus 34 if no padding)
      type = types.int;
    };
    # optional space (in bytes) to leave unallocated after the GPT structure and before the first partition.
    sane.image.firstPartGap = mkOption {
      # align the first part to 16 MiB.
      # do this by inserting a gap of 16 MiB - gptHeaderSize
      # and then multiply by 1MiB and subtract 1 because mobile-nixos
      # has a bug which will divide this by 1 MiB (and round up)
      default = (16 * 1024 * 1024 - 34 * 512) * 1024 * 1024 - 1;
      type = types.nullOr types.int;
    };
    sane.image.bootPartSize = mkOption {
      default = 512 * 1024 * 1024;
      type = types.int;
    };
    sane.image.sectorSize = mkOption {
      default = 512;
      type = types.int;
      description = ''
        disk sector size. MUST match what the disk firmware believes it to be.
        for nvme drives it may be better to use a large sector size like 4096.
        see: <https://wiki.archlinux.org/title/Advanced_Format#Changing_sector_size>.

        N.B.: setting this to something other than 512B is not well tested.
      '';
    };
    sane.image.installBootloader = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = ''
        command which takes the full disk image and installs hw-specific bootloader (u-boot, tow-boot, etc).
        for EFI-native systems (most x86_64), can be left empty.
      '';
    };
  };
  config = let
    # return true if super starts with sub
    startsWith = super: sub: (
      (builtins.substring 0 (builtins.stringLength sub) super) == sub
    );
    # return the (string) path to get from `stem` to `path`
    # or errors if not a sub-path
    relPath = stem: path: (
      builtins.head (builtins.match "^${stem}(.+)" path)
    );

    fileSystems = config.fileSystems;
    bootFs = fileSystems."/boot";
    nixFs = fileSystems."/nix/store" or fileSystems."/nix" or fileSystems."/";
    # resolves to e.g. "nix/store", "/store" or ""
    storeRelPath = relPath nixFs.mountPoint "/nix/store";

    uuidFromFs = fs: builtins.head (builtins.match "/dev/disk/by-uuid/(.+)" fs.device);
    vfatUuidFromFs = fs: builtins.replaceStrings ["-"] [""] (uuidFromFs fs);

    fsBuilderMapBoot = {
      "vfat" = pkgs.imageBuilder.fileSystem.makeESP;
    };
    fsBuilderMapNix = {
      "ext4" = pkgs.imageBuilder.fileSystem.makeExt4;
      "btrfs" = pkgs.imageBuilder.fileSystem.makeBtrfs;
    };

    bootFsImg = fsBuilderMapBoot."${bootFs.fsType}" {
      # fs properties
      name = "ESP";
      partitionID = vfatUuidFromFs bootFs;
      # partition properties
      partitionLabel = "EFI System";
      partitionUUID = "44444444-4444-4444-4444-4444${vfatUuidFromFs bootFs}";
      size = cfg.bootPartSize;
      inherit (cfg) sectorSize;
      blockSize = cfg.sectorSize;  # has to be a multiple of sectorSize

      populateCommands = let
        extras = builtins.toString (builtins.map (d: "cp -R ${d}/* ./") cfg.extraBootFiles);
      in ''
        echo "running installBootLoader"
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d .
        echo "ran installBootLoader"
        ${extras}
        echo "copied extraBootFiles"
      '';
    };
    nixFsImg = fsBuilderMapNix."${nixFs.fsType}" {
      # fs properties
      name = "NIXOS_SYSTEM";
      partitionID = uuidFromFs nixFs;
      # partition properties
      partitionLabel = "Linux filesystem";
      partitionUUID = uuidFromFs nixFs;
      # inherit (cfg) sectorSize;  # imageBuilder only supports sectorSize for vfat. btrfs defaults to a 4096B sector size, somehow it abstracts over the drive's sector size?

      populateCommands = let
        closureInfo = pkgs.buildPackages.closureInfo { rootPaths = config.system.build.toplevel; };
        extraRelPaths = builtins.toString (builtins.map (p: "./" + builtins.toString(relPath nixFs.mountPoint p)) cfg.extraDirectories);
      in ''
        mkdir -p ./${storeRelPath} ${extraRelPaths}
        echo "Copying system closure..."
        while IFS= read -r path; do
          echo "  Copying $path"
          cp -prf "$path" ./${storeRelPath}
        done < "${closureInfo}/store-paths"
        echo "Done copying system closure..."
        cp -v ${closureInfo}/registration ./nix-path-registration
      '';
    };
    img = (pkgs.imageBuilder.diskImage.makeGPT {
      name = "nixos";
      diskID = vfatUuidFromFs bootFs;
      # leave some space for firmware
      # TODO: we'd prefer to turn this into a protected firmware partition, rather than reserving space in the GPT header itself
      # Tow-Boot manages to do that; not sure how.
      headerHole = cfg.extraGPTPadding;
      partitions = [
        (pkgs.imageBuilder.gap cfg.firstPartGap)
        bootFsImg
        nixFsImg
      ];
    }) // {
      passthru = {
        inherit bootFsImg nixFsImg;
      };
    };
  in
  lib.mkIf cfg.enable
  {
    system.build.img = (if cfg.installBootloader == null then
      img
    else pkgs.runCommand "nixos-with-bootloader" {} ''
      cp -vR ${img} $out
      chmod -R +w $out
      ${cfg.installBootloader}
    '') // {
      passthru = {
        inherit bootFsImg nixFsImg;
        withoutBootloader = img;
      };
    };
  };
}
