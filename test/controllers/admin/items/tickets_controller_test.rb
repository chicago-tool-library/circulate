# frozen_string_literal: true

require "test_helper"

module Admin
  module Items
    class TicketsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @item = create(:item)
        @user = create(:admin_user)
        create(:verified_member, user: @user)

        sign_in @user
      end

      test "should get index" do
        @ticket = create(:ticket, item: @item)

        get admin_item_tickets_url(@item)

        assert_response :success
      end

      test "should get new" do
        get new_admin_item_ticket_url(@item)

        assert_response :success
      end

      test "should create ticket" do
        assert_difference("Ticket.count") do
          post admin_item_tickets_url(@item), params: { ticket: { status: "assess", title: "A ticket title", body: "A ticket body" } }
        end

        assert_redirected_to admin_item_ticket_url(@item, Ticket.last)
      end

      test "should show ticket" do
        @ticket = create(:ticket, item: @item)
        create(:verified_member, user: @ticket.creator)

        get admin_item_ticket_url(@item, @ticket)

        assert_response :success
      end

      test "should get edit" do
        @ticket = create(:ticket, item: @item)

        get edit_admin_item_ticket_url(@item, @ticket)

        assert_response :success
      end

      test "should update ticket" do
        @ticket = create(:ticket, item: @item)

        patch admin_item_ticket_url(@item, @ticket), params: { ticket: { status: "parts", time_spent: "15", body: "Waiting on parts" } }

        assert_redirected_to admin_item_ticket_url(@item, @ticket)
      end

      test "should destroy ticket" do
        @ticket = create(:ticket, item: @item)

        assert_difference("Ticket.count", -1) do
          delete admin_item_ticket_url(@item, @ticket)
        end

        assert_redirected_to admin_item_tickets_url
      end
    end
  end
end
