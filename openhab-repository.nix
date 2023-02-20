# Downloads various dependencies for the openhab build.
{ lib, stdenv, maven, openhab-distro }:
stdenv.mkDerivation {
    pname = "openhab-repository";
    version = openhab-distro.shortRev;
    nativeBuildInputs = [ maven ];
    src = openhab-distro;

    buildPhase = ''
        mvn -B -T 128 -Drelease -Dmaven.repo.local="$out" package
    '';

    installPhase = ''
        # Delete all ephemeral files with lastModified timestamps inside
        find "$out" -type f '(' \
            -name '*.lastUpdated' -or \
            -name 'resolver-status.properties' -or \
            -name '_remote.repositories' ')' -delete
    '';

    dontFixup = true;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = builtins.readFile ./openhab-repository.sha256;
}
