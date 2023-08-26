{
  description = "anima's description";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/b458e5133fba2c873649f071f7a8dfeae52ebd17";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        overlays = [ ];
        pkgs =
          import nixpkgs { inherit system overlays; config.allowBroken = true; };
        # https://github.com/NixOS/nixpkgs/issues/140774#issuecomment-976899227
        m1MacHsBuildTools =
          pkgs.haskellPackages.override {
            overrides = self: super:
              let
                workaround140774 = hpkg: with pkgs.haskell.lib;
                  overrideCabal hpkg (drv: {
                    enableSeparateBinOutput = false;
                  });
              in
              {
                ghcid = workaround140774 super.ghcid;
                ormolu = workaround140774 super.ormolu;
              };
          };
        # Build ffmpeg with SVG support (which is missing in nixpkgs)
        ffmpeg = pkgs.ffmpeg.overrideAttrs (
          oa: {
            buildInputs = oa.buildInputs ++ [
              pkgs.gnome3.librsvg
            ];
            configureFlags = oa.configureFlags ++ [
              "--enable-librsvg"
            ];
          }
        );
        # Patch nativeBuildInputs for reanimate libraries.
        # Ref: https://github.com/reanimate/reanimate/blob/d22af8dc38d867122e7d01b328f6bc3ae88759fc/default.nix#L48-L57
        withReanimateDeps = drv:
          drv.overrideAttrs
            (
              oa: {
                nativeBuildInputs = oa.nativeBuildInputs ++ [
                  pkgs.zlib.dev
                  pkgs.zlib.out
                  pkgs.gmp
                  pkgs.gnome3.librsvg
                  ffmpeg
                ];
              }
            );

        project = returnShellEnv:
          pkgs.haskellPackages.developPackage {
            inherit returnShellEnv;
            name = "anima";
            root = ./.;
            withHoogle = false;
            overrides = self: super: with pkgs.haskell.lib; {
              # Use callCabal2nix to override Haskell dependencies here
              # cf. https://tek.brick.do/K3VXJd8mEKO7
              reanimate-svg = withReanimateDeps (dontCheck super.reanimate-svg);
              reanimate = withReanimateDeps (dontCheck super.reanimate);
            };
            modifier = drv:
              pkgs.haskell.lib.addBuildTools drv
                (with (if system == "aarch64-darwin" then m1MacHsBuildTools else pkgs.haskellPackages); [
                  # Specify your build/dev dependencies here. 
                  cabal-fmt
                  cabal-install
                  ghcid
                  haskell-language-server
                  ormolu
                  pkgs.nixpkgs-fmt
                  ffmpeg
                  pkgs.texlive.combined.scheme-full
                ]);
          };
      in
      {
        # Used by `nix build` & `nix run` (prod exe)
        defaultPackage = project false;

        # Used by `nix develop` (dev shell)
        devShell = project true;
      });
}

