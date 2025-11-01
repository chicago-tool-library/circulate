require "test_helper"

module Account
  class ForLaterListItemsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      @member = create(:member, user: @user)
      sign_in @user
    end

    def self.test_with_for_later_list_items_enabled(test_name, &)
      test(test_name) do
        FeatureFlags.stub(:for_later_lists_enabled?, true) do
          instance_eval(&)
        end
      end
    end

    test_with_for_later_list_items_enabled "member can save an item for later" do
      item = create(:item)

      post account_for_later_list_items_path, params: {for_later_list_item: {item_id: item.id}}

      assert_redirected_to item_path(item)
    end

    test_with_for_later_list_items_enabled "member can save an item for later via turbo stream" do
      item = create(:item)

      post account_for_later_list_items_path,
        params: {for_later_list_item: {item_id: item.id}},
        as: :turbo_stream

      assert_turbo_stream(action: "replace", target: "for_later_list_item_show") do |elements|
        assert_includes elements.to_s, "for_later_list_item_show"
        assert_includes elements.to_s, "Don't need it"
      end

      assert_turbo_stream(action: "replace", target: "#{dom_id(item)}_for_later_list_items_index") do |elements|
        assert_includes elements.to_s, "#{dom_id(item)}_for_later_list_items_index"
        assert_includes elements.to_s, "Don't need it"
      end
    end

    test_with_for_later_list_items_enabled "member can unsave an item for later" do
      create(:for_later_list_item, member: @member) # ignored
      for_later_list_item = create(:for_later_list_item, member: @member)

      assert_difference("ForLaterListItem.count", -1) do
        delete account_for_later_list_item_path(for_later_list_item)
      end

      assert_redirected_to account_for_later_list_items_path
    end

    test_with_for_later_list_items_enabled "member can unsave an item for later via turbo stream" do
      create(:for_later_list_item, member: @member) # ignored
      for_later_list_item = create(:for_later_list_item, member: @member)
      item = for_later_list_item.item

      delete account_for_later_list_item_path(for_later_list_item), as: :turbo_stream

      assert_turbo_stream(action: "remove", target: dom_id(for_later_list_item))

      assert_turbo_stream(action: "replace", target: "for_later_list_item_show") do |elements|
        assert_includes elements.to_s, "for_later_list_item_show"
        assert_includes elements.to_s, "Save for later"
      end

      assert_turbo_stream(action: "replace", target: "#{dom_id(item)}_for_later_list_items_index") do |elements|
        assert_includes elements.to_s, "#{dom_id(item)}_for_later_list_items_index"
        assert_includes elements.to_s, "Save for later"
      end
    end
  end
end
