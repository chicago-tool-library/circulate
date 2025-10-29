require "test_helper"

module Admin
  module Items
    class TicketUpdatesControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @item = create(:item)
        @ticket = create(:ticket, item: @item)
        @user = create(:admin_user)
        create(:verified_member, user: @user)

        sign_in @user
      end

      # new edit create update destroy

      test "renders new form" do
        get new_admin_item_ticket_ticket_update_url(@item, @ticket)

        assert_response :success
      end

      test "create ticket update" do
        status = "parts"
        body = "A ticket body"
        time_spent = 2

        assert_difference("TicketUpdate.count") do
          post admin_item_ticket_ticket_updates_url(@item, @ticket), params: {ticket_update_form: {status:, body:, time_spent:}}
        end

        assert_redirected_to admin_item_ticket_url(@item, @ticket)

        ticket_update = @ticket.ticket_updates.last

        assert_equal status, @ticket.reload.status
        assert_equal body, ticket_update.body.to_plain_text
        assert_equal time_spent, ticket_update.time_spent
      end

      test "create ticket update and retiring an item" do
        status = "retired"
        retired_reason = "used_up"
        body = "A ticket body"
        time_spent = 2

        assert_difference("TicketUpdate.count") do
          post admin_item_ticket_ticket_updates_url(@item, @ticket), params: {ticket_update_form: {status:, retired_reason:, body:, time_spent:}}
        end

        assert_redirected_to admin_item_ticket_url(@item, @ticket)

        ticket_update = @ticket.ticket_updates.last

        assert_equal status, @ticket.reload.status
        assert_equal status, @item.reload.status
        assert_equal retired_reason, @item.retired_reason
        assert_equal body, ticket_update.body.to_plain_text
        assert_equal time_spent, ticket_update.time_spent
      end

      test "update ticket update" do
        ticket_update = create(:ticket_update, ticket: @ticket)

        body = "A ticket body"
        time_spent = 2

        patch admin_item_ticket_ticket_update_url(@item, @ticket, ticket_update), params: {ticket_update: {body:, time_spent:}}

        assert_redirected_to admin_item_ticket_url(@item, @ticket)

        ticket_update = @ticket.ticket_updates.last

        assert_equal body, ticket_update.body.to_plain_text
        assert_equal time_spent, ticket_update.time_spent
      end

      test "renders edit form" do
        ticket_update = create(:ticket_update, ticket: @ticket)
        get edit_admin_item_ticket_ticket_update_url(@item, @ticket, ticket_update)

        assert_response :success
      end

      test "destroys ticket update" do
        ticket_update = create(:ticket_update, ticket: @ticket)

        assert_difference("TicketUpdate.count", -1) do
          delete admin_item_ticket_ticket_update_url(@item, @ticket, ticket_update)
        end

        assert_redirected_to admin_item_ticket_url(@item, @ticket)
      end
    end
  end
end
