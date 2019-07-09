# ActiveStorageLogSuppressor

ActiveStorage is really noisy as each image that appears on a page can result in up to two requests being logged through the Rails stack.

This code hides log messages resulting from these requests by patching the base Rails frameworks classes. A few approaches are used to determine if the current context is within a request for an ActiveStorage file, depending on what information is available in each context.

## Usage
Add this plugin to your application's `Gemfile`. It will only activate in `development` mode, but regardless, please do not attempt to run this in production. It is intended purely as a development tool.

## Installation
Add the gem to the `:development` group in your `Gemfile`:

```ruby
group :development do
  gem 'active_storage_log_suppressor'
end
```

And then execute:
```bash
$ bundle
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
