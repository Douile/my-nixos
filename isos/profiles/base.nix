# This module defines the software packages included in the "minimal"
# installation CD. It might be useful elsewhere.

{ config, lib, pkgs, ... }:

{
  # Include some utilities that are useful for installing or repairing
  # the system.
  environment.systemPackages = [
    # Some text editors.
    (pkgs.vim.customize {
      name = "vim";
      vimrcConfig.packages.default = {
        start = [ pkgs.vimPlugins.vim-nix ];
      };
      vimrcConfig.customRC = "syntax on";
    })

    # Some compression/archiver tools.
    pkgs.unzip
    pkgs.zip
  ];

  # Include support for various filesystems and tools to create / manipulate them.
  boot.supportedFilesystems =
    ["vfat"] ++
    lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform config.boot.zfs.package) "zfs";

  # Configure host id for ZFS to work
  networking.hostId = lib.mkDefault "8425e349";
}
