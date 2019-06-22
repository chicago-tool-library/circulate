module Signup
  class Step
    attr_accessor :name
    attr_accessor :tooltip
    attr_accessor :active

    def initialize(name:, tooltip:, active: false)
      @name = name
      @tooltip = tooltip
      @active = active
    end
  end
end
