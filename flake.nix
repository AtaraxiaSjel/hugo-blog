{
  description = "Devenv for hugo blog";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    paper-mod = {
      url = "github:adityatelange/hugo-PaperMod";
      flake = false;
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      paper-mod,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          name = "ataraxiadev.com";
          src = pkgs.lib.cleanSource self;

          nativeBuildInputs = [ pkgs.hugo ];

          buildPhase = ''
            mkdir -p themes/PaperMod
            cp -r ${paper-mod}/* themes/PaperMod/
            hugo
          '';
          installPhase = "cp -r public $out";
        };

        apps.default = flake-utils.lib.mkApp {
          drv = pkgs.hugo;
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            hugo
            static-web-server
          ];
        };
      }
    );
}
