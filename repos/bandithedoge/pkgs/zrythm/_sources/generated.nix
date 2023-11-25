# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  carla-git = {
    pname = "carla-git";
    version = "454e2e5fb6f7db631dc6e5d9d84202b99625c2bc";
    src = fetchFromGitHub {
      owner = "falkTX";
      repo = "Carla";
      rev = "454e2e5fb6f7db631dc6e5d9d84202b99625c2bc";
      fetchSubmodules = false;
      sha256 = "sha256-Jj69g3me0yj9dYgHUmZYuQMmV0F8DAHOvoJRT148vAM=";
    };
    date = "2023-11-19";
  };
  gtk-4_13_0 = {
    pname = "gtk-4_13_0";
    version = "4.13.0";
    src = fetchFromGitHub {
      owner = "GNOME";
      repo = "gtk";
      rev = "4.13.0";
      fetchSubmodules = false;
      sha256 = "sha256-SiL+/wfpeIUF2sQpGN1nWVn/mna+m3UxfORAFq/8fl0=";
    };
  };
  libadwaita-1_4 = {
    pname = "libadwaita-1_4";
    version = "1.4.rc";
    src = fetchFromGitHub {
      owner = "GNOME";
      repo = "libadwaita";
      rev = "1.4.rc";
      fetchSubmodules = false;
      sha256 = "sha256-VJV5kLoDXTPXb3gXz0iANmrfo+wiR4a59Z2tcjL5+/8=";
    };
  };
  zix-git = {
    pname = "zix-git";
    version = "e90109eac8151498fa3b4650abc8f74a8a453c8d";
    src = fetchFromGitHub {
      owner = "drobilla";
      repo = "zix";
      rev = "e90109eac8151498fa3b4650abc8f74a8a453c8d";
      fetchSubmodules = false;
      sha256 = "sha256-O1SfepnDju5GSeTtFcUocJGKkW68jRwrnAh6t6usE6A=";
    };
    date = "2023-11-17";
  };
  zrythm = {
    pname = "zrythm";
    version = "228c7ad526b354c9ba01bed71028b9cb422f73f0";
    src = fetchgit {
      url = "https://git.sr.ht/~alextee/zrythm";
      rev = "228c7ad526b354c9ba01bed71028b9cb422f73f0";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-G7U9GI5B3o2MuS6saZk+yeu1YBdY2iY1QGbksoDpY58=";
    };
    date = "2023-09-02";
  };
}
