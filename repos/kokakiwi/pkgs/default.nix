{ pkgs, lib, ... }:
let
  callPackage = lib.callPackageWith (pkgs // final // {
    inherit callPackage;
  });

  mergeAttrsList = let
    mergeAttrsList' = lib.foldl lib.mergeAttrs { };
  in lib.mergeAttrsList or mergeAttrsList';

  importSub = prefix: attrs: lib.mapAttrs (
    name: {
      _file ? null,
      _subPath ? if _file != null
        then "${name}/${_file}"
        else name,
        _path ? lib.path.append prefix _subPath,
      _attr ? null,
      _common ? null,
      ...
    }@args: let
      args' =
        builtins.removeAttrs args [ "_file" "_subPath" "_path" "_attr" "_common" ]
        // lib.optionalAttrs (_common != null) {
          _common = callPackage ./common/${_common}.nix { };
        };
      package = callPackage _path args';
    in if _attr != null then package.${_attr} else package
  ) attrs;

  applications = importSub ./applications {
    agree = { };
    aura = { };
    enquirer = { };
    ferdium = { };
    go-mod-upgrade = { };
    imhex = { };
    lddtree = { };
    paru = { };
    ots-cli = {
      _common = "ots";
    };
    sccache = { };
    streampager = { };
    tumelune = { };
  };

  development = importSub ./development {
  };

  servers = importSub ./servers {
    cryptpad = { };
    freenginx = {
      modules = with pkgs.nginxModules; [ moreheaders ];
    };
    ots = {
      _common = "ots";
    };
    piped-proxy = { };
  };

  final = mergeAttrsList [
    applications
    development
    servers
  ];
in final
