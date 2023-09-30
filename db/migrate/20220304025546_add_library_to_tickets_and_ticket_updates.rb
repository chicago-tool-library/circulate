# frozen_string_literal: true

class AddLibraryToTicketsAndTicketUpdates < ActiveRecord::Migration[6.1]
  def change
    add_reference :tickets, :library
    add_reference :ticket_updates, :library
  end
end
