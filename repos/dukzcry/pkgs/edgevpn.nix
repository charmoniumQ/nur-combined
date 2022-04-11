{ lib, stdenv, buildGo117Module, fetchFromGitHub, fetchpatch }:

buildGo117Module rec {
  pname = "edgevpn";
  version = "0.10.3";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "1av4l21rkmhd8pi8a7h00wmv9b3rq38nm8ycidp55vvwq51i9yrs";
  };

  vendorSha256 = "0w39f3nx29aaxyd3z2c7vyfjilmj054h4vqspz8az4sldkq0jqbq";

  patches = [
    (fetchpatch {
      url = "https://github.com/mudler/edgevpn/commit/1ee9523dd59de8246d53a83085bbc757bf86376d.patch";
      sha256 = "0yyvjakh4j1wf615s6cc3906j35f10bvci6nsk09yn5smwzagkjn";
    })
  ];

  preBuild = ''
    substituteInPlace internal/version.go \
      --replace 'Version = ""' 'Version = "${src.rev}"'
  '';

  doCheck = false;

  meta = with lib; {
    description = "The immutable, decentralized, statically built VPN without any central server";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
