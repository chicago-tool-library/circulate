# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/member_mailer
class HomepageMailerPreview < ActionMailer::Preview
  def inquiry
    homepage_params = {
      "name" => "Jim",
      "email" => "jim@email.com",
      "city" => "Chicago",
      "state" => "Illinois",
      "country" => "United States",
      "description" => "I manage or volunteer with an established lending library",
      "inventory" => "Lots of tools."
    }

    HomepageMailer.with(homepage_params:).inquiry
  end
end
