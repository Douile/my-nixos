# Enable QEMU guest additions

{ ... }:

{
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
}
