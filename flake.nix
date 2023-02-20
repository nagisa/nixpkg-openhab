{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
        flake-utils.url = "github:numtide/flake-utils";
        openhab-distro = {
            url = "github:openhab/openhab-distro/3.4.2"; # OH-DISTRO-URL
            flake = false;
        };
    };

    outputs = { flake-utils, nixpkgs, openhab-distro, ... }: flake-utils.lib.eachDefaultSystem (system: {
        packages = rec {
            jdk-openhab = nixpkgs.legacyPackages.${system}.jdk11;
            maven-openhab = nixpkgs.legacyPackages.${system}.maven.override { jdk = jdk-openhab; };
            openhab-repository = nixpkgs.legacyPackages.${system}.callPackage ./openhab-repository.nix {
                inherit openhab-distro;
                maven = maven-openhab;
            };
            openhab = nixpkgs.legacyPackages.${system}.callPackage ./openhab.nix {
                inherit openhab-distro openhab-repository jdk-openhab;
                maven = maven-openhab;
            };
            default = openhab;
        };
    });
}
