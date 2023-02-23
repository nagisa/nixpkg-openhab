{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { flake-utils, nixpkgs, ... }:
    let
        overlay = final: prev: rec {
            jdk-openhab = final.callPackage ./jdk.nix {};
            openhab = final.callPackage ./openhab.nix { };
            openhab-addons = final.callPackage ./openhab-addons.nix {};
        };
        pkgs = system: import nixpkgs { inherit system; overlays = [ overlay ]; };
    in {
        inherit overlay;
    } //  flake-utils.lib.eachDefaultSystem (system: {
        packages = rec {
            jdk-openhab = (pkgs system).jdk-openhab;
            openhab = (pkgs system).openhab;
            openhab-addons = (pkgs system).openhab-addons;
        };
    });
}
