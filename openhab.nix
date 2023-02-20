{
 gawk,
 bash,
 coreutils,
 jdk-openhab,
 makeWrapper,
 lib,
 maven,
 openhab-distro,
 openhab-repository,
 stdenv,
}:

stdenv.mkDerivation rec {
    pname = "openhab";
    version = openhab-distro.shortRev;
    src = openhab-distro;
    nativeBuildInputs = [ makeWrapper maven ];
    buildInputs = [ bash ];
    outputs = [ "out" "demo" ];
    extraPath = lib.makeBinPath [ jdk-openhab gawk coreutils ];
    wrappedExecutables = [
        "start.sh"
        "start_debug.sh"
        "runtime/bin/karaf"
        "runtime/bin/backup"
        "runtime/bin/client"
        "runtime/bin/instance"
        "runtime/bin/karaf"
        "runtime/bin/restore"
        "runtime/bin/shell"
        "runtime/bin/start"
        "runtime/bin/status"
        "runtime/bin/stop"
        "runtime/bin/update"
    ];

    buildPhase = ''
        runHook preBuild

        echo "Using repository ${openhab-repository}"
        cp -r ${openhab-repository} ./repository
        chmod -R +rw ./repository
        mvn --offline -B -T $NIX_BUILD_CORES -Drelease -Dmaven.repo.local=./repository package

        runHook postBuild
    '';

    installPhase = ''
        runHook preInstall
        mkdir $out
        tar -C $out -xf distributions/openhab/target/openhab-3.4.2.tar.gz
        mv distributions/openhab-addons/target/openhab-addons-3.4.2.kar $out/addons/
        mkdir $demo
        tar -C $demo -xf distributions/openhab-demo/target/openhab-demo-3.4.2.tar.gz

        rm -rfv \
            "$out/"*.bat \
            "$out/runtime/bin/"*.bat \
            "$out/runtime/bin/"*.ps1 \
            "$out/runtime/bin/"*.psm1 \
            "$out/runtime/bin/"*.lst

        for exe in $wrappedExecutables; do
            echo "Wrapping $exe…"
            wrapProgram $out/$exe --prefix PATH ':' $extraPath
        done

        runHook postInstall
    '';
}
