# frozen_string_literal: true

class MigrateManualsToAttachments < ActiveRecord::Migration[6.0]
  class TemporaryItem < ActiveRecord::Base
    self.table_name = "items"
  end

  class TemporaryItemAttachment < ActiveRecord::Base
    self.table_name = "item_attachments"
  end

  class TemporaryAudit < ActiveRecord::Base
    self.table_name = "audits"
  end

  def change
    TemporaryItem.find_each do |item|
      manual = ActiveStorage::Attachment.where(record_id: item.id, record_type: "Item", name: "manual").first
      next unless manual

      user_id = TemporaryAudit.where(auditable_id: item.id, auditable_type: "Item").order("created_at DESC").first.user_id
      attachment = TemporaryItemAttachment.create!(item_id: item.id, kind: "manual", creator_id: user_id)

      manual.update!(record_type: "ItemAttachment", name: "file", record_id: attachment.id)
    end
  end
end
