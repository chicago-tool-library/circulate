Rails.application.config.after_initialize do
  # this is gross, but I was running into issues using a custom Audit class
  class Audited::Audit # standard:disable Lint/ConstantDefinitionInBlock
    has_one :maintenance_report, foreign_key: "audit_id"
  end
end
