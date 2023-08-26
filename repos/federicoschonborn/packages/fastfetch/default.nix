{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, cmake
, darwin
, ninja
, pkg-config
, yyjson

, enableChafa ? false
, chafa
, enableDbus ? false
, dbus
, enableDconf ? false
, dconf
, enableDdcutil ? false
, ddcutil
, enableEgl ? false
, libGL
, enableFreetype ? false
, freetype
, enableGio ? false
, glib
, libselinux
, libsepol
, pcre16
, pcre2
, utillinux
, enableGlx ? false
, libglvnd
, enableImagemagick ? false
, imagemagick
, enableLibnm ? false
, networkmanager
, enableLibpci ? false
, pciutils
, enableMesa ? false
, mesa_drivers
, enableOpencl ? false
, ocl-icd
, opencl-headers
, enablePulse ? false
, pulseaudio
, enableRpm ? false
, rpm
, enableSqlite3 ? false
, sqlite
, enableVulkan ? false
, vulkan-loader
, enableWayland ? false
, libffi
, wayland
, enableX11 ? false
, xorg
, enableXcb ? false
, enableXfconf ? false
, xfce
, enableXrandr ? false
, enableZlib ? false
, zlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fastfetch";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "LinusDierheimer";
    repo = "fastfetch";
    rev = finalAttrs.version;
    hash = "sha256-8A00XGKX/dbJElrHQrtoDCEGZJ8ktpFJ6zsxu2qZcxI=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    yyjson
  ]
  ++ lib.optionals enableChafa [ chafa ]
  ++ lib.optionals enableImagemagick [ imagemagick ]
  ++ lib.optionals enableSqlite3 [ sqlite ]
  ++ lib.optionals enableVulkan ([ vulkan-loader ] ++ lib.optionals stdenv.isDarwin [ darwin.moltenvk ])
  ++ lib.optionals enableZlib [ zlib ]
  ++ (
    lib.optionals (!stdenv.isDarwin) [ ]
      ++ lib.optionals enableDbus [ dbus ]
      ++ lib.optionals enableDconf [ dconf ]
      ++ lib.optionals enableDdcutil [ ddcutil ]
      ++ lib.optionals enableEgl [ libGL ]
      ++ lib.optionals enableFreetype [ freetype ]
      # glib depends on pcre2 and libselinux depends on pcre16
      ++ lib.optionals enableGio [ glib libselinux libsepol pcre16 pcre2 utillinux ]
      ++ lib.optionals enableGlx [ libglvnd ]
      ++ lib.optionals enableLibnm [ networkmanager ]
      ++ lib.optionals enableLibpci [ pciutils ]
      ++ lib.optionals enableMesa [ mesa_drivers.dev ]
      ++ lib.optionals enableOpencl [ ocl-icd opencl-headers ]
      ++ lib.optionals enablePulse [ pulseaudio ]
      ++ lib.optionals enableRpm [ rpm ]
      ++ lib.optionals enableWayland [ libffi wayland ]
      ++ lib.optionals enableX11 [ xorg.libX11 ]
      ++ lib.optionals enableXcb [ xorg.libXau xorg.libXdmcp xorg.libxcb ]
      ++ lib.optionals enableXfconf [ xfce.xfconf ]
      ++ lib.optionals enableXrandr [ xorg.libXext xorg.libXrandr ]
  );

  cmakeFlags = [
    "-DTARGET_DIR_ROOT=${placeholder "out"}"
    "-DENABLE_SYSTEM_YYJSON=YES"
  ];

  meta = with lib; {
    description = "Like neofetch, but much faster because written in C";
    homepage = "https://github.com/LinusDierheimer/fastfetch";
    changelog = "https://github.com/LinusDierheimer/fastfetch/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = licenses.mit;
    # buildInputs grabs mesa and libselinux somehow.
    broken = stdenv.isDarwin;
    maintainers = with maintainers; [ federicoschonborn ];
  };
})
