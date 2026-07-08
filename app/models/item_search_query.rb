class ItemSearchQuery
  FIELDS = %w[name number brand model size strength].freeze
  FIELD_PATTERN = /\A([A-Za-z]+):(.+)\z/
  MAX_INPUT_LENGTH = 200

  attr_reader :bare_terms, :field_constraints, :raw

  def initialize(input)
    @raw = input.to_s
    @bare_terms = []
    @field_constraints = {}
    parse(@raw.first(MAX_INPUT_LENGTH))
  end

  def blank?
    @bare_terms.empty? && @field_constraints.empty?
  end

  def present?
    !blank?
  end

  private

  def parse(input)
    tokens = tokenize(input)
    tokens.each do |token|
      if (match = token.match(FIELD_PATTERN)) && FIELDS.include?(match[1].downcase)
        @field_constraints[match[1].downcase] = strip_quotes(match[2])
      else
        @bare_terms << strip_quotes(token)
      end
    end
  end

  # Splits on whitespace, but treats a "double quoted" span as one piece so it
  # can attach to a field prefix (e.g. name:"power drill") or stand alone.
  def tokenize(input)
    input.scan(/(?:[^\s"]+|"[^"]*")+/)
  end

  def strip_quotes(value)
    if value.start_with?('"') && value.end_with?('"') && value.length >= 2
      value[1..-2]
    else
      value
    end
  end
end
