{
  description = "Simon's nix-darwin system flake";

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
      # Dein Benutzername (wird später gebraucht)
      username = "simon"; # Passe dies an, falls dein macOS-Benutzername anders ist
      # Dein Home-Verzeichnis (wird später gebraucht)
      homeDirectory = "/Users/${username}"; # Passe dies an
    in
    {
      # Bestehende darwinConfigurations...
      darwinConfigurations."MacBook-Air-von-Simon" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs self; };
        modules = [ 
          ./darwin-configuration.nix 

          home-manager.darwinModules.home-manager
          {
            # Konfiguration für Home Manager selbst
            home-manager.useGlobalPkgs = true; # Erlaube HM, Pakete aus nixpkgs zu nutzen
            home-manager.useUserPackages = true; # Erlaube HM, benutzerspezifische Pakete zu verwalten

            # Konfiguration für deinen Benutzer
            home-manager.users.${username} = import ./home.nix; # Wir erstellen diese Datei gleich

            # Zusätzliche Argumente an home.nix übergeben (optional, aber gute Praxis)
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
}
