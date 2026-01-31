require "test_helper"

module Map
  class ChicagoTest < ActiveSupport::TestCase
    test "runs with no data" do
      assert_nothing_raised do
        Chicago.new({}).to_xml
      end
    end

    test "adds styles and titles to svg" do
      svg = <<~XML
        <svg xmlns="http://www.w3.org/2000/svg">
          <g id="combined">
            <path id="100" />
            <path id="101" />
            <path id="102" />
          </g>
        </svg>
      XML
      values = {
        "100" => 0,
        "101" => 22,
        "103" => 30
      }
      map = Chicago.new(values, svg: svg, fill: "red")
      assert_equal <<~XML, map.to_xml
        <?xml version="1.0"?>
        <svg xmlns="http://www.w3.org/2000/svg">
          <g id="combined">
            <path id="100" style="fill: red; fill-opacity: 0.0;"><title>100: 0</title></path>
            <path id="101" style="fill: red; fill-opacity: 0.7;"><title>101: 22</title></path>
            <path id="102"><title>102: 0</title></path>
          </g>
        </svg>
      XML
    end

    test "style attribute generation" do
      assert_equal "fill: blue; fill-opacity: 0.5;", Chicago.generate_style(5, 10, "blue")
      assert_equal "fill: blue; fill-opacity: 0.1;", Chicago.generate_style(5, 100, "blue")
    end
  end
end
