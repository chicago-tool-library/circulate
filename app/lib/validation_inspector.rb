# Provides convenience methods for introspecting the validations defined on a model
class ValidationInspector
  def initialize(klass)
    @klass = klass
  end

  def attribute_required?(name)
    attr_needle = [name.to_sym]
    @klass.validators.any? do |validator|
      validator.attributes == attr_needle && validator_required?(validator)
    end
  end

  private def validator_required?(validator)
    case validator.kind
    when :presence
      true
    when :length
      !validator.options[:blank]
    when :format
      validator.options[:with] !~ ""
    end
  end
end
