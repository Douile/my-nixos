# This module contains the basic configuration for building a graphical NixOS
# installation CD.
# Based on:
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix

{ lib, pkgs, ... }:

with lib;

{
  imports = [ ./cd-base.nix ];

  services.xserver.enable = true;

  # Provide networkmanager for easy wireless configuration.
  networking.networkmanager.enable = true;
  networking.wireless.enable = mkImageMediaOverride false;

  # KDE complains if power management is disabled (to be precise, if
  # there is no power management backend such as upower).
  powerManagement.enable = true;

  # Enable sound in graphical iso's.
  hardware.pulseaudio.enable = true;

  # Enable plymouth
  boot.plymouth.enable = true;

  environment.defaultPackages = with pkgs; [
    # Include some editors.
    vim

    # Include some version control tools.
    git
  ];

}
