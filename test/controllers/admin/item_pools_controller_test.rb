require "test_helper"

module Admin
  class ItemPoolsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @item_pool = create(:item_pool, :with_image)
      sign_in create(:admin_user)
    end

    test "uploading a new image replaces the old one even when delete is checked" do
      old_blob = @item_pool.image.blob

      patch admin_item_pool_url(@item_pool), params: {item_pool: {image: fixture_file_upload("tool-image.jpg", "image/jpeg"), delete_image: "1"}}

      assert @item_pool.reload.image.attached?
      refute_equal old_blob, @item_pool.image.blob
    end

    test "checking delete without uploading removes the image" do
      patch admin_item_pool_url(@item_pool), params: {item_pool: {delete_image: "1"}}

      refute @item_pool.reload.image.attached?
    end
  end
end
