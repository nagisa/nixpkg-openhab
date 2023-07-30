{ buildPlatform, hostPlatform, jdk17, which, zip, buildPackages }:

if buildPlatform == hostPlatform
then jdk17
else (jdk17.override {
    # libIDL does not compile in cross-compile scenarios.
    enableGnome2 = false;
}).overrideAttrs (old: {
    # lol, nixpkgs can’t get pkgs right
    # AUTOCONF = "${autoconf}/bin/autoconf";
    nativeBuildInputs = old.nativeBuildInputs ++ [ which zip ];
    depsBuildBuild = with buildPackages; [ stdenv.cc autoconf ];
    configureFlags = old.configureFlags ++ [
        "--with-jtreg=no"
        "--disable-hotspot-gtest"
        "--with-build-jdk=${buildPackages.jdk11}"
    ];
})
