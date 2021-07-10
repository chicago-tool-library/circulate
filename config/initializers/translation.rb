TranslationIO.configure do |config|
  config.api_key = ENV.fetch("TRANSLATION_IO_API_KEY", "not a real key")
  config.source_locale = "en"
  config.target_locales = ["es"]

  # Uncomment this if you don't want to use gettext
  # config.disable_gettext = true
end
