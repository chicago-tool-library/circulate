class Category < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :items, through: :categorizations

  belongs_to :parent, class_name: "Category", required: false
  has_many :children, class_name: "Category", foreign_key: "parent_id"

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :assign_slug

  scope :sorted_by_name, -> { order("name ASC") }
  scope :top_level, -> { where(parent_id: nil) }

  def assign_slug
    if slug.blank?
      self.slug = name.parameterize
    end
  end

  def descendents
    self_and_descendents - [self]
  end

  def self_and_descendents
    self.class.tree_for(self)
  end

  def self.tree_for(instance)
    where("#{table_name}.id IN (#{tree_sql_for(instance)})").order("#{table_name}.id")
  end

  def self.tree_sql_for(instance)
    <<-SQL
      WITH RECURSIVE search_tree(id, path) AS (
          SELECT id, ARRAY[id]
          FROM #{table_name}
          WHERE id = #{instance.id}
        UNION ALL
          SELECT #{table_name}.id, path || #{table_name}.id
          FROM search_tree
          JOIN #{table_name} ON #{table_name}.parent_id = search_tree.id
          WHERE NOT #{table_name}.id = ANY(path)
      )
      SELECT id FROM search_tree ORDER BY path
    SQL
  end
end
