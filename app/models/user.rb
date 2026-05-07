# ユーザー・FP 共通モデル
# role カラムで "user"（相談者）と "fp"（ファイナンシャルプランナー）を区別する
class User < ApplicationRecord
  ROLES = %w[user fp].freeze

  # 平日スロット: 10:00〜18:00 を 30 分刻みで 16 枠（分単位で保持）
  WEEKDAY_SLOTS = (0...16).map { |i| [10 * 60 + i * 30, 10 * 60 + i * 30 + 30] }.freeze
  # 土曜スロット: 11:00〜15:00 を 30 分刻みで 8 枠
  SATURDAY_SLOTS = (0...8).map { |i| [11 * 60 + i * 30, 11 * 60 + i * 30 + 30] }.freeze

  # FP として持つ予約枠（foreign_key が fp_id のため明示指定）
  has_many :available_slots, foreign_key: :fp_id, dependent: :destroy
  # ユーザーとして行った予約
  has_many :reservations, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: ROLES }

  # FP のみ・一般ユーザーのみを取得するスコープ
  scope :fps, -> { where(role: "fp") }
  scope :regular_users, -> { where(role: "user") }

  def fp?
    role == "fp"
  end

  # 指定日に設定可能なスロット一覧を返す（日曜は空配列）
  # 戻り値: [{ start_time: "10:00", end_time: "10:30" }, ...]
  def self.slot_times_for_date(date)
    day = date.wday  # 0=日, 1=月, ..., 6=土
    return [] if day == 0  # 日曜は休業

    slot_minutes = day == 6 ? SATURDAY_SLOTS : WEEKDAY_SLOTS
    slot_minutes.map do |start_min, end_min|
      {
        start_time: format("%02d:%02d", start_min / 60, start_min % 60),
        end_time:   format("%02d:%02d", end_min / 60,   end_min % 60)
      }
    end
  end
end
