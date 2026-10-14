module Certificate
  class Generator
    TEMPLATE_PATH = File.join(File.dirname(__FILE__), "template.jpg")

    def initialize(code:)
      @code = code
    end

    def generate
      # see if magick command exists, if not, fall back to convert
      command = command_exists?("magick") ? "magick" : "convert"
      @tempfile = Tempfile.new(["certificate", ".jpg"])
      system(
        command, TEMPLATE_PATH,
        "-fill", "black",
        "-pointsize", "58",
        "-draw", "text 1190,970 '#{@code}'",
        @tempfile.path,
        exception: true
      )
      @tempfile.path
    end

    def command_exists?(name)
      system("which", name, out: File::NULL, err: File::NULL)
    end
  end
end
