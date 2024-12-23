{
  config,
  lib,
  ...
}: let
  cfg = config.componentNtfy;
in {
  options = {
    componentNtfy.enable = lib.mkEnableOption "Enable ntfy service";
  };

  config = lib.mkIf cfg.enable {
    containers.ntfy-sh = {
      autoStart = cfg.enable;
      ephemeral = true;
      privateNetwork = true;

      forwardPorts = [
        {
          containerPort = 443;
          hostPort = 6443;
          protocol = "tcp";
        }
        {
          containerPort = 443;
          hostPort = 6443;
          protocol = "udp";
        }
      ];

      bindMounts.cache = {
        hostPath = "/var/lib/ntfy/cache";
        mountPoint = "/var/lib/ntfy/cache";
        isReadOnly = false;
      };

      bindMounts.auth = {
        hostPath = "/var/lib/ntfy/auth";
        mountPoint = /var/lib/ntfy/auth;
        isReadOnly = false;
      };

      config = {
        services.ntfy-sh = {
          enable = cfg.enable;
          settings = {
            base-url = "http://192.168.20.14";
            listen-http = "";
            listen-unix = "/tmp/ntfy";

            auth-file = "/var/lib/ntfy/auth/auth.db";
            cache-file = "/var/lib/ntfy/cache/cache.db";

            auth-default-access = "deny-all";
            enable-signup = false;
            enable-login = true;

            behind-proxy = true;
          };
        };

        services.nginx = {
          enable = cfg.enable;
          recommendedGzipSettings = true;
          recommendedOptimisation = true;

          upstreams.ntfy.servers = {
            "unix:/tmp/ntfy" = {
            };
          };

          virtualHosts.ntfy = {
            default = true;
            http2 = true;

            listen = [
              {
                addr = "0.0.0.0";
                port = 443;
                ssl = true;
              }
            ];

            locations."/" = {
              proxyPass = "http://ntfy";
              recommendedProxySettings = true;
            };
          };
        };
      };
    };
  };
}
