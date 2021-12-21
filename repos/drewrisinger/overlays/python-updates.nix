self: super:

rec {
  # TODO: expand to python37, py38, py3

  # overlay the most-updated version of these python packages over the default package set.
  # Needed to allow building on e.g. nixpkgs-19.09
  python3 = super.python3.override {
    packageOverrides = py-self: py-super:
    let
      # Check if the py-super version is newer and use that if so.
      overrideSuperVersionIfNewer = superPyPackage: localPyPackage:
        if super.lib.versionAtLeast superPyPackage.version localPyPackage.version then
          superPyPackage
        else
          localPyPackage;
    in
    {
      # Needed for nixpkgs < nixos-unstable
      docplex = overrideSuperVersionIfNewer py-super.docplex (py-self.callPackage ../pkgs/python-modules/docplex { });
      websocket_client = overrideSuperVersionIfNewer py-super.websocket_client (py-self.callPackage ../pkgs/python-modules/websocket-client { });
      yfinance = overrideSuperVersionIfNewer py-super.yfinance (py-self.callPackage ../pkgs/python-modules/yfinance { });
      dill = overrideSuperVersionIfNewer py-super.dill (py-self.callPackage ../pkgs/python-modules/dill { });
      # needed for nixpkgs <= nixos-21.05, broken
      symengine = overrideSuperVersionIfNewer py-super.symengine (py-self.callPackage ../pkgs/python-modules/symengine { inherit (self) symengine; });
    };
  };

  python3Packages = python3.pkgs;
}
