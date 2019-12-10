class GiftMembershipCode
  CODE_CHARACTERS = %w{ 3 6 7 C D F G H J K M N P R T W X }
  CODE_SIZE = 8

  def initialize(value)
    @value = value
  end

  def value
    @value
  end

  def format
    @value.scan(/.{4}/).join("-")
  end

  alias_method :to_s, :format

  def self.random
    code = CODE_SIZE.times.map {
      CODE_CHARACTERS[SecureRandom.random_number(CODE_CHARACTERS.length)]
    }.join
    new(code)
  end
end