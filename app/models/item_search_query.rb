class ItemSearchQuery
  FIELDS = %w[name number brand model size strength].freeze
  FIELD_PATTERN = /\A([A-Za-z]+):(.+)\z/

  attr_reader :bare_terms, :field_constraints, :raw

  def initialize(input)
    @raw = input.to_s
    @bare_terms = []
    @field_constraints = {}
    parse(@raw)
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

  def tokenize(input)
    tokens = []
    buffer = +""
    in_quotes = false
    i = 0
    while i < input.length
      char = input[i]
      if char == '"'
        buffer << char
        in_quotes = !in_quotes
      elsif char =~ /\s/ && !in_quotes
        tokens << buffer unless buffer.empty?
        buffer = +""
      else
        buffer << char
      end
      i += 1
    end
    tokens << buffer unless buffer.empty?
    tokens
  end

  def strip_quotes(value)
    if value.start_with?('"') && value.end_with?('"') && value.length >= 2
      value[1..-2]
    else
      value
    end
  end
end
