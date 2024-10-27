{ lib
, stdenv
, fetchFromGitHub
, cmake
, buildShared ? !stdenv.hostPlatform.isStatic
}:

stdenv.mkDerivation rec {
  pname = "perf-cpp";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "jmuehlig";
    repo = "perf-cpp";
    rev = "v${version}";
    hash = "sha256-C8swFZBQtO47O57ikLfK3V9nCULTWQsaLeaitRGGQDU=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ ] ++ lib.optional buildShared "-DBUILD_SHARED_LIBS=ON";

  meta = with lib; {
    description = "C++ library to make performance analysis more intuitive and focused";
    homepage = "https://github.com/jmuehlig/perf-cpp";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
