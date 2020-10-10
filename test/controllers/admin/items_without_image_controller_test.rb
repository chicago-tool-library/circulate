require 'test_helper'

class Admin::ItemWithoutImageControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = create(:admin_user)
    sign_in @user
  end
  
  test "should get index" do
    get admin_items_without_image_index_url
    assert_response :success
  end
end
