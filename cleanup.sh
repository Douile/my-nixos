#!/bin/sh

nix-collect-garbage -d
sudo nix-collect-garbage -d

nix-store --gc

nix-store --verify --check-contents