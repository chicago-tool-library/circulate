class Note < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :notable, polymorphic: true

  has_rich_text :body

  validates :body, presence: true

  scope :by_creation_date, -> { order(created_at: :asc) }
  scope :newest_first, -> { order(created_at: :desc) }
  broadcasts_to ->(note) { :admin_item_notes }, target: "admin_item_notes", inserts_by: :prepend
  # after_create_commit { broadcast_append_to('admin_item_notes', target: 'admin_item_notes') }
  # after_create_commit :broadcast_to_item_notes_list
  # after_create_commit { broadcast_prepend_to "admin_item_notes" }


  private

    # def broadcast_to_item_notes_list
    #   broadcast_prepend_to ->(note) {"admin_item_notes"}, target: "admin_item_notes", inserts_by: :append
    # end
end
