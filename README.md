# Circulate

[![CircleCI](https://circleci.com/gh/chicago-tool-library/circulate/tree/development.svg?style=svg)](https://circleci.com/gh/chicago-tool-library/circulate/tree/development)

<!-- toc -->

- [Circulate](#circulate)
  - [About](#about)
  - [Requirements](#requirements)
  - [Integrations](#integrations)
  - [Development](#development)
    - [Directly on your machine](#directly-on-your-machine)
    - [Running tests](#running-tests)
    - [Documentation](#documentation)
  - [Deployment](#deployment)
    - [Buildpacks](#buildpacks)
    - [Release Command](#release-command)
    - [Daily Summary Emails](#daily-summary-emails)
  - [Alternatives](#alternatives)

<!-- tocstop -->

## About

Circulate is an operating system for lending libraries. It is in the early stages of development. It currently provides the following functionality:

* Member signup, including optional payment via Square
* Inventory management, including item photos and configurable borrowing rules
* Item loaning to members, including fine calculation
* Volunteer shift scheduling
* Gift membership generation and redemption

There is content and information hard-coded in many of the views that is specific to The Chicago Tool Library, for which the software is being initially developed. Over time, the plan is for these specifics to make their way into configuration or user-editable content so that the software is easily used by other lending libraries.

## Requirements

Circulate is a fairly basic Rails application. The main application requires a recent version of Ruby, a PostgreSQL database, and a modern version of Node and Yarn to build assets.

* A version of chromium (Google Chrome is fine) and a compatible `chromedriver` are required to run application tests.
* Imagemagick needs to be installed for gift memberships and item thumbnails to be generated.

## Integrations

The following third party services are used:

* Sendgrid for sending email
* Amazon S3 for image storage
* Square for payment processing
* Gmail and Google Calendar for volunteer scheduling
* Sentry for error collection
* Skylight for app performance monitoring

## Development

Once you've completed the setup below, you can login to the app using `admin@chicagotoollibrary.org` and `password` to see the admin interface.

### Directly on your machine

If you're new to Ruby or Rails applications, an easy way to get setup is to use the [community setup guides for Discourse](https://github.com/discourse/discourse#development). Discourse is a popular forum software project that also uses Ruby on Rails. There are scripts provided for [macOS](https://meta.discourse.org/t/beginners-guide-to-install-discourse-on-macos-for-development/15772), [Ubuntu](https://meta.discourse.org/t/beginners-guide-to-install-discourse-on-ubuntu-for-development/14727), and [Windows](https://meta.discourse.org/t/beginners-guide-to-install-discourse-on-windows-10-for-development/75149).

Once you've got a development environment setup, you'll need to run the following:

```console
$ yarn install
$ bundle install
$ bundle exec rails db:setup
```

It is most convenient to run `bin/rails server` in one terminal and `bin/webpack-dev-server` in another. The second command kicks off a new webpack build when files change, which speeds up page load during local development considerably if you're making changes to JavaScript or SCSS.

After you have the application running, here are some places to explore:

1. Sign in to [the admin interface](http://localhost:3000/admin/items) using `admin@chicagotoollibrary.org` as the username and `password` as the password.
2. Complete the [new member signup flow](http://localhost:3000/signup).

### Running tests

Use the standard Rails test commands: `rails test`, `rails test:system`, etc.

### Documentation

Circulate leans heavily on a handful of open source frameworks and libraries, the documentation for which will be useful to developers:

* Ruby on Rails web framework [Guides](https://edgeguides.rubyonrails.org), [API](https://edgeapi.rubyonrails.org)
* FactoryBot test data generator [Getting Started guide](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md)
* Stimulus JS framework [Docs](https://stimulusjs.org/reference)
* Spectre CSS framework [Docs](https://picturepan2.github.io/spectre/getting-started.html)
* Feather iconset [Website](https://feathericons.com)
* MJML responsive email framework [Docs](https://mjml.io/documentation/)

## Deployment

Circulate is currently running on Heroku in production, but it should run fairly well anywhere Rails applications can be run.

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

logdna (logdna-symmetrical-xxxxx)                zepto      $5/month  created
 └─ as LOGDNA

scheduler (scheduler-round-xxxxx)                standard   free      created
 └─ as SCHEDULER
 ```

Using a different way of configuring the file storage or email services should require trivial code changes.

### Buildpacks

The following buildpacks are currently used in production:

```
1. https://github.com/mojodna/heroku-buildpack-jemalloc.git
2. heroku/metrics
3. https://github.com/heroku/heroku-buildpack-activestorage-preview
4. heroku/ruby
```

### Release Command

The `Procfile` is configured to run database migrations during the release stage of deployment.

### Daily Summary Emails

`rails send_daily_loan_summaries` is set to run every evening using [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler). Set this to a time _after_ any open hours to ensure that all of the day's activity has taken place.


## Alternatives

It's a bit early for non-developers to adopt Circulate. There are some existing systems worth considering for anyone looking to get something setup right now:

* [MyTurn](https://myturn.com)
* [Lend Engine](https://www.lend-engine.com)
* [Tool Librarian](http://toollibrarian.com) for those in the Portland, OR area

Folks interested in helping to build Circulate should get in touch, though! I'd love to have collaborators on the project.
