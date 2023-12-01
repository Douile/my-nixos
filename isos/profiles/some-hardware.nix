# This module enables all hardware supported by NixOS: i.e., all
# firmware is included, and all devices from which one may boot are
# enabled in the initrd.  Its primary use is in the NixOS installation
# CDs.

{ pkgs, lib,... }:
let
  platform = pkgs.stdenv.hostPlatform;
in
{

  # The initrd has to contain any module that might be necessary for
  # supporting the most important parts of HW like drives.
  boot.initrd.availableKernelModules =
    [ # SATA/PATA support.
      "ahci"

      "ata_piix"

      "sata_inic162x" "sata_nv" "sata_promise" "sata_qstor"
      "sata_sil" "sata_sil24" "sata_sis" "sata_svw" "sata_sx4"
      "sata_uli" "sata_via" "sata_vsc"

      # USB support, especially for booting from USB CD-ROM
      # drives.
      "uas"

      # SD cards.
      "sdhci_pci"

      # NVMe drives
      "nvme"

      # Virtio (QEMU, KVM etc.) support.
      "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "virtio_balloon" "virtio_console"
    ]; 

  # Include lots of firmware.
  #hardware.enableRedistributableFirmware = true;
}
