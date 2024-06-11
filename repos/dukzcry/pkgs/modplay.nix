{ stdenv, lib, fetchFromGitLab, makeWrapper
, coreutils, curl, dtrx, uade123, openmpt123, sidplayfp, libnotify }:

stdenv.mkDerivation rec {
  pname = "modplay";
  version = "2024-06-11";

  src = fetchFromGitLab {
    owner = "dukzcry";
    repo = "crap";
    rev = "af035d498648dc00baf499efea7c0a57d21c0d6c";
    sha256 = "sha256-2TOysYBH/tt/WzMn91VCNgsomUhFwrgvElQy92hI3Ig=";
  };

  buildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 modplay/modplay.sh $out/bin/modplay.sh
    install -Dm755 modplay/modplay-shuffle.sh $out/bin/modplay-shuffle.sh
    wrapProgram $out/bin/modplay.sh \
      --prefix PATH : ${lib.makeBinPath [ coreutils curl dtrx uade123 openmpt123 sidplayfp libnotify ]}
  '';

  meta = with lib; {
    description = "A quick hack to play tracker music on *nix";
    license = licenses.free;
    homepage = "https://gitlab.com/dukzcry/crap/-/tree/master/modplay";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
