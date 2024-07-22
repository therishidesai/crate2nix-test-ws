{
  description = "A devShell example";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    crate2nix.url = "github:nix-community/crate2nix";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, crate2nix, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        cargoNix = crate2nix.tools.${system}.appliedCargoNix {
          name = "test-ws";
          src = ./.;
        };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          nativeBuildInputs = [
            rust-bin.nightly.latest.default
          ];
        };
        packages = {
          testA = cargoNix.workspaceMembers.testA.build;
          testB = cargoNix.workspaceMembers.testB.build;
          testC = cargoNix.workspaceMembers.testC.build;
        };
      }
    );
}
