class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.find_random
    order("RANDOM()").first
  end

  def to_save_result
    if save
      Result.success(self)
    else
      Result.failure(self)
    end
  end
end
