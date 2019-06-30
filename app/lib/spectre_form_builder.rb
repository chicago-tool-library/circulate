class SpectreFormBuilder < ActionView::Helpers::FormBuilder
  alias parent_text_field text_field
  alias parent_collection_select collection_select

  private def validation_inspector
    @validation_inspector = ValidationInspector.new(@object.class)
  end

  def money_field(method, options = {})
    options[:class] = "form-input"

    options[:value] ||= @template.request.params.dig @object.class.to_s.underscore, method
    sequence_layout(method, options) do
      @template.tag.div class: "input-group" do
        @template.tag.span("$", class: "input-group-addon") +
          parent_text_field(method, options)
      end
    end
  end

  def text_area(method, options = {})
    options[:class] = "form-input"
    sequence_layout(method, options) do
      super method, options
    end
  end

  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    html_options[:class] = "form-select"
    sequence_layout(method, options) do
      super method, collection, value_method, text_method, options, html_options
    end
  end

  def summarized_collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    options.merge!( wrapper_options: { data: {controller: "multi-select"} })
    html_options.merge!( data: {target: "multi-select.control", action: "multi-select#change"}, class: "form-select")

    sequence_layout(method, options) do
      parent_collection_select(method, collection, value_method, text_method, options, html_options) + 
        @template.tag.div(data: { target: "multi-select.summary" }, class: "multi-select-summary")
    end
  end

  def select(method, choices = nil, options = {}, html_options = {}, &block)
    html_options[:class] = "form-select"
    sequence_layout(method, options) do
      super method, choices, options, html_options, &block
    end
  end

  def file_field(method, options = {})
    sequence_layout(method, options) do
      super method, options
    end
  end

  def number_field(method, options = {})
    sequence_layout(method, options) do
      super method, options
    end
  end

  def rich_text_area(method, options = {})
    sequence_layout(method, options) do
      super method, options
    end
  end

  def check_box(method, options = {}, *args)
    options[:label_class] = "form-checkbox"
    wrapped_layout(method, options) do
      super +
        @template.tag.i(class: "form-icon")
    end
  end

  def text_field(method, options = {})
    options[:class] = "form-input"
    sequence_layout(method, options) do
      super method, options
    end
  end

  def autocomplete_text_field(method, options = {})
    text_field(method, options.merge(
      wrapper_options: {
        data: {controller: "autocomplete", action: "input->autocomplete#input", autocomplete_path: options.delete(:path)},
      },
      data: {target: "autocomplete.input"}
    ))
  end

  def actions(&block)
    @template.content_tag :div, class: "form-buttons" do
      yield
    end
  end

  def submit(label = nil, options = {})
    super(label, options.merge(class: "btn btn-primary btn-lg btn-block"))
  end

  def errors
    if @object.errors.any?
      kind = @object.class.name.downcase
      message = @template.pluralize(@object.errors.count, "error") + " prevented this #{kind} from being saved!"
      @template.tag.div message, class: "toast toast-error mb-2"
    end
  end

  private

  # Use this method for inputs where the label has to preceed the input as a sibling
  def sequence_layout(method, options = {})
    label_text = label_or_default(options[:label], method)
    has_error = @object.errors.include?(method)
    messages = has_error ? @object.errors.messages[method].join(", ") : options.delete(:hint)

    hint_content = messages.present? ? @template.tag.div(messages, class: "form-input-hint") : ""

    wrapper_options = options.delete(:wrapper_options) || {}
    wrapper_options[:class] ||= "" << " form-group #{"has-error" if has_error}"
    wrapper_options[:class].strip!

    @template.content_tag :div, wrapper_options do
      label(method, (label_text + required_label(method)).html_safe, {class: "form-label #{options[:label_class]}"}) +
        yield +
        hint_content
    end
  end

  def required_label(method)
    if validation_inspector.attribute_required?(method)
      @template.tag.span("required", class: "label label-required-field").html_safe
    else
      ""
    end
  end

  # Use this method for inputs where the label has to wrap the input
  def wrapped_layout(method, options = {})
    label_text = label_or_default(options[:label], method)
    has_error = @object.errors.include?(method)
    messages = has_error ? @object.errors.messages[method].join(", ") : options.delete(:hint)

    hint_content = messages.present? ? @template.tag.div(messages, class: "form-input-hint") : ""

    wrapper_options = options.delete(:wrapper_options) || {}
    wrapper_options[:class] ||= "" << " form-group #{"has-error" if has_error}"
    wrapper_options[:class].strip!

    @template.content_tag :div, wrapper_options do
      label(method, class: "form-label #{options[:label_class]}") {
        yield +
          label_text +
          required_label(method)
      } +
        hint_content
    end
  end

  def label_or_default(label, method)
    return label if label

    method_string = method.to_s
    if /_ids\z/.match?(method_string)
      method_string.sub("_ids", "").pluralize.titleize
    else
      method_string.humanize
    end
  end
end
