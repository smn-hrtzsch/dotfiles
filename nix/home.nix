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
    
    # Node.js & Tools
    nodejs_22
    
    # Fun/Misc
    # ...
  ] ++ (if pkgs.stdenv.isDarwin then [
    pkgs.dockutil # Install dockutil only on macOS
  ] else []);

  # Programs Configuration
  programs.home-manager.enable = true;
  
  # Install global NPM packages from file
  home.activation.installNpmGlobals = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -f "${dotfilesDir}/npm/npm-globals.txt" ]; then
      echo "Installing global NPM packages..."
      # Configure npm prefix if not set to avoid permission issues
      if [[ "$(npm config get prefix)" == "/nix/store"* ]]; then
        npm config set prefix "$HOME/.npm-global"
        export PATH="$HOME/.npm-global/bin:$PATH"
      fi
      
      while IFS= read -r package || [[ -n "$package" ]]; do
        if [[ -n "$package" && ! "$package" =~ ^# ]]; then
          if ! npm list -g "$package" >/dev/null 2>&1; then
             echo "Installing $package..."
             npm install -g "$package"
          fi
        fi
      done < "${dotfilesDir}/npm/npm-globals.txt"
    fi
  '';

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
    
    # Gemini CLI Config
    ".gemini".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/gemini/.gemini";
    
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