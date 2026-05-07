class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :available_slot

  validates :available_slot_id, uniqueness: true
  validate :slot_must_not_be_past
  validate :user_must_not_be_fp

  def fp
    available_slot.fp
  end

  private

  def slot_must_not_be_past
    return unless available_slot
    if available_slot.slot_date < Date.current
      errors.add(:base, "過去の枠は予約できません")
    end
  end

  def user_must_not_be_fp
    errors.add(:user, "FPは予約できません") if user&.fp?
  end
end
