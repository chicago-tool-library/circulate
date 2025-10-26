require "test_helper"

class WishListItemTest < ActiveSupport::TestCase
  [
    :wish_list_item
  ].each do |factory_name|
    test "#{Array(factory_name).join(", ")} is a valid factory/trait" do
      wish_list_item = build(*factory_name)
      wish_list_item.valid?
      assert_equal({}, wish_list_item.errors.messages)
    end
  end

  test "validates unique combination of item and member" do
    original_wish_list_item = create(:wish_list_item)

    new_wish_list_item = build(:wish_list_item, item: original_wish_list_item.item, member: original_wish_list_item.member)

    new_wish_list_item.valid?

    assert_equal ["has already been taken"], new_wish_list_item.errors[:item]

    new_wish_list_item.member = create(:member)

    assert new_wish_list_item.save
  end
end
