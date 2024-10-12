{
  description = "Peter Mousses Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
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
          pkgs.qemu
          pkgs.gradle
          # pkgs.libgcc
          pkgs.jdk

          # Other CLI tools
          pkgs.yt-dlp
          pkgs.neofetch
          # pkgs.ffmpeg
          # pkgs.wget
          # pkgs.curl
          # pkgs.ocaml

          # GUI applications
          pkgs.obsidian
          pkgs.librewolf
          pkgs.bitwarden-cli
          pkgs.spotify

        ];
      
      # fonts.packages = [
      # ];

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "rust"
        ];
        casks = [
          "bitwarden"
          # "librewolf"
          "the-unarchiver"
          "google-chrome"
          # "spotify"
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
          "Tailscale" = "1475387142";
        };
        onActivation = {
          # cleanup = "zap";
          autoUpdate = true;
          upgrade = true;
        };
      };

      # Discover settings here: https://daiderd.com/nix-darwin/manual/index.html
      # and here: https://mynixos.com/nix-darwin/options
      system.keyboard.remapCapsLockToEscape = true;
      system.defaults = {
        # ActivityMonitor.IconType = 5;
        dock = {
          largesize = 60;
          persistent-apps = [
            "/System/Applications/Finder"
            "/System/Applications/Activity Monitor"
            "/System/Applications/Mission Control"
            "/System/Applications/Launchpad"
            "/Applications/Librewolf.app"
            "/Applications/Google Chrome.app"

            "/System/Applications/Calendar"
            "/System/Applications/Mail"
            "/System/Applications/Utilities/Terminal.app"
            "com.apple.terminal"
            "/Applications/Visual Studio Code.app"

            "com.apple.reminders"
            "com.apple.preview"
            "/Applications/Spotify.app"
            "/System/Applications/System Preferences.app"

            "com.apple.notes"
            "com.apple.Music"
          ];
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
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."PeterBook-Air".pkgs;
  };
}
