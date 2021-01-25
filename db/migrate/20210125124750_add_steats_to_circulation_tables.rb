class AddSteatsToCirculationTables < ActiveRecord::Migration[5.2]
  def change
    create_table :circulation_seats_requests do |t|
      t.integer :space_id
      t.string :name
      t.string :location
      t.string :zone
      t.datetime :from
      t.datetime :to
      t.datetime :created
      t.string :status
    end
  end
end
