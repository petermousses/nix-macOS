{
  description = "Peter Mousses Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # homebrew-core = {
    #   url = "github:homebrew/homebrew-core";
    #   flake = false;
    # };
    # homebrew-cask = {
    #   url = "github:homebrew/homebrew-cask";
    #   flake = false;
    # };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:#, homebrew-core, homebrew-cask }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config = {
        allowUnfree = true;
      };

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
          # Terminal setup
          pkgs.mkalias
          pkgs.zsh
          # pkgs.vim
          pkgs.neovim
          pkgs.tmux

          # Development tools
          pkgs.git
          pkgs.openssh
          pkgs.libmamba
          # pkgs.libgcc
          pkgs.gradle
          pkgs.jdk
          pkgs.rustup
          pkgs.qemu
          pkgs.docker
          pkgs.docker-compose
          # pkgs.kubectl

          # Other CLI tools
          pkgs.yt-dlp
          pkgs.neofetch
          pkgs.ffmpeg
          # pkgs.wget
          # pkgs.curl
          # pkgs.ocaml

          # GUI applications
          pkgs.obsidian
          # pkgs.librewolf # no aarch64 support
          pkgs.google-chrome
          # pkgs.bitwarden-desktop # no aarch64 support. Rosseta?
          # pkgs.bitwarden-cli
          # pkgs.spotify
          pkgs.tailscale
        ];
      
      # fonts.packages = [
      # ];

      # https://github.com/zhaofengli/nix-homebrew
      homebrew = {
        enable = true;
        brews = [
          "mas"
          # "rust"
          "cmatrix"
        ];
        casks = [
          "bitwarden"
          "librewolf" # how to use --no-quarantine?
          "the-unarchiver"
          # "google-chrome"
          "spotify"
          "signal"
          "font-monocraft"
          "avibrazil-rdm"
          "unnaturalscrollwheels"
          "utm"
          "vlc"
          "visual-studio-code"
          "aldente"
          "zoom"
        ];
        masApps = {
          # "Tailscale" = "1475387142";
          "MicrosoftOneNote" = 784801555;
          "MicrosoftWord" = 462054704;
          "MicrosoftExcel" = 462058435;
          "MicrosoftPowerPoint" = 462062816;
          # "WindowsAppAKARemoteDesktop" = "1295203466";
          # "Xcode" = "497799835";
          # "DevCleanerXcode" = "1388020431";
          # "Notability" = "360593530";
          # "KindleClassic" = "405399194";
          # "CrystalFetchISO" = "6454431289";
        };
        onActivation = {
          cleanup = "zap";
          autoUpdate = true;
          upgrade = true;
        };
      };

      # Discover settings here: https://daiderd.com/nix-darwin/manual/index.html
      # and here: https://mynixos.com/nix-darwin/options
      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };
      system.defaults = {
        ".GlobalPreferences"."com.apple.sound.beep.sound" = "/System/Library/Sounds/Blow.aiff"; # This should be breeze but the names don't match with the settings app
        # ActivityMonitor.IconType = 5;
        loginwindow.GuestEnabled = false;
        loginwindow.LoginwindowText = "If lost contact peter.mousses@icloud.com";
        ScreenSaver = {
          askForPassword = true;
          askForPasswordDelay = 0;
          modulePath = "/System/Library/Screen Savers/Flurry.saver";
        };
        menuExtraClock = {
          ShowSeconds = true;
          ShowDayOfWeek = true;
          ShowDayOfMonth = true;
          ShowDate = 1;
          ShowAMPM = true;
        };
        finder = {
          FXPreferredViewStyle = "clmv"; # Column view
          _FXSortFoldersFirst = true;
          AppleShowAllFiles = true;
          AppleShowAllExtensions = true;
          FXDefaultSearchScope = "SCcf"; # Search current folder
          QuitMenuItem = false;
          ShowPathbar = false;
          ShowStatusBar = true;
          # NewWindowTarget = "PfHm";
        };
        magicmouse.MouseButtonMode = "TwoButton";
        # screencapture.disable-shadow = true;
        trackpad = {
          ActuationStrength = 0;
          FirstClickThreshold = 0;
          TrackpadRightClick = true;
        };
        WindowManager.EnableStandardClickToShowDesktop = false;
        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          "com.apple.sound.beep.feedback" = 1;
          "com.apple.trackpad.forceClick" = true;
          AppleShowScrollBars = "Always";
          NSAutomaticSpellingCorrectionEnabled = false;
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          # NSAutomaticDashSubstitutionEnable = false;
          NSAutomaticInlinePredictionEnabled = false;
          KeyRepeat = 6;
          InitialKeyRepeat = 25;
          # NSDocumentSaveNewDocumentsToCloud = false;
        };
        dock = {
          orientation = "left";
          magnification = true;
          # largesize = 60;
          showhidden = true;
          show-recents = false;
          persistent-apps = [
            # "/System/Library/CoreServices/Finder.app"
            "/System/Applications/Utilities/Activity Monitor.app"
            "/System/Applications/Mission Control.app"
            "/System/Applications/Launchpad.app"

            "/Applications/Librewolf.app"
            "${pkgs.google-chrome}/Applications/Google Chrome.app"

            "/System/Applications/Calendar.app"
            "/System/Applications/Mail.app"

            "/System/Applications/Utilities/Terminal.app"
            "/Applications/Visual Studio Code.app"
            "/Applications/Android Studio.app"

            "/System/Applications/Reminders.app"
            "/System/Applications/Preview.app"
            "/Applications/Spotify.app"
            "/System/Applications/System Settings.app"
          ];
          persistent-others = [
            "/Users/petermousses/Downloads"
          ];

          # Hot Corners. Options: https://mynixos.com/nix-darwin/option/system.defaults.dock.wvous-bl-corner
          wvous-tl-corner = 5;  # Screen Saver
          wvous-tr-corner = 14;  # Quick Note
          wvous-bl-corner = 11;  # Launchpad
          wvous-br-corner = 4;  # Desktop
        };
      };

      # Source: https://gist.github.com/elliottminns/211ef645ebd484eb9a5228570bb60ec3
      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
            '';

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#PeterBook-Air
    darwinConfigurations."PeterBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "petermousses";
            autoMigrate = true;
            # Optional: Declarative tap management
            # taps = {
            #   "homebrew/homebrew-core" = homebrew-core;
            #   "homebrew/homebrew-cask" = homebrew-cask;
            # };

            # Optional: Enable fully-declarative tap management
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            # mutableTaps = false;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."PeterBook-Air".pkgs;
  };
}
