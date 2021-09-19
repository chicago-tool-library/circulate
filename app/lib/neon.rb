module Neon
  # Map from the fields returned by the Neon API to attributes on the Member model
  # keys are the names of the Member attribute, values are one of:
  #
  # - a period-delimited string, which is used to lookup values using Hash#dig.
  #   This is a shortcut for passing a Hash with the string as :key
  # - a Proc, which is used to define a custom function for determining a value
  # - a Hash with either :key or :name:
  #   - :key will lookup the value at that key using Hash#dig
  #   - :name will search for the field by name in the custom fields section of the payload.
  #
  # Callables passed as :finalize will be called to finalize the value if provided.
  FIELD_MAP = {
    id: {
      name: "Circulate ID"
    },
    neon_id: "individualAccount.accountId",
    full_name: ->(account) {
      contact = account.dig("individualAccount", "primaryContact")
      [contact["firstName"], contact["lastName"]].compact.join(" ")
    },
    preferred_name: "individualAccount.primaryContact.preferredName",
    email: "individualAccount.primaryContact.email1",
    phone_number: {
      key: "individualAccount.primaryContact.addresses.0.phone1",
      finalize: ->(value) { value.tr(" ", "-") }
    },
    postal_code: "individualAccount.primaryContact.addresses.0.zipCode",
    address1: "individualAccount.primaryContact.addresses.0.addressLine1",
    address2: "individualAccount.primaryContact.addresses.0.addressLine2",
    city: "individualAccount.primaryContact.addresses.0.city",
    region: "individualAccount.primaryContact.addresses.0.stateProvince.code",
    pronouns: {
      name: "Pronouns",
      finalize: ->(value) { [value] }
    },
    number: {
      name: "Member number"
    },
    volunteer_interest: {
      name: "Volunteer Interest",
      finalize: ->(value) { value == "Yes" }
    }
  }

  def self.member_to_synced_attributes(member)
    member.attributes.slice(
      "id", "neon_id", "email", "pronouns", "address1", "address2", "city", "region",
      "postal_code", "preferred_name", "volunteer_interest", "phone_number"
    )

    #  "full_name", "pronouns"
  end

  def self.account_to_synced_attributes(account)
    customFields = account.dig("individualAccount", "accountCustomFields")

    lookup = ->(account, key) {
      account.dig(*key.split(".").map { |v| /^\d$/.match?(v) ? v.to_i : v })
    }

    FIELD_MAP.each_with_object({}) { |(key, definition), sum|
      if definition.is_a?(Hash)
        value = if lookup_key = definition[:key]
          lookup.call(account, lookup_key)
        else
          customFields.find { |f| f["name"] == definition[:name] }.dig("value")
        end
        value = definition[:finalize].call(value) if definition.key?(:finalize)
        sum[key.to_s] = value
      elsif definition.is_a?(Proc)
        sum[key.to_s] = definition.call(account)
      else
        sum[key.to_s] = lookup.call(account, definition)
      end
    }
  end

  def self.member_to_account(member)
    {
      "individualAccount" => {
        "accountId" => "",
        "individualTypes" => "",
        "primaryContact" => {
          "contactId" => "",
          "firstName" => "Courtney",
          "lastName" => "Tan",
          "suffix" => "",
          "preferredName" => member.preferred_name,
          "email1" => member.email,
          "deceased" => false,
          "addresses" => [
            {"addressId" => "1046",
             "addressLine1" => member.address1,
             "addressLine2" => member.address2,
             "city" => member.city,
             "stateProvince" => {
               "code" => member.region,
               "name" => "Illinois"
             },
             "isPrimaryAddress" => true,
             "type" => {
               "id" => "999",
               "name" => "Other"
             },
             "validAddress" => false}
          ]
        },
        "accountCustomFields" => [
          {"id" => "77", "name" => "Member number", "value" => member.number.to_s},
          {"id" => "76", "name" => "Pronouns", "value" => "she/her"},
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
