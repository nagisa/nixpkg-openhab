{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { flake-utils, nixpkgs, ... }: flake-utils.lib.eachDefaultSystem (system: {
        packages = rec {
            jdk-openhab = nixpkgs.legacyPackages.${system}.jdk11;
            openhab = nixpkgs.legacyPackages.${system}.callPackage ./openhab.nix {
                inherit jdk-openhab;
            };
            openhab-addons = nixpkgs.legacyPackages.${system}.callPackage ./openhab-addons.nix {};
            default = openhab;
        };
    });
}
