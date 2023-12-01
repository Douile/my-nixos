# Enable vmware guest additions

{ pkgs, ... }:

{
  virtualisation.vmware.guest.enable = pkgs.stdenv.hostPlatform.isx86;
}
