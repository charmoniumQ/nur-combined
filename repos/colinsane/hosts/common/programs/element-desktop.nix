# debugging tips:
# - if element opens but does not render:
#   - `element-desktop --disable-gpu --in-process-gpu`
#     - <https://github.com/vector-im/element-desktop/issues/1029#issuecomment-1632688224>
#   - `rm -rf ~/.config/Element/GPUCache`
#     - <https://github.com/NixOS/nixpkgs/issues/244486>
{ pkgs, ... }:
{
  sane.programs.element-desktop = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  # notifications
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Music"
      "Pictures"
      "Pictures/servo-macros"
      "Videos"
      "Videos/servo"
      "tmp"
    ];

    packageUnwrapped = pkgs.element-desktop.override {
      # use pre-build electron because otherwise it takes 4 hrs to build from source.
      electron = pkgs.electron-bin;
    };

    # creds/session keys, etc
    persist.byStore.private = [ ".config/Element" ];

    suggestedPrograms = [ "gnome-keyring" ];
  };
}
