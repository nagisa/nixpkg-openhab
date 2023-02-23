{ buildPlatform, hostPlatform, jdk11, which, zip, buildPackages }:

if buildPlatform == hostPlatform
then jdk11
else (jdk11.override {
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
