# nix/home.nix
{ pkgs, config, username, homeDirectory, ... }:

let
  dotfilesDir = "${homeDirectory}/dotfiles";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "24.11";

  # User Packages
  home.packages = with pkgs; [
    # Shell & Tools
    stow
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting
    eza
    zoxide
    neofetch
    fzf
    bat
    gh
    jq
    git-lfs
    cmake
    cloc
    shellcheck
    direnv
    tree
    pyenv
    # dockutil # Only useful on macOS, technically works on linux but useless. Nix filters valid pkgs usually.
    
    # Fun/Misc
    # ...
  ] ++ (if pkgs.stdenv.isDarwin then [
    pkgs.dockutil # Install dockutil only on macOS
  ] else []);

  # Programs Configuration
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Simon Hörtzsch"; 
    userEmail = "simon@hoertzsch.de";
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    initContent = ''
      # Nix: Load Powerlevel10k directly from Nix store
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # Source existing zshrc from dotfiles
      if [ -f ${dotfilesDir}/zsh/.zshrc ]; then
        source ${dotfilesDir}/zsh/.zshrc
      fi
    '';
  };
  
  programs.fzf = {
    enable = true;
    enableZshIntegration = false; # We manage this in .zshrc
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = false; # We manage aliases in .zshrc
  };
  
  programs.zoxide = {
    enable = true;
    enableZshIntegration = false; # We manage this in .zshrc
  };
  
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true; # Keep this, it's complex to setup manually
  };

  # Symlink Dotfiles
  home.file = {
    ".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/ghostty";
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/nvim";
    # Link p10k config directly to home
    ".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/zsh/.p10k.zsh";
    
    # sketchybar is macOS only
    ".config/raycast".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/raycast";
    ".config/gh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/gh";
    ".config/neofetch".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/neofetch";
  } // (if pkgs.stdenv.isDarwin then {
    ".config/sketchybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/sketchybar";
  } else {});

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

}