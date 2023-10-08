# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :password, :email, :phone_number, :name, :pronouns,
  :address1, :address2, :postal_code
]
