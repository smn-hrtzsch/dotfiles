{ pkgs, lib, isWSL, ... }:

{
  home.packages = lib.optionals isWSL [
    pkgs.wslu
  ];
}
