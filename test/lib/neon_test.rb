require "test_helper"

require "json"

class NeonTest < ActiveSupport::TestCase
  test "converts from member to account representation" do
    member = create(:member)
    account = Neon.member_to_account(member)

    expected = {
      individualAccount: {
        customAccountFields: [
          {id: "82", value: member.id}
        ]
      }
    }

    assert_equal(expected, account)
  end

  test "converts from account to member" do
    account = JSON.parse(<<-JSON)
    {
      "individualAccount": {
        "accountId": "5269",
        "noSolicitation": false,
        "timestamps": {
          "createdBy": "Tessa Vierk",
          "createdDateTime": "2021-05-30T08:14:40Z",
          "lastModifiedBy": "API User",
          "lastModifiedDateTime": "2021-06-27T22:05:21Z"
        },
        "accountCustomFields": [
          {
            "id": "77",
            "name": "Member number",
            "value": "1"
          },
          {
            "id": "76",
            "name": "Pronouns",
            "value": "he/him"
          },
          {
            "id": "75",
            "name": "Volunteer Interest",
            "value": "Yes"
          },
          {
            "id": "82",
            "name": "Circulate ID",
            "value": "1"
          }
        ],
        "primaryContact": {
          "contactId": "5190",
          "firstName": "Jim",
          "lastName": "Benton",
          "suffix": "",
          "salutation": "",
          "preferredName": "Jim",
          "email1": "jim@chicagotoollibrary.org",
          "email2": "",
          "email3": "",
          "deceased": false,
          "addresses": [
            {
              "addressId": "1050",
              "addressLine1": "",
              "addressLine2": "",
              "city": "Chicago",
              "stateProvince": {
                "code": "IL",
                "name": "Illinois"
              },
              "isPrimaryAddress": true,
              "type": {
                "id": "999",
                "name": "Other"
              },
              "validAddress": false
            }
          ]
        },
        "sendSystemEmail": false,
        "origin": {
          "originDetail": "Memberships Thru 5/28/21(#15)"
        },
        "individualTypes": []
      }
    }
    JSON

    expected = {
      neon_id: "5269",
      email: "jim@chicagotoollibrary.org",
      pronouns: ["he/him"],
      city: "Chicago",
      region: "IL",
      full_name: "Jim Benton",
      preferred_name: "Jim"
    }

    assert_equal expected, Neon.account_to_member(account)
  end
end
