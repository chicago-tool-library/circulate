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
    admin = User.where(email: "admin@example.com").first!
    Audited.audit_class.as_user(admin) do
      load_models Document
      load_models BorrowPolicy
      load_models Category
      load_models Item
    end
  end

  task create_loans_and_holds: :environment do
    ActiveRecord::Base.transaction do
      create_member(holds: 2, waiting_holds: 2, loans: 2)
      create_member(loans: 5)
      create_member
    end
  end

  def create_member(holds: 0, waiting_holds: 0, loans: 0, status: :verified)
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
      postal_code: "60609"
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
