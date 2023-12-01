{
  description = "Live NixOS";
  inputs.nixos.url = "nixpkgs/nixos-unstable";
  outputs = { self, nixos }: {
    nixosConfigurations = {
      webIso = nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./profiles/some-hardware.nix
          "${nixos}/nixos/modules/profiles/hardened.nix"
          ./profiles/guest-additions-qemu.nix
          ./base/cd-graphical-base.nix
          ./web/web.nix
        ];
      };
    };
  };
}
