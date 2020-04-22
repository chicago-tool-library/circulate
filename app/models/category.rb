class Category < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :items, through: :categorizations

  belongs_to :parent, class_name: "Category", required: false
  has_many :children, class_name: "Category", foreign_key: "parent_id"

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :assign_slug

  validate :prevent_circular_reference

  scope :sorted_by_name, -> { order("name ASC") }
  scope :top_level, -> { where(parent_id: nil) }

  def assign_slug
    if slug.blank?
      self.slug = name.parameterize
    end
  end

  def prevent_circular_reference
    category = self
    while (parent = category.parent)
      if parent.id == id
        errors.add(:parent_id, "can't be set to a child")
        break
      end
      category = parent
    end
  end

  def self.entire_tree
    find_by_sql <<-SQL
      WITH RECURSIVE search_tree(id, name, slug, categorizations_count, parent_id, path_names, path_ids) AS (
        SELECT id, name, slug, categorizations_count, parent_id, ARRAY[name], ARRAY[id]
        FROM categories
      WHERE parent_id IS NULL
      UNION ALL
        SELECT categories.id, categories.name, categories.slug, categories.categorizations_count,
               categories.parent_id, path_names || categories.name, path_ids || categories.id
        FROM search_tree
        JOIN categories ON categories.parent_id = search_tree.id
        WHERE NOT categories.id = ANY(path_ids)
      )
      SELECT * FROM search_tree ORDER BY path_names;
    SQL
  end
end
