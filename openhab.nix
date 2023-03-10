{
 bash,
 coreutils,
 fetchurl,
 gawk,
 jdk-openhab,
 lib,
 makeWrapper,
 procps,
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
    extraPath = lib.makeBinPath [ jdk-openhab gawk coreutils procps ];
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
            "$out/runtime/bin/"*.psm1 \
            "$out/runtime/bin/"*.lst

        for exe in $wrappedExecutables; do
            echo "Wrapping $exe…"
            wrapProgram $out/$exe --prefix PATH ':' $extraPath
        done

        runHook postInstall
    '';
}
