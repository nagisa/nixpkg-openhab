{ fetchurl }:

let
    version = builtins.readFile ./version;
    sha256 = builtins.readFile ./openhab-addons.sha256;
in fetchurl {
    url = "https://github.com/openhab/openhab-distro/releases/download/${version}/openhab-addons-${version}.kar";
    inherit sha256;
}
