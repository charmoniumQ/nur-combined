{ lib, config, ... }:
{
  systemd.services.caddy.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];
  repack.caddy = {
    enable = true;
    settings.apps = {
      http.servers.srv0.routes = [
        {
          handle = [
            {
              handler = "reverse_proxy";
              upstreams = [ { dial = "localhost:9000"; } ];
            }
          ];
          match = [ { host = [ "nas.nyaw.xyz" ]; } ];
        }
      ];

      tls = {
        certificates.load_files = [
          {
            certificate = "/run/credentials/caddy.service/nyaw.cert";
            key = "/run/credentials/caddy.service/nyaw.key";
            tags = [ "cert0" ];
          }
        ];
      };
    };
  };
}
