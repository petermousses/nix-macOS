#!/bin/bash

darwin-rebuild switch --flake .#$(scutil --get LocalHostName) --extra-experimental-features "nix-command flakes"