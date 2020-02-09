class RenewalRequest
  KEY = ActiveSupport::KeyGenerator.new(
    ENV.fetch("SECRET_KEY_BASE")
  ).generate_key(
    ENV.fetch("RENEWAL_REQUEST_ENCRYPTION_SALT", "test"),
    ActiveSupport::MessageEncryptor.key_len
  ).freeze

  private_constant :KEY

  attr_accessor :member_id
  attr_accessor :expires_at

  def self.decrypt(encrypted)
    decrypted = new_encryptor.decrypt_and_verify(encrypted)
    new(**decrypted)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    nil
  end

  def initialize(member_id:, expires_at: 7.days.since)
    @member_id = member_id
    @expires_at = expires_at
  end

  def encrypt
    @encrypted ||= generate_encrypted
  end

  private

  def values_to_encrypt
    {
      member_id: @member_id,
      expires_at: @expires_at,
    }
  end

  def generate_encrypted
    self.class.new_encryptor.encrypt_and_sign(values_to_encrypt)
  end

  private_class_method def self.new_encryptor
    ActiveSupport::MessageEncryptor.new(KEY)
  end
end
