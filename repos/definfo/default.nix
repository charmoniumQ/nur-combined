# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { config.allowInsecurePredicate = _: true; },
}:

let
  source = (import ./_sources/generated.nix) {
    inherit (pkgs)
      fetchgit
      fetchurl
      fetchFromGitHub
      dockerTools
      ;
  }; # nvfetcher
  callCoqPackage = pkgs.coqPackages_8_19.callPackage;
  sets = callCoqPackage ./pkgs/coqPackages/sets { };
  fixedpoints = (callCoqPackage ./pkgs/coqPackages/fixedpoints) {
    inherit sets;
  };
  monadlib = (callCoqPackage ./pkgs/coqPackages/monadlib) {
    inherit sets fixedpoints;
  };
in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  lyricer = pkgs.callPackage ./pkgs/lyricer { source = source.lyricer; };
  rime-ls = (pkgs.callPackage ./pkgs/rime-ls { source = source.rime-ls; }).override { rimeDataPkgs = [ (pkgs.callPackage ./pkgs/rime-ice { }) ]; };
  sjtu-canvas-helper = pkgs.callPackage ./pkgs/sjtu-canvas-helper {
    source = source.sjtu-canvas-helper;
  };
  flexcpp = pkgs.callPackage ./pkgs/flexc++ { source = source.flexcpp; };

  coqPackages = {
    inherit sets fixedpoints monadlib;
  };
}
