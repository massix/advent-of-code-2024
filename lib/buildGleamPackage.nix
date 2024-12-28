{ pname
, version
, src
, gleamDepsHash
, pkgs
, ...
}:
let
  inherit (pkgs) stdenv stdenvNoCC;
  gleamDependencies = stdenv.mkDerivation {
    inherit version;
    pname = "${pname}-deps";

    nativeBuildInputs = [ pkgs.gleam ];
    src = builtins.filterSource (path: _: builtins.elem (baseNameOf path) [ "manifest.toml" "gleam.toml" ]) src;

    buildPhase = ''
      mkdir -p $out
      HOME=$PWD gleam deps download
      grep -v '\[packages\]' build/packages/packages.toml | sort > packages.toml
      echo -e "[packages]\n$(cat packages.toml)" > build/packages/packages.toml
      rm packages.toml
    '';

    installPhase = ''
      mkdir -p $out/build
      cp --recursive build/packages $out/build/
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "${gleamDepsHash}";
  };
  common = stdenvNoCC.mkDerivation {
    inherit version;
    pname = "${pname}-common";

    dontBuild = true;
    dontConfigure = true;
    dontFix = true;

    src = ../common;

    installPhase = ''
      mkdir -p $out/common
      cp --recursive . $out/common
    '';
  };
in
stdenv.mkDerivation {
  inherit pname version src;
  nativeBuildInputs = with pkgs; [
    gleam
    rebar3
    which
    gleamDependencies
    common
  ];
  buildInputs = [ pkgs.erlang_27 ];

  configurePhase = ''
    runHook preConfigurePhase
    cp -r ${gleamDependencies}/build build
    chmod -R 0755 build
    runHook postConfigurePhase
  '';

  checkPhase = ''
    runHook preCheckHook
    gleam test -t erlang
    runHook postCheckHook
  '';

  buildPhase = ''
    runHook preBuildHook
    substituteInPlace gleam.toml \
      --replace-fail ../common ${common}/common
    substituteInPlace manifest.toml \
      --replace-fail ../common ${common}/common
    HOME=$PWD gleam export erlang-shipment
    runHook postBuildHook
  '';

  installPhase = ''
    runHook preInstallHook
    mkdir -p $out/opt/${pname}-${version}
    mkdir -p $out/bin
    cp -r build/erlang-shipment/* $out/opt/${pname}-${version}/
    substituteInPlace $out/opt/${pname}-${version}/entrypoint.sh \
      --replace-fail erl ${pkgs.erlang_27}/bin/erl
    echo "exec $out/opt/${pname}-${version}/entrypoint.sh run \"\$@\"" > $out/bin/${pname}
    chmod 0777 $out/bin/${pname}
    runHook postInstallHook
  '';
}
