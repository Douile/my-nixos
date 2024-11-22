{
  description = "My server flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    impermanence.url = "github:nix-community/impermanence";

    deploy-rs.url = "github:serokell/deploy-rs";

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    impermanence,
    deploy-rs,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;

      config.allowUnfree = true;
    };

    deployPkgs = import nixpkgs {
      inherit system;

      overlays = [
        deploy-rs.overlay
        (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
      ];
    };
  in {
    formatter."${system}" = pkgs.alejandra;

    nixosConfigurations = {
      localgpt = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs system;};

        modules = [
          ./localgpt/configuration.nix
        ];
      };

      test-impermenance = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs system;};

        modules = [
          impermanence.nixosModules.impermanence
          ./test-impermenance/configuration.nix
        ];
      };

      supervisor = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs system;};

        modules = [
          ./supervisor/configuration.nix
        ];
      };

      supervisorStaging = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs system;};

        modules = [
          ./supervisor-staging/configuration.nix
        ];
      };
    };

    deploy.nodes.supervisor = {
      hostname = "192.168.0.152";
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.supervisor;
      };
    };

    deploy.nodes.supervisorStaging = {
      hostname = "supervisor-staging";
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.supervisorStaging;
      };
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
