{ config, pkgs, lib, ... }:

{
  home.username = "petermousses";
  home.homeDirectory = "/Users/petermousses";

  # Activation script to set the screensaver
  home.activation.setScreensaver = lib.hm.activationScript {
    description = "Set screensaver settings";
    script = ''
      /usr/bin/defaults -currentHost write com.apple.screensaver moduleDict -dict-add \
        moduleName "Flurry" \
        path "/System/Library/Screen Savers/Flurry.saver" \
        type -int 0

      # Set screensaver idle time to 5 minutes (300 seconds)
      /usr/bin/defaults -currentHost write com.apple.screensaver idleTime -int 300

      # Require password immediately after screensaver starts
      /usr/bin/defaults write com.apple.screensaver askForPassword -int 1
      /usr/bin/defaults write com.apple.screensaver askForPasswordDelay -int 0
    '';
  };

  # Other home-manager configurations can be added here
  # For example, shell configurations, environment variables, etc.
}