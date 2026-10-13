require "test_helper"

module Certificate
  class GeneratorTest < ActiveSupport::TestCase
    test "can generate a certificate" do
      generator = Generator.new(code: "ABCD-1234")
      path = generator.generate

      assert File.size(path) > 0, "expected a non-empty certificate image"
      assert_equal "\xFF\xD8\xFF".b, File.binread(path, 3), "expected a JPEG image"
    end

    test "raises when the image command fails" do
      generator = Generator.new(code: "ABCD-1234")

      generator.stub(:command_exists?, false) do
        with_env("PATH" => "") do
          assert_raises(Errno::ENOENT) { generator.generate }
        end
      end
    end

    private

    def with_env(vars)
      original = vars.keys.to_h { |key| [key, ENV[key]] }
      vars.each { |key, value| ENV[key] = value }
      yield
    ensure
      original.each { |key, value| ENV[key] = value }
    end
  end
end
