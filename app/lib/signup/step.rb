module Signup
  class Step
    attr_accessor :id
    attr_accessor :name
    attr_accessor :active

    def initialize(id, name:, active: false)
      @id = id
      @name = name
      @active = active
    end
  end
end
