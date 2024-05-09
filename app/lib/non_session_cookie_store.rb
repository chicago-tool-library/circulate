# This is a copy of CookieStore from ActionDispatch that does not store or
# check the session ID in order to make the csrf_token truly long lived. Two
# lines have been commented with CHANGE to highlight the differences from the
# original.
#
# For a copy of the original code in context, see:
# https://github.com/rails/rails/blob/v7.1.3/actionpack/lib/action_controller/metal/request_forgery_protection.rb#L312
#
# See the comment above protect_from_forgery in our ApplicationController for
# more background.
class NonSessionCookieStore
  def initialize(cookie = :csrf_token)
    @cookie_name = cookie
  end

  def fetch(request)
    contents = request.cookie_jar.encrypted[@cookie_name]
    return nil if contents.nil?

    value = JSON.parse(contents)
    # CHANGE: This is the check we're skipping:
    # return nil unless value.dig("session_id", "public_id") == request.session.id_was&.public_id

    value["token"]
  rescue JSON::ParserError
    nil
  end

  def store(request, csrf_token)
    request.cookie_jar.encrypted.permanent[@cookie_name] = {
      value: {
        token: csrf_token
        # CHANGE: And we're not storing session ID in the cookie.
        # session_id: request.session.id,
      }.to_json,
      httponly: true,
      same_site: :lax
    }
  end

  def reset(request)
    request.cookie_jar.delete(@cookie_name)
  end
end
