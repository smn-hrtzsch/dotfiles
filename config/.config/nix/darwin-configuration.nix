{ pkgs, ... }: {
    # Aktiviere Zsh (Nix-Darwin kümmert sich darum, sie im Pfad verfügbar zu machen)
    programs.zsh.enable = true;

    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages =
        [ pkgs.vim
        ];

    # Stelle sicher, dass dein Benutzer konfiguriert ist (Beispiel)
    users.users.simon = { # Ersetze simon durch deinen Benutzernamen
    home = "/Users/simon"; # Passe den Pfad an
    };

    # Necessary for using flakes on this system.
    nix.settings.experimental-features = "nix-command flakes";

    # Enable alternative shell support in nix-darwin.
    programs.fish.enable = true;

    # Set Git commit hash for darwin-version.
    # system.configurationRevision = self.rev or self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 6;

    # The platform the configuration will be used on.
    nixpkgs.hostPlatform = "aarch64-darwin";

    # Erlaube ggf. unfree Pakete, falls du später welche brauchst (z.B. VS Code)
    nixpkgs.config.allowUnfree = true;
}