{ lib, pkgsCuda, ... }:

{
  perSystem = { pkgsCuda, ... }:

  let
    llamaScope = pkgsCuda.callPackage ./scope.nix { };

    cudaPkgs = llamaScope.llama-cpp.override {
      useCuda = true;
    };

    runtimeLibs = lib.makeLibraryPath [
      pkgsCuda.stdenv.cc.cc.lib
      pkgsCuda.libgcc
      pkgsCuda.zlib
    ];

    cudaWrapped = pkgsCuda.symlinkJoin {
      name = "llama-cpp-cuda-wrapped";
      paths = [ cudaPkgs ];

      nativeBuildInputs = [ pkgsCuda.makeWrapper ];

      postBuild = ''
        for bin in llama-cli llama-server llama-embedding llama-quantize; do
          if [ -f $out/bin/$bin ]; then
            wrapProgram $out/bin/$bin \
              --prefix LD_LIBRARY_PATH : ${runtimeLibs}:/lib64:/usr/lib64
          fi
        done
      '';
    };

  in
  {
    packages.cuda = cudaWrapped;
    apps =
      let
        mkApp = bin: {
          type = "app";
          program = "${cudaWrapped}/bin/${bin}";
        };
      in
      {
        llama-cli-cuda = mkApp "llama-cli";
        llama-server-cuda = mkApp "llama-server";
        llama-bench-cuda = mkApp "llama-bench";
        
      };
  };
}