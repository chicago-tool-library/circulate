class ReservationDateValidator
  attr_accessor :reservation, :default_reservation_policy, :now

  class Errors
    attr_writer :impossible

    def maximum_duration
      @maximum_duration ||= []
    end

    def minimum_start_distance
      @minimum_start_distance ||= []
    end

    def maximum_start_distance
      @maximum_start_distance ||= []
    end

    def impossible
      @impossible ||= []
    end

    def empty?
      [maximum_duration, minimum_start_distance, maximum_start_distance, impossible].all?(&:empty?)
    end
  end

  def initialize(reservation:, default_reservation_policy: ReservationPolicy.default_policy, now: Time.current)
    self.reservation = reservation
    self.default_reservation_policy = default_reservation_policy
    self.now = now
  end

  def reservation_policies
    (reservation.reservation_policies.presence || [default_reservation_policy]).to_a
  end

  def errors
    errors = Errors.new

    reservation_policies.each do |reservation_policy|
      if violates_duration?(reservation_policy)
        errors.maximum_duration << reservation_policy
      end

      if violates_minimum_start_distance?(reservation_policy)
        errors.minimum_start_distance << reservation_policy
      end

      if violates_maximum_start_distance?(reservation_policy)
        errors.maximum_start_distance << reservation_policy
      end
    end

    errors.impossible = incompatible_combinations

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
end
