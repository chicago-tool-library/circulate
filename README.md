# Circulate

Circulate is an operating system for lending libraries. It is in the early stages of development. It currently provides the following functionality:

* Member signup, including optional payment via Square
* Item management
* Item loaning to members, including fine calculation

There is content and information hard-coded in many of the views that is specific to The Chicago Tool Library, for which the software is being initially developed. Over time, the plan is for these specifics to make their way into configuration or user-editable content so that the software is easily used by other lending libraries.

## Requirements

Circulate is a fairly basic Rails application. It requires a recent version of Ruby, a PostgreSQL database, and a modern version of Node and Yarn to build assets.

## Development

It is most convenient to run `rails server` in one terminal and `bundle exec bin/webpack-dev-server` in another. The second command kicks off a new webpack build when files change, which speeds up page load during local development.

### Running tests

Use the standard Rails test commands: `rails test`, `rails test:system`, etc.

## Deployment

Circulate is currently running on Heroku in production, but it should run just as well anywhere Rails applications can be run.

The following addons are expected to be enabled:

```
$ heroku addons
Add-on                                           Plan       Price     State  
───────────────────────────────────────────────  ─────────  ────────  ───────
bucketeer (bucketeer-defined-xxxxx)              hobbyist   $5/month  created
 └─ as BUCKETEER

heroku-postgresql (postgresql-horizontal-xxxxx)  hobby-dev  free      created
 └─ as DATABASE

sendgrid (sendgrid-tetrahedral-xxxxx)            starter    free      created
 └─ as SENDGRID
 ```

 Using a different way of configuring the file storage or email services would require trivial code changes.

 The `Procfile` is configured to run database migrations during the release stage of deployment.