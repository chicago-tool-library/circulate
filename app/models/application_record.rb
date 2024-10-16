class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.find_random
    order("RANDOM()").first
  end
end
