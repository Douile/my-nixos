{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  networkName = "virbr0";
in {
  # https://astro.github.io/microvm.nix/declarative.html
  imports = [
    inputs.microvm.nixosModules.host
  ];

  microvm = {
    autostart = [
      "test"
    ];
  };

  microvm.vms = let
    hostNixVersion = config.system.stateVersion;
  in {
    test = {
      pkgs = pkgs;

      config = {
        system.stateVersion = hostNixVersion;

        microvm = {
          hypervisor = "cloud-hypervisor";

          shares = [
            {
              proto = "virtiofs";
              tag = "ro-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
            }
          ];
        };

        users.users.root.password = "";
        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "yes";
        };
      };
    };
  };

  networking.interfaces."${networkName}" = {
    virtual = true;
    virtualType = "tap";
    name = networkName;
    # ipv4.addresses = [
    #   {
    #     address = "10.0.0.1";
    #     prefixLength = 24;
    #   }
    # ];
  };

  networking.firewall.interfaces."${networkName}".allowedUDPPorts = [67];

  networking.nat = {
    enable = true;
    internalInterfaces = [networkName];
  };

  services.dnsmasq = {
    enable = true;

    settings = {
      domain-needed = true;
      dhcp-range = ["10.0.0.2,10.0.0.254"];
      bind-interfaces = [networkName];
    };
  };

  # microvm = {
  #   autostart = [
  #     "test"
  #   ];

  #   vms = {
  #     test = {
  #       pkgs = pkgs;

  #       # The configuration for the MicroVM.
  #       # Multiple definitions will be merged as expected.
  #       config = {
  #         # It is highly recommended to share the host's nix-store
  #         # with the VMs to prevent building huge images.
  #         microvm.shares = [{
  #           source = "/nix/store";
  #           mountPoint = "/nix/.ro-store";
  #           tag = "ro-store";
  #           proto = "virtiofs";
  #         }];
  #       };
  #     };
  #   };
  # };
}
