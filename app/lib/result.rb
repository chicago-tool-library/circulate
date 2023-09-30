# frozen_string_literal: true

class Result
  attr_reader :error
  attr_reader :value

  def initialize(success, value, error)
    @value = value
    @success = success
    @error = error
  end

  def success?
    @error.nil?
  end

  def failure?
    !success?
  end

  def self.success(value)
    new(true, value, nil)
  end

  def self.failure(error)
    raise "error can not be nil" if error.nil?
    new(false, nil, error)
  end
end
