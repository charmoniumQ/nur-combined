{ stdenvNoCC, lib, buildDubPackage, enet, common }: with import ./lib.nix { inherit stdenvNoCC lib enet; }; buildDubPackage {
    pname = "${common.pname}-server";
    inherit (common) version src;
    # dubLock = ./dub-lock.server.json;
    dubLock = let fullLock = lib.importJSON ./dub-lock.json; in {
        dependencies = lib.filterAttrs (name: info: builtins.elem name ["derelict-enet" "derelict-util"]) fullLock.dependencies;
    };
    buildInputs = [enet];
    postConfigure = common.patchEnetBindings;
    sourceRoot = "source/src/server";
    postUnpack = ''chmod u+w "$sourceRoot"/../..''; # need to be able to create 'bin' directory there
    installPhase = ''
    runHook preInstall
    mkdir -p "$out"/bin
    cp ../../bin/lixserv "$out"/bin
    runHook postInstall
    '';
    meta = common.meta // {
        description = "${common.meta.description} (standalone multiplayer server)";
        license = lib.licenses.cc0;
        mainProgram = "lixserv";
    };
}