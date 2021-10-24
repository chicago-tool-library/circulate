module Neon
  # Until we are storing per-library credentials somewhere other than environment variables,
  # we will prefix the variable names with the library ID to scope credentials to
  # each tenant.
  def self.credentials_for_library(library)
    api_key_var_name = "NEON_API_KEY_LIB_#{library.id}"
    org_var_name = "NEON_ORGANIZATION_ID_LIB_#{library.id}"

    api_key = ENV[api_key_var_name]
    organization_id = ENV[org_var_name]

    return nil unless api_key.present? && organization_id.present?

    [organization_id, api_key]
  end

  def self.member_to_account(member)
    {
      "individualAccount" => {
        "primaryContact" => {
          # Imperfect method of approximating first and last name
          # could remove entirely if focused on updates?
          "firstName" => member.full_name.split[0],
          "lastName" => member.full_name.split[1..].join(" "),
          "preferredName" => member.preferred_name,
          "email1" => member.email,
          "addresses" => [
            {"addressLine1" => member.address1,
             "addressLine2" => member.address2,
             "city" => member.city,
             "stateProvince" => {
               "code" => member.region,
               "name" => "Illinois"
             },
             "type" => {
               "id" => "1",
               "name" => "Home"
             }}
          ]
        },
        "accountCustomFields" => [
          {"id" => "77", "name" => "Member number", "value" => member.number.to_s},
          {"id" => "76", "name" => "Pronouns", "value" => member.display_pronouns},
          {"id" => "75", "name" => "Volunteer Interest", "value" => boolean_to_yes_no(member.volunteer_interest)}
        ]
      }
    }
  end

  def self.boolean_to_yes_no(value)
    value ? "Yes" : "No"
  end

  class Client
    BASE_URL = "https://api.neoncrm.com/v2"

    def initialize(organization_id, api_key)
      @organization_id = organization_id
      @api_key = api_key

      logger = Logger.new($stdout)
      @http = HTTP.use(logging: {logger: logger})
    end

    def get(path)
      @http.basic_auth(user: @organization_id, pass: @api_key).get(BASE_URL + path)
    end

    def new_request
      @http.basic_auth(user: @organization_id, pass: @api_key)
        .headers(accept: "application/json")
    end

    def get_account(id)
      response = new_request.get(BASE_URL + "/accounts/#{id}")

      response.parse
    end

    def search_account(email)
      payload = {
        outputFields: [
          "Email 1",
          "Account ID"
        ],
        pagination: {
          currentPage: 0,
          pageSize: 20
        },
        searchFields: [
          {
            field: "email",
            operator: "EQUAL",
            value: email
          }
        ]
      }

      response = new_request.post(BASE_URL + "/accounts/search", json: payload)

      data = response.parse

      id = data["searchResults"][0]["Account ID"]

      get_account(id)
    end

    def update_account(id, payload)
      response = new_request.patch("#{BASE_URL}/accounts/#{id}", json: payload)
      response.parse
    end
  end
end
