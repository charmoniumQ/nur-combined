{ stdenv
, bash
, bc
, bemenu
, bonsai
, brightnessctl
, buildPackages
, busybox
, conky
, coreutils
, curl
, dbus
, dmenu
, fetchgit
, fetchpatch
, gitUpdater
, gnugrep
, gojq
, grim
, inotify-tools
, j4-dmenu-desktop
, jq
, lib
, libnotify
, libxml2
, lisgd
, makeBinaryWrapper
, mako
, modemmanager
, nettools
, networkmanager
, playerctl
, procps
, pulseaudio
, rsync
, scdoc
, scrot
, sfeed
, slurp
, superd
, sway
, swayidle
, systemd
, wob
, wl-clipboard
, wtype
, wvkbd
, xdg-user-dirs
, xdotool
, xrdb

, version
, rev ? version
, hash ? ""
, patches ? []
, supportSway ? true
, supportDwm ? false
, preferSystemd ? false
}:

let
  # anything which any sxmo script or default hook in this package might invoke
  runtimeDeps = [
    bc  # also in busybox
    bonsai
    brightnessctl
    conky
    curl
    dbus
    gnugrep  # also in busybox
    gojq
    inotify-tools
    j4-dmenu-desktop
    jq
    libnotify
    libxml2.bin  # for xmllint; sxmo_weather.sh, sxmo_surf_linkset.sh
    lisgd
    mako
    modemmanager  # mmcli
    nettools  # netstat
    networkmanager  # nmcli
    playerctl
    procps  # pgrep
    pulseaudio  # pactl
    sfeed
    wob
    xdg-user-dirs  # used by sxmo_hook_start.sh
    xrdb  # for sxmo_xinit AND sxmo_winit
  ] ++ (
    if preferSystemd then [ systemd ] else [ superd ]
  ) ++ lib.optionals supportSway [
    bemenu
    grim
    slurp  # for sxmo_screenshot.sh
    sway
    swayidle
    wl-clipboard  # for wl-copy; sxmo_screenshot.sh
    wtype  # for sxmo_type
    wvkbd  # sxmo_winit.sh
  ] ++ lib.optionals supportDwm [
    dmenu
    scrot  # sxmo_screenshot.sh
    xdotool
  ];
in
stdenv.mkDerivation rec {
  pname = "sxmo-utils";
  inherit version;

  src = fetchgit {
    url = "https://git.sr.ht/~mil/sxmo-utils";
    inherit rev hash;
  };

  inherit patches;

  postPatch = ''
    # allow sxmo to source its init file
    sed -i "s@/etc/profile\.d/sxmo_init.sh@$out/etc/profile.d/sxmo_init.sh@" scripts/core/*.sh
    # remove absolute paths
    substituteInPlace scripts/core/sxmo_version.sh \
      --replace "/usr/bin/" ""

    # let superd find sxmo service binaries at runtime via PATH
    # TODO: replace with fully-qualified paths
    sed -i 's:ExecStart=/usr/bin/:ExecStart=/usr/bin/env :' configs/superd/services/*.service

    # install udev rules to where nix expects
    substituteInPlace Makefile \
      --replace "/usr/lib/udev/rules.d" "/etc/udev/rules.d"
    # avoid relative paths in udev rules
    substituteInPlace configs/udev/90-sxmo.rules \
      --replace "/bin/chgrp" "${coreutils}/bin/chgrp" \
      --replace "/bin/chmod" "${coreutils}/bin/chmod"
  '' + lib.optionalString preferSystemd ''
    sed -i 's/superctl/systemctl --user/g' **/*.sh
  '';

  nativeBuildInputs = [
    makeBinaryWrapper
    scdoc
  ];

  buildInputs = [ bash ];  # needed here so stdenv's `patchShebangsAuto` hook sets the right interpreter

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "SYSCONFDIR=${placeholder "out"}/etc"
    "DESTDIR="
    "OPENRC=0"
  ];
  preInstall = ''
    # busybox is used by setup_config_version.sh, but placing it in nativeBuildInputs breaks the nix builder
    PATH="$PATH:${buildPackages.busybox}/bin"
  '';

  # we don't wrap sxmo_common.sh or sxmo_init.sh
  # which is unfortunate, for non-sxmo-utils files that might source those.
  # if that's a problem, could inject a PATH=... line into them with sed.
  postInstall = ''
    for f in \
      $out/bin/*.sh \
      $out/share/sxmo/default_hooks/desktop/sxmo_hook_*.sh \
      $out/share/sxmo/default_hooks/one_button_e_reader/sxmo_hook_*.sh \
      $out/share/sxmo/default_hooks/three_button_touchscreen/sxmo_hook_*.sh \
      $out/share/sxmo/default_hooks/sxmo_hook_*.sh \
    ; do
      case $(basename $f) in
        (sxmo_common.sh|sxmo_deviceprofile_*.sh|sxmo_hook_icons.sh|sxmo_init.sh)
          # these are sourced by other scripts: don't wrap them else the `exec` in the nix wrapper breaks the outer script
        ;;
        (*)
          wrapProgram "$f" \
            --suffix PATH : "${lib.makeBinPath runtimeDeps}"
        ;;
      esac
    done
  '';

  passthru = {
    inherit runtimeDeps;
    providedSessions = (lib.optional supportSway "swmo") ++ (lib.optional supportDwm "sxmo");
    updateScript = gitUpdater { };
  };

  meta = {
    homepage = "https://git.sr.ht/~mil/sxmo-utils";
    description = "Contains the scripts and small C programs that glues the sxmo enviroment together";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux; 
  };
}
