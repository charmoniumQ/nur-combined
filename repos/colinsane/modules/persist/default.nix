# borrows from:
#   https://xeiaso.net/blog/paranoid-nixos-2021-07-18
#   https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/
#   https://github.com/nix-community/impermanence
{ config, lib, sane-lib, ... }:

with lib;
let
  path = sane-lib.path;
  sane-types = sane-lib.types;
  cfg = config.sane.persist;

  storeType = types.submodule {
    options = {
      storeDescription = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          an optional description of the store, which is rendered like
            {store.name}: {store.storeDescription}
          for example, a store named "private" could have description "ecnrypted to the user's password and decrypted on login".
        '';
      };
      origin = mkOption {
        type = types.str;
        description = ''
          where this store is rooted within the outer filesystem.
          conceptually, this is the store's "mount point",
          though technically this could be a path within any larger mount.
        '';
      };
      prefix = mkOption {
        type = types.str;
        default = "/";
        description = ''
          optional prefix to strip from children when stored here.
          for example, prefix="/var/private" and mountpoint="/mnt/crypt/private"
          would cause /var/private/www/root to be stored at /mnt/crypt/private/www/root instead of
          /mnt/crypt/private/var/private/www/root.
        '';
      };
      defaultMethod = mkOption {
        type = types.enum [ "bind" "symlink" ];
        default = "symlink";
        description = ''
          preferred way to link items from the store into the fs
        '';
      };
      defaultOrdering.wantedBeforeBy = mkOption {
        type = types.listOf types.str;
        default = [ "local-fs.target" ];
        description = ''
          list of units or targets which would prefer that everything in this store
          be initialized before they run, but failing to do so should not error the items in this list.
        '';
      };
      defaultOrdering.wantedBy = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          list of units or targets which, upon activation, should activate all units in this store.
        '';
      };
    };
  };

  # allows a user to specify the store either by name or as an attrset
  coercedToStore = types.coercedTo types.str (s: cfg.stores."${s}") storeType;

  # options common to all entries, whether they're keyed by path or store
  entryOpts = {
    options = {
      acl = mkOption {
        type = sane-types.aclOverride;
        default = {};
      };
      method = mkOption {
        type = types.nullOr (types.enum [ "bind" "symlink" ]);
        default = null;
        description = ''
          how to link the store entry into the fs
        '';
      };
      type = mkOption {
        type = types.enum [ "dir" "file" ];
        default = "dir";
        description = ''
          whether the thing being persisted is a whole directory,
          or just one file.
        '';
      };
    };
  };

  # options for a single mountpoint / persistence where the store is specified externally
  entryInStore = types.submodule [
    entryOpts
    {
      options = {
        path = mkOption {
          type = types.str;
        };
      };
    }
  ];
  # allow "bar/baz" as shorthand for { path = "bar/baz"; }
  entryInStoreOrShorthand = types.coercedTo
    types.str
    (d: { path = d; })
    entryInStore;

  # allow the user to provide the `acl` field inline: we pop acl sub-attributes placed at the
  # toplevel and move them into an `acl` attribute.
  convertInlineAcl = to: types.coercedTo
    types.attrs
    (orig: lib.recursiveUpdate
      (builtins.removeAttrs orig ["user" "group" "mode" ])
      {
        acl = sane-lib.filterByName ["user" "group" "mode"] orig;
      }
    )
    to;

  # entry where the path is specified externally
  entryAtPath = types.submodule [
    entryOpts
    {
      options = {
        store = mkOption {
          type = coercedToStore;
        };
      };
    }
  ];

  # this submodule converts store-based access to path-based access so that the user can specify e.g.:
  #   <top>.byStore.private = [ ".cache/vim" ];
  #   <top>.byStore.private = [ { path=".cache/vim"; mode = "0700"; } ];
  # to place ".cache/vim" into the private store and/or create with the appropriate mode
  entrySubmodule = types.submodule ({ config, ... }: {
    options = {
      byStore = mkOption {
        type = types.attrsOf (types.listOf (convertInlineAcl entryInStoreOrShorthand));
        default = {};
        description = ''
          directories/files to persist within a specific store (e.g. "plaintext" or "private").
        '';
      };
      byPath = mkOption {
        type = types.attrsOf (convertInlineAcl entryAtPath);
        default = {};
        description = ''
          map of <path> => <path config> for all paths to be persisted.
          this is computed from the other options, but users can also set it explicitly (useful for overriding)
        '';
      };
    };
    config = let
      # set the `store` attribute on one dir attrset
      annotateWithStore = store: dir: {
        "${dir.path}".store = store;
      };
      # convert an `entryInStore` to an `entryAtPath` (less the `store` item)
      dirToAttrs = dir: {
        "${dir.path}" = builtins.removeAttrs dir ["path"];
      };
      # store-names = attrNames cfg.stores;
      # :: (store -> entry -> AttrSet) -> [AttrSet]
      # applyToAllStores = f: lib.concatMap
      #   (store: map (f store) config.byStore."${store}")
      #   store-names;
      applyToAllStores = f: lib.concatMap
        (store: map (f store) config.byStore."${store}")
        (builtins.attrNames config.byStore);
    in {
      byPath = lib.mkMerge (concatLists [
        # convert the list-style per-store entries into attrsOf entries
        (applyToAllStores (_store: dirToAttrs))
        # add the `store` attr to everything we ingested
        (applyToAllStores annotateWithStore)
      ]);
    };
  });
in
{
  options = {
    sane.persist.enable = mkOption {
      default = false;
      type = types.bool;
    };
    sane.persist.sys = mkOption {
      description = "directories (or files) to persist to disk, relative to the fs root /";
      default = {};
      type = entrySubmodule;
    };
    sane.persist.stores = mkOption {
      type = types.attrsOf storeType;
      default = {};
      description = ''
        map from human-friendly name to a fs sub-tree from which files are linked into the logical fs.
      '';
    };
  };

  imports = [
    ./stores
  ];

  config = let
    # String => entryAtPath => generated toplevel config
    cfgFor = fspath: opt:
      let
        store = opt.store;
        method = (sane-lib.withDefault store.defaultMethod) opt.method;
        fsPathToStoreRelPath = fspath: path.from store.prefix fspath;
        fsPathToBackingPath = fspath: path.concat [ store.origin (fsPathToStoreRelPath fspath) ];
      in lib.mkMerge [
        {
          # create destination dir, with correct perms
          sane.fs."${fspath}" = {
            inherit (store.defaultOrdering) wantedBy wantedBeforeBy;
          } // (lib.optionalAttrs (method == "bind") {
            # inherit perms & make sure we don't mount until after the mount point is setup correctly.
            dir.acl = opt.acl;
            mount.bind = fsPathToBackingPath fspath;
          }) // (lib.optionalAttrs (method == "symlink") {
            symlink.acl = opt.acl;
            symlink.target = fsPathToBackingPath fspath;
          });
        }
        (lib.optionalAttrs (opt.type == "dir") {
          # create the backing path as a dir
          sane.fs."${fsPathToBackingPath fspath}" = {
            wantedBeforeBy = [ config.sane.fs."${fspath}".unit ];
            dir.acl = config.sane.fs."${fspath}".generated.acl;
          };
        })
        (lib.optionalAttrs (opt.type == "file") {
          # create the backing file, as an empty file.
          # the old way was to create the parent directory and leave the file empty, expecting the program to create it.
          # that doesn't work well with sandboxing, where the fs handles we want to give the program have to exist before launch.
          sane.fs."${fsPathToBackingPath fspath}" = {
            wantedBeforeBy = [ config.sane.fs."${fspath}".unit ];
            file.acl = config.sane.fs."${fspath}".generated.acl;
            file.text = lib.mkDefault "";
          };
        })
        {
          # default each item along the backing path to have the same acl as the location it would be mounted.
          # also, default each parent to being a directory.
          sane.fs = lib.mkMerge (builtins.map
            (fsSubpath: {
              "${fsPathToBackingPath fsSubpath}" = {
                dir.acl = config.sane.fs."${fsSubpath}".generated.acl;
              };
            })
            (lib.init (path.walk store.prefix fspath))
          );
        }
      ];
    configs = lib.mapAttrsToList cfgFor cfg.sys.byPath;
    take = f: { sane.fs = f.sane.fs; };
  in mkIf cfg.enable (
    take (sane-lib.mkTypedMerge take configs)
  );
}

