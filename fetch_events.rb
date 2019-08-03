require "logger"
require "http"
require "active_support/core_ext/file/atomic"
require "active_support/core_ext/time/calculations"
require "dotenv"

Dotenv.load

TOKEN_ENDPOINT = "https://www.googleapis.com/oauth2/v4/token"
EVENTS_ENDPOINT = "https://www.googleapis.com/calendar/v3/calendars/#{ENV.fetch("GCAL_CALENDAR_ID")}/events"

def min(n)
  60 * n
end

http = HTTP.use(logging: {logger: Logger.new(STDOUT)})

token_response = http.post(TOKEN_ENDPOINT, params: {
                                             client_id: ENV.fetch("GCAL_CLIENT_ID"),
                                             client_secret: ENV.fetch("GCAL_CLIENT_SECRET"),
                                             grant_type: "refresh_token",
                                             refresh_token: ENV.fetch("GCAL_REFRESH_TOKEN"),
                                           })
puts token_response.inspect

token = token_response.parse["access_token"]

thirty_min_ago = Time.now - min(30)
ten_min_since = Time.now + min(10)
eod = Time.now.end_of_day

events = http.auth("Bearer #{token}").get(EVENTS_ENDPOINT, params: {
                                                             orderBy: "startTime",
                                                             singleEvents: true,
                                                             timeZone: "America/Chicago",
                                                            #  timeMin: thirty_min_ago.to_datetime.rfc3339,
                                                            #  timeMax: eod.to_datetime.rfc3339,
                                                           })

if events.status == 200
  # File.atomic_write("data/calendar.json") do |file|
  #   file.write(events.body)
  # end
  puts events.body
else
  raise "error contacting the calendar server"
end