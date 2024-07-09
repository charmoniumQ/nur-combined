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
    i686-linux = "1mjf8riqjlc471ry0p2107w744zbjv4qn0pxczrvjjk0m323shjw";
    x86_64-linux = "0h26g4z33cb7nvmdw5lqgab6i9jf8qm1yv5xklarmvmal1spff1n";
    armv7l-linux = "12vqm5ymr87wzf84dq2x0cjbifsgk2jbx3gwr47zdd6j9wdy5vj7";
    aarch64-linux = "076jw4wlsl6lp1gmcvif78lnagvml79g29zj2khwg1bf6hzlkblv";
    x86_64-darwin = "0xar3qwvg83q2cbdg2pxnjprdj1cx6mbx5lglad4wyw7wv8jrgsw";
    aarch64-darwin = "1my3dxm98jxh9bnzi97bvxbm9p1cd29q6v9hgx6giwbg0krb8j8q";
  };

  urlMap = {
    i686-linux = "https://github.com/charmbracelet/markscribe/releases/download/v0.7.1/markscribe_0.7.1_Linux_i386.tar.gz";
    x86_64-linux = "https://github.com/charmbracelet/markscribe/releases/download/v0.7.1/markscribe_0.7.1_Linux_x86_64.tar.gz";
    armv7l-linux = "https://github.com/charmbracelet/markscribe/releases/download/v0.7.1/markscribe_0.7.1_Linux_arm.tar.gz";
    aarch64-linux = "https://github.com/charmbracelet/markscribe/releases/download/v0.7.1/markscribe_0.7.1_Linux_arm64.tar.gz";
    x86_64-darwin = "https://github.com/charmbracelet/markscribe/releases/download/v0.7.1/markscribe_0.7.1_Darwin_x86_64.tar.gz";
    aarch64-darwin = "https://github.com/charmbracelet/markscribe/releases/download/v0.7.1/markscribe_0.7.1_Darwin_arm64.tar.gz";
  };
  sourceRootMap = {
    i686-linux = "markscribe_0.7.1_Linux_i386";
    x86_64-linux = "markscribe_0.7.1_Linux_x86_64";
    armv7l-linux = "markscribe_0.7.1_Linux_arm";
    aarch64-linux = "markscribe_0.7.1_Linux_arm64";
    x86_64-darwin = "markscribe_0.7.1_Darwin_x86_64";
    aarch64-darwin = "markscribe_0.7.1_Darwin_arm64";
  };
in
stdenvNoCC.mkDerivation {
  pname = "markscribe";
  version = "0.7.1";
  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = sourceRootMap.${system};

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./markscribe $out/bin/markscribe
  '';

  system = system;

  meta = {
    description = "Your personal markdown scribe with template-engine and Git(Hub) & RSS powers";
    homepage = "https://charm.sh/";
    license = lib.licenses.mit;

    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "armv7l-linux"
      "i686-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
