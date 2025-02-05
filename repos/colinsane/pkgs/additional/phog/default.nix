{ lib
, stdenv
, fetchFromGitLab
, fetchpatch
, meson
, ninja
, pkg-config
, gcr
, gitUpdater
, glib
, gnome-desktop
, gtk3
, libgudev
, libjson
, json-glib
, libhandy
, networkmanager
, linux-pam
, systemd
, upower
, wayland
, libxkbcommon
, python3
, phoc
, bash
, gnome
, squeekboard ? null
, wayland-scanner
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "phog";
  version = "0.1.6";

  src = fetchFromGitLab {
    owner = "mobian1";
    repo = "phog";
    rev = version;
    hash = "sha256-PlVhTFH53nk+h1WPli1r+xUwU5/xObSTzdAfrdZOezs=";
  };

  patches = [
    # (fetchpatch {
    #   # merged post 0.1.4
    #   # https://gitlab.com/mobian1/phog/-/merge_requests/4
    #   # fixes "json_node_unref: assertion 'JSON_NODE_IS_VALID (node)' failed"
    #   name = "greetd: Don't free reply_root";
    #   url = "https://gitlab.com/mobian1/phog/-/commit/ad1a2b876a1205f0927c7c02e0471364d557e3fe.patch";
    #   hash = "sha256-gYQLDCKNIc4xPtgKRMzH4fmayx5w2oED2FjkD7fKswA=";
    # })
    ./sway-compat.patch
  ];

  postPatch = ''
    patchShebangs build-aux/post_install.py
    sed -i /phog_plugins_dir/d build-aux/post_install.py
    substituteInPlace src/greetd.c \
      --replace-fail '/usr/share/wayland-sessions' '/run/current-system/sw/share/wayland-sessions/' \
      --replace-fail '/usr/share/xsessions' '/run/current-system/sw/share/xsessions'
  '' + lib.optionalString (squeekboard == null) ''
    substituteInPlace data/phog.in \
      --replace-fail " & squeekboard" ""
  '';
  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ bash squeekboard ]}
      --prefix XDG_DATA_DIRS : "${gnome.gnome-shell}/share/gsettings-schemas/${gnome.gnome-shell.name}"
    )
  '';


  mesonFlags = [ "-Dcompositor=${phoc}/bin/phoc" ];

  depsBuildBuild = [
    pkg-config
  ];

  buildInputs = [
    gcr
    glib
    gnome-desktop
    gtk3
    libgudev
    libjson
    json-glib
    libhandy
    networkmanager
    linux-pam
    systemd
    upower
    wayland
    libxkbcommon
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    glib
    wayland-scanner
    wrapGAppsHook
  ];

  passthru.updateScript = gitUpdater {};

  meta = with lib; {
    description = "Greetd-compatible greeter for mobile phones";
    homepage = "https://gitlab.com/mobian1/phog/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ matthewcroughan ];
  };
}
