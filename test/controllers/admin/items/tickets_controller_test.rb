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
        status = "assess"
        title = "A ticket title"
        body = "A ticket body"
        tag_list = ["a", "b", "c"]

        assert_difference("Ticket.count") do
          post admin_item_tickets_url(@item), params: {ticket: {status:, title:, body:, tag_list:}}
        end

        assert_redirected_to admin_item_ticket_url(@item, Ticket.last)

        ticket = Ticket.first!

        assert_equal status, ticket.status
        assert_equal title, ticket.title
        assert_equal body, ticket.body.to_plain_text
        assert_equal tag_list, ticket.tag_list
      end

      test "creating a ticket with any status besides 'retired' updates the ticket's status to 'maintenance'" do
        status = %w[assess repairing parts resolved].sample

        refute_equal "maintenance", @item.status

        assert_difference("Ticket.count") do
          post admin_item_tickets_url(@item), params: {ticket: {status:, title: "foo", body: ""}}
        end

        ticket = Ticket.first!
        assert_equal status, ticket.status
        assert_equal "maintenance", @item.reload.status
      end

      test "creating a retired ticket updates the item's status to retired too" do
        retired = Item.statuses["retired"]
        broken = Item.retired_reasons["broken"]

        refute_equal retired, @item.status

        assert_difference("Ticket.count") do
          post admin_item_tickets_url(@item), params: {ticket: {status: retired, title: "foo", body: ""}}
        end

        ticket = Ticket.first!
        assert_equal retired, ticket.status
        assert_equal retired, @item.reload.status
        assert_equal broken, @item.retired_reason
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
        @ticket = create(:ticket, item: @item, tag_list: %w[foo bar])
        status = "parts"
        body = "Waiting on parts"
        tag_list = ["a", "b", "c"]

        patch admin_item_ticket_url(@item, @ticket), params: {ticket: {status:, body:, tag_list:}}

        assert_redirected_to admin_item_ticket_url(@item, @ticket)

        @ticket.reload
        assert_equal status, @ticket.status
        assert_equal body, @ticket.body.to_plain_text
        assert_equal tag_list, @ticket.tag_list
      end

      test "creating a ticket with retired status" do
        @ticket = create(:ticket, item: @item)
        retired = Item.statuses["retired"]
        used_up = Item.retired_reasons["used_up"]

        refute_equal retired, @item.status
        refute_equal retired, @ticket.status

        patch admin_item_ticket_url(@item, @ticket), params: {ticket: {status: retired, body: "", retired_reason: used_up}}

        assert_equal retired, @ticket.reload.status
        assert_equal retired, @item.reload.status
        assert_equal used_up, @item.retired_reason
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
