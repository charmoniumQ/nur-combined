{ ... }:
{
  imports = [
    ./coturn.nix
    ./cryptocurrencies
    ./email
    ./ejabberd.nix
    ./freshrss.nix
    ./export
    ./hickory-dns.nix
    ./gitea.nix
    ./goaccess.nix
    ./ipfs.nix
    ./jackett
    ./jellyfin.nix
    ./kiwix-serve.nix
    ./komga.nix
    ./lemmy.nix
    ./matrix
    ./navidrome.nix
    ./nginx.nix
    ./nixos-prebuild.nix
    ./ntfy
    ./ollama.nix
    ./pict-rs.nix
    ./pleroma.nix
    ./postgres.nix
    ./prosody
    ./slskd.nix
    ./transmission
    ./wikipedia.nix
  ];
}
