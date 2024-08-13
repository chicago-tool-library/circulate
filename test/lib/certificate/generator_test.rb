require "test_helper"

module Certificate
  class GeneratorTest < ActiveSupport::TestCase
    test "can generate a certificate" do
      generator = Generator.new(code: "ABCD-1234")
      assert_nothing_raised do
        generator.generate
      end
    end
  end
end
