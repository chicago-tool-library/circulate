# Development Setup using Nix

> [!WARNING]
> This is meant for advanced users already familiar with Nix. If you're looking
> for general development instructions, please see [README.md](README.md).

## Prerequisites

- [Nix](https://nixos.org/download)
- [Docker w/ Compose](https://github.com/docker/compose#where-to-get-docker-compose) via Docker Desktop or equivalent - this setup runs Rails directly but uses a container for the database.
- [direnv](https://github.com/direnv/direnv) - technically optional but helpful to get the environment to automatically load when entering the project directory

## Initial Dependencies

If you have direnv, the `.envrc` file in the repository will get everything set
up for you automatically, you just need to run `direnv allow`. If you're not
using direnv, you can manually start a development shell with `nix develop`.

## Database

This setup uses the development database configured in `docker-compose.yml`,
which can be started like this:

```shell-session
$ docker compose up -d database
```

The database is working properly if this command produces a list of databases:

```shell-session
$ psql -l "$DATABASE_URL"
```

## Bootstrapping

Use the `setup` script to get started for the first time.

```shell-session
$ bin/setup
```

This script will:

- Fetch Ruby and NPM dependencies
- Bootstrap the development database
- Load some sample data into the development database

The setup script doesn't create the test database, so do that separately:

```shell-session
$ bin/rails db:create:all
```

## Asset Compilation

You can get the assets automatically compiling on file changes by leaving this
command running in a shell:

```shell-session
$ bin/dev -m all=1,web=0
```

Note this skips the Rails server, which we run separately below. This is
because something is preventing Rails from loading properly within the Foreman
environment. If somebody figures this out update this guide!

## Development Server

Run the Rails server in a separate shell:

```shell-session
$ bin/rails server
```

## Running Tests

All tests should be able to run normally:

```shell-session
# Unit tests
$ bin/rails test

# Selenium tests
$ bin/rails test:system
```

The Selenium tests are run by having Nix install Chromium and ChromeDriver and
set a `SELENIUM_CHROME_BINARY` environment variable to point Selenium at
Chromium in `test/application_system_test_case.rb`.
