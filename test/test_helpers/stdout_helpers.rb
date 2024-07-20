# Taken from https://gist.github.com/searls/9caa12f66c45a72e379e7bfe4c48405b
# Referenced in https://justin.searls.co/posts/running-rails-system-tests-with-playwright-instead-of-selenium/
#
# This is a stupid utility to squelch stdout output via puts (could do the same
#   for warn; could also override stdout entirely)
#
# Usage in a test, after requiring and including it:
#
#   setup do
#     suppress_puts([
#       /Execution context was destroyed, most likely because of a navigation/
#     ])
#   end
#
#   teardown do
#     restore_puts
#   end
#
module StdoutHelpers
  def suppress_puts(only_these_patterns)
    @__og_puts = og_puts = Kernel.method(:puts)
    Kernel.define_method(:puts) do |*args|
      if only_these_patterns.nil?
        nil
      elsif only_these_patterns.none? { |pattern| args.first.to_s =~ pattern }
        og_puts.call(*args)
      end
    end
  end

  def restore_puts
    Kernel.define_singleton_method(:puts, @__og_puts)
  end
end
