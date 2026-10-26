{
  description = "EVE Desktop: German-first macOS voice and AI assistant";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin-legacy.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-darwin-legacy,
    }:
    let
      version = builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile ./VERSION);
      targetSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forEachSystem =
        f:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = f system;
          }) targetSystems
        );
      pkgsFor =
        system:
        if system == "x86_64-darwin" then
          nixpkgs-darwin-legacy.legacyPackages.${system}
        else
          nixpkgs.legacyPackages.${system};
      packageFor =
        system:
        let
          pkgs = pkgsFor system;
        in
        pkgs.writeShellApplication {
          name = "eve-desktop";
          runtimeInputs = [ pkgs.python313 pkgs.nodejs_24 ];
          text = ''
            set -euo pipefail
            src=${./.}
            case "''${1:-}" in
              ""|install|--install|build|--build)
                exec bash "$src/build.sh"
                ;;
              --check)
                python3 -c 'import pathlib, sys; compile(pathlib.Path(sys.argv[1]).read_text(), sys.argv[1], "exec")' "$src/atticus.py"
                bash -n "$src/build.sh"
                bash -n "$src/install.sh"
                printf '%s\n' 'EVE Desktop source checks passed'
                ;;
              --version)
                printf '%s\n' "atticus ${version}"
                ;;
              --help|-h|help)
                cat <<'EOF'
            EVE Desktop launcher for macOS.

            Usage:
              eve-desktop              Install or update EVE Desktop.app
              eve-desktop --install    Install or update EVE Desktop.app
              eve-desktop --check      Run packaged source checks
              eve-desktop --version    Print the packaged version
              eve-desktop --help       Show this help

            Building requires macOS 26 or later and Apple's command line tools.
            Full use also requires Claude Code (with Claude or a custom server), Devin, or Pi.
            EOF
                ;;
              *)
                printf 'Unknown option: %s\n\n' "$1" >&2
                exec "$0" --help
                ;;
            esac
          '';
          meta = with pkgs.lib; {
            description = "EVE Desktop macOS app launcher";
            homepage = "https://github.com/darkooom/eve-desktop";
            license = licenses.mit;
            mainProgram = "eve-desktop";
            platforms = targetSystems;
          };
        };
    in
    {
      packages = forEachSystem (
        system:
        let
          eve-desktop = packageFor system;
        in
        {
          inherit eve-desktop;
          source = eve-desktop;
          default = eve-desktop;
        }
      );

      apps = forEachSystem (
        system:
        let
          eve-desktop = self.packages.${system}.default;
          program = "${eve-desktop}/bin/eve-desktop";
          app = {
            type = "app";
            inherit program;
            inherit (eve-desktop) meta;
          };
        in
        {
          eve-desktop = app;
          default = app;
        }
      );

      checks = forEachSystem (system: {
        package = self.packages.${system}.default;
      });

      devShells = forEachSystem (system: {
        default =
          let
            pkgs = pkgsFor system;
          in
          pkgs.mkShell {
            packages = [
              pkgs.python313
              pkgs.act
            ];
            shellHook = ''
              echo "EVE Desktop development shell. Building the app requires Apple's command line tools."
            '';
          };
      });

      formatter = forEachSystem (system: (pkgsFor system).nixfmt);
    };
}
