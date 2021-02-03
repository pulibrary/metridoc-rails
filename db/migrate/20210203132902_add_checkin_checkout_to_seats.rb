class AddCheckinCheckoutToSeats < ActiveRecord::Migration[5.2]
  def change
    add_column :circulation_seats_requests, :checked_in, :datetime
    add_column :circulation_seats_requests, :checked_out, :datetime
  end
end
