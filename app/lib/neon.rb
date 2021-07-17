module Neon
  FIELD_MAP = {
    id: {name: "Circulate ID", id: "82"},
    full_name: "",
    preferred_name: "preferredName",
    email: "",
    phone_number: "",
    postal_code: "",
    address1: "",
    address2: "",
    city: "",
    region: "",
    pronouns: "",
    status: "",
    number: {name: "Member number", id: "77"},
    volunteer_interest: "",
    receive_newsletter: ""
  }

  def self.account_to_member(account)
    individual = account["individualAccount"]

    pronouns = individual["accountCustomFields"].find { |f| f["name"] == "Pronouns" }.dig("value")
    address = individual.dig("primaryContact", "addresses", 0)

    {
      neon_id: individual["accountId"],
      email: individual.dig("primaryContact", "email1"),
      region: address.dig("stateProvince", "code"),
      city: address["city"],
      pronouns: [pronouns]
    }
  end

  def self.member_to_account(member)
    {
      individualAccount: {

        customAccountFields: [
          {id: "82", value: member.id}
        ]
      }
    }
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

    def set_account_circulate_id(account_id, circulate_id)
      payload = {
        individualAccount: {
          accountcustomfields: [
            {
              id: "82",
              name: "Circulate ID",
              value: circulate_id
            }
          ]
        }
      }

      new_request.patch(BASE_URL + "/accounts/#{account_id}", json: payload)
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
          # sortColumn: "string",
          # sortDirection: "DESC"
        },
        searchFields: [
          {
            field: "email",
            operator: "EQUAL",
            value: email
          }
        ]
      }

      # response = http.basic_auth(user: @organization_id, pass: @api_key)
      #   .headers(:accept => "application/json")
      #   .get(BASE_URL + "/accounts/search/outputFields")

      # File.write("output_fields.json", response.body)

      response = new_request.post(BASE_URL + "/accounts/search", json: payload)

      data = response.parse

      id = data["searchResults"][0]["Account ID"]

      get_account(id)
      # set_account_circulate_id(id, 1)
    end
  end
end
