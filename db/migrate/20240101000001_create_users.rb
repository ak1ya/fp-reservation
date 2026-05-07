# ユーザー・FP を一元管理するテーブル
# role カラムで "user"（相談者）と "fp"（FP）を区別する
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name,  null: false
      t.string :email, null: false
      t.string :role,  null: false, default: "user"

      t.timestamps
    end

    # メールアドレスの重複登録を防ぐ
    add_index :users, :email, unique: true
    # ロール別の絞り込みを高速化する
    add_index :users, :role
  end
end
