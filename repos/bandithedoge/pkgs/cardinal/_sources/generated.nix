# This file was generated by nvfetcher, please do not modify it manually.
{
  fetchgit,
  fetchurl,
  fetchFromGitHub,
  dockerTools,
}: {
  cardinal = {
    pname = "cardinal";
    version = "30c66ab7c9bf93cbcf78572634bb1622f2be38a1";
    src = fetchFromGitHub {
      owner = "DISTRHO";
      repo = "Cardinal";
      rev = "30c66ab7c9bf93cbcf78572634bb1622f2be38a1";
      fetchSubmodules = true;
      sha256 = "sha256-7p6+SmP5RtbY21Wt4o2OLqSHvZ/n/u+j49cSHBp9zmA=";
    };
    date = "2024-01-22";
  };
}
