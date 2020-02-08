# Used when stubbing a methods that needs to return a sequence of different values to subsequent calls:
# Thing.stub :name, ReturnValues.new("sharon", "bob") do
#   Thing.name => "sharon"
#   Thing.name => "bob"
#   Thing.name => raises ReturnValues::NoMoreValues error
# end
class ReturnValues
  class NoMoreValues < StandardError; end

  def initialize(*values)
    @next_index = 0
    @values = values
  end

  def call(*args)
    if @next_index >= @values.size
      raise NoMoreValues, "attempted to access value at index #{@next_index}, but only have #{@values.size}"
    end

    value = @values[@next_index]
    @next_index += 1
    value
  end
end
