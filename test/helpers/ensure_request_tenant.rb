# frozen_string_literal: true

module EnsureRequestTenant
  def self.included(base)
    base.setup do
      ActsAsTenant.test_tenant = libraries(:chicago_tool_library)
      host! ActsAsTenant.test_tenant.hostname
    end

    base.teardown do
      ActsAsTenant.test_tenant = nil
    end
  end
end
