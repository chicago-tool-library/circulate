# frozen_string_literal: true

class Step
  attr_accessor :id
  attr_accessor :name
  attr_accessor :active
  attr_accessor :path

  def initialize(id, name:, active: false, path: nil)
    @id = id
    @name = name
    @active = active
    @path = path
  end
end
