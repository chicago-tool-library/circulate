# frozen_string_literal: true

require "uri"

class ShortLink < ApplicationRecord
  SLUG_LENGTH = 6
  MAX_ITERATIONS = 10
  VALID_CHARS = ["a".."z", "A".."Z", "0".."9"].inject([]) { |a, r| a.concat(r.to_a) }

  validates :slug, presence: true, uniqueness: { scope: :library_id }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL" }, uniqueness: { scope: :library_id }

  before_validation :generate_slug

  acts_as_tenant :library

  def views
    views_count
  end

  def self.for_url(url)
    link = find_or_initialize_by(url:)
    link.save!
    link
  end

  def record_view
    increment(:views_count)
    save!
  end

  private
    def generate_slug
      self.slug = find_random_unique_slug
    end

    def find_random_unique_slug
      slug = nil
      MAX_ITERATIONS.times do |n|
        slug = random_slug(SLUG_LENGTH)
        break if unique_slug?(slug)
        raise "could not find a unique slug" if n == (MAX_ITERATIONS - 1)
      end
      slug
    end

    def unique_slug?(slug)
      self.class.where(slug:).count == 0
    end

    def random_slug(length)
      chars = VALID_CHARS
      length.times.inject("") { |s| s << chars[rand(chars.size)] }
    end
end
