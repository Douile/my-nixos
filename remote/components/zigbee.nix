{
  config,
  lib,
  ...
}: let
  cfg = config.componentZigbee;
in {
  options.componentZigbee = {
    enable = lib.mkEnableOption "Enable zigbee MQTT";
  };

  config = lib.mkIf cfg.enable {
    services.zigbee2mqtt = {
      enable = cfg.enable;
      settings = {
        serial = {
          port = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_9036d4e75dd9ee1180ecb24c37b89984-if00-port0";
          adapter = "ember";
          rtscts = false;
        };

        mqtt = {
          server = "mqtt://localhost:1813";
          user = "zigbee";
          password = "todo";
        };

        frontend = {
          port = 3005;
          host = "0.0.0.0";
          auth_token = "sneaky";
        };
        availability = true;
      };
    };

    # Disable usbcore timeout
    # https://www.zigbee2mqtt.io/guide/faq/#zigbee2mqtt-crashes-after-some-time
    boot.kernelParams = ["usbcore.autosuspend=-1"];

    networking.firewall.allowedTCPPorts = [3005];

    services.mosquitto = {
      enable = cfg.enable;

      listeners = [
        {
          address = "localhost";
          port = 1813;
          users.zigbee = {
            acl = ["readwrite zigbee2mqtt/#"];
            password = "todo";
          };
          users.grafana = lib.mkIf config.componentGrafana.enable {
            acl = ["read zigbee2mqtt/#"];
            password = "todo";
          };
          users.mqttexporter = lib.mkIf config.componentGrafana.enable {
            acl = ["read zigbee2mqtt/#"];
            password = "todo";
          };
        }
      ];
    };

    services.prometheus.exporters.mqtt = lib.mkIf config.componentGrafana.enable {
      enable = true;

      mqttUsername = "mqttexporter";
      mqttAddress = "127.0.0.1";
      mqttPort = 1813;

      zigbee2MqttAvailability = true;

      listenAddress = config.componentGrafana.exporterAddress;
      port = 9686;
    };

    systemd.services."prometheus-mqtt-exporter" = lib.mkIf config.componentGrafana.enable {
      after = ["mosquitto.service"];
      requires = ["mosquitto.service"];
      environment."MQTT_PASSWORD" = "todo";
    };

    services.mqtt2influxdb = lib.mkIf false {
      enable = false;

      influxdb = {
        username = "test";
        password = "test";
        database = "zigbee";
      };

      mqtt = {
        host = "127.0.0.1";
        port = 1813;
        username = "mqtt2influxdb";
        password = "todo";
      };

      points =
        builtins.map (field: {
          fields.value = "$.${field}";
          measurement = field;
          topic = "zigbee2mqtt/0x28dba7fffef35ed3";
        }) [
          "humidity"
          "linkquality"
          "temperature"
          "update_available"
          "voc_index"
        ];

      # points = [
      #   {
      #     fields = {
      #       value = "$.humidity";
      #     };
      #     measurement = "humidity";
      #     topic = "zigbee2mqtt/0x28dba7fffef35ed3";
      #   }
      #   {
      #     fields = {
      #       value = "$.linkquality";
      #     };
      #     measurement = "link-quality";
      #     topic = "zigbee2mqtt/0x28dba7fffef35ed3";
      #   }
      #   {
      #     fields = {
      #       value = "$.pm25";
      #     };
      #     measurement = "pm25";
      #     topic = "zigbee2mqtt/0x28dba7fffef35ed3";
      #   }
      #   {
      #     fields = {
      #       value = "$.temperature";
      #     };
      #     measurement = "temperature";
      #     topic = "zigbee2mqtt/0x28dba7fffef35ed3";
      #   }
      #   {
      #     fields = {
      #       value = "$.voc_index";
      #     };
      #     measurement = "voc-index";
      #     topic = "zigbee2mqtt/0x28dba7fffef35ed3";
      #   }
      # ];
    };

    systemd.services.zigbee2mqtt.startLimitBurst = 5;
    systemd.services.zigbee2mqtt.startLimitIntervalSec = 10;
    systemd.services.zigbee2mqtt.serviceConfig.RestartSec = 30;
  }; # End of config
}
