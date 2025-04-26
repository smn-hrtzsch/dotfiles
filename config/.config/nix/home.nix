# ~/.config/nix/home.nix
{ pkgs, ... }: # pkgs usw. werden automatisch übergeben

let
  # Dein Benutzername (zur Sicherheit hier wiederholen oder aus args übernehmen)
  username = "simon";
  homeDirectory = "/Users/${username}";
in
{
  # === Home Manager Grundkonfiguration ===

  home.username = username;
  home.homeDirectory = homeDirectory;

  # WICHTIG: Setze die Home Manager State Version.
  # Diese sollte zur verwendeten nixpkgs-Version passen (z.B. 24.05 oder 24.11 für unstable).
  # Ändere diesen Wert später NICHT ohne Grund!
  home.stateVersion = "24.11"; # Oder "24.11" etc.

  # === Paketinstallation über Home Manager ===

  # Hier fügen wir Pakete hinzu, die nur für DICH installiert werden sollen.
  home.packages = [
    # Füge hier später andere User-Tools hinzu, z.B. pkgs.htop, pkgs.ripgrep etc.
  ];

  # === Neovim Konfiguration ===

  # Wir aktivieren das Neovim-Modul von Home Manager
  programs.neovim = {
    enable = true;
    # package = pkgs.neovim; # Standardmäßig wird pkgs.neovim genommen, explizit ist ok
    # defaultEditor = true; # Setzt $EDITOR auf nvim
    # vimAlias = true;      # Erstellt einen 'vim' Alias für 'nvim'
  };

  # === Grundlegende Neovim Konfiguration (direkt in Nix) ===

  # Home Manager kann Konfigurationsdateien erstellen.
  # Wir erstellen eine minimale init.lua für Neovim.
  # Besser für größere Configs: .source = ./config/nvim/init.lua; verwenden
  home.file.".config/nvim/init.lua" = {
    text = ''
      -- ~/.config/nvim/init.lua (Managed by Home Manager)

      -- Grundlegende Einstellungen
      vim.opt.number = true         -- Zeilennummern anzeigen
      vim.opt.relativenumber = true -- Relative Zeilennummern
      vim.opt.mouse = 'a'           -- Mausunterstützung aktivieren
      vim.opt.tabstop = 4           -- Tabs auf 4 Leerzeichen setzen
      vim.opt.shiftwidth = 4        -- Einrückung auf 4 Leerzeichen
      vim.opt.expandtab = true      -- Tabs in Leerzeichen umwandeln
      vim.opt.ignorecase = true     -- Groß-/Kleinschreibung beim Suchen ignorieren
      vim.opt.smartcase = true      -- ...außer wenn Großbuchstaben im Suchbegriff sind

      print("Neovim config loaded by Home Manager!") -- Kleine Testnachricht
    '';
    # Optional: Stelle sicher, dass das Verzeichnis existiert
    # recursive = true; # Nicht nötig, wenn programs.neovim.enable = true ist
  };

  # === Weitere Home Manager Konfigurationen ===
  # Hier könntest du später Git, Zsh, etc. konfigurieren
  # programs.git = {
  #   enable = true;
  #   userName = "Simon Herzsch";
  #   userEmail = "deine@email.com";
  # };

}