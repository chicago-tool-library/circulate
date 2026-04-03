module Myturn
  BASE_URL = ENV.fetch("MYTURN_BASE_URL", "https://chicagotoollibrary.myturn.com")

  def self.configured?
    ENV["MYTURN_USERNAME"].present? && ENV["MYTURN_PASSWORD"].present?
  end

  class Client
    class AuthenticationError < StandardError; end

    def initialize(base_url: BASE_URL, username: ENV["MYTURN_USERNAME"], password: ENV["MYTURN_PASSWORD"])
      @base_url = base_url
      @username = username
      @password = password
      @cookies = {}
    end

    def reservations(from_date:, to_date:, status: "approved")
      response = authenticated_post(
        "/library/orgInventory/reservationReportData",
        form: {
          "status" => status,
          "from_date" => from_date.strftime("%-m/%-d/%Y"),
          "to_date" => to_date.strftime("%-m/%-d/%Y")
        }
      )

      JSON.parse(response.body.to_s).fetch("data", [])
    end

    private

    def authenticate!
      response = HTTP.post(
        "#{@base_url}/library/j_spring_security_check",
        form: {
          j_username: @username,
          j_password: @password,
          _spring_security_remember_me: "on"
        }
      )

      unless response.status.redirect?
        raise AuthenticationError, "MyTurn login failed (status #{response.status})"
      end

      @cookies = extract_cookies(response)

      if @cookies.empty?
        raise AuthenticationError, "MyTurn login returned no session cookies"
      end
    end

    def authenticated_post(path, **options)
      authenticate! if @cookies.empty?

      response = make_request(path, **options)

      if response.status.redirect? || response.status == 401
        authenticate!
        response = make_request(path, **options)
      end

      response
    end

    def make_request(path, **options)
      HTTP.cookies(@cookies)
        .headers(
          "Accept" => "application/json",
          "X-Requested-With" => "XMLHttpRequest"
        )
        .post("#{@base_url}#{path}", **options)
    end

    def extract_cookies(response)
      cookies = {}
      Array(response.headers.get("Set-Cookie")).each do |cookie_str|
        name, value = cookie_str.split(";").first.split("=", 2)
        cookies[name.strip] = value.strip
      end
      cookies
    end
  end
end
