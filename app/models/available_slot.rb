class AvailableSlot < ApplicationRecord
  belongs_to :fp, class_name: "User"
  has_one :reservation, dependent: :destroy

  validates :slot_date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :start_time, uniqueness: { scope: [:fp_id, :slot_date] }

  validate :date_must_not_be_sunday
  validate :date_must_not_be_past

  scope :available, -> { where.missing(:reservation) }
  scope :booked, -> { joins(:reservation) }
  scope :upcoming, -> { where("slot_date >= ?", Date.current).order(:slot_date, :start_time) }

  def booked?
    reservation.present?
  end

  def start_time_str
    start_time.strftime("%H:%M")
  end

  def end_time_str
    end_time.strftime("%H:%M")
  end

  def time_range_str
    "#{start_time_str} - #{end_time_str}"
  end

  private

  def date_must_not_be_sunday
    errors.add(:slot_date, "は日曜日に設定できません") if slot_date&.wday == 0
  end

  def date_must_not_be_past
    errors.add(:slot_date, "は過去の日付に設定できません") if slot_date && slot_date < Date.current
  end
end
