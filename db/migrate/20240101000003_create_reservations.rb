class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :available_slot, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
