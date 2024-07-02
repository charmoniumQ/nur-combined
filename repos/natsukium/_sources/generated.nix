# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  copyq-darwin = {
    pname = "copyq-darwin";
    version = "9.0.0";
    src = fetchurl {
      url = "https://github.com/hluk/CopyQ/releases/download/v9.0.0/CopyQ-macos-12-m1.dmg.zip";
      sha256 = "sha256-ABLYjG2OW6wpMI7uXudkM8MYEQBRbxbGcBm2iiuN/0w=";
    };
  };
  emacs-plus = {
    pname = "emacs-plus";
    version = "af4df5166b357668f8207fbdff46a802633f1a5d";
    src = fetchFromGitHub {
      owner = "d12frosted";
      repo = "homebrew-emacs-plus";
      rev = "af4df5166b357668f8207fbdff46a802633f1a5d";
      fetchSubmodules = false;
      sha256 = "sha256-5HTQk8eBkt++HZIsVK1eEZjmFNlqpEd3oYDjMBeTn/c=";
    };
    date = "2024-07-02";
  };
  nixfmt = {
    pname = "nixfmt";
    version = "c67a7b65906bd2432730929bd0e4957659c95b8e";
    src = fetchFromGitHub {
      owner = "NixOS";
      repo = "nixfmt";
      rev = "c67a7b65906bd2432730929bd0e4957659c95b8e";
      fetchSubmodules = false;
      sha256 = "sha256-Ig9/AAiY41c4qVCBYQ6ovVAt+4AJjSJCHdEoSvkGwA0=";
    };
    date = "2024-05-28";
  };
  nixpkgs-review = {
    pname = "nixpkgs-review";
    version = "8e8f6f97a8259728f7bdbe8ca0aaec87d5f33cc9";
    src = fetchFromGitHub {
      owner = "natsukium";
      repo = "nixpkgs-review";
      rev = "8e8f6f97a8259728f7bdbe8ca0aaec87d5f33cc9";
      fetchSubmodules = false;
      sha256 = "sha256-E8dtlnor79fKVGAGxwibntfSPCcjCmpAYLO+Dxku69k=";
    };
    date = "2024-02-20";
  };
  qmk-toolbox = {
    pname = "qmk-toolbox";
    version = "0.3.3";
    src = fetchurl {
      url = "https://github.com/qmk/qmk_toolbox/releases/download/0.3.3/QMK.Toolbox.app.zip";
      sha256 = "sha256-WPre2csGAQzavtksLbj3L/MrWUT6d2gTJVq7eAmpcLk=";
    };
  };
  qutebrowser-darwin = {
    pname = "qutebrowser-darwin";
    version = "3.2.1";
    src = fetchurl {
      url = "https://github.com/qutebrowser/qutebrowser/releases/download/v3.2.1/qutebrowser-3.2.1-arm64.dmg";
      sha256 = "sha256-HNEXLXy1rgHiD97JyOEuBuZAeGjge1wvHgo9esZZKCY=";
    };
  };
  sbarlua = {
    pname = "sbarlua";
    version = "29395b1928835efa1b376d438216fbf39e0d0f83";
    src = fetchFromGitHub {
      owner = "FelixKratz";
      repo = "SbarLua";
      rev = "29395b1928835efa1b376d438216fbf39e0d0f83";
      fetchSubmodules = false;
      sha256 = "sha256-C2tg1mypz/CdUmRJ4vloPckYfZrwHxc4v8hsEow4RZs=";
    };
    date = "2024-02-28";
  };
  skkeleton = {
    pname = "skkeleton";
    version = "1c96108b9ba055f82c458ddb78638ec266c44af5";
    src = fetchFromGitHub {
      owner = "vim-skk";
      repo = "skkeleton";
      rev = "1c96108b9ba055f82c458ddb78638ec266c44af5";
      fetchSubmodules = false;
      sha256 = "sha256-JSfwTUdssdOwVefvi5QVOL6+F16LdIUQoPDggbXgAYA=";
    };
    date = "2024-06-16";
  };
  vim-startuptime = {
    pname = "vim-startuptime";
    version = "1.3.2";
    src = fetchurl {
      url = "https://github.com/rhysd/vim-startuptime/archive/v1.3.2.tar.gz";
      sha256 = "sha256-1IB0DZJ+pAME35jxM1whJ/R+D6ZX9rjxHmXnQBX/IdQ=";
    };
  };
  vivaldi-darwin = {
    pname = "vivaldi-darwin";
    version = "6.8.3381.46";
    src = fetchurl {
      url = "https://downloads.vivaldi.com/stable/Vivaldi.6.8.3381.46.universal.dmg";
      sha256 = "sha256-p6mdM8pBJIsQ9ic90YwgDMy9lq0bBi+VOkCvZE8s/xM=";
    };
  };
}
