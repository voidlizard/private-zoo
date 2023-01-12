{
description = "private-scripts";

inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    haskell-flake-utils.url = "github:ivanovs-4/haskell-flake-utils";
    hspup.url = "github:voidlizard/hspup";
    hspup.inputs.nixpkgs.follows = "nixpkgs";
};

outputs = { self, nixpkgs, haskell-flake-utils, ... }@inputs:
  haskell-flake-utils.lib.simpleCabal2flake {
      inherit self nixpkgs;
      systems = [ "x86_64-linux" ];

      name = "np-yandex";

      shellWithHoogle = true;

      haskellFlakes = with inputs; [
      ];

      hpPreOverrides = { pkgs }: new: old:
        with pkgs.haskell.lib;
        with haskell-flake-utils.lib;
        tunePackages pkgs old {
        };

      packagePostOverrides = { pkgs }: with pkgs; with haskell.lib; [
        disableExecutableProfiling
        disableLibraryProfiling
        dontBenchmark
        dontCoverage
        dontDistribute
        dontHaddock
        dontHyperlinkSource
        doStrip
        enableDeadCodeElimination
        justStaticExecutables

        dontCheck
      ];

      shellExtBuildInputs = {pkgs}: with pkgs; [
        haskellPackages.haskell-language-server
        jq
        inputs.hspup.packages.${pkgs.system}.default
      ];

  };
}


