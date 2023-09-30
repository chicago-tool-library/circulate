# frozen_string_literal: true

module Map
  class Chicago
    SVG_FILE = File.join(Rails.root, "app/lib/map/chicago.svg")

    def initialize(values = {}, svg: nil, fill: "#DF6C54")
      @values = values
      @svg = svg
      @fill = fill
    end

    def to_xml(options = {})
      load_svg
      add_fills_to_zipcodes
      serialize
    end

    def self.generate_style(value, max, fill)
      float = (value / max.to_f).round(1)
      "fill: #{fill}; fill-opacity: #{float};"
    end

    private
      def load_svg
        @doc = if @svg
          Nokogiri::XML(@svg)
        else
          File.open(SVG_FILE) { |f| Nokogiri::XML(f) }
        end
      end

      def add_fills_to_zipcodes
        max = @values.values.max
        @values.each do |key, value|
          node = @doc.at_css("##{key.to_s.strip}")
          node["style"] = self.class.generate_style(value, max, @fill) if node
        end
      end

      def serialize
        @doc.to_xml
      end
  end
end
