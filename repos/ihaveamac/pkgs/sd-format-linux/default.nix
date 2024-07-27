{ stdenv, lib, fetchFromGitHub, util-linux, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "sd-format-linux";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "profi200";
    repo = "sdFormatLinux";
    rev = "v${version}";
    hash = "sha256-AoAhP1dr+hQSnOpZC0oHt0j3fUVNVhD+3jWm6iMfskk=";
  };

  buildInputs = [ util-linux ];
  nativeBuildInputs = [ makeWrapper ];

  # without this, TARGET will become "source"
  # because it thinks it's building at /build/source
  makeFlags = [ "TARGET=sdFormatLinux" ];

  # remove hardcoded path to lsblk, and instead put "lsblk" only
  # trying to insert the full path will make the string longer than 64 characters
  # so instead the binary will be wrapped to insert util-linux into PATH
  patchPhase = ''
    substituteInPlace source/blockdev.cpp \
      --replace-fail /usr/bin/lsblk lsblk
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp sdFormatLinux $out/bin
    wrapProgram $out/bin/sdFormatLinux \
      --prefix PATH : ${lib.makeBinPath [ util-linux ]}
  '';

  meta = with lib; {
    description = "Properly format SD cards under Linux.";
    homepage = "https://github.com/profi200/sdFormatLinux";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "sdFormatLinux";
  };
}
