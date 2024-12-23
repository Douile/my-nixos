# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./vms.nix
    ./secrets.nix
    ../components/grafana.nix
    ../components/ntfy.nix
    ../components/wireless.nix
    ../components/zigbee.nix
    ../components/invidious.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "supervisor"; # Define your hostname.
  networking.iproute2.enable = true;
  #hardware.enableRedistributableFirmware = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "uk";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    curl
  ];

  # Disable docs (we don't need them)
  documentation = {
    enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
    dev.enable = false;
    nixos.enable = false;
  };

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      "/run/secrets/authorized_keys"
    ];
  };

  users.users.user = {
    isNormalUser = true;
  };

  nix.optimise.automatic = true;
  nix.settings.allowed-users = ["root" "user"];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 2d";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  # Open ports in the firewall.
  networking.firewall.interfaces.enp1s0.allowedTCPPorts = [22];
  networking.firewall.allowedTCPPorts = [80 443];
  networking.firewall.allowedUDPPorts = [443];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  networking.nftables.enable = true;

  networking.wireguard.interfaces."wg0" = {
    privateKeyFile = "/run/secrets/wg0_private_key";
    listenPort = 51820;
    ips = ["192.168.20.16/24"];

    peers = [
      {
        publicKeyFile = "/run/secrets/wg0_public_key";
        endpoint = "vpn_endpoint.internal:5555";
        allowedIPs = ["192.168.20.0/24"];
        persistentKeepalive = 25;
      }
    ];
  };

  # Self-signed cert provider
  services.step-ca = {
    enable = true;
    intermediatePasswordFile = "/run/secrets/step_intermediate_password";
    address = "127.0.0.1";
    port = 8443;
    settings = {
      root = "/run/secrets/step_root";
      federatedRoots = null;
      crt = "/run/secrets/step_crt";
      key = "/run/secrets/step_key";
      address = "127.0.0.1:8443";
      insecureAddress = "";
      dnsNames = ["ca.supervisor.internal.douile.com"];
      logger = {format = "text";};
      db = {
        type = "badgerv2";
        dataSource = "/var/lib/step-ca/db";
        badgerFileLoadingMode = "";
      };
      authority.provisioners = [
        {
          type = "JWK";
          name = "supervisor@internal.douile.com";
          key = {
            use = "sig";
            kty = "EC";
            kid = "XrVHjPl9GXwWmR6lPEwAPf7NAPvkV34qYQ94j0unJPc";
            crv = "P-256";
            alg = "ES256";
            x = "XtrGenuHJ7qrMDOuxlqBDgsQ_arr0S5Lb9fQdh5yBDg";
            y = "kyySCPrliH5SLWrXNTeBHEo7_0qSo6k2m7QMC9sInk8";
          };
          encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjYwMDAwMCwicDJzIjoiTUx4M3N0bVNMMEc0VmFKZ2lNbm1rUSJ9.3Sjb0GX7VVilG12567cxIUzgH3y5Bftis0S1MYGlQrfockh0Uu0D3A.Sekoh-Bsx6FGtr8H.Nqs-3MM6yjFhxWCJnOHrrsR7kTaTy4DKiCVS4BzoPn-7xXFZcoD6w5sM5ArsGr5ofl-pfo4-RLki3hhr55yoZRPu642t3Ei334cVcy4sojF6AqknyIYS0oZ_uf-aLJmqSX-mvDkm8UyUVl8Izzb3KsRylCZGUitLNnuzCN4UuA6LbgxTf3jsvn4CvGBS4uV2-kYczxEDI3wtQjc_vs6IbPOJfULfaiQ5bjHj6jFAX8l4-zle2IHsMjmNQHKo86EbIinrMBalbpmIT4IcetEsJ7Hv_zhRaAZiKPit9-634gpP9T64bx9JEx4TRE090g7V4VUJ1pjCL-Cdw9G2YMg.hooG4TszW9E01JBFtkNPiA";
        }
      ];
      tls = {
        cipherSuites = [
          "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
          "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        ];
        minVersion = 1.2;
        maxVersion = 1.3;
        renegotiation = false;
      };
    };
  };

  networking.hosts = {
    "127.0.0.1" = ["ca.supervisor.internal.douile.com" "supervisor.internal.douile.com" "invidious.supervisor.internal.douile.com"];
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "supervisor@internal.douile.com";
  security.acme.defaults.server = "https://ca.supervisor.internal.douile.com:8443";
  security.acme.defaults.dnsProvider = null;
  security.acme.defaults.webroot = "/var/lib/acme/acme-challenge";

  services.nginx = {
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;

    # virtualHosts."supervisor.internal.douile.com" = {
    #   enableACME = true;
    # };
  };

  # systemd.services."acme-supervisor.internal.douile.com" = { # TODO: fix this trying to use DNS
  #   after = [ "step-ca.service" ];
  #   wants = [ "network-online.target" ];
  #   requires = [ "step-ca.service" ];
  #   #enable = false;
  # };

  security.pki.certificates = [
    ''
      step-ca
      =========
      -----BEGIN CERTIFICATE-----
      MIIB0DCCAXagAwIBAgIQGnUezmR6D82tPTk2r0C7fTAKBggqhkjOPQQDAjAyMRMw
      EQYDVQQKEwpzdXBlcnZpc29yMRswGQYDVQQDExJzdXBlcnZpc29yIFJvb3QgQ0Ew
      HhcNMjQxMjE5MTkyNTIzWhcNMzQxMjE3MTkyNTIzWjA6MRMwEQYDVQQKEwpzdXBl
      cnZpc29yMSMwIQYDVQQDExpzdXBlcnZpc29yIEludGVybWVkaWF0ZSBDQTBZMBMG
      ByqGSM49AgEGCCqGSM49AwEHA0IABMm0gLnLOrVvE1zxMQ3nEe9jA3cUrUpnW71S
      J82RGjXQ/XxgPAVVhhke0TeBW0XqRQSh68ZV5SODQWkkkSMOeT+jZjBkMA4GA1Ud
      DwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBSbvVfN7/Qx
      yY9yMLn6HgMgCJouejAfBgNVHSMEGDAWgBTUe2fWwVJtBgG4ScTuGiZBFs9HZTAK
      BggqhkjOPQQDAgNIADBFAiEAhSNXwTO/ecaqYwk6hS4hQb8hsY0wfcxA4Q6mhMRc
      4xACIB99n9XgWLv0MrtURfq6Gwv/ayNbGI+4JZAGwVKdv9q5
      -----END CERTIFICATE-----
    ''
  ];
  # security.pki.certificateFiles = [ "/run/secrets/step_crt" ];

  componentGrafana.enable = true;
  componentNtfy.enable = false;
  componentWireless.enable = false;
  componentZigbee.enable = true;
  componentInvidious.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
