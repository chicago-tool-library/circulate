class ItemAudit < Audited::Audit
  has_one :maintenance_report, foreign_key: "audit_id"
end
