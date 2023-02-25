# This file was generated by nvfetcher, please do not modify it manually.
{
  fetchgit,
  fetchurl,
  fetchFromGitHub,
  dockerTools,
}: {
  bling = {
    pname = "bling";
    version = "4fc68f7c24f6eb7d9ce96d15da098a4b04b162e1";
    src = fetchFromGitHub {
      owner = "blingcorp";
      repo = "bling";
      rev = "4fc68f7c24f6eb7d9ce96d15da098a4b04b162e1";
      fetchSubmodules = false;
      sha256 = "sha256-VgGHb4rGeSb7+P4Cy1JR5KaHdvy3QFJ5aliia0BQEZ8=";
    };
    date = "2023-02-22";
  };
  cardinal = {
    pname = "cardinal";
    version = "c568a695c875e1e17bf75a0083b1858dacdc5053";
    src = fetchFromGitHub {
      owner = "DISTRHO";
      repo = "Cardinal";
      rev = "c568a695c875e1e17bf75a0083b1858dacdc5053";
      fetchSubmodules = true;
      sha256 = "sha256-+swSxL0TfXk5z92sQ1lnDbSCPROI/wlk3I4mJsirrh8=";
    };
    date = "2023-02-24";
  };
  carla = {
    pname = "carla";
    version = "33a142f447925f55d00532933a1f28e9745c13eb";
    src = fetchFromGitHub {
      owner = "falkTX";
      repo = "Carla";
      rev = "33a142f447925f55d00532933a1f28e9745c13eb";
      fetchSubmodules = false;
      sha256 = "sha256-hQj0HlcOYfwsxG05pq/qcuKcOwDMV1ED+YdxBToBzvk=";
    };
    date = "2023-02-24";
  };
  dmenu-flexipatch = {
    pname = "dmenu-flexipatch";
    version = "05f5efc5e544fdb8e7744eb79a6a5d6f882b4d4c";
    src = fetchFromGitHub {
      owner = "bakkeby";
      repo = "dmenu-flexipatch";
      rev = "05f5efc5e544fdb8e7744eb79a6a5d6f882b4d4c";
      fetchSubmodules = false;
      sha256 = "sha256-6hGunum5+IBSpxJPvEOAgNmCkDNbm3R++RSTg8TL8Vo=";
    };
    date = "2022-10-26";
  };
  dwm-flexipatch = {
    pname = "dwm-flexipatch";
    version = "fcbe686ff250849b00da2479baf71dedc3cb0f07";
    src = fetchFromGitHub {
      owner = "bakkeby";
      repo = "dwm-flexipatch";
      rev = "fcbe686ff250849b00da2479baf71dedc3cb0f07";
      fetchSubmodules = false;
      sha256 = "sha256-VH3+FO2SKTdjnf0InJUBLsEJj+WiZa0Stjl+MlpFKjQ=";
    };
    date = "2023-02-18";
  };
  keepmenu = {
    pname = "keepmenu";
    version = "1.3.1";
    src = fetchFromGitHub {
      owner = "firecat53";
      repo = "keepmenu";
      rev = "1.3.1";
      fetchSubmodules = false;
      sha256 = "sha256-1s+vl5j0oPERUvJCKFTvLubCF8Nhx7OtkPjpWmpEG/o=";
    };
  };
  kiwmi = {
    pname = "kiwmi";
    version = "17814972abe6a8811a586fa87c99a2b16a86075f";
    src = fetchFromGitHub {
      owner = "buffet";
      repo = "kiwmi";
      rev = "17814972abe6a8811a586fa87c99a2b16a86075f";
      fetchSubmodules = false;
      sha256 = "sha256-n9PA6cyEjSlnDcRrqIkO83UaCE/hovbi/oZon1B+nuw=";
    };
    date = "2022-07-30";
  };
  lua-dbus = {
    pname = "lua-dbus";
    version = "cdef26d09aa61d7f1f175675040383f6ae0becbb";
    src = fetchFromGitHub {
      owner = "dodo";
      repo = "lua-dbus";
      rev = "cdef26d09aa61d7f1f175675040383f6ae0becbb";
      fetchSubmodules = false;
      sha256 = "sha256-S+W6QTqv4kdyR86GCyDLnkml10dO4ZVNXEd3/7vDFGE=";
    };
    date = "2015-04-22";
  };
  lua-dbus_proxy = {
    pname = "lua-dbus_proxy";
    version = "v0.10.3";
    src = fetchFromGitHub {
      owner = "stefano-m";
      repo = "lua-dbus_proxy";
      rev = "v0.10.3";
      fetchSubmodules = false;
      sha256 = "sha256-Yd8TN/vKiqX7NOZyy8OwOnreWS5gdyVMTAjFqoAuces=";
    };
  };
  luakit = {
    pname = "luakit";
    version = "858dc946b01487e6ba2475cb7a9bede34c17d134";
    src = fetchFromGitHub {
      owner = "luakit";
      repo = "luakit";
      rev = "858dc946b01487e6ba2475cb7a9bede34c17d134";
      fetchSubmodules = false;
      sha256 = "sha256-TKQvnavoofGtBo2aBJtZVZjrmm5Ln7vOgW9bAXjcpRM=";
    };
    date = "2023-01-29";
  };
  lv2vst = {
    pname = "lv2vst";
    version = "30a669a021812da05258519cef9d4202f5ce26c3";
    src = fetchFromGitHub {
      owner = "x42";
      repo = "lv2vst";
      rev = "30a669a021812da05258519cef9d4202f5ce26c3";
      fetchSubmodules = false;
      sha256 = "sha256-WFVscNivFrsADl7w5pSYx9g+UzK2XUBF7x0Iqg8WKiQ=";
    };
    date = "2020-06-07";
  };
  raze = {
    pname = "raze";
    version = "1.6.2";
    src = fetchFromGitHub {
      owner = "ZDoom";
      repo = "Raze";
      rev = "1.6.2";
      fetchSubmodules = false;
      sha256 = "sha256-5EXU7mXhg9gvNvz13OCvzJHMb4VArYQj/6rTmzDK6uY=";
    };
  };
  slock-flexipatch = {
    pname = "slock-flexipatch";
    version = "780a7887a3b976a48786f991d55fc8a474e76a25";
    src = fetchFromGitHub {
      owner = "bakkeby";
      repo = "slock-flexipatch";
      rev = "780a7887a3b976a48786f991d55fc8a474e76a25";
      fetchSubmodules = false;
      sha256 = "sha256-3jzEXIaH6qZkbvumlYqPSW1kDjg8obDMVoj6y3Vhe4I=";
    };
    date = "2022-10-06";
  };
  st-flexipatch = {
    pname = "st-flexipatch";
    version = "a8e2af0d923e7b6f7b19e8fa516bcd0670dfae84";
    src = fetchFromGitHub {
      owner = "bakkeby";
      repo = "st-flexipatch";
      rev = "a8e2af0d923e7b6f7b19e8fa516bcd0670dfae84";
      fetchSubmodules = false;
      sha256 = "sha256-cYaHI19ctmfPSNr4UgT7p1GSEVMKZUlHJ4Gn33A0KR8=";
    };
    date = "2023-01-09";
  };
  taffybar = {
    pname = "taffybar";
    version = "253c10fc2af08d3d9eab9ca2362f4dce05c58554";
    src = fetchFromGitHub {
      owner = "taffybar";
      repo = "taffybar";
      rev = "253c10fc2af08d3d9eab9ca2362f4dce05c58554";
      fetchSubmodules = false;
      sha256 = "sha256-52epXu0VDlNA6yZ3JTsgbbD/1YCPX2s3Lpaz3Lk7lsA=";
    };
    date = "2022-12-25";
  };
  tailwindcss-intellisense = {
    pname = "tailwindcss-intellisense";
    version = "4b215ba92eb2b0ac0043328468adb10a5b118bfd";
    src = fetchFromGitHub {
      owner = "tailwindlabs";
      repo = "tailwindcss-intellisense";
      rev = "4b215ba92eb2b0ac0043328468adb10a5b118bfd";
      fetchSubmodules = false;
      sha256 = "sha256-cwIPAEfmCja/C+SXtjV972LkbVXCZoFmoNVrupPI5og=";
    };
    date = "2023-01-31";
  };
  xmonad-entryhelper = {
    pname = "xmonad-entryhelper";
    version = "ee2d0c14f9258503d7bd62907aa731dd64fa34d0";
    src = fetchFromGitHub {
      owner = "Javran";
      repo = "xmonad-entryhelper";
      rev = "ee2d0c14f9258503d7bd62907aa731dd64fa34d0";
      fetchSubmodules = false;
      sha256 = "sha256-CGaibR0Yejng9IQInm92Zx0pEZS29tJjWvPgaiWgUNQ=";
    };
    date = "2022-05-18";
  };
  zix = {
    pname = "zix";
    version = "262d4a1522c38be0588746e874159da5c7bb457d";
    src = fetchFromGitHub {
      owner = "drobilla";
      repo = "zix";
      rev = "262d4a1522c38be0588746e874159da5c7bb457d";
      fetchSubmodules = false;
      sha256 = "sha256-3vuefgnirM4ksK3j9sjBHgOmx0JpL+6tCPb69/7jI00=";
    };
    date = "2023-02-13";
  };
  zmusic = {
    pname = "zmusic";
    version = "1.1.3";
    src = fetchFromGitHub {
      owner = "ZDoom";
      repo = "ZMusic";
      rev = "1.1.3";
      fetchSubmodules = false;
      sha256 = "sha256-wrNWfTIbNU/S2qFObUSkb6qyaceh+Y7Loxqudl86+W4=";
    };
  };
  zrythm = {
    pname = "zrythm";
    version = "8b02e7de61507450714412d00db99eb0e9ac54a7";
    src = fetchgit {
      url = "https://git.sr.ht/~alextee/zrythm";
      rev = "8b02e7de61507450714412d00db99eb0e9ac54a7";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-oo2i/t3/iHnw5F840eKQCDmmnt5Z0oX2dHf0hYPSiek=";
    };
    date = "2023-02-12";
  };
}
