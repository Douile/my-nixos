# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  sound.enable = false;

  networking.hostName = "nix-localgpt"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Setup default shell
  users.defaultUserShell = pkgs.zsh;

  # Use dash for /bin/sh
  environment.binsh = "${pkgs.dash}/bin/dash";

  # Mount tmp filesystem
  fileSystems."/tmp" = {
    fsType = "tmpfs";
    device = "none";
    noCheck = true;
    neededForBoot = true;
    options = [
      "defaults"
      "huge=always"
      "nodev"
      "nosuid"
      "size=20%"
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root = {
    uid = 0;
    openssh = {
      authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINJ5YB/4Des3q9zw2KTldv1mT9Xz9ZD1vpuYyZWH5ytq dev@nix-devbox"
      ];
    };
  };

 

  users.users.localgpt = {
    isNormalUser = true;
    description = "localgpt";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [  ];
    initialPassword = "nix";
    openssh = {
      authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINJ5YB/4Des3q9zw2KTldv1mT9Xz9ZD1vpuYyZWH5ytq dev@nix-devbox"
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # TODO: Add definitions for environments then include them individually
  environment.systemPackages = with pkgs; [
     # Dev environment
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.

     dash
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # Enable zsh
  programs.zsh.enable = true;


  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;

    settings.PermitRootLogin = "prohibit-password";
  };

    services = {
      open-webui = {
        enable = true;
        package = pkgs.open-webui;
        port = 8080;
        host = "0.0.0.0";
        environment = {
          WEBUI_AUTH = "False";
          ENABLE_OLLAMA_API = "True";
          OLLAMA_BASE_URL = "http://127.0.0.1:11434";
          OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
          ENABLE_OPENAI_API = "False";
          DEVICE_TYPE = "cpu";
          ENABLE_RAG_HYBRID_SEARCH = "True";
          RAG_EMBEDDING_ENGINE = "ollama";
          RAG_EMBEDDING_MODEL = "mxbai-embed-large:latest";
          RAG_EMBEDDING_MODEL_AUTO_UPDATE = "True";
          RAG_RERANKING_MODEL_AUTO_UPDATE = "True";
          ENABLE_RAG_WEB_SEARCH = "False";
          ENABLE_IAMGE_GENERATION = "True";
        };
      };

      ollama = {
        enable = true;
      };
    };

  # Enable qemu guest-agent
  services.qemuGuest.enable = true;

  # Enable spice agent
  services.spice-vdagentd.enable = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable storage optimisation
  nix.optimise.automatic = true;
  nix.gc.automatic = true;
  nix.settings.auto-optimise-store = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
