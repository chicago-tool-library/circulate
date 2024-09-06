require "fileutils"

DEVDATA_DIR = File.expand_path("db/devdata", Rails.root) unless defined? DEVDATA_DIR

namespace :devdata do
  def models_file_path(klass)
    "#{DEVDATA_DIR}/#{klass.to_s.underscore.pluralize}.yml"
  end

  def load_models(klass, id_offset: 0, creator: nil)
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
      attributes["creator_id"] = creator.id unless creator.nil?
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
    File.write(models_file_path(klass), model_attributes.to_yaml)
  end

  task dump: :environment do
    FileUtils.mkdir_p DEVDATA_DIR
    dump_models Document, Document.all
    dump_models BorrowPolicy, BorrowPolicy.all
    dump_models Category, Category.recursive_all, skip: %w[categorizations_count]
    dump_models Item, Item.order("RANDOM()").limit(200), skip: %w[holds_count], append: %w[category_ids]
  end

  task load: :environment do
    Document.delete_all # There are some documents created in old migrations that we can safely blow away.
    Library.all.each_with_index do |library, index|
      offset = (index + 1) * 10000
      admin = library.users.where(role: "admin").first

      # Attach a fixture image to all items by having them all share a single
      # ActiveStorage::Blob. This means rotating the fixture image in dev will
      # impact every item, but it saves us from duplicating the image hundreds
      # of times.
      image = Rails.root.join("test/fixtures/files/tool-image.jpg").open
      image_blob = ActiveStorage::Blob.create_and_upload!(io: image, filename: "tool-image.jpg")

      # Calling analyze explicitly prevents an AnalyzeJob from kicking off for
      # every image attach below. This is important as it sidesteps this bug:
      # https://github.com/ErwinM/acts_as_tenant/issues/335
      image_blob.analyze

      ActsAsTenant.with_tenant(library) do
        Audited.audit_class.as_user(admin) do
          load_models Document, id_offset: offset
          load_models BorrowPolicy, id_offset: offset
          load_models Category, id_offset: offset
          load_models Item, id_offset: offset
          load_models ActionText::RichText, id_offset: offset
          load_models ItemPool, id_offset: offset, creator: admin
          load_models ReservableItem, id_offset: offset, creator: admin

          Item.find_each do |item|
            item.image.attach(image_blob)
          end
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
          create_member("member_with_holds_and_loans", holds: 2, waiting_holds: 2, loans: 2, city: library.city, postal_code: postal_code)
          create_member("member_with_loans", loans: 5, city: library.city, postal_code: postal_code)
          create_member("member", city: library.city, postal_code: postal_code)
          if library.city == "Chicago"
            # The appointments system isn't fully multitenant yet and some of the views will
            # break if there are appointments for more than the first library.
            create_member("member_with_appointment", appointments: 1, city: library.city, postal_code: postal_code)
          end
        end
      end
    end
  end

  def create_member(username, city:, holds: 0, waiting_holds: 0, loans: 0, appointments: 0, status: :verified, postal_code: "60609")
    email_prefix = (city == "Chicago") ? "" : "#{city.downcase}."
    email = "#{username}@#{email_prefix}example.com"
    full_name = username.titleize
    preferred_name = username.titleize.sub("Member ", "")

    @member_count ||= 100
    number = @member_count += 1

    member = Member.create!(
      status: status,
      email: email,
      user: User.create!(email: email, password: "password", confirmed_at: Time.current, confirmation_sent_at: Time.current),
      phone_number: "5005550006",
      full_name: full_name,
      preferred_name: preferred_name,
      pronouns: ["they/them"],
      address1: "123 W. Chicago Ave",
      postal_code: postal_code,
      address_verified: true,
      number: number,
      reminders_via_email: true,
      reminders_via_text: false
    )

    membership = member.memberships.create!
    membership.start!

    holds.times do
      item = random_model(Item.active.available.without_active_holds)
      Hold.create!(member: member, item: item, creator: member.user)
    end

    appointments.times do
      hold_item = random_model(Item.active.available.without_active_holds)
      hold = Hold.create!(member: member, item: hold_item, creator: member.user)

      loan_item = random_model(Item.active.includes(:borrow_policy).available)
      loan = Loan.create!(item: loan_item, member: member, due_at: 1.week.since, uniquely_numbered: loan_item.borrow_policy.uniquely_numbered)

      next_appointment_slot = Event.appointment_slots.first
      Appointment.create!(
        member: member,
        holds: [hold],
        loans: [loan],
        starts_at: next_appointment_slot.start,
        ends_at: next_appointment_slot.finish
      )
    end

    # holds where this person is in line behind someone else
    waiting_holds.times do
      item = random_model(Item.active.available.without_active_holds)
      member_in_front = random_member
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

  def random_member
    random_model(Member.where.not(email: "member_with_unconfirmed_email@example.com"))
  end
end
