# This file was generated by GoReleaser. DO NOT EDIT.
# vim: set ft=nix ts=2 sw=2 sts=2 et sta
{
system ? builtins.currentSystem
, lib
, fetchurl
, installShellFiles
, stdenvNoCC
}:
let
  shaMap = {
    i686-linux = "1025j5gyi34v64iy48rzjj69dw2gnk6jxg7g3rhhlrnxqfpkf0pz";
    x86_64-linux = "16kf5c2df2gva3d92zp6dj61hwg19cs10414hcc7gvn6a79r1n3l";
    aarch64-linux = "1yw22dgyzhh52px1cc6k88nywacdf4rvmglii24myiyhll9c99xq";
    x86_64-darwin = "0g0dckri2q42r00g8y3wyrk7lrmb3lk3mqa6l8n6qwj3amw9cmc3";
    aarch64-darwin = "0g0dckri2q42r00g8y3wyrk7lrmb3lk3mqa6l8n6qwj3amw9cmc3";
  };

  urlMap = {
    i686-linux = "https://github.com/robinovitch61/kl/releases/download/v0.2.0/kl_0.2.0_Linux_i386.tar.gz";
    x86_64-linux = "https://github.com/robinovitch61/kl/releases/download/v0.2.0/kl_0.2.0_Linux_x86_64.tar.gz";
    aarch64-linux = "https://github.com/robinovitch61/kl/releases/download/v0.2.0/kl_0.2.0_Linux_arm64.tar.gz";
    x86_64-darwin = "https://github.com/robinovitch61/kl/releases/download/v0.2.0/kl_0.2.0_Darwin_all.tar.gz";
    aarch64-darwin = "https://github.com/robinovitch61/kl/releases/download/v0.2.0/kl_0.2.0_Darwin_all.tar.gz";
  };
in
stdenvNoCC.mkDerivation {
  pname = "kl";
  version = "0.2.0";
  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./kl $out/bin/kl
  '';

  system = system;

  meta = {
    description = "An interactive Kubernetes log viewer for your terminal.";
    homepage = "https://github.com/robinovitch61/kl";
    license = lib.licenses.mit;

    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "i686-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
