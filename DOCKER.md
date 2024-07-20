# Development setup using Docker

> [!WARNING]
> This is meant for advanced users already familiar with Docker. If you're
> looking for general development instructions, please see
> [README.md](README.md).

## Initial setup
The following commands should just be run for the initial setup only. Rebuilding
the docker images is only necessary when upgrading, if there are changes to the
Dockerfile, or if gems or npm packages have been added or updated.
1. Install [Docker Community Edition](https://docs.docker.com/install/) if it
   is not already installed, or you can try [Orbstack](https://orbstack.dev) or 
   [colima](https://github.com/abiosoft/colima) if you're using a Mac.
3. Clone the respository to your local machine and change into the application
   directory: `cd circulate`.
5. Run `docker-compose up -d database` to start the database service.
6. Run `docker-compose run --rm web rails db:reset` to create the dev and test
   databases, load the schema, and run the seeds file.
7. Run `docker-compose up -d` to start all the remaining services.
8. Run `docker-compose ps` to view status of the containers. All should have
   state "Up". Check the [logs](#viewing-logs) if there are any containers that
   did not start.
9. The web application will be available at [localhost:3000](http://localhost:3000).

## For ongoing development:
1. Run `docker-compose up -d` to start all services.
2. Run `docker-compose up -d --force-recreate` to start services with new
   containers.
3. Run `docker-compose up -d --force-recreate web`
   to start a container running the new image.
4. Run `docker-compose ps` to view status of containers.
5. Run `docker-compose stop` to stop all services.
6. Run `docker-compose rm <service>` to remove a stopped container.
7. Run `docker-compose rm -f <service>` to force remove a stopped container.
8. Run `docker-compose restart web` to restart the web server.
9. Run `docker-compose down -v` to stop and remove all containers, as well as
   volumes and networks. This command is helpful if you want to start with a
   clean slate.  However, it will completely remove the database and you will
   need to go through the database setup steps again above.

### Running commands
In order to run rake tasks, rails generators, bundle commands, etc., they need to be run inside the container:
```
$ docker-compose exec web rails db:migrate
```

If you do not have the web container running, you can run a command in a one-off container:

```
$ docker-compose run --rm web bundle install
```

However, when using a one-off container, make sure the image is up-to-date by
running `docker-compose build web` first.  If you have been making gem updates
to your container without rebuilding the image, then the one-off container will
be out of date.

### Viewing logs
To view the logs, run:
```
$ docker-compose logs -f <service>
```

For example:
```
$ docker-compose logs -f web
```

### Accessing services
#### Postgres database
```
$ docker-compose exec database psql -h database -Upostgres circulate_development
```

#### Rails console
```
$ docker-compose exec web rails c
```

## Testing Suite
Run the unit testing suite from within the container:

```
$ docker-compose exec web rails test
```

NOTE: System tests are not currently set up with docker.

Run one test with:
```
$ docker-compose exec web rails test <filepath>
```
