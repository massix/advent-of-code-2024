{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              gleam
              rebar3
              erlang_27
            ];
          };

          packages = {
            day1 = self.lib.buildGleamPackage {
              inherit pkgs;
              pname = "day1";
              version = "unstable-2024-12-26";
              gleamDepsHash = "sha256-beehhFnZ775wH28j1kaDymVxzuJ48BahU1kmb39y9NA=";
              src = ./day1;
            };
          };
        })
    //
    {
      lib.buildGleamPackage = import ./lib/buildGleamPackage.nix;
    };
}
