{
  buildGoModule,
  lib,
  installShellFiles,
  fetchFromGitHub,
}: let
  sha = "d3f0a67";
in
  buildGoModule rec {
    pname = "deck";
    version = "1.24.0";
    src = fetchFromGitHub {
      owner = "Kong";
      repo = "deck";
      rev = "v${version}";
      hash = "sha256-Ax3Xxg2DqlVx1bl9TTJn2MVhnaKPn416nL1/IWpQusw=";
    };

    nativeBuildInputs = [installShellFiles];

    CGO_ENABLED = 0;

    ldflags = [
      "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
      "-X github.com/kong/deck/cmd.COMMIT=${sha}"
    ];

    vendorHash = "sha256-ucwJQSZSBvSJzNQYLeNyCnZETmrNgVPFLjjkr1zP6b4=";

    postInstall = ''
      installShellCompletion --cmd deck \
        --bash <($out/bin/deck completion bash) \
        --fish <($out/bin/deck completion fish) \
        --zsh <($out/bin/deck completion zsh)
    '';

    meta = with lib; {
      description = "decK: Configuration management and drift detection for Kong.";
      homepage = "https://github.com/Kong/deck";
      license = licenses.asl20;
    };
  }
