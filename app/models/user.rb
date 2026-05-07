class User < ApplicationRecord
  ROLES = %w[user fp].freeze

  WEEKDAY_SLOTS = (0...16).map { |i| [10 * 60 + i * 30, 10 * 60 + i * 30 + 30] }.freeze
  SATURDAY_SLOTS = (0...8).map { |i| [11 * 60 + i * 30, 11 * 60 + i * 30 + 30] }.freeze

  has_many :available_slots, foreign_key: :fp_id, dependent: :destroy
  has_many :reservations, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: ROLES }

  scope :fps, -> { where(role: "fp") }
  scope :regular_users, -> { where(role: "user") }

  def fp?
    role == "fp"
  end

  def self.slot_times_for_date(date)
    day = date.wday
    return [] if day == 0

    slot_minutes = day == 6 ? SATURDAY_SLOTS : WEEKDAY_SLOTS
    slot_minutes.map do |start_min, end_min|
      {
        start_time: format("%02d:%02d", start_min / 60, start_min % 60),
        end_time: format("%02d:%02d", end_min / 60, end_min % 60)
      }
    end
  end
end
