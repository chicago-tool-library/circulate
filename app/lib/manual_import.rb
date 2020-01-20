require "uri"

class ManualImport
  include ActiveModel::Model

  attr_accessor :url
  attr_accessor :response
  attr_accessor :tempfile

  validates_each :url do |record, attr, value|
    if value&.match?(URI::DEFAULT_PARSER.make_regexp)
      result = open_file(value)
      if result.success?
        record.response = result.value

        record.tempfile = Tempfile.new(binmode: true)
        record.response.body.each do |chunk|
          record.tempfile.write chunk
        end
        record.tempfile.rewind
      else
        record.errors.add(attr, "could not be loaded")
      end
    else
      record.errors.add(attr, "must be a valid URL")
    end
  end

  def update_item!(item)
    filename = File.basename(URI.parse(url).path)

    item.manual.attach(
      filename: filename,
      io: tempfile,
      content_type: response.mime_type,
    )
    item.save!
    tempfile.close
  end

  def self.open_file(url)
    response = HTTP.follow(max_hops: 3).get(url) # auto-follow redirects
    if response.status == 200
      Result.success(response)
    else
      Result.failure("could not load file")
    end
  rescue HTTP::Error => e
    Rails.logger.error "Could not load file from URL #{url}"
    Rails.logger.error e
    Result.failure(e)
  end
end
