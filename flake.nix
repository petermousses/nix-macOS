{
  description = "Peter Mousses Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs:
  let
    userName = "petermousses";
    hostName = "PeterBook-Air";
    systemType = "aarch64-darwin";

    generalConfiguration = { pkgs, config, ... }: {
      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      # programs.zsh = {
      #   enable = true;
      #   enableCompletion = true;
      #   # enableAutosuggestions = true;
      #   enableSyntaxHighlighting = true;
      #   shellAliases = {
      #     rsch="cd /Users/${userName}/Documents/ASU_Local/Research";
      #     nav="cd /Users/${userName}/Documents/ASU_Local/3_2024_Fall";
      #     ll="ls -lAG";
      #     ls="ls --color=auto -F";
      #     gcc="gcc -marm";
      #     gpgZ="gpg -c --no-symkey-cache --cipher-algo AES256";
      #   };
      # };
      # programs.fish.enable = true;
      environment.shells = [ pkgs.bash pkgs.zsh ];
      environment.loginShell = pkgs.zsh;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "${systemType}";
    };

    systemPackagesConfiguration = { pkgs, config, ...}: {
      nixpkgs.config = {
        allowUnfree = true;
        # allowUnsupportedSystem = true;
        # allowBroken = true;
      };

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        # Terminal setup
        pkgs.mkalias
        pkgs.zsh
        # pkgs.oh-my-zsh
        # pkgs.bash
        # pkgs.vim
        pkgs.neovim
        pkgs.tmux

        # Development tools
        # pkgs.coreutils
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
        pkgs.tree
        pkgs.cmatrix
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
        pkgs.spotify
        # pkgs.tailscale # Isn't shown in apps
        # pkgs.signal-desktop
        pkgs.utm
        pkgs.vlc-bin-universal
        # pkgs.unar # The Unarchiver # Isn't shown in apps
      ];
    };

    fontsConfiguration = { pkgs, config, ...}: {
      fonts = {
        fontDir.enable = false;
        # "monocraft" = pkgs.fonts.monocraft;
        fonts = [
          # pkgs.fonts.monocraft
          (pkgs.nerdfonts.override {
            fonts = [
              pkgs.nerdfonts.FiraCode
              pkgs.nerdfonts.Hack
              pkgs.nerdfonts.JetBrainsMono
              pkgs.nerdfonts.Mononoki
              pkgs.nerdfonts.SourceCodePro
              pkgs.nerdfonts.UbuntuMono
            ];
          })
        ];
      };
    };

    homebrewConfiguration = { pkgs, config, nix-homebrew, ...}: {
      # https://github.com/zhaofengli/nix-homebrew
      # inputs.nix-homebrew.darwinModules.nix-homebrew {
        homebrew = {
          # Your nix-homebrew configuration
          enable = false;
          homebrewPrefix = "/opt/homebrew";
          user = "${userName}";
          enableRosetta = true;
          autoMigrate = true;
          brews = [
            "mas"
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
          # Optional: Declarative tap management
          # taps = {
          #   "homebrew/homebrew-core" = homebrew-core;
          #   "homebrew/homebrew-cask" = homebrew-cask;
          # };

          # Optional: Enable fully-declarative tap management
          # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
          # mutableTaps = false;
        };
      # }
    };

    homebrewConfiguration2 = { pkgs, config, nix-homebrew, ...}: {
      system.activationScripts.installHomebrew.text = let
        env = pkgs.buildEnv {
          name = "homebrew";
          paths = config.environment.systemPackages;
          pathsToLink = "/opt/homebrew";
        };
      in
        pkgs.lib.mkForce ''
          # Install Homebrew
          echo "installing Homebrew..." >&2
          rm -rf /opt/homebrew
          mkdir -p /opt
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        '';

      # https://github.com/zhaofengli/nix-homebrew
      homebrew = {
        brews = [
          "mas"
        ];
        casks = [
          "bitwarden"
          "librewolf" # how to use --no-quarantine?
          # "the-unarchiver"
          # "google-chrome"
          # "spotify"
          "signal"
          "font-monocraft"
          "avibrazil-rdm"
          "unnaturalscrollwheels"
          # "vlc"
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
    };

    systemConfiguration = { pkgs, config, ... }: {
      # Discover settings here: https://daiderd.com/nix-darwin/manual/index.html
      # and here: https://mynixos.com/nix-darwin/options
      system = {
        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToEscape = true;
        };
        defaults = {
          ".GlobalPreferences"."com.apple.sound.beep.sound" = "/System/Library/Sounds/Blow.aiff"; # This should be breeze but the names don't match with the settings app
          # ActivityMonitor.IconType = 5;
          loginwindow = {
            GuestEnabled = false;
            LoginwindowText = "If lost contact peter.mousses@icloud.com";
          };
          # ScreenSaver = {
          #   askForPassword = true;
          #   askForPasswordDelay = 0;
          #   modulePath = "/System/Library/Screen Savers/Flurry.saver";
          # };
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
            _FXShowPosixPathInTitle = true;
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
            AppleInterfaceStyle = "Dark"; # Doesn't work
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
              "${pkgs.spotify}/Applications/Spotify.app"
              "/System/Applications/System Settings.app"
            ];
            persistent-others = [
              "/Users/${userName}/Downloads"
            ];

            # Hot Corners. Options: https://mynixos.com/nix-darwin/option/system.defaults.dock.wvous-bl-corner
            wvous-tl-corner = 5;  # Screen Saver
            wvous-tr-corner = 14;  # Quick Note
            wvous-bl-corner = 11;  # Launchpad
            wvous-br-corner = 4;  # Desktop
          };
        };
      };
    };

    scripts = { pkgs, config, ... }: {
      system.activationScripts.extraActivation.text = ''
        # Install Rosetta
        echo "installing Rosetta..." >&2
        softwareupdate --install-rosetta --agree-to-license
      '';

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

      system.activationScripts.setScreensaver.text = let
      in
        pkgs.lib.mkForce ''
          # Set screensaver settings
          echo "setting up screensaver..." >&2
          sudo -u ${userName} /usr/bin/defaults -currentHost write com.apple.screensaver moduleDict -dict-add \
            moduleName "Flurry" \
            path "/System/Library/Screen Savers/Flurry.saver" \
            type -int 0

          sudo -u ${userName} /usr/bin/defaults -currentHost write com.apple.screensaver idleTime -int 300

          sudo -u ${userName} /usr/bin/defaults write com.apple.screensaver askForPassword -int 1
          sudo -u ${userName} /usr/bin/defaults write com.apple.screensaver askForPasswordDelay -int 0
        '';
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#PeterBook-Air
    darwinConfigurations."${hostName}" = inputs.nix-darwin.lib.darwinSystem {
      modules = [
        generalConfiguration
        systemConfiguration
        # fontsConfiguration
        systemPackagesConfiguration
        homebrewConfiguration2
        scripts
        inputs.nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = false;
            enableRosetta = true;
            user = "${userName}";
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
        # inputs.nix-homebrew.darwinModules.nix-homebrew {
        #   nix-homebrew = {
        #     # Your nix-homebrew configuration
        #     enable = true;
        #     user = "${userName}";
        #     enableRosetta = true;
        #     autoMigrate = true;
        #     brews = [
        #       "mas"
        #     ];
        #     casks = [
        #       "bitwarden"
        #       "librewolf" # how to use --no-quarantine?
        #       "the-unarchiver"
        #       # "google-chrome"
        #       # "spotify"
        #       "signal"
        #       "font-monocraft"
        #       "avibrazil-rdm"
        #       "unnaturalscrollwheels"
        #       "utm"
        #       "vlc"
        #       "visual-studio-code"
        #       "aldente"
        #       "zoom"
        #     ];
        #     masApps = {
        #       # "Tailscale" = "1475387142";
        #       "MicrosoftOneNote" = 784801555;
        #       "MicrosoftWord" = 462054704;
        #       "MicrosoftExcel" = 462058435;
        #       "MicrosoftPowerPoint" = 462062816;
        #       # "WindowsAppAKARemoteDesktop" = "1295203466";
        #       # "Xcode" = "497799835";
        #       # "DevCleanerXcode" = "1388020431";
        #       # "Notability" = "360593530";
        #       # "KindleClassic" = "405399194";
        #       # "CrystalFetchISO" = "6454431289";
        #     };
        #     onActivation = {
        #       cleanup = "zap";
        #       autoUpdate = true;
        #       upgrade = true;
        #     };
        #     # Optional: Declarative tap management
        #     # taps = {
        #     #   "homebrew/homebrew-core" = homebrew-core;
        #     #   "homebrew/homebrew-cask" = homebrew-cask;
        #     # };

        #     # Optional: Enable fully-declarative tap management
        #     # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
        #     # mutableTaps = false;
        #   };
        # }
        # inputs.home-manager.darwinModules.home-manager {
        #   home-manager = {
        #     useGlobalPkgs = true;
        #     useUserPackages = true;
        #     users.${userName}.imports = [
        #       ({pkgs, ...}: {

        #         home.stateVersion = "23.05";  # Don't change this when changing package inputs
        #         home.packages = [
        #           # Terminal setup
        #           pkgs.mkalias
        #           pkgs.zsh
        #           # pkgs.oh-my-zsh
        #           # pkgs.bash
        #           # pkgs.vim
        #           pkgs.neovim
        #           pkgs.tmux

        #           # Development tools
        #           # pkgs.coreutils
        #           pkgs.git
        #           pkgs.openssh
        #           pkgs.libmamba
        #           # pkgs.libgcc
        #           pkgs.gradle
        #           pkgs.jdk
        #           pkgs.rustup
        #           pkgs.qemu
        #           pkgs.docker
        #           pkgs.docker-compose
        #           # pkgs.kubectl

        #           # Other CLI tools
        #           pkgs.yt-dlp
        #           pkgs.neofetch
        #           pkgs.cmatrix
        #           pkgs.ffmpeg
        #           # pkgs.wget
        #           # pkgs.curl
        #           # pkgs.ocaml

        #           # GUI applications
        #           pkgs.obsidian
        #           # pkgs.librewolf # no aarch64 support
        #           pkgs.google-chrome
        #           # pkgs.bitwarden-desktop # no aarch64 support. Rosseta?
        #           # pkgs.bitwarden-cli
        #           # pkgs.spotify
        #           pkgs.tailscale
        #         ];
        #         home.sessionVariables = {
        #           PAGER = "less";
        #           EDITOR = "nvim";
        #           CLICOLOR = 1;
        #           # VISUAL = "nvim";
        #           # TERM = "xterm-256color";
        #         };
        #         programs.git.enable = true;
        #         programs.zsh = {
        #           enable = true;
        #           enableCompletion = true;
        #           autosuggestion.enable = true;
        #           syntaxHighlighting.enable = true;
        #           shellAliases = {
        #             rsch="cd /Users/${userName}/Documents/ASU_Local/Research";
        #             nav="cd /Users/${userName}/Documents/ASU_Local/3_2024_Fall";
        #             ll="ls -lAG";
        #             ls="ls --color=auto -F";
        #             gcc="gcc -marm";
        #             gpgZ="gpg -c --no-symkey-cache --cipher-algo AES256";
        #           };
        #         };
        #       })
        #     ];
        #   };
        # }
      ];
    };

    # homeConfigurations."${userName}" = inputs.home-manager.lib.homeManagerConfiguration {
    #   pkgs = inputs.nixpkgs.legacyPackages."${systemType}";
    #   homeDirectory = "/Users/${userName}";
    #   stateVersion = "23.05";  # Adjust to your home-manager version
    #   extraSpecialArgs = { inherit inputs; };
    #   modules = [
    #     ./home.nix  # Path to your home-manager configuration
    #   ];
    # };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = inputs.self.darwinConfigurations."${hostName}".pkgs;
  };
}
