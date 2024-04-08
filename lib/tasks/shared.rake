# Close process allowing Appsignal to flush any exceptions that were rescued
# and manually sent along, per recommendations here:
# https://docs.appsignal.com/ruby/integrations/rake.html#rake-tasks-and-containers
def flush_logs_to_appsignal
  Appsignal.stop "rake"
  sleep 5
end
