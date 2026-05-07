# FP が公開した予約枠を管理するテーブル
# 枠の存在 = FP が受付中、reservation が紐づく = 予約済み、という設計
class CreateAvailableSlots < ActiveRecord::Migration[8.1]
  def change
    create_table :available_slots do |t|
      # fp_id は users テーブルの FP レコードを参照する外部キー
      t.references :fp, null: false, foreign_key: { to_table: :users }
      t.date :slot_date,  null: false
      t.time :start_time, null: false
      t.time :end_time,   null: false

      t.timestamps
    end

    # 同一 FP・同一日・同一開始時刻の重複登録を DB レベルで防ぐ
    add_index :available_slots, [:fp_id, :slot_date, :start_time], unique: true
  end
end
