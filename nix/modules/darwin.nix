{ pkgs, config, lib, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
in
lib.mkIf pkgs.stdenv.isDarwin {
  home.packages = with pkgs; [
    dockutil
  ];

  home.sessionPath = [
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  ];

  home.file = {
    ".config/raycast".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/raycast";
    ".config/sketchybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/sketchybar";
  };
}
