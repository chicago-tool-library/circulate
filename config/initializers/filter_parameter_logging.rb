# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :_key,
  :address1,
  :address2,
  :certificate,
  :crypt,
  :cvc,
  :cvv,
  :email,
  :name,
  :otp,
  :passw,
  :password,
  :phone_number,
  :postal_code,
  :pronouns,
  :salt,
  :secret,
  :ssn,
  :token
]
