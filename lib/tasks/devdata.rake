require "fileutils"

namespace :devdata do
  DEVDATA_DIR = File.expand_path("db/devdata", Rails.root)

  def models_file_path(klass)
    "#{DEVDATA_DIR}/#{klass.to_s.underscore.pluralize}.yml"
  end

  def load_models(klass)
    YAML.load_file(models_file_path(klass)).each do |attributes|
      klass.create!(**attributes)
    end
  end

  def dump_models(klass, models, skip: [], append: [])
    model_attributes = models.map { |model|
      attrs = model.attributes.delete_if { |k, v| v.blank? || skip.include?(k)}
      attrs["created_at"] = attrs["created_at"].to_s
      attrs["updated_at"] = attrs["updated_at"].to_s
      append.each do |attr|
        attrs[attr] = model.send attr
      end
      attrs
    }
    File.open(models_file_path(klass), "w") do |f|
      f.write model_attributes.to_yaml
    end
  end

  task dump: :environment do
    FileUtils.mkdir_p DEVDATA_DIR
    dump_models Document, Document.all
    dump_models BorrowPolicy, BorrowPolicy.all
    dump_models Category, Category.recursive_all, skip: %w[categorizations_count]
    dump_models Item, Item.order("RANDOM()").limit(200), skip: %w[holds_count], append: %w[category_ids]
  end

  task load: :environment do
    admin = User.where(email: "admin@example.com").first!
    Audited.audit_class.as_user(admin) do
      load_models Document
      load_models BorrowPolicy
      load_models Category
      load_models Item
    end
  end
end
