# ユーザーと予約枠を結びつける中間テーブル
# available_slot_id にユニーク制約を設けることで 1 枠 = 1 予約を DB レベルで保証する
class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.references :user,           null: false, foreign_key: true
      # index: { unique: true } で available_slot_id の一意性を保証する
      t.references :available_slot, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
