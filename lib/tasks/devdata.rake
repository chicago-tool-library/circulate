require "fileutils"

DEVDATA_DIR = File.expand_path("db/devdata", Rails.root)

namespace :devdata do
  def models_file_path(klass)
    "#{DEVDATA_DIR}/#{klass.to_s.underscore.pluralize}.yml"
  end

  def load_models(klass, id_offset: 0)
    YAML.load_file(models_file_path(klass)).each do |attributes|
      attributes.each do |key, value|
        if /ids?$/.match?(key)
          next if key == "library_id"
          attributes[key] = if value.is_a?(Array)
            value.map { |v| v + id_offset }
          else
            value + id_offset
          end
        end
      end
      klass.create!(**attributes)
    end
  end

  def dump_models(klass, models, skip: [], append: [])
    model_attributes = models.map { |model|
      attrs = model.attributes.delete_if { |k, v| v.blank? || skip.include?(k) }
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
    Library.all.each_with_index do |library, index|
      offset = (index + 1) * 10000
      admin = library.users.where(role: "admin").first
      ActsAsTenant.with_tenant(library) do
        Audited.audit_class.as_user(admin) do
          load_models Document, id_offset: offset
          load_models BorrowPolicy, id_offset: offset
          load_models Category, id_offset: offset
          load_models Item, id_offset: offset
        end
      end
    end
  end

  task create_loans_and_holds: :environment do
    postal_codes = ["60609", "80219"]
    ActiveRecord::Base.transaction do
      Library.all.each_with_index do |library, index|
        postal_code = postal_codes[index]
        ActsAsTenant.with_tenant(library) do
          create_member(holds: 2, waiting_holds: 2, loans: 2, postal_code: postal_code)
          create_member(loans: 5, postal_code: postal_code)
          create_member(postal_code: postal_code)
        end
      end
    end
  end

  def create_member(holds: 0, waiting_holds: 0, loans: 0, status: :verified, postal_code: "60609")
    @members ||= 0
    id = @members += 1
    email = "member#{id}@example.com"

    member = Member.create!(
      status: status,
      email: email,
      user: User.create!(email: email, password: "password"),
      phone_number: "3121234567",
      full_name: "Member Number #{id}",
      preferred_name: "Member ##{id}",
      address1: "#{id} W. Chicago Ave",
      postal_code: postal_code
    )

    holds.times do
      item = random_model(Item.active.available)
      Hold.create!(member: member, item: item, creator: member.user)
    end

    # holds where this person is in line behind someone else
    waiting_holds.times do
      item = random_model(Item.active.available)
      member_in_front = random_model(Member)
      Hold.create!(member: member_in_front, item: item, creator: member_in_front.user)
      Hold.create!(member: member, item: item, creator: member.user)
    end

    loans.times do
      item = random_model(Item.active.includes(:borrow_policy).available)
      Loan.create!(item: item, member: member, due_at: 1.week.since, uniquely_numbered: item.borrow_policy.uniquely_numbered)
    end
  end

  def random_model(scope)
    scope.order("RANDOM()").first
  end
end
