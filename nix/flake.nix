{
  description = "Simon's system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
    let
      # Shared variables - CHANGE ME
      username = "simon";
      gitUserName = "Simon Hörtzsch";
      gitUserEmail = "simon@hoertzsch.de";
      
      # Define home directories for different platforms
      darwinHome = "/Users/${username}";
      linuxHome = "/home/${username}";

      # Package set helper (enable unfree for Linux targets)
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # macOS Configuration (Apple Silicon)
      darwinConfigurations."MacBook-Air-von-Simon" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs self username darwinHome; };
        modules = [
          ./darwin-configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./home.nix;
            
            # Pass arguments to home.nix
            home-manager.extraSpecialArgs = {
              inherit inputs;
              username = username;
              homeDirectory = darwinHome;
              gitUserName = gitUserName;
              gitUserEmail = gitUserEmail;
              isWSL = false;
            };
          }
        ];
      };

      # Stable alias for macOS builds (avoids host name mismatches)
      darwinConfigurations."macos" = self.darwinConfigurations."MacBook-Air-von-Simon";

      # WSL / Linux Configuration (Standalone Home Manager)
      homeConfigurations."wsl" = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "x86_64-linux"; # WSL runs on x86_64 usually
        modules = [
          ./home.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
          username = username;
          homeDirectory = linuxHome;
          gitUserName = gitUserName;
          gitUserEmail = gitUserEmail;
          isWSL = true;
        };
      };

      # WSL Configuration (ARM64)
      homeConfigurations."wsl-aarch64" = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "aarch64-linux";
        modules = [
          ./home.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
          username = username;
          homeDirectory = linuxHome;
          gitUserName = gitUserName;
          gitUserEmail = gitUserEmail;
          isWSL = true;
        };
      };

      # Generic Linux Configuration (x86_64)
      homeConfigurations."linux-x86_64" = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "x86_64-linux";
        modules = [
          ./home.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
          username = username;
          homeDirectory = linuxHome;
          gitUserName = gitUserName;
          gitUserEmail = gitUserEmail;
          isWSL = false;
        };
      };

      # Generic Linux Configuration (ARM64 / AArch64) - For VMs on Mac
      homeConfigurations."linux-aarch64" = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "aarch64-linux";
        modules = [
          ./home.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
          username = username;
          homeDirectory = linuxHome;
          gitUserName = gitUserName;
          gitUserEmail = gitUserEmail;
          isWSL = false;
        };
      };
    };
}
