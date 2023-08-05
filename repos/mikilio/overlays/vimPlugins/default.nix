# TODO check that no license information gets lost
{ callPackage, config, lib, vimUtils, vim, darwin, llvmPackages
, neovimUtils
, luaPackages
}:

let

  inherit (vimUtils.override {inherit vim;})
    buildVimPluginFrom2Nix;

  inherit (lib) composeManyExtensions;

  plugins = callPackage ./generated.nix {
    inherit buildVimPluginFrom2Nix;
    inherit (neovimUtils) buildNeovimPlugin;
  };

  # TL;DR
  # * Add your plugin to ./vim-plugin-names
  # * run ./update.py
  #
  # If additional modifications to the build process are required,
  # add to ./overrides.nix.
  overrides = callPackage ./overrides.nix {
    inherit (darwin.apple_sdk.frameworks) Cocoa CoreFoundation CoreServices;
    inherit buildVimPluginFrom2Nix;
    inherit llvmPackages luaPackages;
  };

  extension = composeManyExtensions [
    plugins
    overrides
  ];

in
  extension
