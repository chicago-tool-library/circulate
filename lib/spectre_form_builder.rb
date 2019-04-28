class SpectreFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options={})
    options[:class] = "form-input"
    sequence_layout(method) do
      super method, options
    end
  end

  def text_area(method, options={})
    options[:class] = "form-input"
    sequence_layout(method) do
      super method, options
    end
  end

  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    html_options[:class] = "form-select"
    sequence_layout(method) do
      super method, collection, value_method, text_method, options, html_options
    end
  end

  def select(method, choices = nil, options = {}, html_options = {}, &block)
    html_options[:class] = "form-select"
    sequence_layout(method) do
      super method, choices, options, html_options, &block
    end
  end

  def file_field(method, *args)
    sequence_layout(method) do
      super method, *args
    end
  end

  def rich_text_area(method, *args)
    sequence_layout(method) do
      super method, *args
    end
  end

  def check_box(method, *args)
    wrapped_layout(method, label_class: "form-checkbox") do
      super(method, *args) +
        @template.tag.i(class:"form-icon")
    end
  end

  def actions(&block)
    @template.content_tag :div, class: "pt-2" do
      yield
    end
  end

  def submit(label=nil, options={})
    super(label, options.merge(class: "btn btn-primary btn-lg"))
  end

  def errors
    if @object.errors.any?
      kind = @object.class.name.downcase
      message = @template.pluralize(@object.errors.count, "error") + " prevented this #{kind} from being saved!"
      @template.tag.div message, class: "toast toast-error mb-2"
    end
  end

  private

  # def merge_options(defaults, new_options)
  #   (defaults.keys + new_options.keys).inject({}) {|h,key|
  #     h[key] = [defaults[key], new_options[key]].compact.join(" ")
  #     h
  #   }
  # end

  def sequence_layout(method, options={})
    label_text = options.fetch(:label) do |key|
      method_string = method.to_s
      if method_string =~ /_ids\z/
        method_string.sub("_ids", "").pluralize.titleize
      else
        method_string.humanize
      end
    end

    messages = @object.errors.include?(method) &&
      @object.errors.messages[method].join(", ")

    hint = messages ? @template.tag.p(messages, class: "form-input-hint") : ""

    @template.content_tag :div, class: "form-group #{'has-error' if messages}" do
      label(method, label_text, {class: "form-label #{options[:label_class]}"}) +
        yield +
        hint
    end
  end
  
  def wrapped_layout(method, options={})
    label_text = options.fetch(:label) do |key|
      method_string = method.to_s
      if method_string =~ /_ids\z/
        method_string.sub("_ids", "").pluralize.titleize
      else
        method_string.humanize
      end
    end

    messages = @object.errors.include?(method) &&
      @object.errors.messages[method].join(", ")

    hint = messages ? @template.tag.p(messages, class: "form-input-hint") : ""

    @template.content_tag :div, class: "form-group #{'has-error' if messages} #{options[:class]}" do
      label(method, class: "form-label #{options[:label_class]}") do
        yield + 
        label_text
      end + 
      hint
    end
  end
end