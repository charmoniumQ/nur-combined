# This file was generated by nvfetcher, please do not modify it manually.
{
  fetchgit,
  fetchurl,
  fetchFromGitHub,
  dockerTools,
}: {
  umu = {
    pname = "umu";
    version = "3e71418d937f054e04ff9173f18e57756c1fd9d6";
    src = fetchgit {
      url = "https://github.com/Open-Wine-Components/umu-launcher";
      rev = "3e71418d937f054e04ff9173f18e57756c1fd9d6";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [];
      sha256 = "sha256-x86l3nxVfURHWtF6gSaiTWK+dadT1D4HmI/FM10HXxg=";
    };
    date = "2024-09-22";
  };
}
