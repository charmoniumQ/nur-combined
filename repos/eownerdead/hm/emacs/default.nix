{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.eownerdead.emacs;

  fromUsePackage =
    epkgs: initEl:
    map (name: epkgs.${name}) (
      builtins.fromJSON (
        builtins.readFile (
          pkgs.runCommand "from-use-package" {
            nativeBuildInputs = [ epkgs.emacs ];
          } "emacs --script ${./use-package-list.el} ${initEl} > $out || true"
        )
      )
    );
in
{
  options.eownerdead.emacs.enable = lib.mkEnableOption "Enable emacs";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        emacs-all-the-icons-fonts
        mononoki
      ];
    };

    programs.emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
      extraConfig = builtins.readFile ./init.el;
      extraPackages =
        epkgs:
        (fromUsePackage epkgs ./init.el)
        ++ (with epkgs; [
          treesit-grammars.with-all-grammars
          pkgs.my.emacsPackages.eglot-tempel
          llvm-mode
        ]);
    };

    services = {
      emacs = {
        enable = true;
        client.enable = true;
        defaultEditor = true;
      };
    };
  };
}
