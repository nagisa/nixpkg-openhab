# Downloads various dependencies for the openhab build.
{ lib, stdenv, maven, openhab-distro, fetchurl, linkFarm }:

let
    dependencies = (builtins.fromJSON (builtins.readFile ./mvn2nix-lock.json )).dependencies;
    dependenciesAsDrv = (lib.forEach (lib.attrValues dependencies) (dependency: {
        drv = fetchurl {
            url = dependency.url;
            sha256 = dependency.sha256;
        };
        layout = dependency.layout;
    }));
in linkFarm "openhab-repository" (lib.forEach dependenciesAsDrv (dependency: {
    name = dependency.layout;
    path = dependency.drv;
}))
