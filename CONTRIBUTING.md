## Contributing

We ♥ contributors! By participating in this project, you agree to abide by our [code of conduct](./CODE_OF_CONDUCT).

If you're unsure about an issue or have any questions or concerns, just ask in an *existing issue* or *open a new issue*. If you would like to talk to other contributors and get more context about the project before jumping in, you can request to join [RubyForGood Slack](https://rubyforgood.herokuapp.com/). Once you are in Slack, come by `#circulate` channel, introduce yourself, and ask us questions!

If you don't have any questions, the issue is clear, and no one has commented saying they are working on the isssue, you can work on it! If you are so inclined, you can open a draft PR as you continue to work; we encourage this as it can make discussing in-progress work a lot easier. You won't be yelled at for giving your best effort. The worst that can happen is that you'll be politely asked to change something. We appreciate any sort of contribution and will do our best to guide all contributors toward productive solutions.

Here are the basic steps to submit a pull request:

1. Claim an issue on [our issue tracker](https://github.com/rubyforgood/circulate/issues) by commenting on the issue saying you are working on it. The issues that are listed on [the project board in the _Ready to be worked on_ column](https://github.com/rubyforgood/circulate/projects/4#column-10622874) are the highest priority based on input from our stakeholders.

If the issue you want to work on doesn't exist yet, feel free to open it. Please only claim one issue at a time unless you are waiting on us to review work.

1. Fork [the repo](https://github.com/rubyforgood/circulate) and clone your forked repo locally on your machine.

1. Follow [the project setup documentation](https://github.com/rubyforgood/circulate#developing) to get the project up and running on your machine.

1. Run the tests. We only take pull requests with passing tests, and it's great to know that you have a clean slate: `bundle exec rails test`

1. Add a test for your change. If you are adding functionality or fixing a bug, you should add a test!

1. Make the test pass by making changes to models, views, controllers, etc.

1. We try to keep the main user flows covered by [system tests](https://guides.rubyonrails.org/testing.html#system-testing).

1. Run linters and fix any linting errors they brings up.
   1. `bundle exec standardrb --fix` is required by CI

1. Push to your fork and submit a pull request. Include the issue number (ex. `Resolves #1`) in the PR description.

1. For any changes, please create a feature branch and open a PR for it when you feel it's ready to merge. Even if there's no real disagreement about a PR, at least one other person on the team needs to look over a PR before merging. The purpose of this review requirement is to ensure shared knowledge of the app and its changes and to take advantage of the benefits of working together changes without any single person being a bottleneck to making progress.

At this point you're waiting on us–we'll try to respond to your PR quickly. We may suggest some changes or improvements or alternatives.

Some things that will increase the chance that your pull request is accepted:

* Use Rails idioms and helpers
* Include tests that fail without your changes and pass with them.
* Update the documentation, surrounding code, or anything else affected by your contribution.
* Ensure that the following all pass locally:

  ```
  bundle exec rails test
  bundle exec rails test:system
  bundle exec standardrb
  ```

If you are wondering how to keep your fork in sync with the main [repo], follow this [github guide](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/syncing-a-fork).
