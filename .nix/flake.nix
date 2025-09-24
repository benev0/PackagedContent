{
  description = "Development environment for BustedToolbox projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, fenix, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:  let
        # overlays = [ (import fenix) ];
        pkgs = nixpkgs.legacyPackages.${system};
        fenixLib = fenix.packages.${system};
        rustToolchain = fenixLib.stable.toolchain;
        # pkgs = import nixpkgs { inherit system overlays; };
      in {
        devShells.default = with pkgs; mkShell rec {
          buildInputs = [
            # rust
            rustToolchain

            # temp raylib + flecs dependencies
            cmake
            clang
            pkg-config
            glfw
            xorg.libXinerama
            libGL

            # Vulkan dependencies
            shaderc
            spirv-tools
            vulkan-loader
            vulkan-tools
            vulkan-tools-lunarg
            vulkan-validation-layers

            # winit dependencies
            libxkbcommon
            wayland
            xorg.libX11
            xorg.libXcursor
            xorg.libXi
            xorg.libXrandr
          ];

          LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
          SHADERC_LIB_DIR = lib.makeLibraryPath [ shaderc ];
          VK_LAYER_PATH = "${vulkan-validation-layers}/share/vulkan/explicit_layer.d";

          RUST_SRC_PATH = rustPlatform.rustLibSrc;
          # LIBCLANG_PATH = "${pkgs.llvmPackages_16.libclang.lib}/lib";
          LIBCLANG_PATH = "${pkgs.llvmPackages_21.libcxxStdenv}/lib";
        };
      }
    );
}