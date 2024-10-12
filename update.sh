#!/bin/bash

darwin-rebuild switch --flake .#$(scutil --get LocalHostName)