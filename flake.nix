{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        defaultPackage = naersk-lib.buildPackage ./.;
        devShell = with pkgs; mkShell {
          buildInputs = [
            cargo
            rustc
            rustfmt
            pre-commit
            rustPackages.clippy
            cmake
            clang
            pkg-config
            wayland
            glfw
            xorg.libX11
            xorg.libXrandr
            xorg.libXinerama
            xorg.libXcursor
            xorg.libXi
            # libclang
            # clangStdenv
            # mesa
            # glfw
            # glibc
          ];
          # stdenvs = [
          #   "ccacheStdenv"
          #   "clangStdenv"
          #   "gccStdenv"
          #   "libcxxStdenv"
          #   "stdenv"
          # ];
          LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
            libGL
            xorg.libX11
            xorg.libXrandr
            xorg.libXinerama
            xorg.libXcursor
            xorg.libXi
          ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
          LIBCLANG_PATH = "${pkgs.llvmPackages_16.libclang.lib}/lib";
        };
      }
    );
}
