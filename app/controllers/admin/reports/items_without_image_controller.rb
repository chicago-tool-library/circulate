# frozen_string_literal: true

module Admin
  module Reports
    class ItemsWithoutImageController < BaseController
      def index
        @items = Item.without_attached_image
      end
    end
  end
end
