{ username, homeDirectory, ... }:

{
  home.username = username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "24.11";

  imports = [
    ./modules/common.nix
    ./modules/linux.nix
    ./modules/darwin.nix
    ./modules/wsl.nix
  ];
}
