# frozen_string_literal: true

class HomepageMailer < ApplicationMailer
  def inquiry
    @homepage_inquiry = params[:homepage_params]

    mail(to: "team@circulate.software", subject: "[Circulate Inquiry]")
  end
end
