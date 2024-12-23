{
  config,
  lib,
  ...
}: let
  cfg = config.componentGrafana;
in {
  options.componentGrafana = with lib.types; {
    enable = lib.mkEnableOption "Enable custom grafana";
    exporterAddress = lib.mkOption {
      default = "127.0.0.8";
      description = "IP to bind prometheus exporters on";
      type = str;
    };
    prometheusAddress = lib.mkOption {
      default = "127.0.0.9";
      description = "IP to bind prometheus on";
      type = str;
    };
    grafanaAddress = lib.mkOption {
      default = "0.0.0.0";
      description = "IP to bind grafana on";
      type = str;
    };
    pingTargets = lib.mkOption {
      default = [
        "192.168.20.1"
        "192.168.20.5"
        "192.168.20.8"
        "192.168.20.12"
        "192.168.20.15"
      ];
      description = "IPs to target with the ping exporter";
      type = listOf str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings.server = {
        enable_gzip = true;
        http_port = 3000;
        http_addr = cfg.grafanaAddress;
      };
      settings.database = {
        host = "/var/run/postgresql/";
        type = "postgres";
        user = "grafana";
      };
      settings.analytics = {
        check_for_updates = false;
        feedback_links_enabled = false;
        reporting_enabled = false;
      };
      provision.enable = true;
      provision.datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${cfg.prometheusAddress}:9090";
          jsonData.isDefault = true;
        }
        # lib.mkIf config.componentZigbee.enable {
        #   name = "MQTT";
        #   type = "mqtt";
        #   url = "http://";
        # }
      ];
    };

    services.postgresql = {
      enable = true;

      ensureUsers = [
        {
          name = "grafana";
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];

      ensureDatabases = ["grafana"];
    };

    services.prometheus = {
      enable = true;

      listenAddress = cfg.prometheusAddress;
      port = 9090;

      scrapeConfigs = [
        {
          job_name = "local";
          static_configs = [
            {
              targets = [
                "${cfg.exporterAddress}:9100"
                "${cfg.exporterAddress}:9427"
                "${cfg.exporterAddress}:9256"
                "${cfg.exporterAddress}:9586"
                "${cfg.exporterAddress}:9686" # mqtt-exporter
                "127.0.0.1:9000"
              ];
            }
          ];
        }
      ];

      exporters.node = {
        enable = true;
        port = 9100;
        listenAddress = cfg.exporterAddress;
        enabledCollectors = ["systemd"];
      };

      exporters.ping = {
        enable = true;
        port = 9427;
        listenAddress = cfg.exporterAddress;
        settings = {
          targets = cfg.pingTargets;
        };
      };

      exporters.process = {
        enable = true;
        port = 9256;
        listenAddress = cfg.exporterAddress;
      };

      exporters.wireguard = {
        enable = true;
        port = 9586;
        listenAddress = cfg.exporterAddress;
      };
    };

    networking.firewall.allowedTCPPorts = [3000];
  };
}
