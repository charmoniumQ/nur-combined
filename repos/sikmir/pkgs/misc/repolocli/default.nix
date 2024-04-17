{ stdenv, lib, rustPlatform, fetchFromSourcehut, curl, libiconv, openssl, pkg-config, makeWrapper }:

rustPlatform.buildRustPackage rec {
  pname = "repolocli";
  version = "0-unstable-2021-04-06";

  src = fetchFromSourcehut {
    owner = "~matthiasbeyer";
    repo = "repolocli";
    rev = "32b24f4e03d0dc48db7f7d9927501b07b4821c33";
    hash = "sha256-hNT+DilBpzjoJBVgXTB9kU4Obh8cszXFLCTaNhiOZHM=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-TeOxfD6mqihBalx9lwP7qH2/LaXnPVCkTP/f16rpjJM=";

  nativeBuildInputs = [ pkg-config makeWrapper ];

  buildInputs = lib.optionals stdenv.isLinux [ openssl ]
    ++ lib.optionals stdenv.isDarwin [ curl libiconv ];

  postInstall = ''
    install -Dm644 repolocli.toml -t $out/etc/xdg

    wrapProgram $out/bin/repolocli \
      --prefix XDG_CONFIG_DIRS : $out/etc/xdg
  '';

  meta = with lib; {
    description = "Repology commandline interface (and API)";
    inherit (src.meta) homepage;
    license = licenses.gpl2Only;
    maintainers = [ maintainers.sikmir ];
    broken = stdenv.isLinux;
  };
}
