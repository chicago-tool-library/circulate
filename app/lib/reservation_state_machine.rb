require "finite_machine"

ReservationStateMachine = FiniteMachine.define do
  initial :pending

  terminal :cancelled, :rejected, :returned

  event :request, from: :pending, to: :requested
  event :approve, from: :requested, to: :approved
  event :reject, from: :requested, to: :rejected
  event :replace, from: [:requested, :approved, :rejected], to: :obsolete

  event :build, from: :approved, to: :building
  event :ready, from: :building, to: :ready

  event :borrow, from: :ready, to: :borrowed
  event :return, from: :borrowed, to: :returned
  event :unresolve, from: [:borrowed, :returned], to: :unresolved
  event :resolve, from: :unresolved, to: :returned

  event :cancel, from: any_state, to: :cancelled

  on_enter do |event|
    target.status = event.to
  end
end
