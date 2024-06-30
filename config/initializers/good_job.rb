Rails.application.configure do
  # Send errors to Appsignal
  config.good_job.on_thread_error = ->(exception) { Appsignal.send_error(exception) }

  # Soon we will transition from Heroku Scheduler to scheduled jobs here
  config.good_job.enable_cron = ENV["DYNO"] == "worker.1"
  config.good_job.cron = {}
end
