class ActsAsTaggableOnMigration < ActiveRecord::Migration[7.2]
  def change
    create_table "taggings", force: :cascade do |t|
      t.bigint "tag_id"
      t.string "taggable_type"
      t.bigint "taggable_id"
      t.string "tagger_type"
      t.bigint "tagger_id"
      t.string "context", limit: 128
      t.datetime "created_at", precision: nil
      t.string "tenant", limit: 128
      t.index ["context"], name: "index_taggings_on_context"
      t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
      t.index ["tag_id"], name: "index_taggings_on_tag_id"
      t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
      t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
      t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
      t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
      t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
      t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
      t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
      t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
      t.index ["tenant"], name: "index_taggings_on_tenant"
    end

    create_table "tags", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "taggings_count", default: 0
      t.index ["name"], name: "index_tags_on_name", unique: true
    end

    add_foreign_key "taggings", "tags"
  end
end
