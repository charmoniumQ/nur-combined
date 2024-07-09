{
  lib,
  rustPlatform,
  fetchFromGitHub,
  libffi,
  libxml2,
  ncurses,
  zlib,
  llvmPackages_16,
  nix-update-script,
}:
let
  version = "0.15.0";
  src = fetchFromGitHub {
    owner = "inko-lang";
    repo = "inko";
    rev = "v${version}";
    hash = "sha256-Iojv8pTyILYpLFnoTlgUGmlfWWH0DgsGBRxzd3oRNwA=";
  };
in
rustPlatform.buildRustPackage {
  pname = "inko";
  inherit version;

  inherit src;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  buildInputs = [
    libffi
    libxml2
    ncurses
    zlib
  ];

  env.LLVM_SYS_160_PREFIX = llvmPackages_16.llvm.dev;

  # Some of the tests require git to be installed.
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "inko";
    description = "A language for building concurrent software with confidence";
    homepage = "https://github.com/inko-lang/inko";
    changelog = "https://github.com/inko-lang/inko/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}