ActsAsTenant.configure do |config|
  # This is the default, but explicitly making it false because it's required
  # for images to work
  # See: https://github.com/ErwinM/acts_as_tenant/issues/330
  config.require_tenant = false
end
