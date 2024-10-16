module Certificate
  class Generator
    def initialize(code:)
      @code = code
    end

    def generate
      # see if magick command exists, if not, fall back to convert
      command = command_exists?("magick") ? "magick" : "convert"
      @tempfile = Tempfile.new
      `#{command} #{File.dirname(__FILE__)}/template.jpg -fill black -pointsize 58 -draw "text 1190,970 '#{@code}'" #{@tempfile.path}`
      @tempfile.path
    end

    def command_exists?(name)
      `which #{name}`
      $?.success?
    end
  end
end
