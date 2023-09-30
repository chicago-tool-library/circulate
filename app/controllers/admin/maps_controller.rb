# frozen_string_literal: true

module Admin
  class MapsController < BaseController
    def show
      data = Member.open.group(:postal_code).count
      respond_to do |format|
        format.svg {
          render inline: Map::Chicago.new(data).to_xml
        }
      end
    end
  end
end
