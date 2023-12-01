# Enable XE guest additions

{ pkgs, ... }:

{
  services.xe-guest-utilities.enable = pkgs.stdenv.hostPlatform.isx86;
}
