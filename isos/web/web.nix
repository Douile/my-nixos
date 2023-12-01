{ pkgs, lib, ... }: 

{
  isoImage.edition = "web";

  services.xserver = {
    desktopManager.xfce.enable = true;

    xkb.layout = "gb";

    displayManager = {
      sddm.enable = true;
      autoLogin = {
        enable = true;
        user = "nixos";
      };
    };
  };

  # Remove some xfce bloat
  environment.xfce.excludePackages = with pkgs.xfce // pkgs; [
    xfce4-screenshooter
    ristretto
    parole
    mousepad

    tango-icon-theme
    hicolor-icon-theme
    xfce4-icon-theme
  ];

  # Disable useless networking
  services.openssh.enable = lib.mkForce false;
  networking.wireless.enable = lib.mkForce false;

  # Disable sudo
  security.sudo.enable = lib.mkForce false;

  # Disable root user
  users.users.root.hashedPassword = lib.mkForce "!";

  # Remove nixos user privileges
  users.users.nixos.extraGroups = lib.mkForce [ "networkmanager" "video" ];
  nix.settings.trusted-users = lib.mkForce [ "root" ];

  # Setup librewolf
  programs.firefox = {
    package = pkgs.librewolf;

    enable = true;

    preferences = {
      # Disable javascript
      "javascript.enabled" = 0;
      "javascript.options.wasm" = 0;

      # Disable OCSP queries
      "security.OCSP.enabled" = 0;

      # Disable cross-orign refer
      "network.http.referer.XOriginPolicy" = 2;

      # Enable autoscroll
      "middlemouse.paste" = 0;
      "general.autoScroll" = 1;

      # Prevent Extensions from accessing internet
      "extensions.webextensions.base-content-security-policy" =
        "default-src 'none'; script-src 'none'; object-src 'none';";
      "extensions.webextensions.base-content-security-policy.v3" =
        "default-src 'none'; script-src 'none'; object-src 'none';";

      # Enable dark theme
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    };
  };

  environment.etc."librewolf/policies/policies.json" = {
    source = "/etc/firefox/policies/policies.json";
  };

  # Add packages
  environment.systemPackages = with pkgs; [
    neovim
    librewolf
    mpv
    yt-dlp
    git

    papirus-icon-theme
  ];

  # TODO: Remove unwanted system packages when possible

  # Setup GTK theme
  environment.etc."xdg/gtk-2.0/gtkrc".text = ''
    gtk-theme-name = "Adwaita-dark"
    gtk-icon-theme-name = "Papirus"
    gtk-use-dark-theme = true
    gtk-application-prefer-dark-theme = true
    gtk-cursor-theme-name = "Adwaita"
  '';

  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name = Adwaita-dark
    gtk-icon-theme-name = Papirus
    gtk-use-dark-theme = true
    gtk-application-prefer-dark-theme = true
    gtk-cursor-theme-name = Adwaita
  '';

  # Randomise MACs
  networking.networkmanager.wifi.macAddress = "random";
  networking.networkmanager.ethernet.macAddress = "random";
}
