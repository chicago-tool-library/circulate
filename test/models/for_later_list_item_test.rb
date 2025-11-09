require "test_helper"

class ForLaterListItemTest < ActiveSupport::TestCase
  [
    :for_later_list_item
  ].each do |factory_name|
    test "#{Array(factory_name).join(", ")} is a valid factory/trait" do
      for_later_list_item = build(*factory_name)
      for_later_list_item.valid?
      assert_equal({}, for_later_list_item.errors.messages)
    end
  end

  test "validates unique combination of item and member" do
    original_for_later_list_item = create(:for_later_list_item)

    new_for_later_list_item = build(:for_later_list_item, item: original_for_later_list_item.item, member: original_for_later_list_item.member)

    new_for_later_list_item.valid?

    assert_equal ["has already been taken"], new_for_later_list_item.errors[:item]

    new_for_later_list_item.member = create(:member)

    assert new_for_later_list_item.save
  end
end
