module EnsureRequestTenant
  def self.included(base)
    base.setup do
      ActsAsTenant.test_tenant = Library.first
      host! ActsAsTenant.test_tenant.hostname
    end

    base.teardown do
      ActsAsTenant.test_tenant.destroy
      ActsAsTenant.test_tenant = nil
    end
  end
end
