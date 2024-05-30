# Circulate

![CI status](https://github.com/rubyforgood/circulate/actions/workflows/ci.yml/badge.svg)

<!-- toc -->

- [About](#about)
  - [Project Considerations](#project-considerations)
- [Requirements](#requirements)
- [Integrations](#integrations)
- [Development](#development)
  - [Setting up Circulate on your machine](#setting-up-circulate-on-your-machine)
  - [Multi-tenancy](#multi-tenancy)
  - [Configuring your database](#configuring-your-database)
  - [Resetting the application](#resetting-the-application)
  - [Running tests](#running-tests)
    - [Remote tests and test tagging](#remote-tests-and-test-tagging)
  - [Code formatting and linting](#code-formatting-and-linting)
  - [Setup pre-commit checks](#setup-pre-commit-checks)
  - [Documentation](#documentation)
  - [Who to log in as](#who-to-log-in-as)
  - [Alternative Development Setups](#alternative-development-setups)
- [Deployment](#deployment)
  - [Configuring git remotes for Heroku](#configuring-git-remotes-for-heroku)
  - [Promoting a build](#promoting-a-build)
  - [Buildpacks](#buildpacks)
  - [Release Command](#release-command)
  - [Daily Summary Emails](#daily-summary-emails)
  - [Google Calendar](#google-calendar)
    - [Local development](#local-development)
    - [Production](#production)
- [Alternatives](#alternatives)

<!-- tocstop -->

> [!NOTE]
> Welcome, contributors! Please see [our guide for how to contribute to the project](./CONTRIBUTING.md). 💖

## About

Circulate is an operating system for lending libraries. It currently provides the following functionality:

* Member signup, including optional payment via Square
* Inventory management, including item photos and configurable borrowing rules
* Item loaning to members, including fine calculation
* Item holds and waitlists
* Renewal requests and approvals
* Member account view and profile management
* Appointment scheduling for item pick-up and drop-off
* Volunteer shift scheduling
* Gift membership generation and redemption
* Various internal reporting and metrics
* Limited support for multi-tenancy (see Project Board for current status)

There is content and information hard-coded in many of the views that is specific to The Chicago Tool Library, for which the software is being initially developed. Over time, the plan is for these specifics to make their way into configuration or user-editable content so that the software is easily used by other lending libraries.

### Project Considerations
* The Chicago Tool Library serves a diverse group of people in Chicago, with varying levels of technological sophistication, abilities, and understandings of English. The app should strive to be accessible to as many people as possible, including easy-to-understand UX; accessibility to different levels of vision (blind, low vision, color-blind); and straightforward, simple English.
* Look-and-feel for Chicago Tool Library overall is generally fun, warm, bright, accessible, approachable, humble. A neighborhood old-timey hardware store. The Chicago Tool Library version of the app doesn't need to have as specific of a look-and-feel, but it shouldn't clash with this aesthetic. See the [SquareSpace Chicago Tool Library site](https://chicagotoollibrary.org/) for more of a sense of this.
* circulate may be used by other tool libraries or other lending organizations in the future, so should be built with an eye towards multi-tenancy. (Multi-lingual support may also be a goal someday!)


## Requirements

Circulate is a fairly standard Rails application. The main application requires a recent version of Ruby, a PostgreSQL database, and a modern version of Node and Yarn to build assets.

* A version of chromium (Google Chrome is fine) and a compatible `chromedriver` are required to run application tests. This will be downloaded automatically for you when running system tests.
* Imagemagick needs to be installed for gift memberships and item thumbnails to be generated.

## Integrations

The following third party services are used:

* Sendgrid for sending email
* Amazon S3 for image storage
* Square for payment processing
* Gmail and Google Calendar for volunteer and appointment shift scheduling
* Sentry for error collection
* AppSignal for monitoring and error collection
* Imagekit for image resizing and manipulation

## Development

Once you've completed the setup below, you can login to the app using `admin@example.com` and `password` to see the admin interface.

### Setting up Circulate on your machine

If you're new to Ruby or Rails applications, a recommended way to get set up is to use the [GoRails setup guide](https://gorails.com/setup). On that page you can select your operating system and the versions of Ruby and Rails you want to setup. It's worth going through the entire tutorial if you haven't worked on a Ruby on Rails application on your computer already as it is easier to sort through possible issues before getting into a large project like Circulate. It will take about 30 minutes to complete this tutorial.

Time to get the Circulate repo! In your terminal, first make sure you're where you want to put the repo by typing `pwd`. If you want the Circulate repo to be in a different spot, type `cd` and **change** to the **directory** you want to put the Circulate repo in.

Next, put the full text below and press enter:

`git clone https://github.com/rubyforgood/circulate.git`

That will clone the Circulate repo to your machine, so you have a nice copy to work with locally! (Looking ahead, as you work you'll be pushing UP any changes you make from there to the Circulate repo on GitHub as a pull request.)

In your terminal, type `cd circulate` to change the directory you are in to your freshly-cloned, locally-hosted directory, Circulate.

Okay, at this point you've got a Ruby on Rails development environment set up and cloned the Circulate repo! Now you'll need to run the following commands one at a time in your terminal:

```console
$ bin/setup
```

This command will run install Ruby and JavaScript dependencies, create a local database, fill that database with a development dataset. If you see errors when it runs, you can look at [what steps the script runs](https://github.com/rubyforgood/circulate/blob/main/bin/setup) and work through them one at a time to figure out what is going wrong.

All right, almost there! In the terminal, type and run:

```console
$ bin/rails test
```

Look for the word "Finished". That output should look similar to this:

```
Finished in 4.167485s, 41.0319 runs/s, 134.8535 assertions/s.
```

For working on this app, it is great to have two terminal windows open. Run `bin/dev ` in one terminal, which will start up the application, bundle CSS and compile JS all at the same time. Use a second terminal open for `git` and other commands you might need to type while working.

Open an internet browser, type [`localhost:3000`](http://localhost:3000), and hit enter. You should see the Circulate app in your browser!

After you have the application running, here are some places to explore:

1. Sign in to [the admin interface](http://localhost:3000/admin/items) using `admin@example.com` as the username and `password` as the password.
2. Complete the [new member signup flow](http://localhost:3000/signup).

### Multi-tenancy

The default tenant for this application is the Chicago Tool Library, but the application permits multiple tenants, identified by the URL used to access the application. In the local development environment, the following tenants are available:

```
chicago.circulate.local
denver.circulate.local
```

Users are not currently shared between libraries; check `db/seeds.rb` for the full set of users as whom you can login to each of these libraries.

In order to access libraries other than the first one on your local machine, you need to edit your hosts file.
This file is located at `/etc/hosts` on macOS and Linux, and `C:\Windows\System32\drivers\etc` on Windows or under WSL (Windows Subsystem for Linux).
Add the following lines to the file:

```
127.0.0.1 chicago.circulate.local
127.0.0.1 denver.circulate.local
```

You can now access these libraries at http://chicago.circulate.local:3000 and http://denver.circulate.local:3000.

You will need to add additional lines to your hosts file if you need to work with additional libraries locally.

### Configuring your database

By default the application will attempt to connect to a local PostgreSQL database accessible via a local domain socket. IF you need to
specify other credentials on your machine, add any required values to the file `.env.local`:

```
# Database credentials
PGUSER=your-postgres-username
PGPASSWORD=your-postgres-password
PGHOST=localhost
```

If `.env.local` doesn't exist in your project directory yet, you will need to create it.

### Resetting the application

During development, you can reset the database to the initial state by running `bin/setup`. This will delete any changes you have made to the database!

This can be useful if you need to run through a certain scenario multiple times manually, or when switching branches to get back into a known good state.

### Running tests

Use the standard Rails test commands:

```console
$ rails test # to run model, controller, and integration tests
$ rails test:system # to run system tests
```

Note, in order to get system tests to run, you will need `chromedriver` installed. See [Requirements section](#requirements) above.

#### Remote tests and test tagging

Tests tagged as `remote` are not run by default. They are defined by passing additional arguments to `test` when defining the test methods:

```ruby
test "do something with a remote server", :remote do
  # interact with a remote machine
end
```

This kind of test are useful to ensure that some code in the repository actually works with an external server properly, but since that test has a dependency on that server (and often on having access to credentials), we don't want to automatically run those tests all the time.

If you'd like to run all the tests (regardless of whether they are remote or not), you can do that:

```console
$ bin/rails test -t :remote
```

This works for running the tests in a file as well:

```console
$ bin/rails test path/to/file -t :remote
```

The `:` prefix clears the default setting that negates tests with the `remote` flag. You can also run only tests tagged with `remote` (or any other tag):

```console
$ bin/rails test path/to/file -t remote
```

It's also possible to filter out tests with other tags (should we add them) using the `~` prefix. The following would cause the test runner to ignore any tests tagged with `slow`:

```console
$ bin/rails test -t ~slow
```

### Code formatting and linting

We are using [Standard](https://github.com/testdouble/standard) and [ERB Lint](https://github.com/Shopify/erb-lint) to keep the project's code consistently formatted. The format of code is checked on PRs as a part of our GitHub Actions workflow.

To check the format of the project's code, use the following commands:

```
$ bundle exec standardrb --fix                   # Check all .rb files
$ bundle exec erblint --lint-all --autocorrect   # Check all .erb files
```

If you run into issues with these tools, please let us know and we'll be happy to help you out.

### Setup pre-commit checks

You may choose to leverage [Lefthook](https://github.com/Arkweid/lefthook) to run a few linters before creating commits, including [Standard](https://github.com/testdouble/standard). [Follow these instructions](https://github.com/Arkweid/lefthook/blob/master/docs/ruby.md) to configure your local git repository to run pre-commit checks.

Note that ERB files aren't checked as a part of precommit as it is just too slow.

### Documentation

Circulate leans heavily on a handful of open source frameworks and libraries, the documentation for which will be useful to developers:

* Ruby on Rails web framework [Guides](https://edgeguides.rubyonrails.org), [API](https://edgeapi.rubyonrails.org)
* FactoryBot test data generator [Getting Started guide](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md)
* Stimulus JS framework [Docs](https://stimulusjs.org/reference)
* Spectre CSS framework [Docs](https://picturepan2.github.io/spectre/getting-started.html)
* Feather iconset [Website](https://feathericons.com)
* MJML responsive email framework [Docs](https://mjml.io/documentation/)

### Who to log in as

During development, you will probably want to log into the app as various users (e.g. an admin or a member). [seeds.rb](https://github.com/rubyforgood/circulate/blob/main/db/seeds.rb) creates a set of user accounts when `bin/setup` are run. They are:
- Admin `admin@example.com`
- Verified member `verified_member@example.com`
- New member `new_member@example.com`
- Member for 18 months `member_for_18_months@example.com`
- Expired Member `expired_member@example.com`
- Membership expiring in one week `expires_soon@example.com`
- Member with loans `member_with_loans@example.com`
- Member with holds and loans `member_with_holds_and_loans@example.com`
- Member with an upcoming appointment `member_with_appointment@example.com`

These users are associated with the first seed library, Chicago Tool Library. A similar set of users can be used to log in to
the second seed library, Denver Tool Library, by appending `.denver` to the username portion of the email address (for example, `admin.denver@example.com`).

All of the seed user passwords are the word "password".

### Alternative Development Setups

We generally advise you to _avoid_ these alternative development setups unless you are already very comfortable with them. The above development instructions should be better for most users.

* **Docker:**: See [DOCKER.md](DOCKER.md) for instructions on setting up your environment using Docker.
* **Nix:** See [NIX.md](NIX.md) for details on installing dependencies with Nix.

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

### Configuring git remotes for Heroku

If you'll be working with the Heroku apps, it's good to setup git remotes for both staging and production:

```
$ heroku git:remote --remote production -a chicagotoollibrary
$ heroku git:remote --remote staging -a chicagotoollibrary-staging
```

### Promoting a build

To deploy the current staging build to production, use `heroku pipelines:promote -r staging`.

### Buildpacks

The following buildpacks are currently used in production:

```
1. heroku-community/apt
2. https://github.com/mojodna/heroku-buildpack-jemalloc.git
3. heroku/metrics
4. https://github.com/heroku/heroku-buildpack-activestorage-preview
5. heroku/ruby
```

### Release Command

The `Procfile` is configured to run database migrations during the release stage of deployment.

### Daily Summary Emails

`rails send_daily_loan_summaries` is set to run every evening using [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler). Set this to a time _after_ any open hours to ensure that all of the day's activity has taken place.

Here is the full list of scheduled tasks:

```
rails sync:calendars Every 10 minutes
rails email:send_return_reminders Daily at 1:00 PM UTC	
rails email:send_daily_loan_summaries Daily at 3:00 AM UTC	
rails email:send_staff_daily_renewal_requests Daily at 12:00 AM UTC  	
rails holds:start_waiting_holds Every 10 minutes 	
rails email:send_overdue_notices Daily at 3:00 AM UTC 	
rails email:send_membership_renewal_reminders Daily at 12:00 AM UTC
```

### Google Calendar

The application uses the Google Calendar API for several calendar-based features, most importantly, appointment scheduling. There are two ways to handle setting up the calendars and credentials needed for the system to work.

#### Local development

To setup calendars for local development:

1. Log into Google Calendar
2. Create two calendars, one for Appointment slots and one for volunteer shifts.
3. In `.env.local`, set the IDs of these calendars (which can be found on the Settings & Sharing screen) as the values of `APPOINTMENT_SLOT_CALENDAR_ID` and `VOLUNTEER_SLOT_CALENDAR_ID`.

To get credentials to work with these on your local machine:

1. Go to [APIs & Credendials](https://console.cloud.google.com/apis/credentials) and click "Create Credentials".
2. Select "OAuth client ID".
3. Choose "Web application" as the Application type.
4. Use whatever name you'd like, maybe something like "Circulate Development".
5. Under "Authorized redirect URIs", click "ADD URI" and enter `https://developers.google.com/oauthplayground`.
6. Click "Create".
7. Go to the [Google OAuth Playground](https://developers.google.com/oauthplayground).
8. Click on the gear icon to open the "OAuth 2.0 configuration" menu.
9. Select the "Use your own OAuth credentials" checkbox.
10. Enter the values for "OAuth Client ID" and "OAuth Client secret" from step 6.
11. Close the menu.
12. In the left pane, scroll down to "Google Calendar API v3". Under that heading, select "https://www.googleapis.com/auth/calendar" as the scope.
13. Click "Authorize APIs". You'll go through the OAuth flow, be sure to select a Google account that has access to the calendars (like the one that created them).
14. Then click "Exchange authorization code for tokens".
15. Copy the value for "Refresh token" and keep it somewhere safe.
16. In `.env.local`, set the value of `GOOGLE_REFRESH_TOKEN` to the value from step 15 and the value of `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` to the values from step 6.

If everything is setup properly, you should be able to run `bin/rails sync:calendars` without it displaying an error. The output of that command is written to the Rails log, so you can check `log/development.log` to see if it worked.

#### Production

In production, the application authenticates using a service account. This requires two environment variables be set:

* `GOOGLE_APPLICATION_CREDENTIALS_JSON`: The JSON content of the credentials JSON file downloaded from the GCP console.
* `GOOGLE_APPLICATION_CREDENTIALS`: The path on the Heroku ephemeral filesystem where the credentials can be written for the Google client libraries to find them.

At dyno start time, Heroku executes the `.profile` script, which writes the credential JSON into a file that is then read by the `googleauth` library.

The two calendars are both shared with the service account's email using the Google Calendar UI. Their IDs are stored in `APPOINTMENT_SLOT_CALENDAR_ID` and `VOLUNTEER_SLOT_CALENDAR_ID` in the Heroku config.

## Alternatives

It's a bit early for non-developers to adopt Circulate. There are some existing systems worth considering for anyone looking to get something setup right now:

* [MyTurn](https://myturn.com)
* [Lend Engine](https://www.lend-engine.com)
* [Tool Librarian](http://toollibrarian.com) for those in the Portland, OR area

Folks interested in helping to build Circulate should get in touch, though! We'd love to have more contributors to the project.
