{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.componentInvidious;
in {
  options.componentInvidious = with lib.types; {
    enable = lib.mkEnableOption "Enable invidious";

    sigHelperAddress = lib.mkOption {
      default = "127.0.0.37:2999";
      description = "Address for signature helper server";
      type = str;
    };

    domain = lib.mkOption {
      default = "invidious.supervisor.internal.douile.com";
      description = "Domain to host invidious on";
      type = str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;

      ensureUsers = [
        {
          name = "invidious";
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];

      ensureDatabases = ["invidious"];
    };

    services.nginx = {
      package = pkgs.nginxQuic;
    };

    services.invidious = {
      enable = cfg.enable;

      database = {
        createLocally = true;
        host = null; # Null means unix socket
      };

      address = "127.0.0.69";
      port = 3010;

      domain = cfg.domain;
      http3-ytproxy.enable = false; # Doesn't work
      nginx.enable = true;

      settings = {
        popular_enabled = false;
        statistics_enabled = true;
        region = "GB";
        dark_mode = "dark";
        banner = "Go away";
        cache_annotations = true;
        default_user_preferences = {
          region = "GB";
          dark_mode = "dark";
          default_home = "Subscriptions";
          annotations = true;
          preload = false;
          autoplay = false;
          local = true;
        };
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      #enableACME = lib.mkForce false;
      http2 = true;
      http3 = true;
      quic = true;
    };

    systemd.services."acme-invidious.supervisor.internal.douile.com" = {
      # TODO: fix this trying to use DNS
      after = ["step-ca.service"];
      wants = ["network-online.target"];
      requires = ["step-ca.service"];
      enable = false;
    };

    security.acme.certs."invidious.supervisor.internal.douile.com" = {
      dnsProvider = null;
    };

    services.invidious.sig-helper = {
      enable = true;
      listenAddress = cfg.sigHelperAddress;
      package = pkgs.inv-sig-helper.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "iv-org";
          repo = "inv_sig_helper";
          rev = "74e879b54e46831e31c09fd08fe672ca58e9cb2d";
          hash = "sha256-Q+u09WWBwWLcLLW9XwkaYDxM3xoQmeJzi37mrdDGvRc=";
        };
      });
    };
  }; # End of config
}
