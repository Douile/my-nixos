#!/bin/sh

ISO="${1:-web}"

printf "\033[32mBuilding \033[0;1m\"%s\"\033[0;32m iso...\033[0m\n" "$ISO" 

nix build --show-trace .#nixosConfigurations."${ISO}Iso".config.system.build.isoImage
