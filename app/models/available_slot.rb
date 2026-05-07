# FP が「受け付ける」と宣言した予約枠を表すモデル
# この枠に reservation が紐づいていない = 空き、紐づいている = 予約済み
class AvailableSlot < ApplicationRecord
  # fp_id カラムを持つが、参照先は users テーブルなので class_name を指定
  belongs_to :fp, class_name: "User"
  has_one :reservation, dependent: :destroy

  validates :slot_date, presence: true
  validates :start_time, presence: true
  validates :end_time,   presence: true
  # 同一 FP・同一日・同一開始時刻の重複登録を防ぐ
  validates :start_time, uniqueness: { scope: [:fp_id, :slot_date] }

  validate :date_must_not_be_sunday
  validate :date_must_not_be_past

  # reservation が存在しない枠のみを返す（where.missing は LEFT OUTER JOIN で NOT EXISTS と等価）
  scope :available, -> { where.missing(:reservation) }
  scope :booked,    -> { joins(:reservation) }
  scope :upcoming,  -> { where("slot_date >= ?", Date.current).order(:slot_date, :start_time) }

  def booked?
    reservation.present?
  end

  # ビュー表示用のフォーマット済み時刻文字列
  def start_time_str  = start_time.strftime("%H:%M")
  def end_time_str    = end_time.strftime("%H:%M")
  def time_range_str  = "#{start_time_str} - #{end_time_str}"

  private

  def date_must_not_be_sunday
    errors.add(:slot_date, "は日曜日に設定できません") if slot_date&.wday == 0
  end

  def date_must_not_be_past
    errors.add(:slot_date, "は過去の日付に設定できません") if slot_date && slot_date < Date.current
  end
end
