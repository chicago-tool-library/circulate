require "test_helper"

module Certificate
  class GeneratorTest < ActiveSupport::TestCase
    test "can generate a certificate" do
      generator = Generator.new(code: "ABCD-1234")
      generator.generate
    end
  end
end