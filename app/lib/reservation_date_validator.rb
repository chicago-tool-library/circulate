class ReservationDateValidator
  attr_accessor :reservation, :default_reservation_policy, :now

  def initialize(reservation:, default_reservation_policy: ReservationPolicy.default_policy, now: Time.current)
    self.reservation = reservation
    self.default_reservation_policy = default_reservation_policy
    self.now = now
  end

  def reservation_policies
    (reservation.reservation_policies.presence || [default_reservation_policy]).to_a
  end

  def errors
    errors = Hash.new { |hash, key| hash[key] = [] }

    reservation_policies.each do |reservation_policy|
      if violates_duration?(reservation_policy)
        errors[:duration] << duration_error_message(reservation_policy)
      end

      if violates_minimum_start_distance?(reservation_policy)
        errors[:minimum_start_distance] << minimum_start_distance_error_message(reservation_policy)
      end

      if violates_maximum_start_distance?(reservation_policy)
        errors[:maximum_start_distance] << maximum_start_distance_error_message(reservation_policy)
      end
    end

    incompatible_combinations.each do |(policy_a, policy_b)|
      errors[:impossible] << impossible_error_message(policy_a, policy_b)
    end

    errors
  end

  private

  def violates_duration?(reservation_policy)
    duration = (reservation.ended_at.to_date - reservation.started_at.to_date).to_i
    duration > reservation_policy.maximum_duration
  end

  def violates_minimum_start_distance?(reservation_policy)
    (now + reservation_policy.minimum_start_distance.days).beginning_of_day > reservation.started_at
  end

  def violates_maximum_start_distance?(reservation_policy)
    (now + reservation_policy.maximum_start_distance.days).end_of_day < reservation.started_at
  end

  def incompatible_combinations
    return [] if reservation_policies.size < 2

    reservation_policies.combination(2).filter { |policies| incompatible_combination?(policies) }
  end

  def incompatible_combination?(policies)
    minimum = policies.map(&:minimum_start_distance).max
    maximum = policies.map(&:maximum_start_distance).min

    minimum > maximum
  end

  def duration_error_message(reservation_policy)
    "duration is longer than allowed by #{reservation_policy.name} (#{reservation_policy.maximum_duration} days)"
  end

  def minimum_start_distance_error_message(reservation_policy)
    "starts sooner than allowed by #{reservation_policy.name} (#{reservation_policy.minimum_start_distance} days)"
  end

  def maximum_start_distance_error_message(reservation_policy)
    "starts later than allowed by #{reservation_policy.name} (#{reservation_policy.maximum_start_distance} days)"
  end

  def impossible_error_message(policy_a, policy_b)
    "impossible to find valid reservation dates (#{policy_a.name} and #{policy_b.name} are mutually exclusive)"
  end
end
