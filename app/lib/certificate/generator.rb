module Certificate
  class Generator
    def initialize(code:)
      @code = code
    end

    def generate
      @tempfile = Tempfile.new
      `convert #{File.dirname(__FILE__)}/template.jpg -fill black -pointsize 58 -draw "text 1190,970 '#{@code}'" #{@tempfile.path}`
      @tempfile.path
    end
  end
end
