class CreateAvailableSlots < ActiveRecord::Migration[8.1]
  def change
    create_table :available_slots do |t|
      t.references :fp, null: false, foreign_key: { to_table: :users }
      t.date :slot_date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false

      t.timestamps
    end

    add_index :available_slots, [:fp_id, :slot_date, :start_time], unique: true
  end
end
