module Map
  class Chicago
    SVG_FILE = Rails.root.join("app/lib/map/chicago.svg").to_s

    def initialize(values = {}, svg: nil, fill: "#DF6C54")
      @values = values
      @svg = svg
      @fill = fill
    end

    def to_xml(options = {})
      load_svg
      add_fills_and_titles_to_zipcodes
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

    def add_fills_and_titles_to_zipcodes
      max = @values.values.max
      @values.each do |key, value|
        key_value = key.to_s.strip
        next unless key_value.match?(/^\d{5}$/)
        node = @doc.at_css("##{key_value}")
        next unless node
      end

      @doc.css("#combined path").each do |node|
        zipcode = node["id"]
        value = @values[zipcode]
        if value
          node["style"] = self.class.generate_style(value, max, @fill)
          node.add_child("<title>#{zipcode}: #{value}</title>")
        else
          node.add_child("<title>#{zipcode}: 0</title>")
        end
      end
    end

    def serialize
      @doc.to_xml
    end
  end
end
