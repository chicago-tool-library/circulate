# Provides convenience methods for introspecting the validations defined on a model
# ValidationInspector is used by SpectreFormBuilder to determine whether to
# add a "required" tag on a field. This is done by iterating through the validations
# defined on the target class and checking for one that matches a given field name.
class ValidationInspector
  def initialize(klass)
    @klass = klass
  end

  # Note the special handling of names that end with `_id`. This is so that
  # the default validations added by belongs_to associations are handled propberly.
  def attribute_required?(name)
    attr_needle = [name.to_sym]
    attr_sans_id_needle = [name.to_s.sub(/_id$/, "").to_sym]
    @klass.validators.any? do |validator|
      (validator.attributes == attr_needle || validator.attributes == attr_sans_id_needle) &&
        validator_required?(validator)
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
