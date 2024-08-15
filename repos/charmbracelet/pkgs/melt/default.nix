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
    i686-linux = "0xvfdvxg3c2sfdz324rv3bh300zgd9k7h7sxfsvkzdh4dd4hlrmk";
    x86_64-linux = "10mc0dl4zz4isa9dcwdyw3ama6ylvhl6ll3a3634l972mpf47xc2";
    armv6l-linux = "0mqwa274vcvr3ymj2rb17c8gj1rz66800h4kq8aqd583hqs5qpbv";
    armv7l-linux = "091dqwalj018wraci7ixwaxq0zr6s96avqd97rzgd31ypb885any";
    aarch64-linux = "1k9snsvx5qc6vgdds1zl8k489iqr5j8rb11qm6xsizmm17pg9k8j";
    x86_64-darwin = "1rbplszchapwfhadklb2px02186lw389b5r3i46ad3029xiyfv79";
    aarch64-darwin = "0z82kpzjqplsqb6kj9fzkpdpg9m1ciflm011bgylyp8l8ghmv8v4";
  };

  urlMap = {
    i686-linux = "https://github.com/charmbracelet/melt/releases/download/v0.6.2/melt_0.6.2_Linux_i386.tar.gz";
    x86_64-linux = "https://github.com/charmbracelet/melt/releases/download/v0.6.2/melt_0.6.2_Linux_x86_64.tar.gz";
    armv6l-linux = "https://github.com/charmbracelet/melt/releases/download/v0.6.2/melt_0.6.2_Linux_armv6.tar.gz";
    armv7l-linux = "https://github.com/charmbracelet/melt/releases/download/v0.6.2/melt_0.6.2_Linux_armv7.tar.gz";
    aarch64-linux = "https://github.com/charmbracelet/melt/releases/download/v0.6.2/melt_0.6.2_Linux_arm64.tar.gz";
    x86_64-darwin = "https://github.com/charmbracelet/melt/releases/download/v0.6.2/melt_0.6.2_Darwin_x86_64.tar.gz";
    aarch64-darwin = "https://github.com/charmbracelet/melt/releases/download/v0.6.2/melt_0.6.2_Darwin_arm64.tar.gz";
  };
  sourceRootMap = {
    i686-linux = "melt_0.6.2_Linux_i386";
    x86_64-linux = "melt_0.6.2_Linux_x86_64";
    armv6l-linux = "melt_0.6.2_Linux_armv6";
    armv7l-linux = "melt_0.6.2_Linux_armv7";
    aarch64-linux = "melt_0.6.2_Linux_arm64";
    x86_64-darwin = "melt_0.6.2_Darwin_x86_64";
    aarch64-darwin = "melt_0.6.2_Darwin_arm64";
  };
in
stdenvNoCC.mkDerivation {
  pname = "melt";
  version = "0.6.2";
  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = sourceRootMap.${system};

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./melt $out/bin/melt
    installManPage ./manpages/melt.1.gz
    installShellCompletion ./completions/*
  '';

  system = system;

  meta = {
    description = "Backup and restore Ed25519 SSH keys with seed words";
    homepage = "https://charm.sh/";
    license = lib.licenses.mit;

    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
      "i686-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
