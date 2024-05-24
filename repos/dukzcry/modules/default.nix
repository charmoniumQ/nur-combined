rec {
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  logitech-k380 = ./logitech-k380.nix;
  hidpi = ./hidpi.nix;
  jack = ./jack.nix;
  pulseaudio = ./pulseaudio.nix;
  pipewire = ./pipewire.nix;
  bambootracker = ./bambootracker.nix;
  nvidia = ./nvidia.nix;
  job = ./job.nix;
  monitor = ./monitor.nix;
  server = ./server.nix;
  headless = ./headless.nix;
  sunshine = ./sunshine.nix;
  regdomain = ./regdomain.nix;
  vpn = ./vpn.nix;
  awl = ./awl.nix;
  prometheus-nut-exporter = ./prometheus-nut-exporter.nix;
  hardware = ./hardware.nix;
  tun2socks = ./tun2socks.nix;
  cockpit = ./cockpit.nix;
  adblock = ./adblock.nix;
  gamescope = ./gamescope.nix;
  vscodium = ./vscodium.nix;
  udisks = ./udisks.nix;
  local-variables = ./local-variables.nix;
  gaming = ./gaming.nix;
  theme = ./theme.nix;
  sunpaper = ./sunpaper.nix;
}
