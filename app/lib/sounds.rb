module Sounds
  extend self

  ALL = [
    SUCCESS = "success",
    NEUTRAL = "neutral",
    FAILURE = "failure",
    REMOVED = "removed"
  ]

  ALL.each do |sound|
    define_method(:"#{sound}_sound_path") do
      "/sounds/#{sound}.wav"
    end
  end

  def all_sound_paths
    ALL.map { |sound| "/sounds/#{sound}.wav" }
  end
end
