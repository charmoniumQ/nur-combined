{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "mushroom";
  version = "2.8.1";

  src = fetchurl {
    url = "https://github.com/piitaya/lovelace-mushroom/releases/download/v${version}/mushroom.js";
    hash = "sha256-ghu3VS6rYXFi0PGLk+zURrpf0jIaS6269oSOAYEucPQ=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/mushroom.js
  '';

  meta = with lib; {
    changelog = "https://github.com/piitaya/lovelace-mushroom/releases/tag/v${version}";
    description = "Mushroom Cards - Build a beautiful dashboard easily";
    homepage = "https://github.com/piitaya/lovelace-mushroom";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
