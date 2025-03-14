require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  %w[404 406 422 500 503].each do |status|
    test "should get #{status}" do
      get "/#{status}"
      assert_response status.to_i
    end
  end
end
