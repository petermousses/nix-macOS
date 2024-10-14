#!/bin/bash

# darwin-rebuild switch --flake .#$(scutil --get LocalHostName) --extra-experimental-features "nix-command flakes"
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake .#$(scutil --get LocalHostName)