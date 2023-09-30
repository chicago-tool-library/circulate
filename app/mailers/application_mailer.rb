# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "Chicago Tool Library <team@chicagotoollibrary.org>"
  layout "mailer"
end
