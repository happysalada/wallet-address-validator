{
  description = "Just a shell for now";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, flake-utils, devshell, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ devshell.overlays.default ];
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };
        packages = with pkgs; [
          nodejs_latest
          nodePackages_latest.pnpm
          turbo
          surrealdb-migrations
          surrealdb
          sentry-cli
        ];
      in
      {
        devShell = pkgs.devshell.mkShell {
          inherit packages;
          env = [
            {
              name = "SURREAL_URL";
              value = "https://surrealdb.sassy.technology";
            }
            {
              name = "TUS_URL";
              value = "https://rustus.sassy.technology";
            }
          ];
          commands = [
            {
              name = "clean";
              category = "dev";
              help = "Clean the package manager directory and local direnv";
              command = ''
                direnv prune
                pnpm prune
                pnpm store prune
              '';
            }
            {
              name = "dev";
              category = "dev";
              help = "Start dev server locally";
              command = "pnpm run dev";
            }
            {
              name = "deps_update";
              category = "dev";
              help = "update dependencies";
              command = "pnpm up --interactive --latest";
            }
            {
              name = "build";
              category = "dev";
              help = "build the project for release";
              command = "pnpm run build";
            }
            {
              name = "preview";
              category = "dev";
              help = "preview the release build";
              command = "pnpm run preview";
            }
          ];
        };
      }
    );
}
