# Allow time for AppSignal to ship logs before the process exits
# https://docs.appsignal.com/ruby/integrations/rake.html#rake-tasks-and-containers
def wait_for_logs_to_flush
  Appsignal.stop "rails"
  sleep 5
end
