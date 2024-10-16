#!/bin/bash

## Run the commands to set up the environment

# This command needs the sudo password and other inputs, so it is commented for now
# Install Nix package manager. Source: https://nixos.org/download
echo "Installing Nix package manager"
sh <(curl -L https://nixos.org/nix/install)

conf_dir="~/.config/nix-darwin"

echo "Installing homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
mkdir -p /opt/homebrew/Library/

# Install nix-darwin. Source: https://github.com/LnL7/nix-darwin
echo "Installing nix-darwin"
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix

# Initial build
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake .#$(scutil --get LocalHostName)