class Result
  attr_reader :errors
  attr_reader :value

  def initialize(success, value, errors)
    @value = value
    @success = success
    @errors = errors
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  def self.success(value)
    new(true, value, nil)
  end

  def self.failure(errors = [])
    new(false, nil, errors)
  end
end
