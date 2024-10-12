#!/bin/bash

## Run the commands to set up the environment

# This command needs the sudo password and other inputs, so it is commented for now
# Install Nix package manager. Source: https://nixos.org/download
# echo "Installing Nix package manager"
# sh <(curl -L https://nixos.org/nix/install)

conf_dir="~/.config/nix-darwin"

# Install nix-darwin. Source: https://github.com/LnL7/nix-darwin
echo "Installing nix-darwin"
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix