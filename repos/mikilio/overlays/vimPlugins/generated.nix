# GENERATED by ./pkgs/applications/editors/vim/plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, buildNeovimPlugin, fetchFromGitHub, fetchgit }:

final: prev:
{
  knap = buildVimPluginFrom2Nix {
    pname = "knap";
    version = "2023-08-07";
    src = fetchFromGitHub {
      owner = "Mikilio";
      repo = "knap";
      rev = "e8eaba395e7f6d4b47f22e9244a3b400d21a0f45";
      sha256 = "19ndgzk39ilh31saaiw93bbwl382rc5k5khq5kxrjhkyb03s137m";
    };
    meta.homepage = "https://github.com/Mikilio/knap/";
  };

  texmagic-nvim = buildVimPluginFrom2Nix {
    pname = "texmagic.nvim";
    version = "2022-05-15";
    src = fetchFromGitHub {
      owner = "jakewvincent";
      repo = "texmagic.nvim";
      rev = "3c0d3b63c62486f02807663f5c5948e8b237b182";
      sha256 = "19r6sdyaxkjmm9k5l97n4fcp5ycx8d3v9kyydxzcpxji5synv2gq";
    };
    meta.homepage = "https://github.com/jakewvincent/texmagic.nvim/";
  };


}
