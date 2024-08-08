module Minitest
  # This is based roughly on the way tag filtering is done by Rspec.
  #
  # Tags can be either required or negated.
  #
  # If any tags are required, tests much match at least one of the provided
  # tags. Required tags have no prefix.
  #
  # If any tags are negated, tests matching any negated tag will not run. Tags
  # can be negated with ` tilde (`~`) prefix.
  #
  # Tests tagged with `remote` are negated by default.
  #
  # To clear a tag (make it neither required or negated), a colon (`:`) can
  # be used as a tag prefix.
  class TagFilter
    def initialize
      @required_tags = []
      @negated_tags = []
    end

    def require_tag(name)
      name_symbol = name.to_sym
      @negated_tags.delete_if { |k| k == name_symbol }
      @required_tags << name_symbol
    end

    def negate_tag(name)
      name_symbol = name.to_sym
      @required_tags.delete_if { |k| k == name_symbol }
      @negated_tags << name_symbol
    end

    def clear_tag(name)
      name_symbol = name.to_sym
      @negated_tags.delete_if { |k| k == name_symbol }
      @required_tags.delete_if { |k| k == name_symbol }
    end

    def apply_tag_string(tag_string)
      tag_string.split.each do |tag|
        match, prefix, name = *tag.match(/([~:]?)(\w+)/)

        unless match
          raise "unrecognized tag #{tag}, tags must use only letters, numbers, and underscores"
        end

        if prefix == ""
          require_tag(name)
        elsif prefix == "~"
          negate_tag(name)
        elsif prefix == ":"
          clear_tag(name)
        else
          raise "unrecognized tag #{tag}, only ~ or : are supported as prefixes"
        end
      end
    end

    # Determine if a test with the specified tags run should run
    def allow_tags?(tags)
      tags = tags.map(&:to_sym)

      # If there are additive tags, at least one must match
      unless @required_tags.empty?
        return false if @required_tags.intersection(tags).size == 0
      end

      # If there are negated tags, none can match
      return false if @negated_tags.intersection(tags).size > 0

      true
    end
  end

  def self.allow_tags?(tags)
    @tag_filter.allow_tags?(tags)
  end

  def self.plugin_tags_options(opts, options)
    opts.on "--tag TAG", "Filter tests by tag (use ~ to negate)" do |tags|
      options[:tags] ||= []
      options[:tags] << tags
    end
  end

  def self.plugin_tags_init(options)
    @tag_filter = TagFilter.new.tap do |tag_filter|
      tag_filter.negate_tag :remote # don't run remote test by default
      if options.key?(:tags)
        options[:tags].each do |tags|
          tag_filter.apply_tag_string(tags)
        end
      end
    end
  end
end

module TestCasePatch
  # This method returns the names of method that will be run by the test runner.
  def runnable_methods
    super.select { |name| Minitest.allow_tags?(method_tags[name]) }
  end

  # Store a map of method name -> tag array
  def method_tags
    @method_tags ||= {}
  end

  # Override test definition to allow for extra arguments. These become the tags.
  def test(subject, *tags, &block)
    super(subject, &block).tap do |method|
      method_tags[method.name] = tags
    end
  end
end

ActiveSupport.on_load(:active_support_test_case) { extend TestCasePatch }
