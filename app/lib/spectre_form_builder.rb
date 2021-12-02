class SpectreFormBuilder < ActionView::Helpers::FormBuilder
  include ERB::Util

  alias_method :parent_text_field, :text_field
  alias_method :parent_collection_select, :collection_select
  alias_method :parent_button, :button

  private def validation_inspector
    @validation_inspector = ValidationInspector.new(@object.class)
  end

  def money_field(method, options = {})
    options[:class] = "form-input"

    value_from_params = @template.request.params.dig @object.class.to_s.underscore, method
    options[:value] = value_from_params || object.send(method)
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

  def tag_select(method, tags)
    namer = ->(c) { c.path_names.map { |n| h(n) }.join(" &rBarr; ").html_safe }
    @template.tag.div(data: {controller: "tag-editor"}) do
      sequence_layout(method, options) do
        parent_collection_select method, tags, :id, namer, {}, data: {target: "tag-editor.input"}, multiple: true
      end
    end
  end

  def summarized_collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    options[:wrapper_options] = {data: {controller: "multi-select"}}
    html_options[:data] = {target: "multi-select.control", action: "multi-select#change"}
    html_options[:class] = "form-sele5"

    sequence_layout(method, options) do
      parent_collection_select(method, collection, value_method, text_method, options, html_options) +
        @template.tag.div(data: {target: "multi-select.summary"}, class: "multi-select-summary")
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
      attachment = @object.send(method)
      if attachment.attached?
        super(method, options) +
          @template.tag.span {
            ("Currently " +
              @template.link_to(attachment.filename, @template.url_for(attachment))).html_safe
          }
      else
        super method, options
      end
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

  def radio_button(method, tag_value, options = {})
    options[:label_class] = "form-radio"
    options[:label_for] = nil
    wrapped_layout(method, options) do
      super +
        @template.tag.i(class: "form-icon")
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

  def password_field(method, options = {})
    options[:class] = "form-input"
    sequence_layout(method, options) do
      super method, options
    end
  end

  def autocomplete_text_field(method, options = {})
    text_field(method, options.merge(
      wrapper_options: {
        data: {controller: "autocomplete", action: "input->autocomplete#input", autocomplete_path: options.delete(:path)}
      },
      data: {target: "autocomplete.input"}
    ))
  end

  def date_field(method, options = {})
    options[:class] = "form-input"
    sequence_layout(method, options) do
      super method, options
    end
  end

  def actions(&block)
    @template.content_tag :div, class: "form-buttons" do
      yield
    end
  end

  def button(label = nil, options = {})
    super(label, options.merge(class: "btn btn-lg btn-block"))
  end

  def submit(label = nil, options = {}, &block)
    parent_button(label, options.deep_merge(type: "submit", class: "btn btn-primary btn-lg btn-block", data: {disable: true}), &block)
  end

  def errors
    if @object.errors.any?
      @template.tag.div "Please correct the errors below!", class: "toast toast-error mb-2"
    end
  end

  private

  # Use this method for inputs where the label has to preceed the input as a sibling
  def sequence_layout(method, options = {})
    label_text = label_or_default(options[:label], method)
    has_error = @object.errors.include?(method)
    display_required = options.delete(:required)
    messages = has_error ? @object.errors.messages[method].join(", ") : options.delete(:hint)

    hint_content = messages.present? ? @template.tag.div(messages, class: "form-input-hint") : ""

    wrapper_options = options.delete(:wrapper_options) || {}
    wrapper_options[:class] ||= "" << " form-group #{"has-error" if has_error}"
    wrapper_options[:class].strip!

    content_label = options[:label] == false ? "" : label(method, (h(label_text).html_safe + required_label(method, display_required)), {class: "form-label #{options[:label_class]}"})

    @template.content_tag :div, wrapper_options do
      content_label.html_safe +
        yield +
        hint_content
    end
  end

  def required_label(method, show_label)
    if validation_inspector.attribute_required?(method) && show_label.nil?
      @template.tag.span("required", class: "label label-warning label-required-field").html_safe
    elsif show_label
      @template.tag.span("required", class: "label label-warning label-required-field").html_safe
    else
      ""
    end
  end

  # Use this method for inputs where the label has to wrap the input
  def wrapped_layout(method, options = {})
    label_text = label_or_default(options.delete(:label), method)
    has_error = @object.errors.include?(method)
    display_required = options.fetch(:required, true)
    messages = has_error ? @object.errors.messages[method].join(", ") : options.delete(:hint)

    hint_content = messages.present? ? @template.tag.div(messages, class: "form-input-hint") : ""

    wrapper_options = options.delete(:wrapper_options) || {}
    wrapper_options[:class] ||= "" << " form-group #{"has-error" if has_error}"
    wrapper_options[:class].strip!

    @template.content_tag :div, wrapper_options do
      label_options = {class: "form-label #{options.delete(:label_class)}"}
      label_options[:for] = options.delete(:label_for) if options.key?(:label_for)
      label(method, **label_options) {
        yield +
          label_text +
          required_label(method, display_required)
      } +
        hint_content
    end
  end

  def label_or_default(label, method)
    return label if label

    method_string = method.to_s
    if method_string.ends_with?("_ids")
      method_string.sub("_ids", "").pluralize.titleize
    else
      method_string.humanize
    end
  end
end
