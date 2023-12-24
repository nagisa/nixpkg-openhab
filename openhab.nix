{
 bash,
 coreutils,
 fetchurl,
 gawk,
 jdk-openhab,
 lib,
 makeWrapper,
 procps,
 zip,
 unzip,
 stdenv,
}:

let
    version = builtins.readFile ./version;
    sha256 = builtins.readFile ./openhab.sha256;
in stdenv.mkDerivation rec {
    inherit version;
    pname = "openhab";
    src = fetchurl {
        url = "https://github.com/openhab/openhab-distro/releases/download/${version}/openhab-${version}.tar.gz";
        inherit sha256;
    };
    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ bash ];
    outputs = [ "out" ];
    extraPath = lib.makeBinPath [ jdk-openhab gawk coreutils procps zip unzip ];
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

    unpackPhase = ''
        runHook preUnpack
        mkdir -p $out
        tar -C $out -xf $src
        runHook postUnpack
    '';

    installPhase = ''
        runHook preInstall
        rm -rfv \
            "$out/"*.bat \
            "$out/runtime/bin/"*.bat \
            "$out/runtime/bin/"*.ps1 \
            "$out/runtime/bin/"*.psm1

        for exe in $wrappedExecutables; do
        echo "Rewriting $exe…"
        cat - $out/$exe > "$out/$exe".new << EOF
        #!${bash}/bin/sh
        export PATH="\''$PATH:$extraPath"
        EOF
        mv "$out/$exe".new "$out/$exe"
        done

        runHook postInstall
    '';
}
