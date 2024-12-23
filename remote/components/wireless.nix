{
  config,
  lib,
  pkg,
  ...
}: let
  cfg = config.componentWireless;
in {
  options.componentWireless = with lib.types; {
    enable = lib.mkEnableOption "Enable wireless network";
    radioName = lib.mkOption {
      default = "wlp0s16u2";
      description = "Name of wireless interface to use";
      type = str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.hostapd = {
      enable = cfg.enable;

      radios."${cfg.radioName}" = {
        #countryCode = "UK";
        driver = "nl80211";
        band = "2g";
        channel = 6;
        noScan = false;
        settings = {
          acs_num_scans = 5;
          enable_background_radar = true;
          acs_exclude_dfs = false;
          #ieee80211d = true;
        };
        # https://github.com/morrownr/USB-WiFi/blob/main/home/iw_list/ALFA_AWUS036ACM.txt
        wifi4.enable = true;
        wifi4.capabilities = [
          "LDPC"
          "HT40+"
          "HT40-"
          "GF"
          "SHORT-GI-20"
          "SHORT-GI-40"
          "TX-STBC"
          "RX-STBC1"
        ];
        wifi5.enable = false;
        wifi5.capabilities = [
          "RXLDPC"
          "SHORT-GI-80"
          "TX-STBC-2BY1"
          "RX-STBC-1"
          "MAX-A-MPDU-LEN-EXP3"
          "RX-ATENNA-PATTERN"
          "TX-ATENNA-PATTERN"
        ];
        wifi5.operatingChannelWidth = "80";
        wifi5.require = true;
        wifi6.enable = false;
        #wifi6.require = true;
        networks."${cfg.radioName}" = {
          ssid = "Test network";
          logLevel = 0;
          apIsolate = true;
          authentication.enableRecommendedPairwiseCiphers = true;
          authentication.mode = "wpa3-sae";
          authentication.saePasswords = [
            {
              password = "todo5todo@";
            }
          ];
        };
      };
    };

    # networking.interfaces."${cfg.radioName}" = {
    #   ipv4.addresses = [
    #     {
    #       address = "10.0.0.1";
    #       prefix = 16;
    #     }
    #   ];
    #   useDHCP = false;
    # };

    systemd.network.enable = true;
    networking.useNetworkd = true;

    systemd.network.networks."${cfg.radioName}" = {
      address = ["10.0.0.1/16"];
      dhcpServerConfig = {
        ServerAddress = "10.0.0.1/16";
        # EmitDns = "yes";
        # DNS = "10.0.0.1";
      };
      enable = true;
      name = cfg.radioName;
      networkConfig = {
        DHCPServer = true;
      };
    };

    networking.firewall.interfaces."${cfg.radioName}" = {
      allowedTCPPorts = [53 5201];
      allowedUDPPorts = [53 67 67 5201];
    };

    networking.nat = {
      enable = true;
      externalInterface = "enp1s0";

      internalInterfaces = [cfg.radioName];
    };

    systemd.services.hostapd.startLimitBurst = 5;
    systemd.services.hostapd.startLimitIntervalSec = 10;
    systemd.services.hostapd.serviceConfig.RestartSec = 30;
  }; # End of config
}
