# ユーザーと予約枠を紐づける予約モデル
# available_slot_id にユニーク制約があるため、1 枠に対して予約は 1 件のみ
class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :available_slot

  # DB のユニーク制約と合わせてアプリ側でも重複を防ぐ
  validates :available_slot_id, uniqueness: true
  validate :slot_must_not_be_past
  validate :user_must_not_be_fp

  # 予約から担当 FP を取得するショートカット
  def fp
    available_slot.fp
  end

  private

  def slot_must_not_be_past
    return unless available_slot
    errors.add(:base, "過去の枠は予約できません") if available_slot.slot_date < Date.current
  end

  # FP 自身が予約することを禁止する
  def user_must_not_be_fp
    errors.add(:user, "FPは予約できません") if user&.fp?
  end
end
