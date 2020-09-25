# Circulate

[![CircleCI](https://circleci.com/gh/rubyforgood/circulate.svg?style=svg)](https://circleci.com/gh/rubyforgood/circulate)

<!-- toc -->

- [About](#about)
  * [Project Considerations](#project-considerations)
- [Requirements](#requirements)
- [Integrations](#integrations)
- [Development](#development)
  * [Setting up Circulate on your machine](#setting-up-circulate-on-your-machine)
  * [Running tests](#running-tests)
  * [Setup pre-commit checks](#setup-pre-commit-checks)
  * [Documentation](#documentation)
- [Deployment](#deployment)
  * [Buildpacks](#buildpacks)
  * [Release Command](#release-command)
  * [Daily Summary Emails](#daily-summary-emails)
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

### Project Considerations
* The Chicago Tool Library serves a diverse group of people in Chicago, with varying levels of technological sophistication, abilities, and understandings of English. The app should strive to be accessible to as many people as possible, including easy-to-understand UX; accessibility to different levels of vision (blind, low vision, color-blind); and straightforward, simple English.
* Look-and feel for Chicago Tool Library overall is generally fun, warm, bright, accessible, approachable, humble. A neighborhood old-timey hardware store. The Chicago Tool Library version of the app doesn't need to have as specific of a look-and-feel, but it shouldn't clash with this aesthetic. See the [SquareSpace Chicago Tool Library site](https://chicagotoollibrary.org/) for more of a sense of this.
* circulate may be used by other tool libraries or other lending organizations in the future, so should be built with an eye towards multi-tenancy. (Multi-lingual support may also be a goal someday!)
* Many desired features may be able to be adapted from [babywearing](https://github.com/rubyforgood/babywearing), Ruby For Good's lending app for babywearing accessories.


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

See [DOCKER.md](DOCKER.md) for instructions on setting up your environment using Docker. For non-Docker installations, follow the instructions below.

### Setting up Circulate on your machine

If you're new to Ruby or Rails applications, a recommended way to get set up is to use the [community setup guides for Discourse](https://github.com/discourse/discourse#development). Discourse is a popular forum software project that also uses Ruby on Rails. There are scripts provided for [macOS](https://meta.discourse.org/t/beginners-guide-to-install-discourse-on-macos-for-development/15772), [Ubuntu](https://meta.discourse.org/t/beginners-guide-to-install-discourse-on-ubuntu-for-development/14727), and [Windows](https://meta.discourse.org/t/beginners-guide-to-install-discourse-on-windows-10-for-development/75149). On those pages you'll see more than the one script- for the purposes of this project, you **only** need to run the first, initial script command that you see. You do not need to keep going with the steps/information on Discourse. Stop when you get to "Clone Discourse"- don't do that! Come back here :sparkles:
**Note** You do want to pay attention to this install as it runs in your terminal- it may ask for your password once or twice throughout the process- keep an eye on it and be prepared to type your computer's password (in the terminal! NEVER share your password in a GitHub doc). Also note that the install takes some time to run completely- it is not a 5-minute process.


Time to get the Circulate repo! In your terminal, first make sure you're where you want to put the repo by typing `pwd`. If you want the Circulate repo to be in a different spot, type `cd` and **change** to the **directory** you want to put the Circulate repo in.

Next, put the full text below and press enter:

`git clone https://github.com/rubyforgood/circulate.git`

That will clone the Circulate repo to your machine, so you have a nice copy to work with locally! (Looking ahead, as you work you'll be pushing UP any changes you make from there to the Circulate repo on GitHub as a pull request.)

In your terminal, type `cd circulate` to change the directory you are in to your freshly-cloned, locally-hosted directory, Circulate.

In your terminal, type `ls` to take a look at what you'll be working with in this repo!

It should look like this:

```
CODE_OF_CONDUCT.md	bin			package.json
Gemfile			config			postcss.config.js
Gemfile.lock		config.ru		public
LICENSE.md		db			script
Procfile		exports			storage
README.md		gems			test
Rakefile		lefthook.yml		tmp
app			lib			vendor
babel.config.js		log			yarn.lock
```

Close your Terminal window and open a new one so your changes take effect.

Okay, at this point you've got a Ruby on Rails development environment set up and cloned the Circulate repo! Now you'll need to run the following commands one at a time in your terminal:

```console
$ yarn install
$ bundle install
$ bundle exec rails db:setup
```
All right, almost there! In the terminal, type and run:

`rails test`

Look for the word "Finished". That output should look similar to this:

```
Finished in 4.167485s, 41.0319 runs/s, 134.8535 assertions/s.
```

For working on this app, it is great to have several terminal windows open. Run `bin/rails server` in one terminal,  `bin/webpack-dev-server` in another, and have a third terminal open for commands. The command in the second terminal kicks off a new webpack build when files change, which speeds up page load during local development considerably if you're making changes to JavaScript or SCSS.

Open an internet browser, and type `chicago.local.chicagotoollibrary.org:3000`. You should see the Circulate app in your browser!

After you have the application running, here are some places to explore:

1. Sign in to [the admin interface](http://chicago.local.chicagotoollibrary.org:3000/admin/items) using `admin@chicagotoollibrary.org` as the username and `password` as the password. (Please note, this is very rare, and only for the purposes of building at this moment. Please do not share your password on GitHub files!)
2. Complete the [new member signup flow](http://chicago.local.chicagotoollibrary.org:3000/signup).

### Multi-tenancy

The default tenant for this application is the Chicago Tool Library, but the application permits multiple tenants, identified by the URL used to access the application. In the local development environment, the following tenants are available:

* chicago.local.chicagotoollibrary.org
* portland.local.chicagotoollibrary.org

Users are not currently shared between libraries; check `db/seeds.rb` for the full set of users as whom you can login to each of these libraries.

### Running tests

Use the standard Rails test commands: `rails test`, `rails test:system`, etc.

### Setup pre-commit checks

Circulate uses [Lefthook](https://github.com/Arkweid/lefthook) to run a few linters before creating commits, including [Standard](https://github.com/testdouble/standard). [Follow these instructions](https://github.com/Arkweid/lefthook/blob/master/docs/ruby.md) to configure your local git repository to run pre-commit checks.

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
