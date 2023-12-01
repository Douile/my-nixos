# Provide a basic configuration for installation devices like CDs.
{ config, pkgs, lib, ... }:

with lib;

{
  config = {
    system.nixos.variant_id = lib.mkDefault "live";

    # Enable in installer, even if the minimal profile disables it.
    documentation.enable = mkImageMediaOverride false;

    # Show the manual.
    documentation.nixos.enable = mkImageMediaOverride false;

    # Use less privileged nixos user
    users.users.nixos = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "video" ];
      # Allow the graphical user to login without password
      initialHashedPassword = "";
    };

    # Automatically log in at the virtual consoles.
    services.getty.autologinUser = "nixos";

    # Some more help text.
    services.getty.helpLine = ''
      The "nixos" and "root" accounts have empty passwords.

      To log in over ssh you must set a password for either "nixos" or "root"
      with `passwd` (prefix with `sudo` for "root"), or add your public key to
      /home/nixos/.ssh/authorized_keys or /root/.ssh/authorized_keys.

      If you need a wireless connection, type
      `sudo systemctl start wpa_supplicant` and configure a
      network using `wpa_cli`. See the NixOS manual for details.
    '' + optionalString config.services.xserver.enable ''

      Type `sudo systemctl start display-manager' to
      start the graphical user interface.
    '';

    # Tell the Nix evaluator to garbage collect more aggressively.
    # This is desirable in memory-constrained environments that don't
    # (yet) have swap set up.
    environment.variables.GC_INITIAL_HEAP_SIZE = "1M";

    # Make the installer more likely to succeed in low memory
    # environments.  The kernel's overcommit heustistics bite us
    # fairly often, preventing processes such as nix-worker or
    # download-using-manifests.pl from forking even if there is
    # plenty of free memory.
    boot.kernel.sysctl."vm.overcommit_memory" = "1";

    # TODO: Needed?
    boot.swraid.enable = true;

    # Show all debug messages from the kernel but don't log refused packets
    # because we have the firewall enabled. This makes installs from the
    # console less cumbersome if the machine has a public IP.
    networking.firewall.logRefusedConnections = mkDefault false;

    # Prevent installation media from evacuating persistent storage, as their
    # var directory is not persistent and it would thus result in deletion of
    # those entries.
    environment.etc."systemd/pstore.conf".text = ''
      [PStore]
      Unlink=no
    '';

    # allow nix-copy to live system
    nix.settings.trusted-users = [ "root" ];
  };
}
