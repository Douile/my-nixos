# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nix-devbox"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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
  services.xserver = {
    layout = "gb";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Setup default shell
  users.defaultUserShell = pkgs.zsh;

  # Use dash for /bin/sh
  environment.binsh = "${pkgs.dash}/bin/dash";

  # Mount src filesystem
  fileSystems."/src" = {
    fsType = "virtiofs";
    device = "src_mnt";
    noCheck = true;
    neededForBoot = false;
    options = [
      "defaults"
      "nofail"
    ];
  };

  # Mount tmp filesystem
  fileSystems."/tmp" = {
    fsType = "tmpfs";
    device = "none";
    noCheck = true;
    neededForBoot = true;
    options = [
      "defaults"
      "huge=always"
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dev = {
    isNormalUser = true;
    description = "dev";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    openssh = {
      authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgfKjKKJfDBlPimzK3UxymYVWqK0TQCeXyil+YwkKsn generic-key"
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     # Dev environment
     neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     git
     git-lfs
     eza
     gnupg
     pinentry-curses
     curl
     pre-commit

     # Shell tools
     ripgrep
     fzf
     fd
     file
     jq
     yq

     # Compilers
     rustup
     gcc
     clang
     nodejs
     deno
     bun
     python311
     go
     gopls
     go-outline
     gnumake
     protobuf

     # Containers
     podman
     podman-compose
     act

     # Shells
     zsh
     dash
     
     # Home manager
     home-manager
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

  # Setup gpg
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
  };

  # Enable nix-ld
  programs.nix-ld.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable qemu guest-agent
  services.qemuGuest.enable = true;

  # Enable spice agent
  services.spice-vdagentd.enable = true;

  # Enable podman
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Home manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      dev = import ./home.nix;
    };
  };

  # Enable storage optimisation
  nix.optimise.automatic = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
