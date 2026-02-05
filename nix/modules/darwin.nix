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
}
