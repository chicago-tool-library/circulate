#
# This file defines dependencies for the Nix development environment.
#
# For details on the Nix development setup, see NIX.md.
#
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    nixpkgs-ruby.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-ruby, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # Install a Ruby version matching .ruby-version
        ruby = nixpkgs-ruby.lib.packageFromRubyVersionFile {
          file = ./.ruby-version;
          inherit system;
        };
      in
      {
        devShell = with pkgs;
          mkShell {
            buildInputs = [
              ruby
              nodejs
              yarn
              foreman

              # needed to build pg gem, even though we'll run the db from Docker
              postgresql

              # lib/certificate/generator.rb shells out to convert
              # ghostscript override fixes issue with with convert being unable
              # to find a font, workaround copied from
              # https://github.com/NixOS/nixpkgs/pull/246444
              (imagemagick.override { ghostscriptSupport = true; })

              # for selenium tests
              chromium
              chromedriver

              # for linters and git hooks
              lefthook

              # for deployment
              heroku

              # needed to build psych gem, which is in the dependency tree as of rails 7.1
              libyaml
            ];

            # Keep gems installed in a subdirectory
            BUNDLE_PATH = "./vendor/bundle";

            # Point to Docker-hosted db server, using the same settings as
            # config/docker.env
            DATABASE_URL = "postgres://localhost:5435";
            PGUSER = "postgres";

            # We'll run chromium in headless mode
            HEADLESS = "true";
            PARALLEL_WORKERS = "3";
            SELENIUM_CHROME_BINARY = "${pkgs.chromium}/bin/chromium";
          };
      });
}
